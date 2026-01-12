enum MessageReceivedType {
  invoice('INVOICE'),
  system('SYSTEM'),
  text('TEXT');

  const MessageReceivedType(this.value);

  final String value;
}
