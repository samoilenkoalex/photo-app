import 'dart:developer';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../../network/exception.dart';
import '../../../network/network.dart';

/// A service that manages a queue for uploading photos with retry capabilities.
/// Handles sequential photo uploads, tracks failed uploads, and implements
/// retry logic for failed attempts.
class UploadPhotoQueueService {
  // Internal queue to store paths of photos pending upload
  final List<String> _queue = [];

  // Tracks photos that failed to upload after maximum retry attempts
  final List<String> _failedUploads = [];

  // Flag to prevent concurrent uploads
  bool _isUploading = false;

  /// Adds a photo path to the upload queue
  /// [photo] The file path of the photo to be uploaded
  void addToQueue(String photo) {
    _queue.add(photo);
  }

  /// Returns the list of photos that failed to upload after all retry attempts
  List<String> get failedUploads => _failedUploads;

  /// Returns the current queue of photos pending upload
  List<String> get queue => _queue;

  /// Indicates whether a photo is currently being uploaded
  bool get isUploading => _isUploading;

  /// Processes the next photo in the upload queue if available and not currently uploading
  /// Returns a NetworkResponse indicating the upload result
  /// If queue is empty or upload is in progress, returns NetworkResponse.none()
  Future<NetworkResponse<dynamic>> processUploadQueue() async {
    if (_queue.isEmpty || _isUploading) return NetworkResponse.none();

    _isUploading = true;
    try {
      final photo = _queue.first;
      return await _processPhoto(photo);
    } finally {
      _isUploading = false;
    }
  }

  /// Internal method to process a single photo upload
  /// Handles the upload attempt and queue management based on the result
  /// [photo] The file path of the photo to process
  Future<NetworkResponse<dynamic>> _processPhoto(String photo) async {
    try {
      final uploadResponse = await uploadPhoto(photo);
      if (uploadResponse.status == Status.completed) {
        _queue.removeAt(0); // Remove successfully uploaded photo from queue
      }
      return uploadResponse;
    } catch (e) {
      return await retryFailedUploads(photo);
    }
  }

  /// Attempts to upload a single photo to the server
  /// [photo] The file path of the photo to upload
  /// Returns NetworkResponse with the upload result
  /// Throws various APIExceptions based on server response
  Future<NetworkResponse<dynamic>> uploadPhoto(String photo) async {
    log('Starting upload for photo: ${photo.split('/').last}');
    // Constructs upload URL with candidate name as query parameter
    final url = Uri.parse('https://prioritysoftfile-upload-testap-production.up.railway.app/upload').replace(queryParameters: {'candidateName': 'Alex Samoilenko'});

    try {
      // Prepare multipart request for file upload
      final request = http.MultipartRequest('POST', url);
      final file = File(photo);
      final fileStream = http.ByteStream(file.openRead());
      final length = await file.length();

      // Create multipart file from photo
      final multipartFile = http.MultipartFile(
        'file',
        fileStream,
        length,
        filename: file.path.split('/').last,
      );

      request.files.add(multipartFile);
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      log('Upload response: Status ${response.statusCode}, Body: $responseBody');

      // Handle response based on status code
      if (response.statusCode == 200) {
        return NetworkResponse.completed(response);
      } else {
        switch (response.statusCode) {
          case 400:
            throw BadRequestException(responseBody);
          case 401:
          case 403:
            throw UnauthorisedException(responseBody);
          default:
            throw FetchDataException('Error occurred while uploading: ${response.statusCode}');
        }
      }
    } catch (e) {
      log('Upload error: $e');
      if (e is APIException) {
        return NetworkResponse.error(e.toString());
      }
      return NetworkResponse.error('Failed to upload photo: $e');
    }
  }

  /// Implements retry logic for failed uploads
  /// Makes up to 5 attempts to upload the photo with 2-second delays between attempts
  /// [photo] The file path of the photo to retry uploading
  /// Returns NetworkResponse with final upload result
  Future<NetworkResponse<dynamic>> retryFailedUploads(String photo) async {
    int retryCount = 0;
    const maxRetries = 5;
    NetworkResponse<dynamic> lastResponse;

    while (retryCount < maxRetries) {
      try {
        log('Retry attempt ${retryCount + 1} for photo: ${photo.split('/').last}');
        lastResponse = await uploadPhoto(photo);

        if (lastResponse.status == Status.completed) {
          _queue.removeAt(0); // Remove successfully uploaded photo
          return lastResponse;
        }

        retryCount++;
        if (retryCount == maxRetries) {
          log('Max retries reached, moving photo to failed uploads');
          _failedUploads.add(photo);
          _queue.removeAt(0);
          return NetworkResponse.error('Failed after $maxRetries retry attempts');
        }

        await Future<void>.delayed(const Duration(seconds: 2)); // Wait before retrying
      } catch (e) {
        retryCount++;
        log('Retry attempt $retryCount failed: $e');

        if (retryCount == maxRetries) {
          _failedUploads.add(photo);
          _queue.removeAt(0);
          return NetworkResponse.error('Failed after $maxRetries retry attempts: $e');
        }
        await Future<void>.delayed(const Duration(seconds: 2));
      }
    }

    return NetworkResponse.error('Upload failed after all retry attempts');
  }

  /// Clears the list of failed uploads
  void clearFailedUploads() {
    _failedUploads.clear();
  }
}
