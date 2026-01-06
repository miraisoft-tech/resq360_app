
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:resq360/__lib.dart';
import 'package:resq360/features/settings/data/models/ticket.model.dart';
import 'package:resq360/features/settings/data/models/ticket_message.model.dart';
import 'package:resq360/features/settings/data/service/support_service.dart';

part 'support_ticket_state.dart';


class SupportTicketState extends Equatable {

  const SupportTicketState({
    this.loading = false,
    this.sending = false,
    this.ticket,
    this.messages = const [],
    this.error,
  });
  final bool loading;
  final bool sending;
  final Ticket? ticket;
  final List<TicketMessage> messages;
  final String? error;

  bool get isClosed => ticket?.isClosed ?? false;

  SupportTicketState copyWith({
    bool? loading,
    bool? sending,
    Ticket? ticket,
    List<TicketMessage>? messages,
    String? error,
  }) {
    return SupportTicketState(
      loading: loading ?? this.loading,
      sending: sending ?? this.sending,
      ticket: ticket ?? this.ticket,
      messages: messages ?? this.messages,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
        loading,
        sending,
        ticket,
        messages,
        error,
      ];
}
