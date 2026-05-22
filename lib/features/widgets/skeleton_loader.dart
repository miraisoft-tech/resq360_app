import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SkeletonLoader extends StatelessWidget {
  const SkeletonLoader({
    super.key,
    this.width,
    this.height,
    this.borderRadius = 8,
    this.padding = EdgeInsets.zero,
  });
  final double? width;
  final double? height;
  final double borderRadius;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Padding(
        padding: padding,
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
      ),
    );
  }
}

class SkeletonStatsCard extends StatelessWidget {
  const SkeletonStatsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          SkeletonLoader(
            width: 100,
            height: 16,
            borderRadius: 6,
            padding: EdgeInsets.only(bottom: 12),
          ),
          SkeletonLoader(width: 60, height: 24, borderRadius: 6),
        ],
      ),
    );
  }
}

class SkeletonListItem extends StatelessWidget {
  const SkeletonListItem({
    super.key,
    this.padding = const EdgeInsets.symmetric(vertical: 8),
  });
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonLoader(
            width: double.infinity,
            height: 16,
            borderRadius: 6,
            padding: EdgeInsets.only(bottom: 8),
          ),
          SkeletonLoader(
            width: double.infinity,
            height: 12,
            borderRadius: 6,
            padding: EdgeInsets.only(bottom: 8),
          ),
          SkeletonLoader(width: 200, height: 12, borderRadius: 6),
        ],
      ),
    );
  }
}

class SkeletonBookingCard extends StatelessWidget {
  const SkeletonBookingCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SkeletonLoader(
                width: 60,
                height: 60,
                borderRadius: 30,
                padding: EdgeInsets.only(right: 12),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonLoader(
                      width: double.infinity,
                      height: 16,
                      borderRadius: 6,
                      padding: EdgeInsets.only(bottom: 8),
                    ),
                    SkeletonLoader(width: 200, height: 12, borderRadius: 6),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          SkeletonLoader(width: double.infinity, height: 40, borderRadius: 6),
        ],
      ),
    );
  }
}

class SkeletonBookingList extends StatelessWidget {
  const SkeletonBookingList({super.key, this.itemCount = 4});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: itemCount,
      separatorBuilder: (_, _) => const SizedBox(height: 16),
      itemBuilder: (_, _) => const SkeletonBookingCard(),
    );
  }
}

class SkeletonChatList extends StatelessWidget {
  const SkeletonChatList({super.key, this.itemCount = 7});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 100),
      itemCount: itemCount,
      separatorBuilder:
          (_, _) => Divider(height: 1, color: Colors.grey.shade100),
      itemBuilder: (_, _) => const SkeletonChatTile(),
    );
  }
}

class SkeletonChatTile extends StatelessWidget {
  const SkeletonChatTile({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: 12, bottom: 16),
      child: Row(
        children: [
          SkeletonLoader(width: 48, height: 48, borderRadius: 24),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: SkeletonLoader(height: 14, borderRadius: 6),
                    ),
                    SizedBox(width: 30),
                    SkeletonLoader(width: 42, height: 10, borderRadius: 5),
                  ],
                ),
                SizedBox(height: 10),
                SkeletonLoader(height: 12, borderRadius: 6),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SkeletonChatDetailContent extends StatelessWidget {
  const SkeletonChatDetailContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 10, 16, 12),
          child: Row(
            children: [
              SkeletonLoader(width: 40, height: 40, borderRadius: 20),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonLoader(width: 140, height: 14, borderRadius: 6),
                    SizedBox(height: 8),
                    SkeletonLoader(width: 72, height: 10, borderRadius: 5),
                  ],
                ),
              ),
              SkeletonLoader(width: 36, height: 36, borderRadius: 18),
            ],
          ),
        ),
        Divider(height: 1, color: Colors.grey.shade100),
        const Expanded(child: SkeletonChatMessages()),
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 10, 16, 16),
          child: SkeletonLoader(height: 48, borderRadius: 24),
        ),
      ],
    );
  }
}

class SkeletonChatMessages extends StatelessWidget {
  const SkeletonChatMessages({super.key, this.itemCount = 7});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      reverse: true,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 50),
      itemCount: itemCount,
      itemBuilder: (_, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 15),
          child: SkeletonChatBubble(
            isMine: index.isEven,
            width: index.isEven ? 190 : 240,
          ),
        );
      },
    );
  }
}

class SkeletonChatBubble extends StatelessWidget {
  const SkeletonChatBubble({required this.isMine, super.key, this.width = 220});

  final bool isMine;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        width: width,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            SkeletonLoader(height: 12, borderRadius: 6),
            SizedBox(height: 8),
            SkeletonLoader(width: 120, height: 12, borderRadius: 6),
            SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: SkeletonLoader(width: 44, height: 9, borderRadius: 5),
            ),
          ],
        ),
      ),
    );
  }
}

class SkeletonPromotionCard extends StatelessWidget {
  const SkeletonPromotionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonLoader(
            width: double.infinity,
            height: 20,
            borderRadius: 6,
            padding: EdgeInsets.only(bottom: 12),
          ),
          SkeletonLoader(
            width: double.infinity,
            height: 16,
            borderRadius: 6,
            padding: EdgeInsets.only(bottom: 12),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SkeletonLoader(width: 100, height: 14, borderRadius: 6),
              SkeletonLoader(width: 100, height: 14, borderRadius: 6),
            ],
          ),
        ],
      ),
    );
  }
}
