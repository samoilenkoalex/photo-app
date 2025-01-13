import 'package:get_it/get_it.dart';

import '../features/camera/services/location_service.dart';
import '../features/upload/services/upload_photo_queue.dart';

final GetIt locator = GetIt.asNewInstance();

Future<void> injectDependencies() async {
  GetIt.I.registerLazySingleton<UploadPhotoQueueService>(() => UploadPhotoQueueService());
  GetIt.I.registerLazySingleton<LocationService>(() => LocationService());
}
