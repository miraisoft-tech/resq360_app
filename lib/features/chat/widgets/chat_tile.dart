import 'package:resq360/__lib.dart';
import 'package:resq360/features/chat/data/models/chat_model.dart';

class ChatTile extends StatelessWidget {
  const ChatTile({required this.chat, required this.onTap, super.key});
  final Chat chat;
  final void Function() onTap;
  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.only(top: 12.h, bottom: 16.h),
        child: Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundImage: AssetImage(chat.avatar),
            ),
            10.horizontalSpace,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: GenText(
                          chat.name,
                          weight: FontWeight.w500,
                          color: appColors.black,
                        ),
                      ),
                      GenText(
                        chat.time,
                        size: 10,
                        color: appColors.textColor.shade400,
                      ),
                    ],
                  ),
                  6.verticalSpace,
                  Row(
                    children: [
                      SizedBox(
                        width: MediaQuery.sizeOf(context).width * 0.65,
                        child: GenText(
                          chat.message,
                          color:
                              chat.typing
                                  ? appColors.primary
                                  : appColors.textColor.shade400,
                          weight:
                              chat.typing ? FontWeight.w500 : FontWeight.w400,
                          size: 12,
                          height: 14.5,
                          maxLines: 1,
                        ),
                      ),
                      const Spacer(),
                      if (chat.unread > 0)
                        Container(
                          padding: pad(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: appColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: GenText(
                            '${chat.unread}',
                            size: 12,
                            height: 14.5,
                            color: appColors.whiteColor,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
