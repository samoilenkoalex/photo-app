import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../features/upload/repositories/upload_repository.dart';
import '../../features/upload/services/upload_photo_queue.dart';

class RepositoriesHolder extends StatelessWidget {
  final Widget child;

  const RepositoriesHolder({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<UploadRepository>(
          create: (context) => UploadRepositoryImpl(uploadPhotoQueueService: GetIt.I.get<UploadPhotoQueueService>()),
        ),
      ],
      child: child,
    );
  }
}
