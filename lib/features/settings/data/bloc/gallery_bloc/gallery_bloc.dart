import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:resq360/__lib.dart';
import 'package:resq360/core/services/auth.local.repo.dart';
import 'package:resq360/features/settings/data/models/gallery.model.dart';
import 'package:resq360/features/settings/data/service/gallery_service.dart';

part 'gallery_event.dart';
part 'gallery_state.dart';

class GalleryBloc extends Bloc<GalleryEvent, GalleryState> {
  GalleryBloc() : super(GalleryInitial()) {
    on<FetchAllGalleryItems>(_onFetchAllGalleryItems);
    on<FetchAGalleryItem>(_onFetchAGalleryItem);
    on<UpdateAGalleryItem>(_onUpdateAGalleryItem);
    on<DeleteAGalleryItem>(_onDeleteAGalleryItem);
    on<UpdateServiceEvent>(_onCreateGallery);
  }
  final GalleryRepo galleryRepo = GalleryRepo();

  Future<void> _onFetchAllGalleryItems(
    FetchAllGalleryItems event,
    Emitter<GalleryState> emit,
  ) async {
    emit(GalleryLoading());
    try {
      final result = await galleryRepo.fetchAllGalleryItemsForAprovider();

      if (result.data != null) {
        emit(GalleryItemsFetched(gallery: result.data!));
      } else {
        emit(
          GalleryError(message: result.error ?? 'Unexpected error occurred.'),
        );
      }
    } on Exception catch (e, s) {
      log('FetchAll Error: $e \n$s');
      emit(GalleryError(message: e.toString()));
    }
  }

  Future<void> _onFetchAGalleryItem(
    FetchAGalleryItem event,
    Emitter<GalleryState> emit,
  ) async {
    emit(GalleryLoading());
    try {
      final result = await galleryRepo.fetchAGalleryItem(event.id);

      if (result.data != null) {
        emit(GalleryItemFetched(gallery: result.data!));
      } else {
        emit(
          GalleryError(message: result.error ?? 'Unexpected error occurred.'),
        );
      }
    } on Exception catch (e, s) {
      log('FetchOne Error: $e \n$s');
      emit(GalleryError(message: e.toString()));
    }
  }

  Future<void> _onUpdateAGalleryItem(
    UpdateAGalleryItem event,
    Emitter<GalleryState> emit,
  ) async {
    emit(GalleryLoading());
    try {
      final result = await galleryRepo.updateAgalleryItem(
        galleryitemID: event.galleryItemId,
        caption: event.caption,
        displayOrder: event.displayOrder,
      );

      if (result.data != null) {
        emit(GalleryItemUpdated());
        add(const FetchAllGalleryItems());
      } else {
        emit(
          GalleryError(message: result.error ?? 'Unexpected error occurred.'),
        );
      }
    } on Exception catch (e, s) {
      log('Update Error: $e \n$s');
      emit(GalleryError(message: e.toString()));
    }
  }

  Future<void> _onCreateGallery(
    UpdateServiceEvent event,
    Emitter<GalleryState> emit,
  ) async {
    emit(GalleryLoading());

    try {
      final provider =
          await AuthLocalRepo.instance.getProviderAuthCredentials();
      if (provider == null) {
        emit(const GalleryError(message: 'no Provider found'));
        return;
      }

      final uploadResult = await uploadService.uploadMultiple(
        files: event.images,
      );

      if (uploadResult.error != null) {
        emit(GalleryError(message: uploadResult.error!));
        return;
      }

      final uploads = uploadResult.data ?? [];
      if (uploads.isEmpty) {
        emit(const GalleryError(message: 'no images were uploaded'));
        return;
      }

      /// 3. Create gallery items (ONE call per image)
      for (var i = 0; i < uploads.length; i++) {
        final upload = uploads[i];

        final result = await galleryRepo.createNewGalleryItem(
          providerId: provider.id!,
          imageUrl: upload.url,
          imageId: upload.id,
          caption: event.caption,
          displayOrder: i,
        );

        if (result.error != null) {
          emit(GalleryError(message: result.error!));

          return;
        }
      }

      emit(GalleryItemCreated());
    } on Exception catch (e, s) {
      log('Create gallery failed: $e');
      log('Stacktrace: $s');
      emit(GalleryError(message: e.toString()));
    }
  }

  Future<void> _onDeleteAGalleryItem(
    DeleteAGalleryItem event,
    Emitter<GalleryState> emit,
  ) async {
    emit(GalleryLoading());
    try {
      final result = await galleryRepo.deleteAgalleryItem(
        galleryitemID: event.galleryItemId,
      );

      if (result.data != null) {
        emit(GalleryItemDeleted());
        add(const FetchAllGalleryItems()); // Optional refresh
      } else {
        emit(
          GalleryError(message: result.error ?? 'Unexpected error occurred.'),
        );
      }
    } on Exception catch (e, s) {
      log('Delete Error: $e \n$s');
      emit(GalleryError(message: e.toString()));
    }
  }
}
