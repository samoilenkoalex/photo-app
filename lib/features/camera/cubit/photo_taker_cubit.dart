import 'dart:developer';

import 'package:camera/camera.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_app/features/camera/cubit/photo_taker_state.dart';

/// A Cubit that manages the state and functionality of a camera-based photo taking feature.
/// Handles camera initialization, photo capture, and maintains a list of captured photos.
class PhotoTakerCubit extends Cubit<PhotoTakerState> {
  // Controller for managing camera operations
  CameraController? _controller;

  // Future that completes when camera is initialized
  Future<void>? _initializeControllerFuture;

  // Flag to prevent multiple simultaneous captures
  bool _isCapturing = false;

  /// Creates a new instance of PhotoTakerCubit with initial empty state
  PhotoTakerCubit() : super(const PhotoTakerState());

  /// Initializes the camera by:
  /// 1. Getting available cameras
  /// 2. Setting up controller with the first camera (usually back camera)
  /// 3. Configuring camera settings (max resolution, no audio)
  /// 4. Updating state with controller and initialization future
  Future<void> initializeCamera() async {
    try {
      final cameras = await availableCameras();
      _controller = CameraController(
        cameras[0], // Use the first available camera
        ResolutionPreset.max, // Use maximum resolution
        enableAudio: false, // Disable audio as it's not needed for photos
      );
      _initializeControllerFuture = _controller!.initialize();
      emit(
        state.copyWith(
          controller: _controller,
          initializeControllerFuture: _initializeControllerFuture,
        ),
      );
    } catch (e) {
      log('Error initializing camera: $e');
      emit(state.copyWith(error: e.toString()));
    }
  }

  /// Captures a photo using the initialized camera.
  /// Prevents multiple simultaneous captures using _isCapturing flag.
  /// Updates state with the new photo path and adds it to the photos list.
  Future<void> takePicture() async {
    if (_isCapturing) return; // Prevent multiple simultaneous captures

    try {
      _isCapturing = true;
      emit(state.copyWith(isCapturing: true));

      // Ensure camera is initialized before capturing
      await _initializeControllerFuture;
      final image = await _controller!.takePicture();

      // Add new photo to the list of captured photos
      final updatedPhotos = List<String>.from(state.photos)..add(image.path);
      emit(
        state.copyWith(
          photos: updatedPhotos,
          newPhoto: image.path,
          isCapturing: false,
        ),
      );
    } catch (e) {
      log('Error taking picture: $e');
      emit(state.copyWith(error: e.toString(), isCapturing: false));
    } finally {
      _isCapturing = false; // Reset capturing flag regardless of success/failure
    }
  }

  /// Adds an existing photo path to the list of photos.
  /// Useful for adding photos from external sources or restoring saved photos.
  /// [photo] The file path of the photo to add
  void addPhotos(String photo) {
    final updatedPhotos = List<String>.from(state.photos)..add(photo);
    emit(
      state.copyWith(
        photos: updatedPhotos,
        newPhoto: photo,
      ),
    );
  }

  /// Clears all photos from the state, resetting to an empty list
  void clearPhotos() {
    emit(state.copyWith(photos: []));
  }

  /// Properly disposes of camera resources when the cubit is closed
  @override
  Future<void> close() {
    _controller?.dispose(); // Release camera resources
    return super.close();
  }
}
