
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:resq360/__lib.dart';
import 'package:resq360/features/settings/data/models/ticket.model.dart';
import 'package:resq360/features/settings/data/models/ticket_message.model.dart';
import 'package:resq360/features/settings/data/service/support_service.dart';

part 'support_ticket_state.dart';

class SupportTicketCubit extends Cubit<SupportTicketState> {
  SupportTicketCubit(this._supportRepo) : super(const SupportTicketState());

  final SupportRepo _supportRepo;
  String? _currentTicketId;

  Future<void> loadTicket(String ticketId) async {
    _currentTicketId = ticketId;
    emit(state.copyWith(loading: true));

    try {
      final result = await _supportRepo.getTicketById(ticketId: ticketId);

      if (result.error != null) {
        emit(state.copyWith(
          loading: false,
          error: result.error,
        ));
        return;
      }

      if (result.data == null) {
        emit(state.copyWith(
          loading: false,
          error: 'No ticket data found',
        ));
        return;
      }

      final ticketData = result.data!['data']?['ticket'] as Map<String, dynamic>?;
      
      if (ticketData == null) {
        emit(state.copyWith(
          loading: false,
          error: 'Invalid ticket data',
        ));
        return;
      }

      final ticket = Ticket.fromJson(ticketData);
      

      final messagesJson = ticketData['messages'] as List<dynamic>? ?? [];
      final messages = messagesJson
          .map((e) => TicketMessage.fromJson(e as Map<String, dynamic>))
          .toList()
          .reversed
          .toList();

      emit(state.copyWith(
        ticket: ticket,
        messages: messages,
        loading: false,
        isClosed: ticket.status == 'closed' || ticket.status == 'CLOSED',
      ));
    } on Exception catch (e) {
      emit(state.copyWith(
        loading: false,
        error: 'Failed to load ticket: $e',
      ));
    }
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty || _currentTicketId == null) return;


    final localMessage = TicketMessage.local(
      message: text.trim(),
      senderName: 'You',
    );

    final updatedMessages = [localMessage, ...state.messages];
    emit(state.copyWith(messages: updatedMessages));

    try {
      final result = await _supportRepo.sendTicketMessage(
        ticketId: _currentTicketId!,
        message: text.trim(),
      );

      if (result.error != null) {
        final failedMessages = state.messages.map((msg) {
          if (msg.localId == localMessage.localId) {
            return msg.copyWith(status: MessageStatus.failed);
          }
          return msg;
        }).toList();

        emit(state.copyWith(
          messages: failedMessages,
          error: result.error,
        ));
        return;
      }

      
      final messageData = result.data?['data']?['message'] as Map<String, dynamic>?;
      
      if (messageData == null) {
        final failedMessages = state.messages.map((msg) {
          if (msg.localId == localMessage.localId) {
            return msg.copyWith(status: MessageStatus.failed);
          }
          return msg;
        }).toList();

        emit(state.copyWith(
          messages: failedMessages,
          error: 'Failed to send message',
        ));
        return;
      }

      final sentMessage = TicketMessage.fromJson(messageData);

 
      final finalMessages = state.messages.map((msg) {
        if (msg.localId == localMessage.localId) {
          return sentMessage;
        }
        return msg;
      }).toList();

      emit(state.copyWith(messages: finalMessages));
    } on Exception catch (e) {
      
      final failedMessages = state.messages.map((msg) {
        if (msg.localId == localMessage.localId) {
          return msg.copyWith(status: MessageStatus.failed);
        }
        return msg;
      }).toList();

      emit(state.copyWith(
        messages: failedMessages,
        error: 'Failed to send message: $e',
      ));
    }
  }

  Future<void> retryMessage(TicketMessage failedMessage) async {
    if (failedMessage.status != MessageStatus.failed || _currentTicketId == null) {
      return;
    }

   
    final updatedMessages = state.messages.map((msg) {
      if (msg.localId == failedMessage.localId) {
        return msg.copyWith(status: MessageStatus.sending);
      }
      return msg;
    }).toList();

    emit(state.copyWith(messages: updatedMessages));

    try {
      final result = await _supportRepo.sendTicketMessage(
        ticketId: _currentTicketId!,
        message: failedMessage.message,
      );

      if (result.error != null) {
        final failedMessages = state.messages.map((msg) {
          if (msg.localId == failedMessage.localId) {
            return msg.copyWith(status: MessageStatus.failed);
          }
          return msg;
        }).toList();

        emit(state.copyWith(
          messages: failedMessages,
          error: result.error,
        ));
        return;
      }

      final messageData = result.data?['data']?['message'] as Map<String, dynamic>?;
      
      if (messageData == null) {
        final failedMessages = state.messages.map((msg) {
          if (msg.localId == failedMessage.localId) {
            return msg.copyWith(status: MessageStatus.failed);
          }
          return msg;
        }).toList();

        emit(state.copyWith(
          messages: failedMessages,
          error: 'Failed to retry message',
        ));
        return;
      }

      final sentMessage = TicketMessage.fromJson(messageData);

     
      final finalMessages = state.messages.map((msg) {
        if (msg.localId == failedMessage.localId) {
          return sentMessage;
        }
        return msg;
      }).toList();

      emit(state.copyWith(messages: finalMessages));
    } on Exception catch (e) {
      final failedMessages = state.messages.map((msg) {
        if (msg.localId == failedMessage.localId) {
          return msg.copyWith(status: MessageStatus.failed);
        }
        return msg;
      }).toList();

      emit(state.copyWith(
        messages: failedMessages,
        error: 'Failed to retry message: $e',
      ));
    }
  }

  void deleteFailedMessage(TicketMessage message) {
    final updatedMessages = state.messages
        .where((msg) => msg.localId != message.localId)
        .toList();
    emit(state.copyWith(messages: updatedMessages));
  }

  void clearError() {
    emit(state.copyWith());
  }
}
