import 'package:resq360/__lib.dart';
import 'package:resq360/features/customer/chat/widgets/chat_box_widget.dart';
import 'package:resq360/features/customer/chat/widgets/chat_bubble.dart';

class SupportChatScreen extends StatelessWidget {
  const SupportChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return Scaffold(
      backgroundColor: appColors.whiteColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: appColors.whiteColor,
        forceMaterialTransparency: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: appColors.black),
          onPressed: () => pop(context),
        ),
        title: Row(
          children: [
            const CircleAvatar(
              backgroundImage: AssetImage(
                AppAssets.ASSETS_IMAGES_PROFILE_PIC_PNG,
              ),
              radius: 25,
            ),
            8.horizontalSpace,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GenText(
                  'You, Admin, QuickTow ',
                  weight: FontWeight.w500,
                  color: appColors.black,
                ),
                GenText(
                  'Online',
                  size: 13,
                  color: appColors.success.shade600,
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: AppAssets.ASSETS_ICONS_PHONE_ICON_SVG.svg,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const ListDivider(),
            Expanded(
              child: ListView(
                padding: EdgeInsets.only(
                  left: 16.w,
                  right: 16.w,
                  bottom: 50.h,
                  top: 10.h,
                ),
                children: [
                  const ChatBubble(
                    type: MessageType.received,
                    message:
                        '''Hello Jane, we have received your appeal. Please describe the issue and attach photos or evidence''',
                    time: '2:50 pm',
                  ),
                  20.verticalSpace,
                  const ChatBubble(
                    type: MessageType.sent,
                    message:
                        '''The service was not completed as agreed. They towed my vehicle only halfway through.''',
                    time: '2:50 pm',
                  ),
                  30.verticalSpace,
                  GestureDetector(
                    onTap: () async {
                      if (context.mounted) await pop(context);
                    },
                    child: GenText(
                      'Return to dashboard',
                      weight: FontWeight.w500,
                      color: appColors.primary.shade500,
                      decoration: TextDecoration.underline,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            ChatBoxWidget(
              onAttachment: () => _showAttachmentMenu(context),
              onSend: () {},
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAttachmentMenu(BuildContext context) async {
    final button = context.findRenderObject()! as RenderBox;
    final overlay =
        Navigator.of(context).overlay!.context.findRenderObject()! as RenderBox;
    final position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset(0, 800.h), ancestor: overlay),
        button.localToGlobal(
          button.size.bottomRight(Offset.zero),
          ancestor: overlay,
        ),
      ),
      Offset.zero & overlay.size,
    );

    await showMenu<String>(
      context: context,
      position: position,
      color: Colors.white,
      items: [
        PopupMenuItem<String>(
          value: 'media',
          child: Row(
            children: [
              const GenText('Media'),
              70.horizontalSpace,
              AppAssets.ASSETS_ICONS_ATTACH_IMAGE_SVG.svg,
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'location',
          child: Row(
            children: [
              const GenText('Location'),
              55.horizontalSpace,
              AppAssets.ASSETS_ICONS_ATTACH_LOCATION_SVG.svg,
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'document',
          child: Row(
            children: [
              const GenText('Document'),
              45.horizontalSpace,
              AppAssets.ASSETS_ICONS_ATTACH_DOC_SVG.svg,
            ],
          ),
        ),
      ],
    ).then((String? result) {
      if (result != null) {
        switch (result) {
          case 'media':
            _onMediaTap();
          case 'location':
            _onLocationTap();
          case 'document':
            _onDocumentTap();
        }
      }
    });
  }

  void _onMediaTap() {}

  void _onLocationTap() {}

  void _onDocumentTap() {}
}
