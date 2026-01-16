/// Enum for message types in chat
enum MessageReceivedType {
  invoice('INVOICE'),
  system('SYSTEM'),
  text('TEXT');

  const MessageReceivedType(this.value);

  final String value;
}
