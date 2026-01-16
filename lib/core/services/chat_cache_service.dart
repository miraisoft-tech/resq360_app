import 'package:resq360/features/customer/chat/data/models/chat/chat_response.dart';
import 'package:resq360/features/customer/chat/data/models/chat/message_response.dart';

/// A simple in-memory cache for chat data to avoid reloading on every screen visit.
/// Cache entries expire after [_cacheExpiry] duration.
class ChatCacheService {
  ChatCacheService._();
  static final ChatCacheService instance = ChatCacheService._();

  final Map<int, CachedChatData> _cache = {};

  /// Cache expiry duration - cached data older than this will be refreshed
  static const Duration _cacheExpiry = Duration(minutes: 5);

  /// Check if we have valid cached data for a chat
  bool hasCachedData(int chatId) {
    final cached = _cache[chatId];
    if (cached == null) return false;

    // Check if cache has expired
    final age = DateTime.now().difference(cached.cachedAt);
    if (age > _cacheExpiry) {
      _cache.remove(chatId);
      return false;
    }

    return true;
  }

  /// Get cached data for a chat
  CachedChatData? getCachedData(int chatId) {
    if (!hasCachedData(chatId)) return null;
    return _cache[chatId];
  }

  /// Store chat data in cache
  void cacheData({
    required int chatId,
    required ChatResponse chat,
    required List<MessageResponse> messages,
    required int currentPage,
    required int totalPages,
    required bool hasMoreMessages,
  }) {
    _cache[chatId] = CachedChatData(
      chat: chat,
      messages: messages,
      currentPage: currentPage,
      totalPages: totalPages,
      hasMoreMessages: hasMoreMessages,
      cachedAt: DateTime.now(),
    );
  }

  /// Update only the messages in cache (when new messages arrive)
  void updateMessages({
    required int chatId,
    required List<MessageResponse> messages,
    int? currentPage,
    int? totalPages,
    bool? hasMoreMessages,
  }) {
    final existing = _cache[chatId];
    if (existing == null) return;

    _cache[chatId] = CachedChatData(
      chat: existing.chat,
      messages: messages,
      currentPage: currentPage ?? existing.currentPage,
      totalPages: totalPages ?? existing.totalPages,
      hasMoreMessages: hasMoreMessages ?? existing.hasMoreMessages,
      cachedAt: DateTime.now(),
    );
  }

  /// Clear cache for a specific chat
  void clearChat(int chatId) {
    _cache.remove(chatId);
  }

  /// Clear all cached data
  void clearAll() {
    _cache.clear();
  }
}

class CachedChatData {
  const CachedChatData({
    required this.chat,
    required this.messages,
    required this.currentPage,
    required this.totalPages,
    required this.hasMoreMessages,
    required this.cachedAt,
  });

  final ChatResponse chat;
  final List<MessageResponse> messages;
  final int currentPage;
  final int totalPages;
  final bool hasMoreMessages;
  final DateTime cachedAt;
}
