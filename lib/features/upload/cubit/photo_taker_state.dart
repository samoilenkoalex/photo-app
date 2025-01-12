// import 'package:equatable/equatable.dart';
//
// class PhotoTakerState extends Equatable {
//   final List<String> photos;
//   final String? newPhoto;
//
//   const PhotoTakerState({
//     this.photos = const [],
//     this.newPhoto,
//   });
//
//   PhotoTakerState copyWith({
//     List<String>? photos,
//     String? newPhoto,
//   }) {
//     return PhotoTakerState(
//       photos: photos ?? this.photos,
//       newPhoto: newPhoto ?? this.newPhoto,
//     );
//   }
//
//   @override
//   List<Object?> get props => [
//         photos,
//         newPhoto,
//       ];
// }

import 'package:camera/camera.dart';
import 'package:equatable/equatable.dart';

class PhotoTakerState extends Equatable {
  final List<String> photos;
  final String? newPhoto;
  final String? error;
  final bool isCapturing;
  final CameraController? controller;
  final Future<void>? initializeControllerFuture;

  const PhotoTakerState({
    this.photos = const [],
    this.newPhoto,
    this.error,
    this.isCapturing = false,
    this.controller,
    this.initializeControllerFuture,
  });

  PhotoTakerState copyWith({
    List<String>? photos,
    String? newPhoto,
    String? error,
    bool? isCapturing,
    CameraController? controller,
    Future<void>? initializeControllerFuture,
  }) {
    return PhotoTakerState(
      photos: photos ?? this.photos,
      newPhoto: newPhoto ?? this.newPhoto,
      error: error ?? this.error,
      isCapturing: isCapturing ?? this.isCapturing,
      controller: controller ?? this.controller,
      initializeControllerFuture: initializeControllerFuture ?? this.initializeControllerFuture,
    );
  }

  @override
  List<Object?> get props => [
    photos,
    newPhoto,
    error,
    isCapturing,
    controller,
    initializeControllerFuture,
  ];
}