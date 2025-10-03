import 'package:resq360/core/models/api_response.dart';

class Booking extends EmptyResponse {
  Booking({
    this.service,
    this.category,
    this.amount,
    this.date,
    this.start,
    this.end,
  });

  factory Booking.fromMap(Map<String, dynamic> map) {
    return Booking(
      service: map['service'] as String,
      category: map['category'] as String?,
      amount: map['amount'] as String?,
      date: map['date'] as String?,
      start: map['start'] as String?,
      end: map['end'] as String?,
    );
  }

  final String? service;
  final String? category;
  final String? amount;
  final String? date;
  final String? start;
  final String? end;

  Map<String, dynamic> toMap() {
    return {
      'service': service,
      'category': category,
      'amount': amount,
      'date': date,
      'start': start,
      'end': end,
    };
  }
}
