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
          SkeletonLoader(
            width: 60,
            height: 24,
            borderRadius: 6,
          ),
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
          SkeletonLoader(
            width: 200,
            height: 12,
            borderRadius: 6,
          ),
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
                    SkeletonLoader(
                      width: 200,
                      height: 12,
                      borderRadius: 6,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          SkeletonLoader(
            width: double.infinity,
            height: 40,
            borderRadius: 6,
          ),
        ],
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
              SkeletonLoader(
                width: 100,
                height: 14,
                borderRadius: 6,
              ),
              SkeletonLoader(
                width: 100,
                height: 14,
                borderRadius: 6,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
