import 'package:resq360/__lib.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatLocationBubble extends StatelessWidget {
  const ChatLocationBubble({
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.time,
    required this.isMine,
    super.key,
  });

  final double latitude;
  final double longitude;
  final String address;
  final String time;
  final bool isMine;

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        margin: EdgeInsets.symmetric(vertical: 4.h),
        child: Column(
          crossAxisAlignment:
              isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: isMine ? appColors.primary : appColors.neutral.shade100,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: appColors.neutral.shade200,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: _openInMaps,
                    child: Container(
                      height: 150.h,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: appColors.neutral.shade200,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(12.r),
                          topRight: Radius.circular(12.r),
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(12.r),
                          topRight: Radius.circular(12.r),
                        ),
                        child: Stack(
                          children: [
                            Image.network(
                              _getStaticMapUrl(),
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              errorBuilder: (context, error, stackTrace) {
                                return ColoredBox(
                                  color: appColors.neutral.shade200,
                                  child: Center(
                                    child: Icon(
                                      Icons.location_on,
                                      size: 48.sp,
                                      color: appColors.primary.shade500,
                                    ),
                                  ),
                                );
                              },
                            ),
                            Center(
                              child: Icon(
                                Icons.location_on,
                                size: 40.sp,
                                color: appColors.error.shade600,
                                shadows: const [
                                  Shadow(
                                    color: Colors.black38,
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              top: 8.h,
                              right: 8.w,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8.w,
                                  vertical: 4.h,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.map,
                                      size: 14.sp,
                                      color: Colors.white,
                                    ),
                                    4.horizontalSpace,
                                    const GenText(
                                      'Open',
                                      size: 11,
                                      color: Colors.white,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(12.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        8.verticalSpace,
                        GenText(
                          address,
                          size: 13,
                          color: isMine ? appColors.whiteColor : null,
                          maxLines: 3,
                        ),
                        8.verticalSpace,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GenText(
                              time,
                              size: 11,
                              color: isMine ? appColors.whiteColor : null,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getStaticMapUrl() {
    return 'https://static-maps.yandex.ru/1.x/?'
        'lang=en_US&ll=$longitude,$latitude&z=14&l=map&size=600,400&pt=$longitude,$latitude,pm2rdm';
  }

  Future<void> _openInMaps() async {
    final googleMapsUrl = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
    );

    final appleMapsUrl = Uri.parse(
      'https://maps.apple.com/?q=$latitude,$longitude',
    );

    final universalUrl = Uri.parse(
      'geo:$latitude,$longitude?q=$latitude,$longitude',
    );

    try {
      if (await canLaunchUrl(googleMapsUrl)) {
        await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
      } else if (await canLaunchUrl(appleMapsUrl)) {
        await launchUrl(appleMapsUrl, mode: LaunchMode.externalApplication);
      } else if (await canLaunchUrl(universalUrl)) {
        await launchUrl(universalUrl, mode: LaunchMode.externalApplication);
      } else {
        log('Could not launch maps');
      }
    } on Exception catch (e) {
      log('Error launching maps: $e');
    }
  }
}
