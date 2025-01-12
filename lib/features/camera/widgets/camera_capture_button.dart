import 'package:flutter/material.dart';

class CameraCaptureButton extends StatelessWidget {
  final Color bgColor;
  final Color iconColor;
  final VoidCallback onButtonTap;

  const CameraCaptureButton({
    super.key,
    required this.bgColor,
    required this.iconColor,
    required this.onButtonTap,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 30,
      right: 30,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withAlpha(204),
            width: 10,
          ),
        ),
        child: FloatingActionButton(
          onPressed: onButtonTap,
          backgroundColor: bgColor,
          elevation: 0,
          shape: const CircleBorder(),
          child: Icon(
            Icons.camera_alt_rounded,
            color: iconColor,
            size: 28,
          ),
        ),
      ),
    );
  }
}
