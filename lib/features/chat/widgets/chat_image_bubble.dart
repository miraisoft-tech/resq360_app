import 'package:resq360/__lib.dart';

class ChatImageBubble extends StatelessWidget {
  const ChatImageBubble({
    required this.imageUrl,
    required this.time,
    required this.isMine,
    this.caption,
    super.key,
  });

  final String imageUrl;
  final String time;
  final bool isMine;
  final String? caption;

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
            GestureDetector(
              onTap: () => _showFullImage(context),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: appColors.neutral.shade200,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: Stack(
                    children: [
                      Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            height: 200.h,
                            width: double.infinity,
                            color: appColors.neutral.shade100,
                            child: Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                                color: appColors.primary,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 200.h,
                            width: double.infinity,
                            color: appColors.neutral.shade100,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.broken_image,
                                  size: 48.sp,
                                  color: appColors.neutral.shade400,
                                ),
                                8.verticalSpace,
                                GenText(
                                  'Failed to load image',
                                  size: 12,
                                  color: appColors.neutral.shade500,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    
                      Positioned(
                        bottom: 8.h,
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
                          child: GenText(
                            time,
                            size: 11,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (caption != null && caption!.isNotEmpty) ...[
              4.verticalSpace,
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color:
                      isMine
                          ? appColors.primary.shade50
                          : appColors.neutral.shade100,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: GenText(
                  caption!,
                  color: appColors.black,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _showFullImage(BuildContext context) async {
    await pushScreen(context,  _FullImageViewer(imageUrl: imageUrl));
    
  }
}

class _FullImageViewer extends StatelessWidget {
  const _FullImageViewer({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              //// TO Implement image download
            },
          ),
        ],
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4,
          child: Image.network(
            imageUrl,
            fit: BoxFit.contain,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                  color: Colors.white,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
