// ignore_for_file: document_ignores, public_member_api_docs, must_be_immutable

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class NavItem extends Equatable {
  NavItem({
    this.key,
    this.color,
    this.content = '',
    this.onTap,
    this.body = const SizedBox.shrink(),
    this.title = '',
    this.subTitle = '',
    this.imagePath = '',
    this.unselectedImgPath = '',
    this.selectedImgPath = '',
    this.isIcon = true,
    this.isSelected = false,
    this.hideIcon = false,
    this.children = const [],
  });
  final Widget body;
  final String title;
  final String subTitle;
  final String content;
  final String imagePath;
  final String unselectedImgPath;
  final String selectedImgPath;
  bool isIcon;
  bool isSelected;
  void Function()? onTap;
  final bool hideIcon;
  final Color? color;
  final dynamic key;
  final List<String> children;

  @override
  List<Object?> get props => [title];
}
