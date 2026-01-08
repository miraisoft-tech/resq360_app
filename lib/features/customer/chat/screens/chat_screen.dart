import 'package:resq360/__lib.dart';
import 'package:resq360/core/bloc/general-chat-bloc/chat_list_bloc/chat_list_bloc.dart';
import 'package:resq360/core/models/chat_summary.dart';
import 'package:resq360/features/customer/chat/data/models/chat_model.dart';
import 'package:resq360/features/customer/chat/screens/chat_details_screen.dart';
import 'package:resq360/features/widgets/chat_tile.dart';
import 'package:resq360/features/widgets/empty_screen_widget.dart';
import 'package:resq360/features/widgets/inputs/filter_search_field.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _searchController = TextEditingController();
  String selectedFilter = 'All';

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

    return Scaffold(
      backgroundColor: appColors.whiteColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: appColors.whiteColor,
        forceMaterialTransparency: true,
        automaticallyImplyLeading: false,
        title: const Text('Chats'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: RefreshIndicator(
            color: appColors.primary,
          onRefresh:_onRefresh,
          child: Column(
            children: [
              FilterSearchFormField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                prefixIconPath: AppAssets.ASSETS_ICONS_SEARCH_SVG,
                hintText: 'Search',
              ),
              const SizedBox(height: 12),
               ChatFilterTabs(
              selectedFilter: selectedFilter,
              onFilterSelected:
                  (value) => setState(() => selectedFilter = value),
            ),
              const SizedBox(height: 12),
              Expanded(
                child: BlocBuilder<ChatListBloc, ChatListState>(
                  builder: (context, state) {
                    if (state.isLoading && state.chats.isEmpty) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
          
                    if (state.error != null) {
                      return ErrorMessageAndButton(
                        error: state.error!,
                        onPressed: () {
                          context
                              .read<ChatListBloc>()
                              .add(LoadChatList());
                        },
                      );
                    }
          
                    final chats = _applyFilter(state.chats);
          
                    if (chats.isEmpty) {
                      return const EmptyScreenWidget(
                        imagePath:
                            AppAssets.ASSETS_IMAGES_EMPTY_CHAT_PNG,
                        message: 'No messages yet',
                        subMessage:
                            'Start a conversation with a service provider',
                      );
                    }
          
                    return ListView.separated(
                      itemCount: chats.length,
                      separatorBuilder: (_, _) =>
                          const ListDivider( verticalSpacing: 0),
                      itemBuilder: (context, index) {
                        final chat = chats[index];
          
                        return ChatTile(
                          chat: Chat(
                            name: chat.title,
                            message: chat.lastMessage ?? '',
                            time: chat.lastMessageTime != null
                                ? _formatTime(chat.lastMessageTime!)
                                : '',
                            avatar:
                                AppAssets.ASSETS_IMAGES_PROFILE_PIC_PNG,
                          ),
                          onTap: () async {
                            context
                                .read<ChatListBloc>()
                                .add(ClearUnreadCount(chat.chatId));
          
                            await pushScreen(
                              context,
                              ChatDetailScreen(
                                chatId: chat.chatId,
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
    );
  }

  // Widget _buildFilterRow() {
  //   final filters = ['All', 'Unread', 'Appeal'];

  //   return Row(
  //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //     children: filters.map((filter) {
  //       final isSelected = selectedFilter == filter;

  //       return GestureDetector(
  //         onTap: () {
  //           setState(() => selectedFilter = filter);
  //         },
  //         child: Chip(
  //           label: Text(filter),
  //           backgroundColor: isSelected
  //               ? context.appColors.primary
  //               : Colors.grey[200],
  //           labelStyle: TextStyle(
  //             color:
  //                 isSelected ? Colors.white : Colors.black87,
  //           ),
  //         ),
  //       );
  //     }).toList(),
  //   );
  // }

  List<ChatSummary> _applyFilter(List<ChatSummary> chats) {
    final query = _searchController.text.toLowerCase();

    return chats.where((chat) {
      if (query.isNotEmpty &&
          !chat.title.toLowerCase().contains(query)) {
        return false;
      }

      switch (selectedFilter) {
        case 'Unread':
          return chat.unreadCount > 0;
        case 'Appeal':
          return chat.title.toLowerCase().contains('appeal');
        default:
          return true;
      }
    }).toList();
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();

    if (dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day) {
      return '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    }

    return '${dateTime.month}/${dateTime.day}/${dateTime.year}';
  }
}



// class ChatScreen extends StatefulWidget {
//   const ChatScreen({super.key});

//   @override
//   State<ChatScreen> createState() => _ChatScreenState();
// }

// class _ChatScreenState extends State<ChatScreen> {
//   final TextEditingController _searchController = TextEditingController();

//   String selectedFilter = 'All';

//   final List<Chat> chats = [
//     Chat(
//       name: 'QuickTow Emergency',
//       message: 'I’m on my way to your location. You can...',
//       time: 'Just Now',
//       avatar: AppAssets.ASSETS_IMAGES_PROFILE_PIC_PNG,
//       unread: 1,
//     ),
//     Chat(
//       name: 'You, Admin, QuickTow Emergency',
//       message: 'Please share photos of the issue',
//       time: '2:00 pm',
//       avatar: AppAssets.ASSETS_IMAGES_PROFILE_PIC_PNG,
//       status: 'appeal',
//     ),
//     Chat(
//       name: 'Homify',
//       message: 'I’d like to give my home a deep cleaning...',
//       time: '10:00 am',
//       avatar: AppAssets.ASSETS_IMAGES_PROFILE_PIC_PNG,
//     ),
//     Chat(
//       name: 'Africoelectrics',
//       message: 'Typing...',
//       time: '9:00 am',
//       avatar: AppAssets.ASSETS_IMAGES_PROFILE_PIC_PNG,
//       typing: true,
//     ),
//     Chat(
//       name: 'Davi’s Mechanics',
//       message: 'I’m on my way to your location. You can...',
//       time: 'yesterday',
//       avatar: AppAssets.ASSETS_IMAGES_PROFILE_PIC_PNG,
//       unread: 1,
//       status: 'unread',
//     ),
//     Chat(
//       name: 'The Johnsons',
//       message: 'Thank you',
//       time: '2/7/25',
//       avatar: AppAssets.ASSETS_IMAGES_PROFILE_PIC_PNG,
//     ),
//   ];

//   List<Chat> get filteredChats {
//     switch (selectedFilter) {
//       case 'Unread':
//         return chats.where((c) => c.unread > 0).toList();
//       case 'Appeal':
//         return chats.where((c) => c.status == 'appeal').toList();
//       default:
//         return chats;
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     context.read<ChatBloc>().add(GetChatsEvent());
//   }

//   @override
//   Widget build(BuildContext context) {
//     final appColors = context.appColors;

//     return Scaffold(
//       backgroundColor: appColors.whiteColor,
//       appBar: AppBar(
//         elevation: 0,
//         backgroundColor: appColors.whiteColor,
//         forceMaterialTransparency: true,
//         automaticallyImplyLeading: false,
//         centerTitle: false,
//         title: UrbText(
//           'Chats',
//           size: 22,
//           height: 32.5,
//           weight: FontWeight.w700,
//           color: appColors.black,
//         ),
//       ),
//       body: Padding(
//         padding: pad(horizontal: 16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             FilterSearchFormField(
//               controller: _searchController,
//               hintText: 'Search for services',
//               onTapSuffix: () {},
//               onChanged: (value) {
//                 setState(() {});
//               },
//               prefixIconPath: AppAssets.ASSETS_ICONS_SEARCH_SVG,
//             ),
//             16.verticalSpace,
//             ChatFilterTabs(
//               selectedFilter: selectedFilter,
//               onFilterSelected:
//                   (value) => setState(() => selectedFilter = value),
//             ),
//             16.verticalSpace,
//             BlocBuilder<ChatBloc, ChatState>(
//               builder: (context, state) {
                
//                 return Expanded(
//                   child:
//                       (chats.isEmpty)
//                           ? const EmptyScreenWidget(
//                             imagePath: AppAssets.ASSETS_IMAGES_EMPTY_CHAT_PNG,
//                             message: 'No messages yet',
//                             subMessage:
//                                 'Start a conversation with a service provider',
//                           )
//                           : ListView.separated(
//                             itemCount: chats.length,
//                             itemBuilder: (context, index) {
//                               return ChatTile(
//                                 chat: chats[index],
//                                 onTap: () async {
//                                   await pushScreen(
//                                     context,
//                                     const ChatDetailScreen(),
//                                   );
//                                 },
//                               );
//                             },
//                             separatorBuilder: (context, index) {
//                               return const ListDivider(
//                                 verticalSpacing: 0,
//                               );
//                             },
//                           ),
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

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
