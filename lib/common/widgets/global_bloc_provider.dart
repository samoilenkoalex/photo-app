import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:photo_app/features/camera/services/location_service.dart';

import '../../features/camera/cubit/photo_taker_cubit.dart';
import '../../features/permission/cubit/permission_cubit.dart';
import '../../features/upload/cubit/uploader_cubit.dart';
import '../../features/upload/repositories/upload_repository.dart';

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
        BlocProvider<PermissionCubit>(
          create: (context) => PermissionCubit(),
        ),
        BlocProvider(
          create: (context) => UploaderCubit(
            uploadRepository: context.read<UploadRepository>(),
          ),
        ),
        BlocProvider(
          create: (context) => PhotoTakerCubit(
            locationService: GetIt.I.get<LocationService>(),
          ),
        ),
      ],
      child: child,
    );
  }
}
