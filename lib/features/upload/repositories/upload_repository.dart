import '../models/queue_result.dart';
import '../services/upload_photo_queue.dart';

abstract class UploadRepository {
  final UploadPhotoQueueService uploadPhotoQueueService;

  UploadRepository(this.uploadPhotoQueueService);

  void addToQueue(String photos);

  List<String> get failedUploads;

  List<String> get queue;

  Future<QueueProcessResult> processUploadQueue();
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
  Future<QueueProcessResult> processUploadQueue() async {
    return await uploadPhotoQueueService.processUploadQueue();
  }
}
