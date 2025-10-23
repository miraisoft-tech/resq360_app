import 'package:resq360/__lib.dart';


class ChatBoxWidget extends StatefulWidget {
  const ChatBoxWidget({
    required this.onSend,
    required this.onAttachment,
    super.key,
  });

  final void Function(String message) onSend; // now sends the message text
  final VoidCallback onAttachment;

  @override
  State<ChatBoxWidget> createState() => _ChatBoxWidgetState();
}

class _ChatBoxWidgetState extends State<ChatBoxWidget> {
  final TextEditingController _controller = TextEditingController();

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      widget.onSend(text);
      _controller.clear(); // clear after sending
    }
  }

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return Container(
      padding: pad(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: appColors.whiteColor,
        border: Border(
          top: BorderSide(color: appColors.textColor.shade100),
        ),
      ),
      child: Row(
        children: [
          SVGButton(
            path: AppAssets.ASSETS_ICONS_ATTACHMENT_ICON_SVG,
            onTap: widget.onAttachment,
          ),
          6.horizontalSpace,
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Type your message...',
                hintStyle: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w400,
                  color: appColors.neutral.shade400,
                ),
                contentPadding: pad(horizontal: 10, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: BorderSide(
                    color: appColors.neutral.shade300,
                    width: 0.5,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: BorderSide(
                    color: appColors.neutral.shade300,
                    width: 0.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: BorderSide(
                    color: appColors.black,
                    width: 0.5,
                  ),
                ),
              ),
              onSubmitted: (_) => _handleSend(),
            ),
          ),
          6.horizontalSpace,
          SVGButton(
            path: AppAssets.ASSETS_ICONS_SEND_ICON_SVG,
            onTap: _handleSend,
          ),
        ],
      ),
    );
  }
}


