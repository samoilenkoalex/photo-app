import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:photo_app/features/photo/repositories/photo_repository.dart';

import '../../features/photo/services/photo_api_service.dart';

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
        RepositoryProvider<PhotoRepository>(
          create: (context) => PhotoRepositoryImpl(photoApiService: GetIt.I.get<PhotoApiService>()),
        ),
      ],
      child: child,
    );
  }
}
