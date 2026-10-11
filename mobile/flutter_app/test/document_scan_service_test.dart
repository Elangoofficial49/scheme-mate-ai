import 'package:flutter_test/flutter_test.dart';
import 'package:scheme_mate_ai/services/document_scan_service.dart';

void main() {
  group('DocumentScanService.extractIdentifier', () {
    test('extracts and normalizes a 12-digit Aadhaar number', () {
      expect(
        DocumentScanService.extractIdentifier(
            'Aadhaar number: 1234 5678 9012', 'Aadhaar'),
        '123456789012',
      );
    });

    test('does not accept an Aadhaar number embedded in a longer number', () {
      expect(
        DocumentScanService.extractIdentifier('91234567890123', 'Aadhaar'),
        isNull,
      );
    });

    test('extracts PAN identifiers without case differences', () {
      expect(
        DocumentScanService.extractIdentifier('ABCDE1234F', 'PAN'),
        'ABCDE1234F',
      );
    });

    test('extracts Udyam identifiers', () {
      expect(
        DocumentScanService.extractIdentifier('UDYAM-TN-03-0012345', 'Udyam'),
        'UDYAM-TN-03-0012345',
      );
    });

    test('extracts income certificate numbers', () {
      expect(
        DocumentScanService.extractIdentifier(
            'Certificate No: INC/2026/98231', 'Income'),
        'INC/2026/98231',
      );
    });

    test('returns null when no matching identifier exists', () {
      expect(
        DocumentScanService.extractIdentifier(
            'The document is clear and readable.', 'PAN'),
        isNull,
      );
    });
  });
}
