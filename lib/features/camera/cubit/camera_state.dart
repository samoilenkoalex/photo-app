import 'package:equatable/equatable.dart';

enum CaptureStatus {
  initial,
  capturing,
  success,
  error
}

class CameraState extends Equatable {
  final CaptureStatus status;
  final String? imagePath;
  final String? errorMessage;

  const CameraState({
    this.status = CaptureStatus.initial,
    this.imagePath,
    this.errorMessage,
  });

  CameraState copyWith({
    CaptureStatus? status,
    String? imagePath,
    String? errorMessage,
  }) {
    return CameraState(
      status: status ?? this.status,
      imagePath: imagePath ?? this.imagePath,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, imagePath, errorMessage];
}