// part of 'support_bloc.dart';

// sealed class SupportEvent extends Equatable {
//   const SupportEvent();

//   @override
//   List<Object?> get props => [];
// }

// class SubmitSupportTicket extends SupportEvent {

//   const SubmitSupportTicket({
//     required this.name,
//     required this.email,
//     required this.phone,
//     required this.subject,
//     required this.message,
//     this.category = 'GENERAL_INQUIRY',
//   });
//   final String name;
//   final String email;
//   final int phone;
//   final String subject;
//   final String message;
//   final String category;

//   @override
//   List<Object?> get props => [
//         name,
//         email,
//         phone,
//         subject,
//         message,
//         category,
//       ];
// }
