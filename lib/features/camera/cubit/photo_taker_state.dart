import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';

class PhotoTakerState extends Equatable {
  final List<String> photos;
  final String? newPhoto;
  final String? error;
  final bool isCapturing;
  final Position? currentLocation;

  const PhotoTakerState({
    this.photos = const [],
    this.newPhoto,
    this.error,
    this.isCapturing = false,
    this.currentLocation,
  });

  PhotoTakerState copyWith({
    List<String>? photos,
    String? newPhoto,
    String? error,
    bool? isCapturing,
    Position? currentLocation,
  }) {
    return PhotoTakerState(
      photos: photos ?? this.photos,
      newPhoto: newPhoto ?? this.newPhoto,
      error: error ?? this.error,
      isCapturing: isCapturing ?? this.isCapturing,
      currentLocation: currentLocation ?? this.currentLocation,
    );
  }

  @override
  List<Object?> get props => [
        photos,
        newPhoto,
        error,
        isCapturing,
        currentLocation,
      ];
}
