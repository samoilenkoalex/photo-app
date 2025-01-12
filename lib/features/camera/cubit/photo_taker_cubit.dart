import 'dart:developer';

import 'package:camera/camera.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_app/features/camera/cubit/photo_taker_state.dart';
import 'package:photo_app/features/permission/utils/permission_util.dart';

import '../services/location_service.dart';
import '../utils/camera_utils.dart';

/// A Cubit that manages the state and functionality of a camera-based photo taking system.
/// Handles camera initialization, photo capture, GPS location tagging, and photo management.
class PhotoTakerCubit extends Cubit<PhotoTakerState> {
  LocationService locationService;

  // Flag to prevent multiple simultaneous photo capture operations
  bool _isCapturing = false;

  /// Creates a new instance of PhotoTakerCubit with an initial empty state
  PhotoTakerCubit({required this.locationService}) : super(const PhotoTakerState());

  Future<void> getCurrentLocation() async {
    final currentLocation = await locationService.getCurrentPosition();
    emit(state.copyWith(currentLocation: currentLocation));
  }

  /// Takes a picture and processes it by:
  /// 1. Capturing the image
  /// 2. Getting current GPS location
  /// 3. Writing GPS data to image EXIF metadata
  /// 4. Adding the photo to the state
  Future<void> takePicture(CameraController controller) async {
    if (_isCapturing || !controller.value.isInitialized) return;

    try {
      _isCapturing = true;
      emit(state.copyWith(isCapturing: true));
      final isLocationAllowed = await checkLocationPermissionStatus();
      final image = await controller.takePicture();
      if (isLocationAllowed && state.currentLocation != null) {
        final position = state.currentLocation!;
        await writeExifData(image.path, position);
      }
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
      _isCapturing = false;
    }
  }

  /// Clears all photos from the state
  void clearPhotos() {
    emit(state.copyWith(photos: []));
  }
}
