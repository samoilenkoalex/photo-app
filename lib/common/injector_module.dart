import 'package:get_it/get_it.dart';

import '../features/upload/services/upload_photo_queue.dart';

final GetIt locator = GetIt.asNewInstance();

Future<void> injectDependencies() async {
  GetIt.I.registerLazySingleton<UploadPhotoQueueService>(() => UploadPhotoQueueService());
}
