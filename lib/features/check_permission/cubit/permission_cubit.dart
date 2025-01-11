import 'package:flutter_bloc/flutter_bloc.dart';

import '../utils/permission_util.dart';
import 'permission_state.dart';

class PermissionCubit extends Cubit<PermissionState> {
  PermissionCubit() : super(const PermissionState());

  Future<void> checkCameraPermission() async {
    final isGranted = await requestCameraPermissionStatus();

    emit(
      state.copyWith(
        status: isGranted ? PermissionStatus.granted : PermissionStatus.denied,
      ),
    );
  }
}

