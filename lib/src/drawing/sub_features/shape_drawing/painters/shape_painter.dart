import 'package:flutter/material.dart';
import 'package:flutter_drawio/src/drawing/drawing_barrel.dart';
import 'package:flutter_drawio/src/utils/utils_barrel.dart';

/// This class holds the active methods for painting a [ShapeDrawing] object.
base class ShapePainter extends DrawingPainter<ShapeDrawing> {
  const ShapePainter();

  @override
  void paintDrawing(
    Canvas canvas,
    Size size,
    ShapeDrawing drawing,
  ) {
    final Paint paint = Paint()
      ..color = drawing.metadata?.color ?? Colors.black
      ..strokeWidth = drawing.metadata?.strokeWidth ?? 4
      ..style = PaintingStyle.stroke;

    if (drawing.deltas.length == 1) return;

    switch (drawing.shape) {
      case Shape.rectangle:
        final rect = _prepareRectangle(drawing: drawing);
        canvas.drawRect(rect, paint);
        break;
      case Shape.circle:
        final rect = _prepareCircle(drawing: drawing);
        final double radius = rect.size.magnitude / 2;
        canvas.drawCircle(rect.center, radius, paint);
        break;
      case Shape.triangle:
        final path = _prepareTriangle(drawing: drawing);
        canvas.drawPath(path, paint);
        break;
      case Shape.star:
        final path = _prepareStar(drawing: drawing);
        canvas.drawPath(path, paint);
        break;
    }
  }

  @override
  bool contains(PointDouble point, ShapeDrawing drawing) {
    switch (drawing.shape) {
      case Shape.rectangle:
        final rect = _prepareRectangle(drawing: drawing);
        return rect.contains(point.toOffset);

      case Shape.circle:
        const margin = 1.0;
        final rect = _prepareCircle(drawing: drawing);
        final double distanceToCenter = (point.toOffset - rect.center).distance;
        final double radius = rect.size.magnitude / 2;
        return distanceToCenter <= (radius + margin);

      case Shape.triangle:
        final path = _prepareTriangle(drawing: drawing);
        return path.contains(point.toOffset);

      case Shape.star:
        final path = _prepareStar(drawing: drawing);
        return path.contains(point.toOffset);
    }
  }

  Path _prepareTriangle({required Drawing drawing}) {
    final DrawingDelta firstDelta = drawing.deltas.firstWhere(
      (element) => element.operation == DrawingOperation.start,
    );
    final DrawingDelta secondDelta = drawing.deltas.lastWhere(
      (element) =>
          element.operation == DrawingOperation.neutral ||
          element.operation == DrawingOperation.end,
    );

    final double x1 = firstDelta.point.x;
    final double x2 = secondDelta.point.x;

    final double y1 = firstDelta.point.y;
    final double y2 = secondDelta.point.y;

    final PointDouble topVertex = PointDouble((x1 + x2) / 2, y2);

    final Path path = Path();

    path.moveTo(x1, y1);
    path.lineTo(topVertex.x, topVertex.y);

    path.lineTo(x2, y1);
    path.lineTo(x1, y1);

    return path;
  }

  Path _prepareStar({required Drawing drawing}) {
    final DrawingDelta firstDelta = drawing.deltas.firstWhere(
      (element) => element.operation == DrawingOperation.start,
    );
    final DrawingDelta secondDelta = drawing.deltas.lastWhere(
      (element) =>
          element.operation == DrawingOperation.neutral ||
          element.operation == DrawingOperation.end,
    );

    final Rect rect = Rect.fromPoints(
      firstDelta.point.toOffset,
      secondDelta.point.toOffset,
    );

    final Path path = Path();

    final double width = rect.width;
    final double height = rect.height;

    final PointDouble zero = rect.topLeft.point;

    final PointDouble v1 = PointDouble(
      zero.x + width / 2,
      rect.top,
    );

    final PointDouble m1 = PointDouble(
      zero.x + width.percent(38.8),
      (zero.y + height.percent(34.5)),
    );

    final PointDouble v2 = PointDouble(
      (zero.x + width.percent(2.5)),
      (zero.y + height.percent(34.5)),
    );

    final PointDouble m2 = PointDouble(
      (zero.x + width.percent(31.6)),
      (zero.y + height.percent(56.0)),
    );

    final PointDouble v3 = PointDouble(
      (zero.x + width.percent(18.5)),
      (zero.y + height.percent(90.5)),
    );

    final PointDouble m3 = PointDouble(
      (zero.x + width.percent(50)),
      (zero.y + height.percent(69.0)),
    );

    final PointDouble v4 = PointDouble(
      (zero.x + width.percent(81.5)),
      (zero.y + height.percent(90.5)),
    );

    final PointDouble m4 = PointDouble(
      (zero.x + width.percent(68.4)),
      (zero.y + height.percent(56.0)),
    );

    final PointDouble v5 = PointDouble(
      (zero.x + width.percent(97.5)),
      (zero.y + height.percent(34.5)),
    );

    final PointDouble m5 = PointDouble(
      zero.x + width.percent(61.2),
      (zero.y + height.percent(34.5)),
    );

    path.moveTo(v1.x, v1.y);
    path.lineTo(m1.x, m1.y);
    path.lineTo(v2.x, v2.y);
    path.lineTo(m2.x, m2.y);
    path.lineTo(v3.x, v3.y);
    path.lineTo(m3.x, m3.y);
    path.lineTo(v4.x, v4.y);
    path.lineTo(m4.x, m4.y);
    path.lineTo(v5.x, v5.y);
    path.lineTo(m5.x, m5.y);
    path.lineTo(v1.x, v1.y);
    return path;
  }

  Rect _prepareCircle({required Drawing drawing}) {
    final DrawingDelta firstDelta = drawing.deltas.firstWhere(
      (element) => element.operation == DrawingOperation.start,
    );
    final DrawingDelta secondDelta = drawing.deltas.lastWhere(
      (element) =>
          element.operation == DrawingOperation.neutral ||
          element.operation == DrawingOperation.end,
    );

    return Rect.fromPoints(
      firstDelta.point.toOffset,
      secondDelta.point.toOffset,
    );
  }

  Rect _prepareRectangle({required Drawing drawing}) {
    final DrawingDelta firstDelta = drawing.deltas.firstWhere(
      (element) => element.operation == DrawingOperation.start,
    );
    final DrawingDelta secondDelta = drawing.deltas.lastWhere(
      (element) =>
          element.operation == DrawingOperation.neutral ||
          element.operation == DrawingOperation.end,
    );

    return Rect.fromPoints(
      firstDelta.point.toOffset,
      secondDelta.point.toOffset,
    );
  }
}
