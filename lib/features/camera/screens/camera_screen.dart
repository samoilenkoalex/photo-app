import 'dart:developer';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../../common/widgets/custom_appbar.dart';
import '../../../theme/theme.dart';
import '../../permission/cubit/permission_cubit.dart';
import '../../permission/cubit/permission_state.dart';
import '../../permission/dialogs/dialogs.dart';
import '../cubit/photo_taker_cubit.dart';
import '../cubit/photo_taker_state.dart';
import '../services/location_service.dart';
import '../widgets/camera_capture_button.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> with WidgetsBindingObserver {
  bool _showButton = false;

  final locationService = GetIt.I.get<LocationService>();
  CameraController? _controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await showAccessDialog(context);
    });
  }

  Future<void> _initializeCamera() async {
    if (mounted) {
      try {
        /// Initializes the camera by:
        /// 1. Getting available cameras
        /// 2. Creating a controller for the first (usually back) camera
        /// 3. Setting up the camera with maximum resolution and no audio
        final cameras = await availableCameras();
        _controller = CameraController(
          cameras[0],
          ResolutionPreset.max,
          enableAudio: false,
        );
        await _controller!.initialize();
        if (mounted) {
          setState(() {});
          await context.read<PermissionCubit>().checkCameraPermission();
        }
      } catch (e) {
        log('Error initializing camera: $e');
      }
    }
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      final permissionCubit = context.read<PermissionCubit>();
      await permissionCubit.checkCameraPermission();
      if (mounted && permissionCubit.state.cameraPermissionStatus == PermissionStatus.granted) {
        _initializeCamera();
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<PermissionCubit, PermissionState>(
          listener: (context, state) async {
            await context.read<PermissionCubit>().checkLocationPermission();
            if (state.locationPermissionStatus == PermissionStatus.granted && context.mounted) {
              await context.read<PhotoTakerCubit>().getCurrentLocation();
            }

            await _handleCameraPermissionStateChange(state);
          },
        ),
      ],
      child: BlocBuilder<PhotoTakerCubit, PhotoTakerState>(
        builder: (context, state) {
          final cubit = context.read<PhotoTakerCubit>();

          if (_controller == null || !_controller!.value.isInitialized) {
            return const Scaffold(
              backgroundColor: Colors.black,
              body: Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            );
          }

          return Scaffold(
            backgroundColor: Colors.black,
            appBar: const CustomAppBar(),
            body: Stack(
              alignment: Alignment.center,
              children: [
                CameraPreview(_controller!),
                if (_showButton)
                  CameraCaptureButton(
                    bgColor: state.isCapturing ? Colors.grey : primaryButtonColor,
                    iconColor: state.isCapturing ? Colors.black54 : Colors.white,
                    onButtonTap: () => cubit.takePicture(_controller!),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _handleCameraPermissionStateChange(PermissionState state) async {
    switch (state.cameraPermissionStatus) {
      case PermissionStatus.granted:
        await _handleCameraGrantedPermission(state);
      case PermissionStatus.denied:
        await _handleCameraDeniedPermission();
      case PermissionStatus.initial:
        return;
    }
  }

  Future<void> _handleCameraGrantedPermission(PermissionState state) async {
    if (!mounted) return;

    if (state.locationPermissionStatus != PermissionStatus.granted) {
      try {
        await context.read<PermissionCubit>().requestLocationPermissionDialog();
      } catch (e) {
        log('Error getting location: $e');
      }
    }
    setState(() => _showButton = true);
  }

  Future<void> _handleCameraDeniedPermission() async {
    if (!mounted) return;
    try {
      await showPermissionBottomSheet(context);
    } catch (e) {
      log('Error showing permission sheet: $e');
    }
  }
}
