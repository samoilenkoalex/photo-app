import 'dart:developer';

import 'package:permission_handler/permission_handler.dart';

Future<bool> requestCameraPermissionStatus() async {
  const permission = Permission.camera;
  final status = await permission.status;

  if (status.isGranted || status.isLimited) {
    log('Camera permission granted');
    return true;
  } else if (status.isDenied || status.isPermanentlyDenied) {
    log('Camera permission denied');
    return false;
  } else {
    log('Camera permission status: $status');
    return false;
  }
}

Future<void> requestCameraPermission() async {
  const permission = Permission.camera;
  await permission.request();
}
