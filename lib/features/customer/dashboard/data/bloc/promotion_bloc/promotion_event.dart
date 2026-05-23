part of 'promotion_bloc.dart';

abstract class PromotionEvent extends Equatable {
  const PromotionEvent();

  @override
  List<Object?> get props => [];
}

class FetchMyPromotions extends PromotionEvent {}

class FetchActivePromotions extends PromotionEvent {
  const FetchActivePromotions(this.providerId);
  final int providerId;

  @override
  List<Object?> get props => [providerId];
}

class FetchPromotionPrice extends PromotionEvent {}

class CreatePromotion extends PromotionEvent {
  const CreatePromotion({
    required this.discountPercentage,
    required this.durationInMilliSeconds,
    required this.paymentMethod,
    required this.description,
    this.providerServiceId,
  });
  final int? providerServiceId;
  final int discountPercentage;
  final int durationInMilliSeconds;
  final String paymentMethod;
  final String description;

  @override
  List<Object?> get props => [
    providerServiceId,
    discountPercentage,
    durationInMilliSeconds,
    paymentMethod,
    description,
  ];
}

class VerifyPromotionPayment extends PromotionEvent {
  const VerifyPromotionPayment({required this.reference});
  final String reference;

  @override
  List<Object?> get props => [reference];
}

class UpdatePromotion extends PromotionEvent {
  const UpdatePromotion({
    required this.id,
    this.title,
    this.description,
    this.discountPercentage,
  });
  final int id;
  final String? title;
  final String? description;
  final int? discountPercentage;

  @override
  List<Object?> get props => [id, title, description, discountPercentage];
}

class DeletePromotion extends PromotionEvent {
  const DeletePromotion(this.id);
  final int id;

  @override
  List<Object?> get props => [id];
}
