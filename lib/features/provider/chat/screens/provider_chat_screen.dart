import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:resq360/__lib.dart';
import 'package:resq360/core/bloc/general-chat-bloc/chat_bloc.dart';
import 'package:resq360/features/customer/chat/data/models/chat/chat_response.dart';
import 'package:resq360/features/customer/chat/data/models/chat_model.dart';
import 'package:resq360/features/provider/chat/screens/provider_chat_details_screen.dart';
import 'package:resq360/features/widgets/chat_tile.dart';
import 'package:resq360/features/widgets/empty_screen_widget.dart';
import 'package:resq360/features/widgets/inputs/filter_search_field.dart';

class ProviderChatScreen extends StatefulWidget {
  const ProviderChatScreen({super.key});

  @override
  State<ProviderChatScreen> createState() => _ProviderChatScreenState();
}

class _ProviderChatScreenState extends State<ProviderChatScreen> {
  final TextEditingController _searchController = TextEditingController();

  String selectedFilter = 'All';

  final List<Chat> chats = [
    Chat(
      name: 'QuickTow Emergency',
      message: 'I’m on my way to your location. You can...',
      time: 'Just Now',
      avatar: AppAssets.ASSETS_IMAGES_PROFILE_PIC_PNG,
      unread: 1,
    ),
    Chat(
      name: 'You, Admin, QuickTow Emergency',
      message: 'Please share photos of the issue',
      time: '2:00 pm',
      avatar: AppAssets.ASSETS_IMAGES_PROFILE_PIC_PNG,
      status: 'appeal',
    ),
    Chat(
      name: 'Homify',
      message: 'I’d like to give my home a deep cleaning...',
      time: '10:00 am',
      avatar: AppAssets.ASSETS_IMAGES_PROFILE_PIC_PNG,
    ),
    Chat(
      name: 'Africoelectrics',
      message: 'Typing...',
      time: '9:00 am',
      avatar: AppAssets.ASSETS_IMAGES_PROFILE_PIC_PNG,
      typing: true,
    ),
    Chat(
      name: 'Davi’s Mechanics',
      message: 'I’m on my way to your location. You can...',
      time: 'yesterday',
      avatar: AppAssets.ASSETS_IMAGES_PROFILE_PIC_PNG,
      unread: 1,
      status: 'unread',
    ),
    Chat(
      name: 'The Johnsons',
      message: 'Thank you',
      time: '2/7/25',
      avatar: AppAssets.ASSETS_IMAGES_PROFILE_PIC_PNG,
    ),
  ];

  List<Chat> get filteredChats {
    switch (selectedFilter) {
      case 'Unread':
        return chats.where((c) => c.unread > 0).toList();
      case 'Appeal':
        return chats.where((c) => c.status == 'appeal').toList();
      default:
        return chats;
    }
  }

  @override
  void initState() {
    super.initState();
    context.read<ChatBloc>().add(GetChatsEvent());
  }

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return Scaffold(
      backgroundColor: appColors.whiteColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: appColors.whiteColor,
        forceMaterialTransparency: true,
        automaticallyImplyLeading: false,
        centerTitle: false,
        title: UrbText(
          'Chats',
          size: 22,
          height: 32.5,
          weight: FontWeight.w700,
          color: appColors.black,
        ),
      ),
      body: Padding(
        padding: pad(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FilterSearchFormField(
              controller: _searchController,
              hintText: 'Search chats...',
              onTapSuffix: () {},
              onChanged: (value) {
                setState(() {});
              },
              prefixIconPath: AppAssets.ASSETS_ICONS_SEARCH_SVG,
            ),
            16.verticalSpace,
            ChatFilterTabs(
              selectedFilter: selectedFilter,
              onFilterSelected:
                  (value) => setState(() => selectedFilter = value),
            ),
            16.verticalSpace,
            Expanded(
              child: BlocBuilder<ChatBloc, ChatState>(
                builder: (context, state) {
                  if (state is FetchingChatsState) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is ChatErrorState) {
                    return Center(
                      child: Text(
                        state.message,
                        style: TextStyle(color: appColors.textColor),
                      ),
                    );
                  }

                  if (state is ChatListLoadedState) {
                    final chats = _applyFilter(
                      state.chats.chats,
                      selectedFilter,
                    );
                    if (chats.isEmpty) {
                      return const EmptyScreenWidget(
                        imagePath: AppAssets.ASSETS_IMAGES_EMPTY_CHAT_PNG,
                        message: 'No messages yet',
                        subMessage:
                            'Start a conversation with a service provider',
                      );
                    }

                    return ListView.separated(
                      itemCount: chats.length,
                      itemBuilder: (context, index) {
                        final chat = chats[index];
                        return ChatTile(
                          chat: Chat(
                            name: chat.title ?? 'Untitled',
                            message: chat.lastMessage ?? '',
                            time:
                                chat.lastMessageAt != null
                                    ? _formatTime(chat.lastMessageAt!)
                                    : '',
                            avatar: AppAssets.ASSETS_IMAGES_PROFILE_PIC_PNG
                          ),
                          onTap: () async {
                            await pushScreen(
                              context,
                               ProviderChatDetailScreen(chat: chat,),
                            );
                          },
                        );
                      },
                      separatorBuilder: (context, index) {
                        return const ListDivider(
                          verticalSpacing: 0,
                        );
                      },
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget _buildFilterRow() {
  //   final filters = ['All', 'Unread', 'Appeal'];
  //   return Row(
  //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //     children:
  //         filters.map((f) {
  //           final isSelected = selectedFilter == f;
  //           return GestureDetector(
  //             onTap: () => setState(() => selectedFilter = f),
  //             child: Chip(
  //               label: Text(f),
  //               backgroundColor:
  //                   isSelected ? context.appColors.primary : Colors.grey[200],
  //               labelStyle: TextStyle(
  //                 color: isSelected ? Colors.white : Colors.black87,
  //               ),
  //             ),
  //           );
  //         }).toList(),
  //   );
  // }

  List<ChatResponse> _applyFilter(
    List<ChatResponse> chats,
    String selectedFilter,
  ) {
    switch (selectedFilter) {
      case 'Unread':
        // later use lastReadAt to compute unread
        return chats;
      case 'Appeal':
        return chats
            .where((c) => c.title?.toLowerCase().contains('appeal') ?? false)
            .toList();
      default:
        return chats;
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    if (dateTime.day == now.day &&
        dateTime.month == now.month &&
        dateTime.year == now.year) {
      return '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
    return '${dateTime.month}/${dateTime.day}/${dateTime.year}';
  }
}

class ChatFilterTabs extends StatelessWidget {
  const ChatFilterTabs({
    required this.selectedFilter,
    required this.onFilterSelected,
    super.key,
  });
  final String selectedFilter;
  final ValueChanged<String> onFilterSelected;

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    final filters = ['All', 'Unread', 'Appeal'];

    return Row(
      children:
          filters.map((f) {
            final isActive = selectedFilter == f;
            return Padding(
              padding: const EdgeInsets.only(right: 16),
              child: GestureDetector(
                onTap: () => onFilterSelected(f),
                child: Container(
                  padding: pad(vertical: 4, horizontal: 10),
                  decoration: BoxDecoration(
                    color: isActive ? appColors.primary : Colors.transparent,
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
    );
  }
}
