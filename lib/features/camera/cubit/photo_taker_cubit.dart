import 'dart:developer';

import 'package:camera/camera.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:native_exif/native_exif.dart';
import 'package:photo_app/features/camera/cubit/photo_taker_state.dart';

import '../services/location_service.dart';

/// A Cubit that manages the state and functionality of a camera-based photo taking system.
/// Handles camera initialization, photo capture, GPS location tagging, and photo management.
class PhotoTakerCubit extends Cubit<PhotoTakerState> {
  LocationService locationService;

  // Controller for accessing and controlling the device's camera
  CameraController? _controller;

  // Flag to prevent multiple simultaneous photo capture operations
  bool _isCapturing = false;

  CameraController? get controller => _controller;

  /// Creates a new instance of PhotoTakerCubit with an initial empty state
  PhotoTakerCubit({required this.locationService}) : super(const PhotoTakerState());

  /// Initializes the camera by:
  /// 1. Getting available cameras
  /// 2. Creating a controller for the first (usually back) camera
  /// 3. Setting up the camera with maximum resolution and no audio

  Future<void> initializeCamera() async {
    try {
      await _controller?.dispose();
      _controller = null;

      final cameras = await availableCameras();
      _controller = CameraController(
        cameras[0], // Use the first available camera (usually back camera)
        ResolutionPreset.max, // Use maximum resolution
        enableAudio: false, // Disable audio as it's not needed for photos
      );

      await _controller!.initialize();
      emit(state.copyWith(isInitialized: true));
    } catch (e) {
      log('Error initializing camera: $e');
      emit(state.copyWith(error: e.toString(), isInitialized: false));
    }
  }

  /// Takes a picture and processes it by:
  /// 1. Capturing the image
  /// 2. Getting current GPS location
  /// 3. Writing GPS data to image EXIF metadata
  /// 4. Adding the photo to the state
  Future<void> takePicture() async {
    if (_isCapturing || !_controller!.value.isInitialized) return;

    try {
      _isCapturing = true;
      emit(state.copyWith(isCapturing: true));

      final position = await locationService.getCurrentPosition();
      final image = await _controller!.takePicture();
      await _writeExifData(image.path, position);

      final updatedPhotos = List<String>.from(state.photos)..add(image.path);
      emit(state.copyWith(
        photos: updatedPhotos,
        newPhoto: image.path,
        isCapturing: false,
      ));
    } catch (e) {
      log('Error taking picture: $e');
      emit(state.copyWith(error: e.toString(), isCapturing: false));
    } finally {
      _isCapturing = false;
    }
  }

  Future<void> _writeExifData(String imagePath, Position position) async {
    final exif = await Exif.fromPath(imagePath);
    final now = DateTime.now().toUtc();
    final gpsTimeStamp = '${now.hour}:${now.minute}:${now.second}';

    await exif.writeAttributes({
      'GPSLatitude': position.latitude.abs(),
      'GPSLongitude': position.longitude.abs(),
      'GPSTimeStamp': gpsTimeStamp,
      'GPSDateStamp': '${now.year}:${now.month.toString().padLeft(2, '0')}:${now.day.toString().padLeft(2, '0')}',
    });

    await exif.close();
  }

  /// Clears all photos from the state
  void clearPhotos() {
    emit(state.copyWith(photos: []));
  }

  /// Disposes of the camera controller when the cubit is closed
  @override
  Future<void> close() async {
    await _controller?.dispose();
    _controller = null;
    return super.close();
  }
}
