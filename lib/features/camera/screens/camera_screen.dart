import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../common/widgets/custom_appbar.dart';
import '../../../theme/theme.dart';
import '../../permission/cubit/permission_cubit.dart';
import '../../permission/cubit/permission_state.dart';
import '../../permission/dialogs/dialogs.dart';
import '../../permission/utils/permission_util.dart';
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

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      context.read<PhotoTakerCubit>().initializeCamera();

      final isPermissionGranted = await requestCameraPermissionStatus();
      if (isPermissionGranted) {
        setState(() {
          _showButton = true;
        });
      } else {
        if (mounted) {
          await showAccessDialog(context);
        }
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      final isPermissionGranted = await requestCameraPermissionStatus();
      if (isPermissionGranted && mounted) {
        context.read<PhotoTakerCubit>().initializeCamera();
        setState(() {
          _showButton = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PermissionCubit, PermissionState>(
      listenWhen: (previous, current) => previous.status != current.status && current.status == PermissionStatus.denied,
      listener: (context, state) {
        showPermissionBottomSheet(context);
      },
      child: BlocBuilder<PhotoTakerCubit, PhotoTakerState>(
        builder: (context, state) {
          if (state.controller == null || state.initializeControllerFuture == null) {
            return const Scaffold(
              backgroundColor: Colors.black,
              body: Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),
            );
          }

          return Scaffold(
            backgroundColor: Colors.black,
            appBar: const CustomAppBar(),
            body: FutureBuilder<void>(
              future: state.initializeControllerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      CameraPreview(state.controller!),
                      if (_showButton)
                        CameraCaptureButton(
                          bgColor: state.isCapturing ? Colors.grey : primaryButtonColor,
                          iconColor: state.isCapturing ? Colors.black54 : Colors.white,
                          onButtonTap: () {
                            if (state.isCapturing) {
                              context.read<PhotoTakerCubit>().takePicture();
                            }
                          },
                        ),
                    ],
                  );
                } else {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  );
                }
              },
            ),
          );
        },
      ),
    );
  }
}
