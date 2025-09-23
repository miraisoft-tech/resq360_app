import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

/// Custom branch Navigator container that provides animated transitions
/// when switching branches.
class AnimatedBranchContainer extends StatelessWidget {
  const AnimatedBranchContainer({
    required this.currentIndex,
    required this.children,
    super.key,
  });

  static const _defaultAnimationDuration = Duration(milliseconds: 250);

  final int currentIndex;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children:
          children.mapIndexed((int index, Widget navigator) {
            return AnimatedScale(
              scale: index == currentIndex ? 1 : 1.5,
              duration: _defaultAnimationDuration,
              child: AnimatedOpacity(
                opacity: index == currentIndex ? 1 : 0,
                duration: _defaultAnimationDuration,
                child: _branchNavigatorWrapper(index, navigator),
              ),
            );
          }).toList(),
    );
  }

  Widget _branchNavigatorWrapper(int index, Widget navigator) => IgnorePointer(
    ignoring: index != currentIndex,
    child: TickerMode(enabled: index == currentIndex, child: navigator),
  );
}
