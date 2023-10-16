import 'dart:math';
import 'package:equatable/equatable.dart';
import 'package:flutter_drawio/src/drawing/drawing_barrel.dart';
import 'package:flutter_drawio/src/utils/utils_barrel.dart';
import 'package:uuid/uuid.dart';

part 'actionables/drawing_mode.dart';

part 'drawing_type.dart';

/// This is the base class for all [Drawing] objects.
abstract base class Drawing with EquatableMixin {
  final String id;
  final List<DrawingDelta> deltas;
  final DrawingMetadata? metadata;

  const Drawing({
    required this.id,
    required this.deltas,
    this.metadata,
  });

  /// This method is used to create a copy of the current [Drawing] object
  Drawing copyWith({
    List<DrawingDelta>? deltas,
    DrawingMetadata? metadata,
  });

  Drawing move({required PointDouble delta}) {
    return copyWith(
      deltas: deltas
          .map(
            (element) => element.copyWith(
              point: Point(
                element.point.x + delta.x,
                element.point.y + delta.y,
              ),
            ),
          )
          .toList(),
    );
  }

  /// This function is used to convert a list of [DrawingDelta]s and a [DrawingMetadata]to a [Drawing]
  static Drawing convertDeltasToDrawing<T extends Drawing>({
    required List<DrawingDelta> deltas,
    required DrawingMetadata? metadata,
    Shape? shape,
  }) {
    assert(
      () {
        if (T == ShapeDrawing) {
          return shape != null;
        }
        return true;
      }(),
      'Shape cannot be null when constructing a [ShapeDrawing] object',
    );
    switch (T) {
      case ShapeDrawing:
        return ShapeDrawing(
          id: const Uuid().v4(),
          shape: shape!,
          deltas: deltas,
          metadata: metadata,
        );
      default:
        return SketchDrawing(
          id: const Uuid().v4(),
          deltas: deltas,
          metadata: metadata,
        );
    }
  }

  @override
  List<Object?> get props => [metadata, ...deltas];

  Map<String, dynamic> toMap();

  /// This method is used to create a new instance of this class from a map
  factory Drawing.fromMap(Map<String, dynamic> map) {
    final DrawingType type =
        DrawingType.values[int.parse(map['type'].toString())];

    switch (type) {
      case DrawingType.shape:
        return ShapeDrawing.fromMap(map);
      case DrawingType.sketch:
        return SketchDrawing.fromMap(map);
      case DrawingType.line:
        // TODO: Handle this case.
        break;
    }
    //TODO: Change
    return SketchDrawing.fromMap(map);
  }
}
