import 'package:equatable/equatable.dart';

class PhotoTakerState extends Equatable {
  final List<String> photos;
  final String? newPhoto;
  final String? error;
  final bool isCapturing;
  final bool isInitialized; //check if controller is initialized

  const PhotoTakerState({
    this.photos = const [],
    this.newPhoto,
    this.error,
    this.isCapturing = false,
    this.isInitialized = false,
  });

  PhotoTakerState copyWith({
    List<String>? photos,
    String? newPhoto,
    String? error,
    bool? isCapturing,
    bool? isInitialized,
  }) {
    return PhotoTakerState(
      photos: photos ?? this.photos,
      newPhoto: newPhoto ?? this.newPhoto,
      error: error ?? this.error,
      isCapturing: isCapturing ?? this.isCapturing,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }

  @override
  List<Object?> get props => [
        photos,
        newPhoto,
        error,
        isCapturing,
        isInitialized,
      ];
}
