import 'package:dio/dio.dart';
import 'package:resq360/core/models/api_response.dart';
import 'package:resq360/core/services/base_api.dart';
import 'package:resq360/features/settings/data/models/ticket.model.dart';

class SupportRepo extends BaseAPI {
  factory SupportRepo() => instance;
  SupportRepo._internal();
  static final SupportRepo instance = SupportRepo._internal();

  Future<ApiResult<int>> fileDispute({
  required int requestId,
  String? reason,
  String? details,
}) async {
  const endpoint = '/requests/dispute';

  try {
    final res = await dio().post<Map<String, dynamic>>(
      endpoint,
      data: {
        'requestId': requestId,
        if (reason != null) 'reason': reason,
        if (details != null) 'details': details,
      },
    );

    if (res.statusCode == 201 && res.data != null) {
      final chatId = res.data!['data']?['chatId'] as int?;
      if (chatId == null) return ApiResult(error: 'No chatId in response');
      return ApiResult(data: chatId);
    }

    return ApiResult(
      error: res.data?['message'] as String? ?? 'Failed to file dispute',
    );
  } on DioException catch (e) {
    return handleDioError(e);
  }
}

  Future<ApiResult<Map<String, dynamic>>> createTicket({
    required String subject,
    required String description,
    required String category, 
    required String priority, 
    String? contactEmail,
    String? contactPhone,
    int? serviceCategory,
    int? relatedServiceProviderId,
  }) async {
    const endpoint = '/support/tickets';

    final data = {
      'subject': subject,
      'description': description,
      'category': category,
      'priority': priority,
      if (contactEmail != null) 'contactEmail': contactEmail,
      if (contactPhone != null) 'contactPhone': contactPhone,
      if (serviceCategory != null) 'serviceCategory': serviceCategory,
      if (relatedServiceProviderId != null)
        'relatedServiceProviderId': relatedServiceProviderId,
    };

    try {
      final res = await dio().post<Map<String, dynamic>>(
        endpoint,
        data: data,
      );

      if (res.statusCode == 201 && res.data != null) {
        return ApiResult(data: res.data);
      }

      return ApiResult(
        error: res.data?['message'] as String? ?? 'Failed to create ticket',
      );
    } on DioException catch (e) {
      return handleDioError(e);
    }
  }

  Future<ApiResult<List<Ticket>>> getTickets() async {
    const endpoint = '/support/tickets';

    try {
      final res = await dio().get<Map<String, dynamic>>(endpoint);

      if (res.statusCode == 200 && res.data != null) {
         final ticketsJson = res.data!['data']?['tickets'] as List<dynamic>?;

      if (ticketsJson == null) {
        return ApiResult(error: 'No tickets found');
      }

      final tickets = ticketsJson
          .map((e) => Ticket.fromJson(e as Map<String, dynamic>))
          .toList();
        return ApiResult(data: tickets);
      }

      return ApiResult(
        error: res.data?['message'] as String? ?? 'Failed to fetch tickets',
      );
    } on DioException catch (e) {
      return handleDioError(e);
    }
  }

  Future<ApiResult<Map<String, dynamic>>> getTicketById({
    required String ticketId,
  }) async {
    final endpoint = '/support/tickets/$ticketId';

    try {
      final res = await dio().get<Map<String, dynamic>>(endpoint);

      if (res.statusCode == 200 && res.data != null) {
        return ApiResult(data: res.data);
      }

      return ApiResult(
        error: res.data?['message']as String? ?? 'Failed to fetch ticket',
      );
    } on DioException catch (e) {
      return handleDioError(e);
    }
  }
  

  Future<ApiResult<Map<String, dynamic>>> sendTicketMessage({
    required String ticketId,
    required String message,
  }) async {
    final endpoint = '/support/tickets/$ticketId/messages';

    try {
      final res = await dio().post<Map<String, dynamic>>(
        endpoint,
        data: {'message': message},
      );

      if (res.statusCode == 201 && res.data != null) {
        return ApiResult(data: res.data);
      }

      return ApiResult(
        error: res.data?['message']as String?  ?? 'Failed to send message',
      );
    } on DioException catch (e) {
      return handleDioError(e);
    }
  }

  Future<ApiResult<Map<String, dynamic>>> uploadTicketAttachment({
    required String ticketId,
    required File file,
  }) async {
    final endpoint = '/support/tickets/$ticketId/attachments';

    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path),
    });

    try {
      final res = await dio().post<Map<String, dynamic>>(
        endpoint,
        data: formData,
      );

      if (res.statusCode == 201 && res.data != null) {
        return ApiResult(data: res.data);
      }

      return ApiResult(
        error: res.data?['message']as String? ?? 'Failed to upload attachment',
      );
    } on DioException catch (e) {
      return handleDioError(e);
    }
  }


  Future<ApiResult<Map<String, dynamic>>> updateTicket({
    required String ticketId,
    required String subject,
    required String description,
    required String category,
    required String priority,
  }) async {
    final endpoint = '/support/tickets/$ticketId';

    final data = {
      'subject': subject,
      'description': description,
      'category': category,
      'priority': priority,
    };

    try {
      final res = await dio().patch<Map<String, dynamic>>(
        endpoint,
        data: data,
      );

      if (res.statusCode == 200 && res.data != null) {
        return ApiResult(data: res.data);
      }

      return ApiResult(
        error: res.data?['message']as String?  ?? 'Failed to update ticket',
      );
    } on DioException catch (e) {
      return handleDioError(e);
    }
  }

  Future<String?> findExistingOpenAppealTicketId() async {
  final res = await SupportRepo.instance.getTickets();

  if (res.error != null && res.error!.isNotEmpty) {
    return null;
  }

  final tickets = res.data;
  if (tickets == null || tickets.isEmpty) return null;

  for (final ticket in tickets) {
    final isOpen = ticket.status == 'OPEN';
    final isAppeal = ticket.subject == 'Service Appeal';
    final isGeneralInquiry = ticket.category == 'GENERAL_INQUIRY';

    if (isOpen && isAppeal && isGeneralInquiry) {
      return ticket.ticketId;
    }
  }

  return null;
}
}
