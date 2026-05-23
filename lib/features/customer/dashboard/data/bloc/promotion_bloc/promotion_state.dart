part of 'promotion_bloc.dart';

abstract class PromotionState extends Equatable {
  const PromotionState();

  @override
  List<Object?> get props => [];
}

class PromotionInitial extends PromotionState {}

class PromotionLoading extends PromotionState {}

class PromotionsFetched extends PromotionState {
  const PromotionsFetched({required this.promotions});
  final List<Advertisement> promotions;

  @override
  List<Object?> get props => [promotions];
}

class ActivePromotionsFetched extends PromotionState {
  const ActivePromotionsFetched({required this.promotions});
  final List<Advertisement> promotions;

  @override
  List<Object?> get props => [promotions];
}

class PromotionPriceFetched extends PromotionState {
  const PromotionPriceFetched({required this.price});
  final int price;

  @override
  List<Object?> get props => [price];
}

class PromotionPaymentInitiated extends PromotionState {
  const PromotionPaymentInitiated(this.payment);
  final PaymentResponse payment;

  @override
  List<Object?> get props => [payment];
}

class PromotionPaymentVerifying extends PromotionState {}

class PromotionCreated extends PromotionState {}

class PromotionUpdated extends PromotionState {}

class PromotionDeleted extends PromotionState {}

class PromotionError extends PromotionState {
  const PromotionError({required this.error});
  final String error;

  @override
  List<Object?> get props => [error];
}
