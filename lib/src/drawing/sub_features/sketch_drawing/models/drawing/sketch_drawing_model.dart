import 'package:flutter_drawio/src/drawing/drawing_barrel.dart';

/// This class is used to represent a [Drawing] of type [DrawingType.sketch].
base class SketchDrawing extends Drawing {
  SketchDrawing({
    required super.id,
    required super.deltas,
    super.metadata,
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

  @override
  String toString() {
    return '''\n
    SketchDrawing{
      id: $id,
      deltas: $deltas,
      metadata: $metadata,
    }''';
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': DrawingType.sketch.index,
      'deltas': deltas.map((e) => e.toMap()).toList(),
      'metadata': metadata?.toMap(),
    };
  }

  factory SketchDrawing.fromMap(Map<String, dynamic> map) {
    return SketchDrawing(
      id: map['id'],
      deltas: (map['deltas'] as List)
          .cast<Map>()
          .map<DrawingDelta>((e) => DrawingDelta.fromMap(e.cast()))
          .toList(),
      metadata: map['metadata'] == null
          ? null
          : DrawingMetadata.fromMap((map['metadata'] as Map).cast()),
    );
  }
}
