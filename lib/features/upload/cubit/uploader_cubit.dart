import 'dart:async';
import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../network/network.dart';
import '../repositories/upload_repository.dart';
import 'uploader_state.dart';

/// A Cubit that manages the state of photo uploads and network connectivity.
/// Handles queuing of photos, processing uploads, and monitoring network status.
class UploaderCubit extends Cubit<UploaderState> {
  // Repository responsible for handling upload operations
  final UploadRepository _uploadRepository;

  // Service to monitor network connectivity status
  final Connectivity _connectivity;

  // Subscription to connectivity changes stream
  StreamSubscription<dynamic>? _connectivitySubscription;

  /// Creates a new UploaderCubit instance.
  ///
  /// Parameters:
  /// - uploadRepository: Required repository for managing uploads
  /// - connectivity: Optional connectivity service (will create new instance if not provided)
  UploaderCubit({
    required UploadRepository uploadRepository,
    Connectivity? connectivity,
  })  : _uploadRepository = uploadRepository,
        _connectivity = connectivity ?? Connectivity(),
        super(const UploaderState()) {
    _initConnectivity();
  }

  /// Initializes connectivity monitoring and sets up listeners for network changes.
  /// Called automatically when the Cubit is created.
  Future<void> _initConnectivity() async {
    // Check initial connectivity status
    final initialResult = await _connectivity.checkConnectivity();
    if (initialResult != [ConnectivityResult.none]) {
      emit(state.copyWith(connectionStatus: ConnectionStatus.connected));
    }

    // Set up listener for future connectivity changes
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) async {
      // Check if device has either WiFi or mobile data connection
      if (results.contains(ConnectivityResult.wifi) || results.contains(ConnectivityResult.mobile)) {
        emit(state.copyWith(connectionStatus: ConnectionStatus.connected));
        // If there are pending uploads, process them when connection is restored
        if (state.queue.isNotEmpty) {
          await processQueue();
        }
      } else {
        // Update state to reflect disconnected status
        emit(state.copyWith(connectionStatus: ConnectionStatus.disconnected));
      }
    });
  }

  /// Adds new photos to the upload queue and initiates processing if connected.
  ///
  /// Parameters:
  /// - photo: String identifier or path of the photo to be uploaded
  Future<void> addPhoto(String photo) async {
    // Add photo to the repository's queue
    _uploadRepository.addToQueue(photo);

    // Check current connectivity status
    final currentConnectivity = await _connectivity.checkConnectivity();
    final hasConnection = currentConnectivity != [ConnectivityResult.none];

    // Update state with new queue info and connection status
    emit(
      state.copyWith(
        queue: _uploadRepository.queue,
        isUploading: true,
        connectionStatus: hasConnection ? ConnectionStatus.uploading : ConnectionStatus.disconnected,
        totalPhotos: state.totalPhotos + 1, // Track total number of photos added
      ),
    );

    // If connected, begin processing the queue
    if (hasConnection) {
      await processQueue();
    }
  }

  /// Processes the upload queue, handling both successful and failed uploads.
  /// Updates state accordingly and manages connection status throughout the process.
  Future<void> processQueue() async {
    // Guard clause: exit if not currently uploading
    if (!state.isUploading) return;

    emit(state.copyWith(connectionStatus: ConnectionStatus.uploading));

    try {
      // Continue processing while there are items in the queue
      while (_uploadRepository.queue.isNotEmpty && state.isUploading) {
        final result = await _uploadRepository.processUploadQueue();

        if (result.response.status == Status.completed) {
          emit(
            state.copyWith(
              queue: _uploadRepository.queue,
              successfulUploads: state.successfulUploads + result.successCount,
              isUploading: _uploadRepository.queue.isNotEmpty,
            ),
          );
          log('Successful uploads - Updated count: ${state.successfulUploads + result.successCount}');
        } else {
          emit(
            state.copyWith(
              queue: _uploadRepository.queue,
              failedUploads: _uploadRepository.failedUploads,
              isUploading: _uploadRepository.queue.isNotEmpty,
            ),
          );
          // Break the loop if upload failed
          break;
        }
      }

      // Update connection status based on queue state
      emit(
        state.copyWith(
          connectionStatus: _uploadRepository.queue.isEmpty ? ConnectionStatus.connected : ConnectionStatus.uploading,
        ),
      );
    } catch (e) {
      log('Process queue error: $e');
      emit(
        state.copyWith(
          connectionStatus: ConnectionStatus.connected,
          isUploading: _uploadRepository.queue.isNotEmpty,
        ),
      );
    }
  }

  /// Cleanup method to cancel connectivity subscription when Cubit is closed.
  @override
  Future<void> close() {
    _connectivitySubscription?.cancel();
    return super.close();
  }
}
