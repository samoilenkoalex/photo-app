import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../theme/theme.dart';
import '../../upload/cubit/photo_taker_cubit.dart';
import '../cubit/camera_cubit.dart';
import '../cubit/camera_state.dart';

class CameraCaptureButton extends StatefulWidget {
  const CameraCaptureButton({super.key});

  @override
  State<CameraCaptureButton> createState() => _CameraCaptureButtonState();
}

class _CameraCaptureButtonState extends State<CameraCaptureButton> {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CameraCubit, CameraState>(
      listenWhen: (previous, current) => current.status == CaptureStatus.success || current.status == CaptureStatus.error,
      listener: (context, state) {
        if (state.status == CaptureStatus.success && state.imagePath != null) {
          if (context.mounted) {
            context.read<PhotoTakerCubit>().addPhotos([state.imagePath!]);
            context.read<CameraCubit>().reset();
          }
        } else if (state.status == CaptureStatus.error) {
          log('state.errorMessage>>>> ${state.errorMessage}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage ?? 'Failed to take picture')),
          );
          context.read<CameraCubit>().reset();
        }
      },
      builder: (context, state) {
        final isCapturing = state.status == CaptureStatus.capturing;

        return Positioned(
          bottom: 30,
          right: 30,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.8),
                width: 10,
              ),
            ),
            child: FloatingActionButton(
              onPressed: isCapturing ? null : () => context.read<CameraCubit>().capturePhoto(),
              backgroundColor: isCapturing ? Colors.grey : primaryButtonColor,
              elevation: 0,
              shape: const CircleBorder(),
              child: Icon(
                Icons.camera_alt_rounded,
                color: Colors.white,
                size: 28,
                semanticLabel: isCapturing ? 'Processing' : 'Take Picture',
              ),
            ),
          ),
        );
      },
    );
  }
}
