import 'package:flutter/foundation.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

import '../core/network/api_client.dart';

class DocumentScanResult {
  const DocumentScanResult({
    required this.identifier,
    required this.source,
    required this.recognizedText,
  });

  final String? identifier;
  final String source;
  final String recognizedText;
}

class DocumentScanImage {
  const DocumentScanImage({
    required this.path,
    required this.name,
    this.webBytes,
  });

  final String path;
  final String name;
  final Uint8List? webBytes;

  static Future<DocumentScanImage> fromXFile(XFile file) async {
    return DocumentScanImage(
      path: file.path,
      name: file.name,
      webBytes: kIsWeb ? await file.readAsBytes() : null,
    );
  }
}

class DocumentScanService {
  static bool get supportsCamera =>
      kIsWeb ||
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;

  static Future<DocumentScanResult> scanImage(
      DocumentScanImage image, String documentType) async {
    if (kIsWeb) {
      final bytes = image.webBytes;
      if (bytes == null || bytes.isEmpty) {
        throw StateError(
            "The selected image could not be loaded. Please retake it or choose another image.");
      }
      final response =
          await ApiClient.uploadDocument(bytes, image.name, documentType);
      if (response["success"] != true || response["data"] is! Map) {
        final errorMessage = response["error"] is Map
            ? response["error"]["message"]?.toString()
            : null;
        throw StateError(errorMessage ?? "The document could not be scanned.");
      }

      final data = response["data"] as Map;
      final ocrResult = data["ocr_result"];
      final fields = ocrResult is Map ? ocrResult["extracted_fields"] : null;
      final extractedFields =
          fields is Map ? fields : const <String, dynamic>{};
      final identifier = extractedFields["extracted_number"] ??
          extractedFields["pan_number"] ??
          extractedFields["udyam_number"] ??
          extractedFields["certificate_number"];
      return DocumentScanResult(
        identifier: identifier?.toString(),
        source: "server QR/text recognition (web)",
        recognizedText: "",
      );
    }

    if (!supportsCamera) {
      throw UnsupportedError(
          "Camera scanning is not supported on this device.");
    }

    final inputImage = InputImage.fromFilePath(image.path);
    final barcodeScanner =
        BarcodeScanner(formats: const [BarcodeFormat.qrCode]);
    String? qrPayload;
    try {
      final barcodes = await barcodeScanner.processImage(inputImage);
      for (final barcode in barcodes) {
        final value = barcode.rawValue;
        if (value != null && value.trim().isNotEmpty) {
          qrPayload = value;
          final identifier = extractIdentifier(value, documentType);
          if (identifier != null) {
            return DocumentScanResult(
              identifier: identifier,
              source: "QR code",
              recognizedText: value,
            );
          }
        }
      }
    } finally {
      await barcodeScanner.close();
    }

    final textRecognizer = TextRecognizer();
    try {
      final recognized = await textRecognizer.processImage(inputImage);
      final text = recognized.text;
      return DocumentScanResult(
        identifier: extractIdentifier(text, documentType) ??
            (qrPayload == null
                ? null
                : extractIdentifier(qrPayload, documentType)),
        source: "on-device text recognition",
        recognizedText: text,
      );
    } finally {
      await textRecognizer.close();
    }
  }

  static String? extractIdentifier(String text, String documentType) {
    final type = documentType.toLowerCase();
    final String pattern;
    if (type.contains("aadhaar") || type.contains("identity")) {
      pattern = r'(?<!\d)(?:\d[\s-]?){11}\d(?!\d)';
      final match = RegExp(pattern).firstMatch(text);
      final digits = match?.group(0)?.replaceAll(RegExp(r'\D'), '');
      return digits?.length == 12 ? digits : null;
    }
    if (type.contains("pan")) {
      return RegExp(r'\b[A-Z]{5}\d{4}[A-Z]\b', caseSensitive: false)
          .firstMatch(text)
          ?.group(0)
          ?.toUpperCase();
    }
    if (type.contains("udyam")) {
      return RegExp(r'\bUDYAM-[A-Z]{2}-\d{2}-\d{7}\b', caseSensitive: false)
          .firstMatch(text)
          ?.group(0)
          ?.toUpperCase();
    }
    if (type.contains("income")) {
      return RegExp(r'\b[A-Z]{2,4}/\d{4}/\d{3,6}\b', caseSensitive: false)
          .firstMatch(text)
          ?.group(0)
          ?.toUpperCase();
    }
    return RegExp(
      r'\b(?:CERT|COMM|REG)[-/A-Z0-9]{4,25}\b',
      caseSensitive: false,
    ).firstMatch(text)?.group(0);
  }
}
