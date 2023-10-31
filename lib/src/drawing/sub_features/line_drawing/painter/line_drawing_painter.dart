import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_drawio/src/drawing/drawing_barrel.dart';
import 'package:flutter_drawio/src/utils/constants/typedefs.dart';

/// This class holds the active methods for painting a [LineDrawing] object.
base class LineDrawingPainter extends DrawingPainter<LineDrawing> {
  const LineDrawingPainter();

  @override
  void paintDrawing(Canvas canvas, Size size, LineDrawing drawing) {
    if (drawing.deltas.length == 1) return;

    final Paint paint = Paint()
      ..color = drawing.metadata.color
      ..strokeWidth = drawing.metadata.strokeWidth
      ..style = PaintingStyle.stroke;

    final Path path = Path()..moveTo(0, 0);

    final DrawingDelta firstDelta = drawing.deltas.firstWhere(
      (element) => element.operation == DrawingOperation.start,
    );
    final DrawingDelta latestDelta = drawing.deltas.lastWhere(
      (element) => element.operation == DrawingOperation.neutral,
    );

    path
      ..moveTo(firstDelta.point.x, firstDelta.point.y)
      ..lineTo(latestDelta.point.x, latestDelta.point.y);

    canvas.drawPath(path, paint);
  }

  @override
  bool contains(PointDouble point, LineDrawing drawing) {
    final double buffer = (drawing.metadata.strokeWidth) + 10;
    final double distance = _distanceFromPointToLine(point, drawing.deltas);
    return distance <= buffer;
  }

  double _distanceFromPointToLine(PointDouble point, List<DrawingDelta> deltas) {
    final DrawingDelta firstDelta = deltas.firstWhere(
      (element) => element.operation == DrawingOperation.start,
    );
    final DrawingDelta latestDelta = deltas.lastWhere(
      (element) => element.operation == DrawingOperation.neutral,
    );
    double dotProduct =
        (point.x - firstDelta.point.x) * (latestDelta.point.x - firstDelta.point.x) +
            (point.y - firstDelta.point.y) * (latestDelta.point.y - firstDelta.point.y);
    num lineLengthSquared = pow(latestDelta.point.x - firstDelta.point.x, 2) +
        pow(latestDelta.point.y - firstDelta.point.y, 2);

    if (dotProduct < 0) {
      return point.distanceTo(firstDelta.point);
    }
    if (dotProduct > lineLengthSquared) {
      return point.distanceTo(latestDelta.point);
    }

    final double numerator = (latestDelta.point.y - firstDelta.point.y) * point.x -
        (latestDelta.point.x - firstDelta.point.x) * point.y +
        latestDelta.point.x * firstDelta.point.y -
        latestDelta.point.y * firstDelta.point.x;
    final double denominator = sqrt(lineLengthSquared);

    return numerator.abs() / denominator;
  }
}
