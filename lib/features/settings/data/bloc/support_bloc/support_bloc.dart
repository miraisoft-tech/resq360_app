// import 'package:bloc/bloc.dart';
// import 'package:equatable/equatable.dart';
// import 'package:resq360/features/settings/data/service/support_service.dart';

// part 'support_event.dart';
// part 'support_state.dart';


// class SupportBloc extends Bloc<SupportEvent, SupportState> {
//   SupportBloc(this._repo) : super(SupportInitial()) {
//     on<SubmitSupportTicket>(_onSubmitSupport);
//   }

//   final SupportRepo _repo;

//   Future<void> _onSubmitSupport(
//     SubmitSupportTicket event,
//     Emitter<SupportState> emit,
//   ) async {
//     emit(SupportLoading());

//     final result = await _repo.contactSuport(
//       name: event.name,
//       email: event.email,
//       phone: event.phone,
//       subject: event.subject,
//       message: event.message,
//       category: event.category,
//     );

//     if (result.data != null) {
//       emit(
//         SupportSuccess(
//           ticketId: result.data!['ticketId'] as String,
//           message: result.data!['message'] as String,
//         ),
//       );
//     } else {
//       emit(SupportError(result.error ?? 'Failed to submit support request'));
//     }
//   }
// }
