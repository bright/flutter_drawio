import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_drawio/src/drawing/drawing_barrel.dart';
import 'package:flutter_drawio/src/drawing/sub_features/sketch_drawing/painters/sketch_drawing_model.dart';
import 'package:flutter_drawio/src/utils/utils_barrel.dart';

/// This class holds all the methods used to paint a [SketchDrawing] on a [Canvas].
base class SketchPainter extends DrawingPainter<SketchDrawing> {
  const SketchPainter();

  @override
  void paintDrawing(Canvas canvas, Size size, SketchDrawing drawing) {
    final model = _create(drawing);
    canvas.drawPath(model.path, model.paint);
  }

  @override
  bool contains(PointDouble point, SketchDrawing drawing) {
    const margin = 15.0;
    final model = _create(drawing);
    for (final PathMetric pathMetric in model.path.computeMetrics()) {
      final double length = pathMetric.length;
      final double step = length / 100;

      for (double d = 0; d < length; d += step) {
        final Tangent? tangent = pathMetric.getTangentForOffset(d);
        if (tangent != null) {
          final Offset pathPoint = tangent.position;
          final double distance = (pathPoint - point.toOffset).distance;

          if (distance <= margin) {
            return true;
          }
        }
      }
    }
    return false;
  }

  SketchDrawingModel _create(SketchDrawing drawing) {
    final Paint paint = Paint()
      ..color = drawing.metadata?.color ?? Colors.black
      ..strokeWidth = drawing.metadata?.strokeWidth ?? 4
      ..style = PaintingStyle.stroke;

    final Path path = Path();
    path.moveTo(0, 0);

    for (final DrawingDelta drawingDelta in drawing.deltas) {
      _paintDelta(
        drawing: drawing,
        drawingDelta: drawingDelta,
        paint: paint,
        path: path,
      );
    }

    return SketchDrawingModel(paint: paint, path: path);
  }

  void _paintDelta({
    required Drawing drawing,
    required DrawingDelta drawingDelta,
    required Paint paint,
    required Path path,
  }) {
    switch (drawingDelta.operation) {
      case DrawingOperation.start:
        paint.color = drawingDelta.metadata?.color ?? drawing.metadata?.color ?? paint.color;
        paint.strokeWidth = drawingDelta.metadata?.strokeWidth ??
            drawing.metadata?.strokeWidth ??
            paint.strokeWidth;

        path.moveTo(drawingDelta.point.x, drawingDelta.point.y);
        break;
      case DrawingOperation.end:
        break;
      case DrawingOperation.neutral:
        {
          paint.color = drawingDelta.metadata?.color ?? drawing.metadata?.color ?? paint.color;
          paint.strokeWidth = drawingDelta.metadata?.strokeWidth ??
              drawing.metadata?.strokeWidth ??
              paint.strokeWidth;

          if (drawing.deltas.isFirst(drawingDelta)) break;

          path.lineTo(drawingDelta.point.x, drawingDelta.point.y);

          break;
        }
    }
  }
}
