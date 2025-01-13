import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'features/camera/cubit/photo_taker_cubit.dart';
import 'features/camera/cubit/photo_taker_state.dart';
import 'features/camera/screens/camera_screen.dart';
import 'features/upload/cubit/uploader_cubit.dart';

class Application extends StatelessWidget {
  const Application({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Photo App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BlocListener<PhotoTakerCubit, PhotoTakerState>(
        listenWhen: (previous, current) => current.newPhoto != null && current.newPhoto != previous.newPhoto,
        listener: (context, state) {
          if (state.photos.isNotEmpty) {
            context.read<UploaderCubit>().addPhoto(state.newPhoto!);
          }
        },
        child: const CameraScreen(),
      ),
    );
  }
}
