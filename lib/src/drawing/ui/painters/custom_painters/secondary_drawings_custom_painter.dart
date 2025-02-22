import 'package:flutter/cupertino.dart';
import 'package:flutter_drawio/src/drawing/drawing_barrel.dart';

/// This class is holds the methods used to paint every complete [Drawing] on a canvas.
class SecondaryDrawingsPainter extends CustomPainter {
  final List<Drawing> drawings;
  final DrawingPainter<ShapeDrawing> shapeDrawingPainter;
  final DrawingPainter<SketchDrawing> sketchDrawingPainter;
  final DrawingPainter<LineDrawing> lineDrawingPainter;
  final DrawingPainter<TextDrawing> textDrawingPainter;

  const SecondaryDrawingsPainter({
    required this.shapeDrawingPainter,
    required this.sketchDrawingPainter,
    required this.lineDrawingPainter,
    required this.textDrawingPainter,
    required this.drawings,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final Drawing drawing in drawings) {
      switch (drawing) {
        case ShapeDrawing():
          shapeDrawingPainter.paintDrawing(
            canvas,
            size,
            drawing,
          );
          break;
        case LineDrawing():
          lineDrawingPainter.paintDrawing(
            canvas,
            size,
            drawing,
          );
        case SketchDrawing():
          sketchDrawingPainter.paintDrawing(
            canvas,
            size,
            drawing,
          );
          break;
        case TextDrawing():
          textDrawingPainter.paintDrawing(
            canvas,
            size,
            drawing,
          );
          break;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is SecondaryDrawingsPainter && oldDelegate.drawings != drawings;
  }
}
