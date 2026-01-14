enum BookingStatus {
  upcoming('upcoming'),
  ongoing('ongoing'),
  completed('completed'),
  cancelled('cancelled'),
  inProgress('IN_PROGRESS'),
  matching('MATCHING'),
  assigned('ASSIGNED');

  const BookingStatus(this.value);
  final String value;
}
