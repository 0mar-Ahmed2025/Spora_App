// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class CustomSvgWrapper extends StatelessWidget {
  const CustomSvgWrapper({
    super.key,
    required this.path,
    this.height,
    this.width,
    this.color,
  });

  final String path;
  final double? height;
  final double? width;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(path, height: height, width: width, color: color);
  }
}
