enum BookingStatus {
  pending('PENDING'),
  completed('COMPLETED'),
  cancelled('CANCELLED'),
  inProgress('IN_PROGRESS'),
  matching('MATCHING'),
  assigned('ASSIGNED');

  const BookingStatus(this.value);
  final String value;
}
