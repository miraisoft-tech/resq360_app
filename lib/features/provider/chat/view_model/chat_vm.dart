// import 'dart:async';
// import 'dart:async';
// import 'dart:convert';
// import 'dart:convert';
// import 'dart:io';
// import 'dart:io';

// import 'package:resq360/__lib.dart';
// import 'package:resq360/__lib.dart';
// import 'package:resq360/features/customer/chat/data/services/chat_repo.dart';
// import 'package:resq360/features/customer/chat/data/services/chat_repo.dart';
// import 'package:socket_io_client/socket_io_client.dart' as IO;

// final messagingViewModelProvider = ChangeNotifierProvider<MessagingViewModel>(
//   (ref) => MessagingViewModel(messagingRepo: ChatRepo(), ref: ref),
// );

// class MessagingViewModel extends ChangeNotifier {
//   MessagingViewModel({required this.messagingRepo, required this.ref});

//   final ChatRepo messagingRepo;
//   final Ref ref;

//   // Runtime flags
//   bool isLoading = false;
//   bool isConnected = false;
//   bool _isUploadingImage = false;

//   // Socket.io
//   IO.Socket? _socket;

//   // Active booking
//   String? _currentBookingId;

//   // Data stores
//   List<msg.MessageModel> _messages = [];
//   final Map<String, msg.MessageModel?> _lastMessages = {};

//   // Lists for chat summaries
//   List<BookingModel> _bookings = [];
//   List<BookingModel> _artisanBookings = [];

//   // Public getters
//   List<msg.MessageModel> get messages => _messages;
//   bool get connected => isConnected;
//   bool get isUploadingImage => _isUploadingImage;
//   Map<String, msg.MessageModel?> get lastMessages => _lastMessages;
//   List<BookingModel> get bookings => _bookings;
//   List<BookingModel> get artisanBookings => _artisanBookings;

//   // ---- UI helpers ----

//   void setBusy({required bool isBusy}) {
//     isLoading = isBusy;
//     notifyListeners();
//   }

//   msg.MessageModel? getLastMessageForBooking(int bookingId) {
//     return _lastMessages[bookingId.toString()];
//   }

//   String getLastMessageContent(int bookingId) {
//     final lastMessage = getLastMessageForBooking(bookingId);
//     if (lastMessage == null) return 'No messages yet';

//     switch (lastMessage.messageType?.toLowerCase()) {
//       case 'image':
//         return 'Image';
//       case 'file':
//         return 'File';
//       default:
//         return lastMessage.content ?? 'Message';
//     }
//   }

//   DateTime? getLastMessageTimestamp(int bookingId) {
//     return getLastMessageForBooking(bookingId)?.timestamp;
//   }

//   // ---- REST data ----

//   Future<void> fetchBookings() async {
//     setBusy(isBusy: true);
//     try {
//       final result = await messagingRepo.getCustomerChats();
//       if (result is List<BookingModel>) {
//         _bookings = result;
//         await fetchLastMessagesForBookings(_bookings);
//       } else {
//         showErrorSnackbar('${(result as ErrorResponse).message}');
//       }
//     } on Exception catch (e) {
//       showErrorSnackbar('Error fetching bookings: $e');
//     } finally {
//       setBusy(isBusy: false);
//     }
//   }

//   Future<void> fetchArtisanBookings() async {
//     setBusy(isBusy: true);
//     try {
//       final result = await messagingRepo.getArtisanChats();
//       if (result is List<BookingModel>) {
//         _artisanBookings = result;
//         await fetchLastMessagesForBookings(_artisanBookings);
//       } else {
//         showErrorSnackbar('${(result as ErrorResponse).message}');
//       }
//     } on Exception catch (e) {
//       showErrorSnackbar('Error fetching artisan bookings: $e');
//     } finally {
//       setBusy(isBusy: false);
//     }
//   }

//   Future<void> fetchChatMessages({required String bookingId}) async {
//     setBusy(isBusy: true);
//     try {
//       final result = await messagingRepo.getChatMessages(bookingId: bookingId);
//       _messages = result;
//       notifyListeners();
//     } on Exception catch (e) {
//       showErrorSnackbar('Error fetching messages: $e');
//     } finally {
//       setBusy(isBusy: false);
//     }
//   }

//   Future<void> fetchLastMessage({required String bookingId}) async {
//     try {
//       final result = await messagingRepo.getChatMessages(bookingId: bookingId);
//       _lastMessages[bookingId] = result.isNotEmpty ? result.last : null;
//       notifyListeners();
//     } on Exception catch (e) {
//       log('Error fetching last message for booking $bookingId: $e');
//       _lastMessages[bookingId] = null;
//     }
//   }

//   Future<void> fetchLastMessagesForBookings(List<BookingModel> bookings) async {
//     _lastMessages.clear();
//     final futures =
//         bookings.map((b) {
//           if (b.id != null) return fetchLastMessage(bookingId: b.id.toString());
//           return Future<void>.value();
//         }).toList();
//     await Future.wait(futures);
//   }

//   static const String _WS_URL = 'https://resq360-kspk.onrender.com';
//   static const String _NAMESPACE = '/chat';

//   void connectToChat(String bookingId, String userId) {
//     _currentBookingId = bookingId;
//     _connectSocket();
//   }

//   void _connectSocket() {
//     final token = ref.read(authProvider).authInfo?.token;
//     if (token == null || token.isEmpty) {
//       showErrorSnackbar('Missing auth token');
//       return;
//     }

//     // Dispose any old socket
//     _disposeSocket();

