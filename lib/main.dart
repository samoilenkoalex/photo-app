import 'package:flutter/material.dart';

import 'app.dart';
import 'common/injector_module.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await injectDependencies();

  runApp(
    const Application(),
  );
}
