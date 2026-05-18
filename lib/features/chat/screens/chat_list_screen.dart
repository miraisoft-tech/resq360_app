import 'package:resq360/__lib.dart';
import 'package:resq360/core/models/chat_summary.dart';
import 'package:resq360/core/utils/app_text.util.dart';
import 'package:resq360/features/chat/bloc/chat_list_bloc/chat_list_bloc.dart';
import 'package:resq360/features/chat/data/models/chat_models.dart';
import 'package:resq360/features/chat/screens/chat_details_screen.dart';
import 'package:resq360/features/intro/models/user_type.emum.dart';
import 'package:resq360/features/widgets/chat_tile.dart';
import 'package:resq360/features/widgets/empty_screen_widget.dart';
import 'package:resq360/features/widgets/inputs/filter_search_field.dart';

/// Unified chat list screen for both customer and provider users.
class ChatListScreen extends StatefulWidget {
  const ChatListScreen({required this.userType, super.key});

  final UserType userType;

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String selectedFilter = 'All';

  bool get isCustomer => widget.userType == UserType.customer;
  bool get isProvider => widget.userType == UserType.provider;

  @override
  void initState() {
    super.initState();
    context.read<ChatListBloc>().add(LoadChatList());
  }

  Future<void> _onRefresh() async {
    context.read<ChatListBloc>().add(RefreshChatList());
  }

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    final filters = ['All', 'Unread', 'Appeal'];

    return Scaffold(
      backgroundColor: appColors.whiteColor,

      body: SafeArea(
        child: Padding(
          padding: pad(horizontal: 16),
          child: RefreshIndicator(
            color: appColors.primary,
            onRefresh: _onRefresh,
            child: Col(
              children: [
                UrbText(
                  'Chats',
                  size: 20,
                  height: 28,
                  weight: FontWeight.w700,
                  color: appColors.black,
                ),
                10.verticalSpace,
                FilterSearchFormField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  prefixIconPath: AppAssets.ASSETS_ICONS_SEARCH_SVG,
                  hintText: isCustomer ? 'Search' : 'Search chats...',
                  onTapSuffix: () {
                    _searchController.clear();
                    setState(() {});
                  },
                ),
                16.verticalSpace,
                Row(
                  children:
                      filters.map((f) {
                        final isActive = selectedFilter == f;
                        return Padding(
                          padding: const EdgeInsets.only(right: 16),
                          child: GestureDetector(
                            onTap: () {
                              setState(() => selectedFilter = f);
                            },
                            child: Container(
                              padding: pad(vertical: 4, horizontal: 10),
                              decoration: BoxDecoration(
                                color:
                                    isActive
                                        ? appColors.primary
                                        : Colors.transparent,
                                borderRadius: BorderRadius.circular(8.r),
                                border: Border.all(
                                  color:
                                      isActive
                                          ? Colors.transparent
                                          : appColors.textColor.shade200,
                                ),
                              ),
                              child: GenText(
                                f,
                                color:
                                    isActive
                                        ? appColors.whiteColor
                                        : appColors.textColor.shade500,
                                height: 16.5,
                                weight: FontWeight.w400,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                ),
                16.verticalSpace,
                Expanded(
                  child: BlocBuilder<ChatListBloc, ChatListState>(
                    builder: (context, state) {
                      if (state.isLoading && state.chats.isEmpty) {
                        return Center(
                          child: CircularProgressIndicator(
                            color: appColors.primary,
                          ),
                        );
                      }

                      if (state.error != null) {
                        return ErrorMessageAndButton(
                          error: state.error!,
                          onPressed: () {
                            context.read<ChatListBloc>().add(LoadChatList());
                          },
                        );
                      }

                      final chats = _applyFilter(state.chats);

                      if (chats.isEmpty) {
                        return EmptyScreenWidget(
                          image:
                              AppAssets.ASSETS_IMAGES_EMPTY_CHAT_PNG
                                  .imageAsset(),
                          message: 'No messages yet',
                          subMessage:
                              isCustomer
                                  ? 'Start a conversation with a service provider'
                                  : 'Start a conversation with a customer',
                        );
                      }

                      return ListView.separated(
                        itemCount: chats.length,
                        padding: EdgeInsets.only(bottom: 100.h),
                        separatorBuilder:
                            (_, _) => const ListDivider(verticalSpacing: 0),
                        itemBuilder: (context, index) {
                          final chat = chats[index];

                          return ChatTile(
                            chat: Chat(
                              name: chat.title,
                              message: chat.lastMessage ?? '',
                              time:
                                  chat.lastMessageTime != null
                                      ? AppTextUtil.formatChatListTime(
                                        chat.lastMessageTime!,
                                      )
                                      : '',
                              imgUrl: chat.imgurl,
                            ),
                            onTap: () async {
                              context.read<ChatListBloc>().add(
                                ClearUnreadCount(chat.chatId),
                              );

                              await pushScreen(
                                context,
                                ChatDetailScreen(
                                  chatId: chat.chatId,
                                  userType: widget.userType,
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<ChatSummary> _applyFilter(List<ChatSummary> chats) {
    final query = _searchController.text.toLowerCase();

    final filtered =
        chats.where((chat) {
            if (query.isNotEmpty && !chat.title.toLowerCase().contains(query)) {
              return false;
            }

            switch (selectedFilter) {
              case 'Unread':
                return chat.unreadCount > 0;
              case 'Appeal':
                return chat.title.contains('DISPUTE');
              default:
                return true;
            }
          }).toList()
          ..sort((a, b) {
            final aHasMessage = a.lastMessageTime != null;
            final bHasMessage = b.lastMessageTime != null;

            if (!aHasMessage && !bHasMessage) {
              return 0;
            }
            if (!aHasMessage && bHasMessage) {
              return 1;
            }
            if (aHasMessage && !bHasMessage) {
              return -1;
            }
            return b.lastMessageTime!.compareTo(a.lastMessageTime!);
          });
    return filtered;
  }
}
