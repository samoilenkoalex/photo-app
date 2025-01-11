import '../../../network/network.dart';
import '../services/upload_photo_queue.dart';

abstract class UploadRepository {
  final UploadPhotoQueueService uploadPhotoQueueService;

  UploadRepository(this.uploadPhotoQueueService);

  void addToQueue(String photos);

  List<String> get failedUploads;

  List<String> get queue;

  bool get isUploading;

  Future<NetworkResponse<dynamic>?> processUploadQueue();

  void clearFailedUploads();
}

class UploadRepositoryImpl implements UploadRepository {
  @override
  final UploadPhotoQueueService uploadPhotoQueueService;

  UploadRepositoryImpl({required this.uploadPhotoQueueService});

  @override
  void addToQueue(String photos) {
    uploadPhotoQueueService.addToQueue(photos);
  }

  @override
  List<String> get failedUploads => uploadPhotoQueueService.failedUploads;

  @override
  List<String> get queue => uploadPhotoQueueService.queue;

  @override
  bool get isUploading => uploadPhotoQueueService.isUploading;

  @override
  Future<NetworkResponse<dynamic>?> processUploadQueue() async {
    return await uploadPhotoQueueService.processUploadQueue();
  }

  @override
  void clearFailedUploads() {
    uploadPhotoQueueService.clearFailedUploads();
  }
}
