import 'dart:developer';

import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

Future<bool> checkCameraPermissionStatus() async {
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

Future<bool> checkLocationPermissionStatus() async {
  final permission = await Geolocator.checkPermission();

  if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
    log('Location permission granted');
    return true;
  } else if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
    log('Location permission denied');
    return false;
  } else {
    log('Location permission status: $permission');
    return false;
  }
}

Future<void> requestLocationPermission() async {
  final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    throw Exception('Location services are disabled');
  }

  // Check and request location permissions
  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      throw Exception('Location permissions are denied');
    }
  }

  // Check if permissions are permanently denied
  if (permission == LocationPermission.deniedForever) {
    throw Exception('Location permissions are permanently denied');
  }
}
