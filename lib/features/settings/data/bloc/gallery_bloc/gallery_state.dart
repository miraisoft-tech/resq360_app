part of 'gallery_bloc.dart';

sealed class GalleryState extends Equatable {
  const GalleryState();

  @override
  List<Object?> get props => [];
}

final class GalleryInitial extends GalleryState {}

final class GalleryLoading extends GalleryState {}

final class GalleryItemsFetched extends GalleryState {
  const GalleryItemsFetched({required this.gallery});
  final List<Gallery> gallery;

  @override
  List<Object?> get props => [gallery];
}

final class GalleryItemFetched extends GalleryState {
  const GalleryItemFetched({required this.gallery});
  final Gallery gallery;

  @override
  List<Object?> get props => [gallery];
}

final class GalleryItemCreated extends GalleryState {}

final class GalleryItemUpdated extends GalleryState {}

final class GalleryItemDeleted extends GalleryState {}

final class GalleryError extends GalleryState {
  const GalleryError({required this.message});
  final String message;

  @override
  List<Object?> get props => [message];
}
