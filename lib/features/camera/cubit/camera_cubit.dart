import 'dart:developer';

import 'package:camera/camera.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../services/camera_service.dart';
import 'camera_state.dart';

class CameraCubit extends Cubit<CameraState> {
  final CameraService _cameraService;
  bool _isProcessing = false;

  CameraCubit({
    required CameraService cameraService,
  })  : _cameraService = cameraService,
        super(const CameraState());

  Future<void> capturePhoto() async {
    if (_isProcessing || state.status == CaptureStatus.capturing) {
      log('Skipping capture: Already processing');
      return;
    }

    try {
      _isProcessing = true;
      emit(
        state.copyWith(
          status: CaptureStatus.capturing,
          errorMessage: null,
        ),
      );

      await Future<void>.delayed(const Duration(milliseconds: 500));
      final image = await _cameraService.takePicture();
      log('Photo captured successfully: ${image.path}');

      if (!isClosed) {
        emit(
          state.copyWith(
            status: CaptureStatus.success,
            imagePath: image.path,
          ),
        );
      }
    } on CameraException catch (e) {
      log('Camera error during capture: ${e.description}');
      if (!isClosed) {
        emit(state.copyWith(
          status: CaptureStatus.error,
          errorMessage: 'Camera error: ${e.description}',
        ));
      }
    } catch (e) {
      log('Unexpected error during capture: $e');
      if (!isClosed) {
        emit(
          state.copyWith(
            status: CaptureStatus.error,
            errorMessage: 'Failed to capture photo: $e',
          ),
        );
      }
    } finally {
      await Future<void>.delayed(const Duration(milliseconds: 500));
      _isProcessing = false;

      if (!isClosed) {
        emit(state.copyWith(status: CaptureStatus.initial));
      }
    }
  }

  void reset() {
    if (!_isProcessing) {
      emit(const CameraState());
    }
  }

  @override
  Future<void> close() {
    _isProcessing = false;
    return super.close();
  }
}
