part of 'drawing_delta.dart';

/// This defines the styling data for any drawing.
class DrawingMetadata with EquatableMixin {
  final Color color;
  final double strokeWidth;

  const DrawingMetadata({
    required this.color,
    required this.strokeWidth,
  });

  @override
  List<Object?> get props => [color, strokeWidth];

  DrawingMetadata copyWith({
    Color? color,
    double? strokeWidth,
  }) {
    return DrawingMetadata(
      color: color ?? this.color,
      strokeWidth: strokeWidth ?? this.strokeWidth,
    );
  }

  static DrawingMetadata get initial => const DrawingMetadata(color: Colors.black, strokeWidth: 4);
}
