import 'package:flutter_bloc/flutter_bloc.dart';

import 'photo_taker_state.dart';

class PhotoTakerCubit extends Cubit<PhotoTakerState> {
  PhotoTakerCubit() : super(const PhotoTakerState());

  void addPhotos(String photo) {
    final updatedPhotos = List<String>.from(state.photos)..add(photo);
    emit(
      state.copyWith(
        photos: updatedPhotos,
        newPhoto: photo,
      ),
    );
  }

  void clearPhotos() {
    emit(state.copyWith(photos: []));
  }
}
