import 'dart:developer';
import 'package:camera/camera.dart';

class CameraService {
  CameraController? _controller;
  Future<void>? _initializeFuture;
  bool _isCapturing = false;

  CameraController? get controller => _controller;

  Future<void>? get initializeFuture => _initializeFuture;

  Future<void> initialize() async {
    try {
      final cameras = await availableCameras();
      _controller = CameraController(
        cameras[0],
        ResolutionPreset.max,
        enableAudio: false,
      );
      _initializeFuture = _controller!.initialize();
      await _initializeFuture;
      log('Camera initialized successfully');
    } catch (e) {
      log('Failed to initialize camera: $e');
      throw CameraException('Failed to initialize camera', e.toString());
    }
  }

  Future<XFile> takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      throw CameraException('Camera not initialized', 'Initialize camera first');
    }

    if (_isCapturing) {
      throw CameraException(
        'Camera busy',
        'Previous capture still in progress',
      );
    }

    try {
      _isCapturing = true;
      final image = await _controller!.takePicture();
      return image;
    } finally {
      _isCapturing = false;
    }
  }

  void dispose() {
    _isCapturing = false;
    _controller?.dispose();
    _controller = null;
    _initializeFuture = null;
  }
}
