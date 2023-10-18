import 'dart:math';

class EditDrawingItem {
  final String id;
  final Point<double> startPoint;

  EditDrawingItem({
    required this.id,
    required this.startPoint,
  });

  EditDrawingItem copyWith(Point<double>? startPoint) => EditDrawingItem(
        id: id,
        startPoint: startPoint ?? this.startPoint,
      );
}
