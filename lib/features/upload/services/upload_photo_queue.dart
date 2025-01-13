import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../../../network/api_client.dart';
import '../../../network/network.dart';
import '../models/queue_result.dart';

/// A service that manages photo upload queue with retry capabilities.
class UploadPhotoQueueService {
  final ApiClient _httpService;

  /// Maximum number of retry attempts for failed uploads
  final int _maxRetries;

  /// Delay duration between retry attempts
  final Duration _retryDelay;

  /// Filename for persisting the main upload queue
  static const String _queueFileName = 'upload_queue.json';

  /// Filename for persisting the failed uploads list
  static const String _failedUploadsFileName = 'failed_uploads.json';

  /// Main queue storing paths of photos pending upload
  final List<String> _queue = [];

  /// List of photo paths that failed to upload after maximum retries
  final List<String> _failedUploads = [];

  /// Queue of photos currently being processed
  final List<String> _processingQueue = [];

  /// Flag indicating if the queue is currently being processed
  bool _isProcessing = false;

  /// Flag indicating if an upload is currently in progress
  bool _isUploading = false;

  UploadPhotoQueueService({
    ApiClient? httpService,
    int maxRetries = 5,
    Duration? retryDelay,
  })  : _httpService = httpService ?? ApiClient(baseUrl: 'https://prioritysoftfile-upload-testap-production.up.railway.app'),
        _maxRetries = maxRetries,
        _retryDelay = retryDelay ?? const Duration(seconds: 2) {
    _loadPersistedQueues();
  }

  /// Returns an unmodifiable list of photos that failed to upload after all retry attempts.
  /// This prevents external modification of the internal list.
  List<String> get failedUploads => List.unmodifiable(_failedUploads);

  /// Returns an unmodifiable list of photos currently in the upload queue.
  /// This prevents external modification of the internal queue.
  List<String> get queue => List.unmodifiable(_queue);

  /// Indicates whether the queue is currently being processed.
  bool get isProcessing => _isProcessing;

  /// Adds a photo path to the upload queue and persists the updated queue state.
  /// The queue is automatically persisted to handle offline scenarios.
  void addToQueue(String photo) {
    _queue.add(photo);
    _persistQueue();
  }

  /// Loads previously persisted queues from local storage.
  Future<void> _loadPersistedQueues() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final queueFile = File('${directory.path}/$_queueFileName');
      final failedUploadsFile = File('${directory.path}/$_failedUploadsFileName');

      if (await queueFile.exists()) {
        final queueData = await queueFile.readAsString();
        final queueList = List<String>.from(jsonDecode(queueData));
        _queue.addAll(queueList);
        log('Loaded ${queueList.length} items from persisted queue');
      }

      if (await failedUploadsFile.exists()) {
        final failedData = await failedUploadsFile.readAsString();
        final failedList = List<String>.from(jsonDecode(failedData));
        _failedUploads.addAll(failedList);
        log('Loaded ${failedList.length} items from persisted failed uploads');
      }
    } catch (e) {
      log('Error loading persisted queues: $e');
    }
  }

  /// Persists the current state of both queues to local storage.
  Future<void> _persistQueue() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final queueFile = File('${directory.path}/$_queueFileName');
      final failedUploadsFile = File('${directory.path}/$_failedUploadsFileName');

      await queueFile.writeAsString(jsonEncode(_queue));
      await failedUploadsFile.writeAsString(jsonEncode(_failedUploads));
      log('Persisted queue (${_queue.length} items) and failed uploads (${_failedUploads.length} items)');
    } catch (e) {
      log('Error persisting queues: $e');
    }
  }

  /// Processes all photos in the upload queue sequentially.
  Future<QueueProcessResult> processUploadQueue() async {
    if (_queue.isEmpty || _isUploading) {
      return QueueProcessResult(NetworkResponse.none(), 0);
    }

    _isUploading = true;
    NetworkResponse<dynamic> lastResponse = NetworkResponse.none();
    int successCount = 0;

    try {
      final itemsToProcess = List<String>.from(_queue);

      for (final photo in itemsToProcess) {
        lastResponse = await _uploadWithRetry(photo);

        if (lastResponse.status == Status.completed) {
          successCount++;
          _queue.remove(photo);
          await _persistQueue(); // Persist after each successful upload
        } else {
          break; // Stop processing on first failure
        }
      }

      return QueueProcessResult(lastResponse, successCount);
    } finally {
      _isUploading = false;
    }
  }

  /// Handles the upload of a single photo with retry logic.
  Future<NetworkResponse<dynamic>> _uploadWithRetry(String photo) async {
    NetworkResponse<dynamic> lastResponse;
    int attempts = 0;

    log('Starting upload with retry for ${photo.split('/').last}');
    do {
      try {
        lastResponse = await _uploadPhoto(photo);

        if (lastResponse.status == Status.completed) {
          return lastResponse;
        }

        log('Upload attempt ${attempts + 1} failed for ${photo.split('/').last}');
        if (attempts + 1 < _maxRetries) {
          log('Retrying in ${_retryDelay.inSeconds} seconds...');
        }
        await Future<void>.delayed(_retryDelay);
      } catch (e) {
        lastResponse = NetworkResponse.error(e.toString());
        log('Upload error on attempt ${attempts + 1}: $e');
        if (attempts + 1 < _maxRetries) {
          log('Retrying in ${_retryDelay.inSeconds} seconds...');
        }
        await Future<void>.delayed(_retryDelay);
      }

      attempts++;
    } while (attempts < _maxRetries);

    // Handle final failure
    log('All retry attempts exhausted for ${photo.split('/').last}');
    _failedUploads.add(photo);
    _queue.remove(photo);
    return NetworkResponse.error('Failed after $_maxRetries attempts');
  }

  /// Performs the actual HTTP upload request for a single photo.
  Future<NetworkResponse<dynamic>> _uploadPhoto(String photo) async {
    final result = await _httpService.uploadFile(
      '/upload',
      File(photo),
      queryParams: {'candidateName': 'Alex Samoilenko'},
    );

    log('Upload result for ${photo.split('/').last}: $result');
    return result;
  }

  /// Cancels all pending uploads and clears both queues.
  void cancelAll() {
    _queue.clear();
    _processingQueue.clear();
    _isProcessing = false;
    _isUploading = false;
    _persistQueue(); // Persist the cleared state
  }
}
