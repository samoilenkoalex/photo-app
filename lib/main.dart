import 'package:flutter/material.dart';

import 'app.dart';
import 'common/injector_module.dart';
import 'common/widgets/global_bloc_provider.dart';
import 'common/widgets/repository_holder.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await injectDependencies();

  runApp(
    const RepositoriesHolder (
      child:  GlobalBlocProvider(
        child: Application(),
      ),
    ),
  );
}
