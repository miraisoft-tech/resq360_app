enum KycEnums {
  pending('PENDING'),
  approved('APPROVED'),
  rejected('REJECTED');

  const KycEnums(this.name);
  final String name;
}
