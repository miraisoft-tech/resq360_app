import 'dart:async';

import 'package:resq360/core/models/gallery_item_model.dart';
import 'package:resq360/features/widgets/images.widgets.dart';

import '../../../__lib.dart';

class GalleryImageViewWrapper extends StatefulWidget {
  const GalleryImageViewWrapper({
    required this.titleGallery,
    required this.backgroundColor,
    required this.initialIndex,
    required this.galleryItems,
    required this.loadingWidget,
    required this.errorWidget,
    required this.minScale,
    required this.maxScale,
    required this.radius,
    required this.reverse,
    required this.showListInGalley,
    required this.showAppBar,
    required this.closeWhenSwipeUp,
    required this.closeWhenSwipeDown,
    super.key,
  });

  final Color? backgroundColor;
  final int? initialIndex;
  final List<GalleryItemModel> galleryItems;
  final String? titleGallery;
  final Widget? loadingWidget;
  final Widget? errorWidget;
  final double minScale;
  final double maxScale;
  final double radius;
  final bool reverse;
  final bool showListInGalley;
  final bool showAppBar;
  final bool closeWhenSwipeUp;
  final bool closeWhenSwipeDown;

  @override
  State<StatefulWidget> createState() {
    return _GalleryImageViewWrapperState();
  }
}

class _GalleryImageViewWrapperState extends State<GalleryImageViewWrapper> {
  late final PageController _controller = PageController(
    initialPage: widget.initialIndex ?? 0,
  );
  int _currentPage = 0;

  @override
  void initState() {
    _currentPage = 0;
    _controller.addListener(() {
      setState(() {
        _currentPage = _controller.page?.toInt() ?? 0;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.backgroundColor,
      body: SafeArea(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              child: Container(
                constraints: BoxConstraints.expand(
                  height: MediaQuery.of(context).size.height,
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onVerticalDragEnd: (details) {
                          if (widget.closeWhenSwipeUp &&
                              details.primaryVelocity! < 0) {
                            Navigator.of(context).pop();
                          }
                          if (widget.closeWhenSwipeDown &&
                              details.primaryVelocity! > 0) {
                            Navigator.of(context).pop();
                          }
                        },
                        child: PageView.builder(
                          padEnds: false,
                          reverse: widget.reverse,
                          controller: _controller,
                          itemCount: widget.galleryItems.length,
                          itemBuilder:
                              (context, index) =>
                                  _buildImage(widget.galleryItems[index]),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              child: IconButton(
                iconSize: 24,
                icon: const Icon(
                  Icons.close,
                  color: Colors.white,
                ),
                onPressed: () {
                  unawaited(pop(context));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(GalleryItemModel item) {
    return Hero(
      tag: item.id,
      child: Material(
        color: Colors.transparent,
        child: Stack(
          children: [
            InteractiveViewer(
              minScale: widget.minScale,
              maxScale: widget.maxScale,
              child: Center(
                child: CacheNetworkImageWidget(
                  imageUrl: item.imageUrl,
                  width: double.infinity,
                  fit: BoxFit.fitHeight,
                ),
              ),
            ),
            if (_currentPage != 0)
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios,
                    color: Colors.white,
                  ),
                  onPressed: () async {
                    {
                      await _controller.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                ),
              ),
            if (_currentPage != widget.galleryItems.length - 1)
              Positioned(
                right: 10,
                top: 0,
                bottom: 0,
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white,
                  ),
                  onPressed: () async {
                    {
                      await _controller.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
