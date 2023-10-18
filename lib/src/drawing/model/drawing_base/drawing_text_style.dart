import 'package:flutter/material.dart';

class DrawingTextStyle {
  final Color textColor;
  final double fontSize;
  final String fontFamily;
  final Color backgroundColor;
  final TextDirection textDirection;
  final TextDecoration textDecoration;
  final FontWeight fontWeight;
  final Axis axis;

  DrawingTextStyle({
    required this.textColor,
    required this.fontSize,
    required this.fontFamily,
    required this.backgroundColor,
    required this.textDirection,
    required this.textDecoration,
    required this.fontWeight,
    required this.axis,
  });
}
