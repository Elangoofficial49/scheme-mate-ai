import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../services/document_scan_service.dart';
import '../services/web_camera_capture_stub.dart'
    if (dart.library.js_interop) '../services/web_camera_capture_web.dart'
    as web_camera;

class CameraCaptureScreen extends StatefulWidget {
  const CameraCaptureScreen({super.key});

  @override
  State<CameraCaptureScreen> createState() => _CameraCaptureScreenState();
}

class _CameraCaptureScreenState extends State<CameraCaptureScreen> {
  CameraController? _controller;
  bool _isInitializing = true;
  bool _isTakingPicture = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        throw CameraException(
            'NoCamera', 'No camera was found on this device.');
      }

      final camera = cameras.firstWhere(
        (description) => description.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      final controller = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
      );
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() {
        _controller = controller;
        _isInitializing = false;
      });
    } on CameraException catch (error) {
      _showCameraError(error.description ?? error.code);
    } catch (error) {
      _showCameraError(error.toString());
    }
  }

  void _showCameraError(String details) {
    if (!mounted) return;
    setState(() {
      _isInitializing = false;
      _errorMessage =
          "Camera could not be opened. Allow camera access in your browser or device settings, then try again. On web, open this app over HTTPS or localhost.\n\n$details";
    });
  }

  Future<void> _takePicture() async {
    final controller = _controller;
    if (controller == null ||
        !controller.value.isInitialized ||
        _isTakingPicture) {
      return;
    }

    setState(() => _isTakingPicture = true);
    try {
      final DocumentScanImage scanImage;
      if (kIsWeb) {
        final bytes = await web_camera.captureCameraFrame(controller.cameraId);
        if (bytes == null || bytes.isEmpty) {
          throw StateError(
            "The browser camera frame could not be read. Please allow camera access and try again.",
          );
        }
        scanImage = DocumentScanImage(
          path: "",
          name: "camera_capture.jpg",
          webBytes: bytes,
        );
      } else {
        final image = await controller.takePicture();
        scanImage = await DocumentScanImage.fromXFile(image);
      }
      if (mounted) Navigator.pop(context, scanImage);
    } on CameraException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.description ?? "Could not capture the image."),
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Could not prepare the captured image: $error")),
        );
      }
    } finally {
      if (mounted) setState(() => _isTakingPicture = false);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    return Scaffold(
      appBar: AppBar(title: const Text("Capture document")),
      body: Center(
        child: _isInitializing
            ? const CircularProgressIndicator()
            : _errorMessage != null
                ? Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.no_photography_outlined,
                            size: 48, color: Colors.redAccent),
                        const SizedBox(height: 16),
                        Text(_errorMessage!, textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.photo_library_outlined),
                          label: const Text("Choose an existing photo"),
                        ),
                      ],
                    ),
                  )
                : Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(12),
                        child: Text(
                          "Place the full document inside the frame and keep it steady.",
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        child: controller != null
                            ? Center(
                                child: AspectRatio(
                                  aspectRatio: controller.value.aspectRatio,
                                  child: CameraPreview(controller),
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: FloatingActionButton.large(
                          onPressed: _isTakingPicture ? null : _takePicture,
                          tooltip: "Take document photo",
                          child: _isTakingPicture
                              ? const CircularProgressIndicator()
                              : const Icon(Icons.camera_alt),
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}
