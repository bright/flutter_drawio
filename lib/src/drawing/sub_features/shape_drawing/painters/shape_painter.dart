import 'dart:math';

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
    const padding = 15.0;

    switch (drawing.shape) {
      case Shape.rectangle:
        final rect = _prepareRectangle(drawing: drawing, padding: padding);
        return rect.contains(point.toOffset);

      case Shape.circle:
        final rect = _prepareCircle(drawing: drawing, padding: padding);
        return rect.contains(point.toOffset);

      case Shape.triangle:
        final path = _prepareTriangle(drawing: drawing, padding: padding);
        return path.contains(point.toOffset);

      case Shape.star:
        final path = _prepareStar(drawing: drawing);
        return path.contains(point.toOffset);
    }
  }

  Path _prepareTriangle({required Drawing drawing, double padding = 0}) {
    final DrawingDelta firstDelta = drawing.deltas.firstWhere(
      (element) => element.operation == DrawingOperation.start,
    );
    final DrawingDelta secondDelta = drawing.deltas.lastWhere(
      (element) =>
          element.operation == DrawingOperation.neutral ||
          element.operation == DrawingOperation.end,
    );

    final PointDouble point1 = Point(firstDelta.point.x, firstDelta.point.y);
    final PointDouble point2 = Point(secondDelta.point.x, secondDelta.point.y);

    final PointDouble topVertex = PointDouble((point1.x + point2.x) / 2, point2.y);

    final PointDouble middlePoint =
        Point((point1.x + point2.x + topVertex.x) / 3, (point1.y + point1.y + topVertex.y) / 3);

    final PointDouble inflatedP1 = _inflateTrianglePoint(
      point: point1,
      middlePoint: middlePoint,
      padding: padding,
    );

    final PointDouble inflatedTopVertex = _inflateTrianglePoint(
      point: topVertex,
      middlePoint: middlePoint,
      padding: padding,
    );

    final PointDouble inflatedP2 = _inflateTrianglePoint(
      point: point2,
      middlePoint: middlePoint,
      padding: padding,
    );

    final Path path = Path();

    path.moveTo(inflatedP1.x, inflatedP1.y);
    path.lineTo(inflatedTopVertex.x, inflatedTopVertex.y);
    path.lineTo(inflatedP2.x, inflatedP1.y);
    path.lineTo(inflatedP1.x, inflatedP1.y);

    return path;
  }

  PointDouble _inflateTrianglePoint({
    required PointDouble point,
    required PointDouble middlePoint,
    required double padding,
  }) {
    final double dx = point.x - middlePoint.x;
    final double dy = point.y - middlePoint.y;

    final double distance = sqrt(dx * dx + dy * dy);
    final double newX = point.x + (padding * dx) / distance;
    final double newY = point.y + (padding * dy) / distance;

    return PointDouble(newX, newY);
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

  Rect _prepareCircle({required Drawing drawing, double padding = 0}) {
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
    ).inflate(padding);
  }

  Rect _prepareRectangle({required Drawing drawing, double padding = 0}) {
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
    ).inflate(padding);
  }
}
