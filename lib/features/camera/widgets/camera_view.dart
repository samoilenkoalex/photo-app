import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../services/camera_service.dart';
import '../widgets/camera_capture_button.dart';

class CameraView extends StatelessWidget {
  final bool showControls;

  const CameraView({
    required this.showControls,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final cameraService = GetIt.I<CameraService>();

    return Stack(
      alignment: Alignment.center,
      children: [
        if (cameraService.controller != null) CameraPreview(cameraService.controller!),
        if (showControls) ...[
          const CameraCaptureButton(),
        ],
      ],
    );
  }
}
