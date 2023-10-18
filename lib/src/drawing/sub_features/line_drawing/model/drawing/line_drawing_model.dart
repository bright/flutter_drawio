import 'package:flutter_drawio/src/drawing/drawing_barrel.dart'
    show Drawing, DrawingDelta, DrawingMetadata, DrawingType;

/// This class is used to represent a [Drawing] of type [DrawingType.line].
base class LineDrawing extends Drawing {
  LineDrawing({
    required super.id,
    required super.deltas,
    super.metadata,
  });

  factory LineDrawing.fromMap(Map<String, dynamic> map) {
    return LineDrawing(
      id: map['id'] as String,
      deltas: (map['deltas'] as List)
          .cast<Map>()
          .map<DrawingDelta>((e) => DrawingDelta.fromMap(e.cast()))
          .toList(),
      metadata: map['metadata'] == null
          ? null
          : DrawingMetadata.fromMap((map['metadata'] as Map).cast()),
    );
  }

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

  @override
  String toString() {
    return '''\n
    LineDrawing{
      id: $id,
      deltas: $deltas,
      metadata: $metadata,
    }''';
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': DrawingType.line.index,
      'deltas': deltas.map((e) => e.toMap()).toList(),
      'metadata': metadata?.toMap(),
    };
  }
}
