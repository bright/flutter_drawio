import 'dart:math';
import 'package:equatable/equatable.dart';
import 'package:flutter_drawio/src/drawing/drawing_barrel.dart';
import 'package:flutter_drawio/src/utils/utils_barrel.dart';

sealed class Drawing with EquatableMixin {
  final String id;
  final List<DrawingDelta> deltas;
  final DrawingMetadata metadata;

  const Drawing({
    required this.id,
    required this.deltas,
    required this.metadata,
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

  @override
  List<Object?> get props => [id, ...deltas, metadata];
}

class LineDrawing extends Drawing {
  LineDrawing({
    required super.id,
    required super.deltas,
    required super.metadata,
  });

  @override
  Drawing copyWith({
    List<DrawingDelta>? deltas,
    DrawingMetadata? metadata,
  }) {
    return LineDrawing(
      deltas: deltas ?? this.deltas,
      metadata: metadata ?? this.metadata,
      id: id,
    );
  }
}

class ShapeDrawing extends Drawing {
  final Shape shape;

  ShapeDrawing({
    required super.id,
    required this.shape,
    required super.deltas,
    required super.metadata,
  });

  @override
  ShapeDrawing copyWith({
    final Shape? shape,
    List<DrawingDelta>? deltas,
    DrawingMetadata? metadata,
  }) {
    return ShapeDrawing(
      shape: shape ?? this.shape,
      deltas: deltas ?? this.deltas,
      metadata: metadata ?? this.metadata,
      id: id,
    );
  }
}

class SketchDrawing extends Drawing {
  SketchDrawing({
    required super.id,
    required super.deltas,
    required super.metadata,
  });

  @override
  SketchDrawing copyWith({
    List<DrawingDelta>? deltas,
    DrawingMetadata? metadata,
  }) {
    return SketchDrawing(
      deltas: deltas ?? this.deltas,
      metadata: metadata ?? this.metadata,
      id: id,
    );
  }
}

class TextDrawing extends Drawing {
  final String text;
  final DrawingTextStyle style;
  TextDrawing({
    required String id,
    required List<DrawingDelta> deltas,
    required this.style,
    required this.text,
  }) : super(id: id, deltas: deltas, metadata: DrawingMetadata.initial);

  @override
  Drawing copyWith({
    List<DrawingDelta>? deltas,
    DrawingMetadata? metadata,
    String? text,
    DrawingTextStyle? style,
  }) {
    return TextDrawing(
      id: id,
      deltas: deltas ?? this.deltas,
      style: style ?? this.style,
      text: text ?? this.text,
    );
  }
}
