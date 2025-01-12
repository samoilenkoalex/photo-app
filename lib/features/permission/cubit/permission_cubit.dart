import 'package:flutter_bloc/flutter_bloc.dart';

import '../utils/permission_util.dart';
import 'permission_state.dart';

class PermissionCubit extends Cubit<PermissionState> {
  PermissionCubit() : super(const PermissionState());

  Future<void> checkCameraPermission() async {
    final isGranted = await checkCameraPermissionStatus();
    emit(
      state.copyWith(
        cameraPermissionStatus: isGranted ? PermissionStatus.granted : PermissionStatus.denied,
      ),
    );
  }

  Future<void> checkLocationPermission() async {
    final isGranted = await checkLocationPermissionStatus();
    emit(
      state.copyWith(
        locationPermissionStatus: isGranted ? PermissionStatus.granted : PermissionStatus.denied,
      ),
    );
  }
  Future<void> requestLocationPermissionDialog() async {
    await requestLocationPermission();
  }
}
