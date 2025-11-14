
class Metadata {
  Metadata();
  
// This constructor intentionally keeps parameters for future metadata expansion.
  // ignore: avoid_unused_constructor_parameters
  factory Metadata.fromJson(Map<String, dynamic> json) => Metadata();

  Map<String, dynamic> toJson() => {};
}
