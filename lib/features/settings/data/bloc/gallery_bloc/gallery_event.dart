part of 'gallery_bloc.dart';

sealed class GalleryEvent extends Equatable {
  const GalleryEvent();

  @override
  List<Object?> get props => [];
}

final class FetchAllGalleryItems extends GalleryEvent {
  const FetchAllGalleryItems();
}

final class FetchAGalleryItem extends GalleryEvent {
  const FetchAGalleryItem(this.id);
  final int id;

  @override
  List<Object?> get props => [id];
}

final class UpdateAGalleryItem extends GalleryEvent {
  const UpdateAGalleryItem({
    required this.galleryItemId,
    this.caption,
    this.displayOrder,
  });
  final String galleryItemId;
  final String? caption;
  final String? displayOrder;

  @override
  List<Object?> get props => [galleryItemId, caption, displayOrder];
}
class UpdateServiceEvent extends GalleryEvent {

  const UpdateServiceEvent({
    required this.caption,
    required this.images,
  });
  final String caption;
  final List<File> images;
}

final class DeleteAGalleryItem extends GalleryEvent {
  const DeleteAGalleryItem(this.galleryItemId);
  final String galleryItemId;

  @override
  List<Object?> get props => [galleryItemId];
}
