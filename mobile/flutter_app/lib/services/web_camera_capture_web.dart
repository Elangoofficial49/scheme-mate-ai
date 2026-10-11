import 'dart:convert';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:camera_web/camera_web.dart';
import 'package:web/web.dart' as web;

Future<Uint8List?> captureCameraFrame(int cameraId) async {
  final platform = CameraPlatform.instance;
  if (platform is! CameraPlugin) return null;

  // camera_web exposes no capture-to-bytes API; use its active preview to avoid Blob URLs.
  // ignore: invalid_use_of_visible_for_testing_member
  final camera = platform.cameras[cameraId];
  if (camera == null) return null;

  final video = camera.videoElement;
  final width = video.videoWidth;
  final height = video.videoHeight;
  if (width == 0 || height == 0) {
    throw StateError("The webcam has not produced a video frame yet.");
  }

  final canvas = web.HTMLCanvasElement()
    ..width = width
    ..height = height;
  canvas.context2D.drawImage(video, 0, 0, width.toDouble(), height.toDouble());

  final dataUrl = canvas.toDataURL('image/jpeg', 0.92.toJS);
  final separator = dataUrl.indexOf(',');
  if (separator < 0) {
    throw StateError("The captured webcam frame could not be encoded.");
  }
  return base64Decode(dataUrl.substring(separator + 1));
}
