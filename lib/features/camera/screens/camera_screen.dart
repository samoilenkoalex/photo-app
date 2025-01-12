import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../common/widgets/custom_appbar.dart';
import '../../../theme/theme.dart';
import '../../permission/cubit/permission_cubit.dart';
import '../../permission/cubit/permission_state.dart';
import '../../permission/dialogs/dialogs.dart';
import '../cubit/photo_taker_cubit.dart';
import '../cubit/photo_taker_state.dart';
import '../widgets/camera_capture_button.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> with WidgetsBindingObserver {
  bool _showButton = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    await context.read<PhotoTakerCubit>().initializeCamera();
    if (mounted) {
      await context.read<PermissionCubit>().checkCameraPermission();
    }
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      await context.read<PermissionCubit>().checkCameraPermission();
      if (mounted && context.read<PermissionCubit>().state.status == PermissionStatus.granted) {
        await context.read<PhotoTakerCubit>().initializeCamera();
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<PermissionCubit, PermissionState>(
          listener: (context, state) async {
            switch (state.status) {
              case PermissionStatus.granted:
                if (mounted) {
                  setState(() {
                    _showButton = true;
                  });
                }
              case PermissionStatus.denied:
                await showAccessDialog(context);
                if (context.mounted) {
                  showPermissionBottomSheet(context);
                }

              case PermissionStatus.initial:
                break;
            }
          },
        ),
      ],
      child: BlocBuilder<PhotoTakerCubit, PhotoTakerState>(
        builder: (context, state) {
          final cubit = context.read<PhotoTakerCubit>();
          final controller = cubit.controller;

          if (controller == null || !state.isInitialized) {
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
                CameraPreview(controller),
                if (_showButton)
                  CameraCaptureButton(
                    bgColor: state.isCapturing ? Colors.grey : primaryButtonColor,
                    iconColor: state.isCapturing ? Colors.black54 : Colors.white,
                    onButtonTap: () => cubit.takePicture(),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
