import 'package:equatable/equatable.dart';

class PhotoTakerState extends Equatable {
  final List<String> photos;
  final String? newPhoto;

  const PhotoTakerState({
    this.photos = const [],
    this.newPhoto,
  });

  PhotoTakerState copyWith({
    List<String>? photos,
    String? newPhoto,
  }) {
    return PhotoTakerState(
      photos: photos ?? this.photos,
      newPhoto: newPhoto ?? this.newPhoto,
    );
  }

  @override
  List<Object?> get props => [
        photos,
        newPhoto,
      ];
}
