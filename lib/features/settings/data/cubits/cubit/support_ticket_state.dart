part of 'support_ticket_cubit.dart';

class SupportTicketState {
  const SupportTicketState({
    this.ticket,
    this.messages = const [],
    this.loading = false,
    this.error,
    this.isClosed = false,
  });

  final Ticket? ticket;
  final List<TicketMessage> messages;
  final bool loading;
  final String? error;
  final bool isClosed;

  SupportTicketState copyWith({
    Ticket? ticket,
    List<TicketMessage>? messages,
    bool? loading,
    String? error,
    bool? isClosed,
  }) {
    return SupportTicketState(
      ticket: ticket ?? this.ticket,
      messages: messages ?? this.messages,
      loading: loading ?? this.loading,
      error: error ?? 'failed',
      isClosed: isClosed ?? this.isClosed,
    );
  }
}
