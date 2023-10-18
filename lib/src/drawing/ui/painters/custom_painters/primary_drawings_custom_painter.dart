import 'package:flutter/cupertino.dart';
import 'package:flutter_drawio/src/drawing/drawing_barrel.dart';

/// This class is holds the methods used to paint the currently active [Drawing] on a canvas.
class PrimaryDrawingsPainter extends CustomPainter {
  final Drawing drawing;
  final DrawingPainter<ShapeDrawing> shapeDrawingPainter;
  final DrawingPainter<SketchDrawing> sketchDrawingPainter;
  final DrawingPainter<LineDrawing> lineDrawingPainter;
  final DrawingPainter<TextDrawing> textDrawingPainter;

  const PrimaryDrawingsPainter({
    required this.shapeDrawingPainter,
    required this.sketchDrawingPainter,
    required this.lineDrawingPainter,
    required this.textDrawingPainter,
    required this.drawing,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final type = drawing;
    switch (type) {
      case ShapeDrawing():
        shapeDrawingPainter.paintDrawing(
          canvas,
          size,
          type,
        );
        break;
      case LineDrawing():
        lineDrawingPainter.paintDrawing(
          canvas,
          size,
          type,
        );
      case SketchDrawing():
        sketchDrawingPainter.paintDrawing(
          canvas,
          size,
          type,
        );
        break;
      case TextDrawing():
        textDrawingPainter.paintDrawing(
          canvas,
          size,
          type,
        );
        break;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is PrimaryDrawingsPainter && oldDelegate.drawing != drawing;
  }
}
