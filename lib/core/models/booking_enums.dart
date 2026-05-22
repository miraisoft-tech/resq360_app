enum BookingEnums {
  assigned('ASSIGNED'),
  arrived('ARRIVED'),
  progress('IN_PROGRESS'),
  completed('COMPLETED'),
  cancelled('CANCELLED');

  const BookingEnums(this.name);
  final String name;
}
