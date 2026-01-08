import 'dart:async';

import 'package:resq360/__lib.dart';
import 'package:resq360/features/settings/data/cubits/cubit/support_ticket_cubit.dart';
import 'package:resq360/features/settings/data/models/ticket_message.model.dart';
import 'package:resq360/features/settings/data/service/support_service.dart';
import 'package:resq360/features/widgets/chat_box_widget.dart';
import 'package:resq360/features/widgets/chat_bubble.dart';

class SupportChatScreen extends StatelessWidget {
  const SupportChatScreen({
    required this.ticketId,
    this.providerName,
    super.key,
  });

  final String ticketId;
  final String? providerName;
  @override
  Widget build(BuildContext context) {
    log(ticketId);
    return BlocProvider(
      create: (_) {
        final cubit = SupportTicketCubit(SupportRepo.instance);
        unawaited(cubit.loadTicket(ticketId));
        return cubit;
      },
      child: _SupportChatView(providerName),
    );
  }
}

class _SupportChatView extends StatefulWidget {
  const _SupportChatView(this.providerName);

  final String? providerName;

  @override
  State<_SupportChatView> createState() => _SupportChatViewState();
}

class _SupportChatViewState extends State<_SupportChatView> {
  final ScrollController _scrollController = ScrollController();

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (_scrollController.hasClients) {
        await _scrollController.animateTo(
          _scrollController.position.minScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return Scaffold(
      backgroundColor: appColors.whiteColor,
      appBar: _buildAppBar(context,),
      body: SafeArea(
        child: BlocConsumer<SupportTicketCubit, SupportTicketState>(
          listener: (context, state) {

          },
          builder: (context, state) {
            if (state.loading && state.messages.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            _scrollToBottom();

            return Column(
              children: [
                const ListDivider(),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.only(
                      left: 16.w,
                      right: 16.w,
                      bottom: 50.h,
                      top: 10.h,
                    ),
                    itemCount: state.messages.length,
                    itemBuilder: (_, index) {
                      final message = state.messages[index];
                      final cubit = context.read<SupportTicketCubit>();

                      return Padding(
                        padding: EdgeInsets.only(bottom: 20.h),
                        child: ChatBubble(
                          type:
                              message.isFromUser
                                  ? MessageType.sent
                                  : MessageType.received,
                          message: message.message,
                          time: message.createdAt.formatDate,
                          status: message.status,
                          onRetry:
                              message.status == MessageStatus.failed
                                  ? () => cubit.retryMessage(message)
                                  : null,
                          onDelete:
                              message.status == MessageStatus.failed
                                  ? () => cubit.deleteFailedMessage(message)
                                  : null,
                        ),
                      );
                    },
                  ),
                ),
                if (state.isClosed)
                  Padding(
                    padding: EdgeInsets.all(16.w),
                    child: GenText(
                      'Appeal closed',
                      color: appColors.textColor.shade400,
                    ),
                  )
                else
                  ChatBoxWidget(
                    onAttachment: () async {
                      await _showAttachmentMenu(context);
                    },
                    onSend: (text) async {
                      await context.read<SupportTicketCubit>().sendMessage(
                        text,
                      );
                    },
                  ),
              ],
            );
          },
        ),
      ),
    );
  }


  
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final appColors = context.appColors;
    final name = widget.providerName ?? '';
    return AppBar(
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
                'You, Admin ${name.isNotEmpty ? ', $name' : ''} ',
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
