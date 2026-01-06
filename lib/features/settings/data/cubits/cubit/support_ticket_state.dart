part of 'support_ticket_cubit.dart';



class SupportTicketCubit extends Cubit<SupportTicketState> {
  SupportTicketCubit(this._repo) : super(const SupportTicketState());

  final SupportRepo _repo;

  Future<void> loadTicket(String ticketId) async {
    emit(state.copyWith(loading: true, ));

    final res = await _repo.getTicketById(ticketId: ticketId);

    if (res.error!.isNotEmpty) {
      emit(state.copyWith(
        loading: false,
        error: res.error,
      ));
      return;
    }

    final ticket = Ticket.fromJson(res.data!['data'] as Map<String, dynamic>);

    emit(state.copyWith(
      loading: false,
      ticket: ticket,
      messages: ticket.messages,
    ));
  }

  Future<void> sendMessage(String text) async {
    if (state.ticket == null || state.isClosed) return;

    emit(state.copyWith(sending: true));

    final optimisticMessage = TicketMessage(
      id: -DateTime.now().millisecondsSinceEpoch,
      message: text,
      isFromUser: true,
      senderType: 'USER',
      senderName: 'You',
      ticketId: state.ticket!.id,
      createdAt: DateTime.now(),
      success: true,
    );

    final updatedMessages = [
      optimisticMessage,
      ...state.messages,
    ];

    emit(state.copyWith(messages: updatedMessages));

    final res = await _repo.sendTicketMessage(
      ticketId: state.ticket!.id.toString(),
      message: text,
    );

    if (res.error!.isNotEmpty) {
      emit(state.copyWith(
        sending: false,
        error: res.error,
      ));
      return;
    }

    final confirmed =
        TicketMessage.fromJson(res.data!);

    emit(state.copyWith(
      sending: false,
      messages: [
        confirmed,
        ...state.messages.where((m) => m.id != optimisticMessage.id),
      ],
    ));
  }

  Future<void> uploadAttachment(File file) async {
    if (state.ticket == null || state.isClosed) return;

    emit(state.copyWith(sending: true));

    final res = await _repo.uploadTicketAttachment(
      ticketId: state.ticket!.id.toString(),
      file: file,
    );

    if (res.error!.isEmpty) {
      emit(state.copyWith(
        sending: false,
        error: res.error,
      ));
      return;
    }

    emit(state.copyWith(sending: false));
  }


  void clearError() {
    emit(state.copyWith());
  }
}