//     _socket = IO.io(
//       '$_WS_URL$_NAMESPACE',
//       IO.OptionBuilder()
//           .setTransports(['websocket', 'polling'])
//           .enableAutoConnect()
//           .enableReconnection()
//           .setReconnectionAttempts(5)
//           .setReconnectionDelay(1000)
//           .setReconnectionDelayMax(5000)
//           .setAuth({'token': token})
//           .build(),
//     );

//     _setupSocketListeners();
//     _socket?.connect();
//   }

//   void _setupSocketListeners() {
//     _socket?.onConnect((_) async {
//       isConnected = true;
//       notifyListeners();

//       final id = _currentBookingId;
//       if (id != null) {
//         await _joinBookingRoom(id);
//       }
//     });

//     _socket?.onDisconnect((_) {
//       isConnected = false;
//       notifyListeners();
//     });

//     _socket?.onConnectError((err) {
//       isConnected = false;
//       notifyListeners();
//       log('Connect error: $err');
//     });

//     _socket?.onError((err) {
//       log('Socket error: $err');
//     });

//     // Incoming message payloads should match server contract
//     _socket?.on('message', (data) {
//       try {
//         final parsed = (data is String) ? jsonDecode(data) : data;
//         final message = msg.MessageModel.fromJson(
//           parsed as Map<String, dynamic>,
//         );
//         _messages.add(message); //////////////////
//         // Update per-chat last message cache
//         final bId = _currentBookingId;
//         if (bId != null) _lastMessages[bId] = message;
//         notifyListeners();
//       } on Exception catch (e) {
//         log('Error parsing message: $e');
//       }
//     });

//     _socket?.on('chat-notification', (data) {
//       // Optional: surface toast or badge updates
//       log('chat-notification: $data');
//     });

//     _socket?.on('message-read', (data) {
//       log('message-read: $data');
//     });
//   }

//   Future<void> _joinBookingRoom(String bookingId) async {
//     if (!(_socket?.connected ?? false)) return;

//     final chatId = int.tryParse(bookingId) ?? bookingId;
//     final c = Completer<void>();
//     _socket?.emitWithAck(
//       'join-chat',
//       {'chatId': chatId},
//       ack: (_) {
//         c.complete();
//       },
//     );
//     await c.future;
//   }

//   Future<void> _leaveBookingRoom(String bookingId) async {
//     if (!(_socket?.connected ?? false)) return;

//     final chatId = int.tryParse(bookingId) ?? bookingId;
//     final c = Completer<void>();
//     _socket?.emitWithAck(
//       'leave-chat',
//       {'chatId': chatId},
//       ack: (_) {
//         c.complete();
//       },
//     );
//     await c.future;
//   }

//   void typing(bool isTyping) {
//     if (!(_socket?.connected ?? false)) return;
//     final id = _currentBookingId;
//     if (id == null) return;

//     final chatId = int.tryParse(id) ?? id;
//     _socket?.emit('typing', {'chatId': chatId, 'isTyping': isTyping});
//   }

//   void sendMessage(
//     String content,
//     String userId,
//     String userToken, {
//     MessageType messageType = MessageType.text,
//   }) {
//     final id = _currentBookingId;
//     if (content.trim().isEmpty || id == null) return;
//     if (!(_socket?.connected ?? false)) {
//       showErrorSnackbar('Not connected');
//       return;
//     }

//     final chatId = int.tryParse(id) ?? id;
//     final payload = {
//       'chatId': chatId,
//       'messageType': messageType.value,
//       'content': content.trim(),
//     };

//     _socket?.emitWithAck('send-message', payload, ack: (_) {});

//     // Optimistic update of last message and timeline
//     final tempMessage = msg.MessageModel(
//       id: DateTime.now().millisecondsSinceEpoch,
//       content: content.trim(),
//       messageType: messageType.value,
//       timestamp: DateTime.now(),
//       sender: msg.AppUserModel(
//         id: ref.read(authProvider).authInfo?.user?.id,
//         firstName: ref.read(authProvider).authInfo?.user?.firstName,
//         lastName: ref.read(authProvider).authInfo?.user?.lastName,
//       ),
//     );

//     _messages.add(tempMessage);
//     _lastMessages[id] = tempMessage;
//     notifyListeners();

//     // Refresh history from REST to ensure consistency
//     fetchChatMessages(bookingId: id);
//   }

//   Future<void> sendImageMessage(File imageFile) async {
//     final id = _currentBookingId;
//     if (id == null) return;

//     _isUploadingImage = true;
//     notifyListeners();

//     try {
//       final configRepo = ref.read(configProvider);
//       await configRepo.uploadRecordImages([imageFile]);

//       if (configRepo.uploadedImageUrls.isNotEmpty) {
//         final imageUrl = configRepo.uploadedImageUrls.first;
//         sendMessage(imageUrl, '', '', messageType: MessageType.image);
//         configRepo.clearUploadedImages();
//       } else {
//         log('Failed to upload image');
//       }
//     } on Exception catch (e) {
//       log('Error uploading image: $e');
//     } finally {
//       _isUploadingImage = false;
//       notifyListeners();
//     }
//   }

//   // ---- Lifecycle ----

//   void disconnect() {
//     final id = _currentBookingId;
//     if (id != null) {
//       _leaveBookingRoom(id);
//     }
//     _disposeSocket();
//     isConnected = false;
//     _currentBookingId = null;
//     _messages.clear();
//     notifyListeners();
//   }

//   void _disposeSocket() {
//     try {
//       _socket?.disconnect();
//       _socket?.dispose();
//     } catch (_) {}
//     _socket = null;
//   }

//   @override
//   void dispose() {
//     disconnect();
//     super.dispose();
//   }
// }
