part of '../drawing_canvas.dart';

class _PrimaryCanvas extends StatelessWidget {
  final DrawingController controller;
  final DrawingPainter<ShapeDrawing> shapeDrawingPainter;
  final DrawingPainter<SketchDrawing> sketchDrawingPainter;
  final DrawingPainter<LineDrawing> lineDrawingPainter;
  final DrawingPainter<TextDrawing> textDrawingPainter;

  const _PrimaryCanvas({
    Key? key,
    required this.controller,
    required this.lineDrawingPainter,
    required this.shapeDrawingPainter,
    required this.sketchDrawingPainter,
    required this.textDrawingPainter,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierBuilder<DrawingController>(
      listenable: controller,
      buildWhen: (previous, next) =>
          previous?.currentlyActiveDrawing == next.currentlyActiveDrawing,
      builder: (context, value) => value.currentlyActiveDrawing == null
          ? const SizedBox.shrink()
          : CustomPaint(
              painter: PrimaryDrawingsPainter(
                lineDrawingPainter: lineDrawingPainter,
                shapeDrawingPainter: shapeDrawingPainter,
                sketchDrawingPainter: sketchDrawingPainter,
                textDrawingPainter: textDrawingPainter,
                drawing: value.currentlyActiveDrawing!,
              ),
            ),
    );
  }
}
