import 'package:resq360/__lib.dart';
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
              hintText: 'Search for services',
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
              child:
                  (chats.isEmpty)
                      ? const EmptyScreenWidget(
                        imagePath: AppAssets.ASSETS_IMAGES_EMPTY_CHAT_PNG,
                        message: 'No messages yet',
                        subMessage:
                            'Start a conversation with a service provider',
                      )
                      : ListView.separated(
                        itemCount: chats.length,
                        itemBuilder: (context, index) {
                          return ChatTile(
                            chat: chats[index],
                            onTap: () async {
                              await pushScreen(
                                context,
                                const ChatDetailScreen(),
                              );
                            },
                          );
                        },
                        separatorBuilder: (context, index) {
                          return const ListDivider(
                            verticalSpacing: 0,
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
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
