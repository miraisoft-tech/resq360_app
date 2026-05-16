import 'package:resq360/__lib.dart';
import 'package:resq360/features/chat/data/models/chat_models.dart';

class ChatCacheService {
  ChatCacheService._();
  static final ChatCacheService instance = ChatCacheService._();

  final Map<int, CachedChatData> _cache = {};

  static const Duration _cacheExpiry = Duration(minutes: 5);

  bool hasCachedData(int chatId) {
    final cached = _cache[chatId];
    if (cached == null) return false;

    final age = DateTime.now().difference(cached.cachedAt);
    if (age > _cacheExpiry) {
      _cache.remove(chatId);
      return false;
    }

    return true;
  }

  CachedChatData? getCachedData(int chatId) {
    if (!hasCachedData(chatId)) return null;
    return _cache[chatId];
  }

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

  void clearChat(int chatId) {
    _cache.remove(chatId);
  }

  
  void clearAll() {
    log('Clearing all chat cache data');
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
