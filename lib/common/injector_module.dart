import 'package:get_it/get_it.dart';

import '../features/camera/services/camera_service.dart';
import '../features/photo/services/photo_api_service.dart';
import '../features/upload/services/upload_photo_queue.dart';


final GetIt locator = GetIt.asNewInstance();

Future<void> injectDependencies() async {
  GetIt.I.registerLazySingleton<PhotoApiService>(() => PhotoApiService());
  GetIt.I.registerLazySingleton<UploadPhotoQueue>(() => UploadPhotoQueue());
  GetIt.I.registerLazySingleton<CameraService>(() => CameraService());
}
