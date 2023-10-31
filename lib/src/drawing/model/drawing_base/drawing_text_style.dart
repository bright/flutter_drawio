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

  DrawingTextStyle copyWith({
    Color? textColor,
    double? fontSize,
    String? fontFamily,
    Color? backgroundColor,
    TextDirection? textDirection,
    TextDecoration? textDecoration,
    FontWeight? fontWeight,
    Axis? axis,
  }) =>
      DrawingTextStyle(
        textColor: textColor ?? this.textColor,
        fontSize: fontSize ?? this.fontSize,
        fontFamily: fontFamily ?? this.fontFamily,
        backgroundColor: backgroundColor ?? this.backgroundColor,
        textDirection: textDirection ?? this.textDirection,
        textDecoration: textDecoration ?? this.textDecoration,
        fontWeight: fontWeight ?? this.fontWeight,
        axis: axis ?? this.axis,
      );
}
