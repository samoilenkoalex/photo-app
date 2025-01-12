import 'dart:developer';

import 'package:camera/camera.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_app/features/upload/cubit/photo_taker_state.dart';

class PhotoTakerCubit extends Cubit<PhotoTakerState> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  bool _isCapturing = false;

  PhotoTakerCubit() : super(const PhotoTakerState());

  Future<void> initializeCamera() async {
    try {
      final cameras = await availableCameras();
      _controller = CameraController(
        cameras[0],
        ResolutionPreset.max,
        enableAudio: false,
      );
      _initializeControllerFuture = _controller!.initialize();
      emit(state.copyWith(
        controller: _controller,
        initializeControllerFuture: _initializeControllerFuture,
      ));
    } catch (e) {
      log('Error initializing camera: $e');
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> takePicture() async {
    if (_isCapturing) return;

    try {
      _isCapturing = true;
      emit(state.copyWith(isCapturing: true));

      await _initializeControllerFuture;
      final image = await _controller!.takePicture();

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

  void addPhotos(String photo) {
    final updatedPhotos = List<String>.from(state.photos)..add(photo);
    emit(state.copyWith(
      photos: updatedPhotos,
      newPhoto: photo,
    ));
  }

  void clearPhotos() {
    emit(state.copyWith(photos: []));
  }

  @override
  Future<void> close() {
    _controller?.dispose();
    return super.close();
  }
}
