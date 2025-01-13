import 'package:equatable/equatable.dart';

enum PermissionStatus {
  initial,
  granted,
  denied,
}

class PermissionState extends Equatable {
  final PermissionStatus cameraPermissionStatus;
  final PermissionStatus locationPermissionStatus;
  final bool isAccessDialogTapped;

  const PermissionState({
    this.cameraPermissionStatus = PermissionStatus.initial,
    this.locationPermissionStatus = PermissionStatus.initial,
    this.isAccessDialogTapped = false,
  });

  PermissionState copyWith({
    PermissionStatus? cameraPermissionStatus,
    PermissionStatus? locationPermissionStatus,
    bool? isAccessDialogTapped,
  }) {
    return PermissionState(
      cameraPermissionStatus: cameraPermissionStatus ?? this.cameraPermissionStatus,
      locationPermissionStatus: locationPermissionStatus ?? this.locationPermissionStatus,
      isAccessDialogTapped: isAccessDialogTapped ?? this.isAccessDialogTapped,
    );
  }

  @override
  List<Object?> get props => [cameraPermissionStatus, locationPermissionStatus, isAccessDialogTapped];
}
