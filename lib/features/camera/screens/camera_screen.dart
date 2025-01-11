import 'dart:developer';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../common/widgets/custom_appbar.dart';
import '../../../theme/theme.dart';
import '../../check_permission/cubit/permission_cubit.dart';
import '../../check_permission/cubit/permission_state.dart';
import '../../check_permission/dialogs/dialogs.dart';
import '../../upload/cubit/photo_taker_cubit.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  bool _showButton = false;
  bool _isCapturing = false; // Add lock flag

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _initializeCamera();
      final result = await showAccessDialog(context);
      if (mounted && result == true) {
        setState(() {
          _showButton = true;
        });
      }
    });
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      _controller = CameraController(
        cameras[0],
        ResolutionPreset.max,
        enableAudio: false,
      );
      _initializeControllerFuture = _controller!.initialize();
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      log('Error initializing camera: $e');
    }
  }

  Future<void> _takePicture() async {
    if (_isCapturing) return; // Prevent multiple captures

    try {
      setState(() {
        _isCapturing = true; // Set lock
      });

      await _initializeControllerFuture;
      final image = await _controller!.takePicture();

      if (mounted) {
        context.read<PhotoTakerCubit>().addPhotos(image.path);
      }
    } catch (e) {
      log('Error taking picture: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isCapturing = false; // Release lock
        });
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || _initializeControllerFuture == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        ),
      );
    }

    return BlocListener<PermissionCubit, PermissionState>(
      listenWhen: (previous, current) => previous.status != current.status && current.status == PermissionStatus.denied,
      listener: (context, state) {
        showPermissionBottomSheet(context);
      },
      child: BlocBuilder<PermissionCubit, PermissionState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: Colors.black,
            appBar: const CustomAppBar(),
            body: FutureBuilder<void>(
              future: _initializeControllerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      CameraPreview(_controller!),
                      if (state.status == PermissionStatus.granted && _showButton)
                        Positioned(
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
                              onPressed: _isCapturing ? null : _takePicture,
                              // Disable button while capturing
                              backgroundColor: _isCapturing ? Colors.grey : primaryButtonColor,
                              elevation: 0,
                              shape: const CircleBorder(),
                              child: Icon(
                                Icons.camera_alt_rounded,
                                color: _isCapturing ? Colors.black54 : Colors.white,
                                size: 28,
                              ),
                            ),
                          ),
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
