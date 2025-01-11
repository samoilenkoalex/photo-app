import 'package:equatable/equatable.dart';

enum PermissionStatus {
  initial,
  granted,
  denied,
}

class PermissionState extends Equatable {
  final PermissionStatus status;

  const PermissionState({
    this.status = PermissionStatus.initial,
  });

  PermissionState copyWith({
    PermissionStatus? status,
  }) {
    return PermissionState(
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [status];
}
