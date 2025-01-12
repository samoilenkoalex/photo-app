import 'package:equatable/equatable.dart';

enum PermissionStatus {
  initial,
  granted,
  denied,
}

class PermissionState extends Equatable {
  final PermissionStatus cameraPermissionStatus;
  final PermissionStatus locationPermissionStatus;

  const PermissionState({
    this.cameraPermissionStatus = PermissionStatus.initial,
    this.locationPermissionStatus = PermissionStatus.initial,
  });

  PermissionState copyWith({
    PermissionStatus? cameraPermissionStatus,
    PermissionStatus? locationPermissionStatus,
  }) {
    return PermissionState(
      cameraPermissionStatus: cameraPermissionStatus ?? this.cameraPermissionStatus,
      locationPermissionStatus: locationPermissionStatus ?? this.locationPermissionStatus,
    );
  }

  @override
  List<Object?> get props => [cameraPermissionStatus, locationPermissionStatus];
}
