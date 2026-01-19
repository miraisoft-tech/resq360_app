enum BookingEnums {
  assigned('ASSIGNED'),
  progress('IN_PROGRESS'),
  completed('COMPLETED'),
  cancelled('CANCELLED');

  const BookingEnums(this.name);
  final String name;
}
