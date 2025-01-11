import 'dart:async';
import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../network/network.dart';
import '../repositories/upload_repository.dart';
import 'uploader_state.dart';

class UploaderCubit extends Cubit<UploaderState> {
  final UploadRepository _uploadRepository;

  final Connectivity _connectivity;
  StreamSubscription? _connectivitySubscription;

  UploaderCubit({
    required UploadRepository uploadRepository,
    Connectivity? connectivity,
  })  : _uploadRepository = uploadRepository,
        _connectivity = connectivity ?? Connectivity(),
        super(const UploaderState()) {
    _initConnectivity();
  }

  Future<void> _initConnectivity() async {
    // Check initial connectivity status
    final initialResult = await _connectivity.checkConnectivity();
    if (initialResult != ConnectivityResult.none) {
      emit(state.copyWith(connectionStatus: ConnectionStatus.connected));
    }

    // Listen for connectivity changes
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) async {
      if (results.contains(ConnectivityResult.wifi) || results.contains(ConnectivityResult.mobile)) {
        emit(state.copyWith(connectionStatus: ConnectionStatus.connected));
        if (state.queue.isNotEmpty) {
          await processQueue();
        }
      } else {
        emit(state.copyWith(connectionStatus: ConnectionStatus.disconnected));
      }
    });
  }

  Future<void> addPhotos(String photo) async {
    _uploadRepository.addToQueue(photo);

    final currentConnectivity = await _connectivity.checkConnectivity();
    final hasConnection = currentConnectivity != ConnectivityResult.none;

    emit(
      state.copyWith(
        queue: _uploadRepository.queue,
        isUploading: true,
        connectionStatus: hasConnection ? ConnectionStatus.uploading : ConnectionStatus.disconnected,
        totalPhotos: state.totalPhotos + 1, // Increment total photos
      ),
    );

    if (hasConnection) {
      await processQueue();
    }
  }

  Future<void> processQueue() async {
    if (!state.isUploading) return;

    emit(state.copyWith(connectionStatus: ConnectionStatus.uploading));

    try {
      final result = await _uploadRepository.processUploadQueue();

      if (result != null) {
        if (result.status == Status.completed) {
          // Successful upload
          emit(
            state.copyWith(
              queue: _uploadRepository.queue, // Get updated queue
              successfulUploads: state.successfulUploads + 1,
              isUploading: _uploadRepository.queue.isNotEmpty,
            ),
          );
          log('Successful upload - Updated count: ${state.successfulUploads + 1}');
        } else {
          // Failed upload
          emit(
            state.copyWith(
              queue: _uploadRepository.queue,
              failedUploads: _uploadRepository.failedUploads,
              isUploading: _uploadRepository.queue.isNotEmpty,
            ),
          );
        }
      }

      // Update connection status
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

  @override
  Future<void> close() {
    _connectivitySubscription?.cancel();
    return super.close();
  }
}
