import '../models/queue_result.dart';
import '../services/upload_photo_queue.dart';

abstract class UploadRepository {
  final UploadPhotoQueueService uploadPhotoQueueService;

  UploadRepository(this.uploadPhotoQueueService);

  void addToQueue(String photos);

  List<String> get failedUploads;

  List<String> get queue;

  Future<QueueProcessResult> processUploadQueue();

  /// Called when a single photo is successfully uploaded
  void Function(String path)? get onUploadSuccess;
  set onUploadSuccess(void Function(String path)? callback);
}

class UploadRepositoryImpl implements UploadRepository {
  @override
  final UploadPhotoQueueService uploadPhotoQueueService;

  void Function(String path)? _onUploadSuccess;

  @override
  void Function(String path)? get onUploadSuccess => _onUploadSuccess;

  @override
  set onUploadSuccess(void Function(String path)? callback) {
    _onUploadSuccess = callback;
    uploadPhotoQueueService.onUploadSuccess = callback;
  }

  UploadRepositoryImpl({
    required this.uploadPhotoQueueService,
  });

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
