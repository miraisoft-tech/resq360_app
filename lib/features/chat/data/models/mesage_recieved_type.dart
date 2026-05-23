enum MessageReceivedType {
  text('TEXT'),
  image('IMAGE'),
  document('DOCUMENT'),
  location('LOCATION'),
  invoice('INVOICE');

  const MessageReceivedType(this.value);
  final String value;
}
