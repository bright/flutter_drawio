import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_drawio/src/drawing/drawing_barrel.dart';
import 'package:flutter_drawio/src/utils/utils_barrel.dart';

base class TextDrawingPainter extends DrawingPainter<TextDrawing> {
  const TextDrawingPainter();

  @override
  bool contains(PointDouble point, TextDrawing drawing) {
    final rect = _prepareTextRectangle(drawing: drawing);
    return rect.contains(point.toOffset);
  }

  @override
  void paintDrawing(Canvas canvas, Size size, TextDrawing drawing) {
    final textPainter = _prepareTextPainter(drawing);
    final position = drawing.deltas.first.point.toOffset;

    switch (drawing.style.axis) {
      case Axis.horizontal:
        textPainter.paint(canvas, position);
        break;
      case Axis.vertical:
        canvas.save();
        canvas.translate(position.dx, position.dy);
        canvas.rotate(pi / 2);
        textPainter.paint(canvas, Offset.zero);
        canvas.restore();
        break;
    }
  }

  TextPainter _prepareTextPainter(TextDrawing drawing) {
    final style = drawing.style;

    final textPainter = TextPainter(
      text: TextSpan(
        text: drawing.text,
        style: TextStyle(
          color: style.textColor,
          fontSize: style.fontSize,
          fontFamily: style.fontFamily,
          fontWeight: style.fontWeight,
          backgroundColor: style.backgroundColor,
          decorationColor: style.textColor,
          decoration: style.textDecoration,
        ),
      ),
      textDirection: style.textDirection,
    );

    textPainter.layout();

    return textPainter;
  }

  Rect _prepareTextRectangle({required TextDrawing drawing}) {
    final textPainter = _prepareTextPainter(drawing);
    final drawingPoint = drawing.deltas.first.point.toOffset;

    switch (drawing.style.axis) {
      case Axis.horizontal:
        return Rect.fromPoints(
          drawingPoint,
          drawingPoint + Offset(textPainter.width, textPainter.height),
        );
      case Axis.vertical:
        return Rect.fromPoints(
          Offset(drawingPoint.dx - textPainter.height, drawingPoint.dy),
          Offset(drawingPoint.dx, drawingPoint.dy + textPainter.width),
        );
    }
  }
}
