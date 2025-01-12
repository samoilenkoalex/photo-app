import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/permission/cubit/permission_cubit.dart';
import '../../features/upload/cubit/photo_taker_cubit.dart';
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
          create: (context) => PhotoTakerCubit(),
        ),
      ],
      child: child,
    );
  }
}
