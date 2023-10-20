import 'dart:math';
import 'package:flutter_drawio/flutter_drawio.dart';

class EditDrawingItem {
  final String id;
  final Point<double> startPoint;
  final List<DrawingDelta> startDeltas;

  EditDrawingItem({
    required this.id,
    required this.startPoint,
    required this.startDeltas,
  });

  EditDrawingItem copyWith(Point<double>? startPoint) => EditDrawingItem(
        id: id,
        startPoint: startPoint ?? this.startPoint,
        startDeltas: startDeltas,
      );
}
