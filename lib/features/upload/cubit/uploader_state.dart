import 'package:equatable/equatable.dart';

enum ConnectionStatus { connected, disconnected, uploading }

extension ConnectionStatusText on ConnectionStatus {
  String getStatusText() => switch (this) {
    ConnectionStatus.connected => 'Connected',
    ConnectionStatus.disconnected => 'No Internet',
    ConnectionStatus.uploading => 'Uploading...',
  };
}
class UploaderState extends Equatable {
  final List<String> queue;
  final List<String> failedUploads;
  final bool isUploading;
  final ConnectionStatus connectionStatus;
  final int totalPhotos;
  final int successfulUploads;

  const UploaderState({
    this.queue = const [],
    this.failedUploads = const [],
    this.isUploading = false,
    this.connectionStatus = ConnectionStatus.disconnected,
    this.totalPhotos = 0,
    this.successfulUploads = 0,
  });

  UploaderState copyWith({
    List<String>? queue,
    List<String>? failedUploads,
    bool? isUploading,
    ConnectionStatus? connectionStatus,
    int? totalPhotos,
    int? successfulUploads,
  }) {
    return UploaderState(
      queue: queue ?? this.queue,
      failedUploads: failedUploads ?? this.failedUploads,
      isUploading: isUploading ?? this.isUploading,
      connectionStatus: connectionStatus ?? this.connectionStatus,
      totalPhotos: totalPhotos ?? this.totalPhotos,
      successfulUploads: successfulUploads ?? this.successfulUploads,
    );
  }

  @override
  List<Object?> get props => [
        queue,
        failedUploads,
        isUploading,
        connectionStatus,
        totalPhotos,
        successfulUploads,
      ];
}
