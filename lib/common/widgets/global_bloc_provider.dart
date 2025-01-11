import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:photo_app/features/camera/services/camera_service.dart';
import 'package:photo_app/features/upload/services/upload_photo_queue.dart';

import '../../features/camera/cubit/camera_cubit.dart';
import '../../features/check_permission/cubit/permission_cubit.dart';
import '../../features/connectivity/cubit/connectivity_cubit.dart';
import '../../features/photo/cubit/photo_cubit.dart';
import '../../features/upload/cubit/photo_taker_cubit.dart';
import '../../features/upload/cubit/uploader_cubit.dart';

class GlobalBlocProvider extends StatelessWidget {
  const GlobalBlocProvider({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<PhotoCubit>(
          create: (context) => PhotoCubit(
            context.read<ConnectivityCubit>(),
          ),
        ),
        BlocProvider<PermissionCubit>(
          create: (context) => PermissionCubit(),
        ),
        BlocProvider(
          create: (context) => UploaderCubit(
            uploadQueue: GetIt.I<UploadPhotoQueue>(),
          ),
        ),
        BlocProvider(
          create: (context) => PhotoTakerCubit(),
        ),
        BlocProvider(
          create: (context) => CameraCubit(cameraService: GetIt.I<CameraService>()),
        ),
      ],
      child: child,
    );
  }
}
