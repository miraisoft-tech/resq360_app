enum PromotionDuration {
  hours24(1),
  hours48(2),
  hours72(3),
  week1(7);

  const PromotionDuration(this.value);
  final int value;
}


extension PromotionDurationLabel on PromotionDuration {
  String get label {
    switch (this) {
      case PromotionDuration.hours24:
        return '24 hours';
      case PromotionDuration.hours48:
        return '48 hours';
      case PromotionDuration.hours72:
        return '72 hours';
      case PromotionDuration.week1:
        return '1 week';
    }
  }
}

extension PromotionDurationToMs on PromotionDuration {
  int get milliseconds => Duration(days: value).inMilliseconds;
}
