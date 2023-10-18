import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_drawio/src/drawing/drawing_barrel.dart';
import 'package:flutter_drawio/src/drawing/ui/controller/edit_drawing_item.dart';
import 'package:flutter_drawio/src/utils/utils_barrel.dart';
import 'package:uuid/uuid.dart';

/// This is the brain class of the package and is responsible for managing the state of the drawing process.
class DrawingController extends ChangeNotifier {
  final Function(Point<double>) onAddTextItem;
  final Function(TextDrawing) onEditTextItem;

  DrawingController({
    required this.onAddTextItem,
    required this.onEditTextItem,
  });

  late DrawingMode _drawingMode;
  DrawingMode get drawingMode => _drawingMode;

  @protected
  set drawingMode(DrawingMode value) {
    _drawingMode = value;
  }

  Drawings _drawings = [];
  Drawing? _currentlyActiveDrawing;
  EditDrawingItem? _editDrawingItem;

  final DrawingPainter<ShapeDrawing> _shapeDrawingPainter = const ShapePainter();
  final DrawingPainter<SketchDrawing> _sketchDrawingPainter = const SketchPainter();
  final DrawingPainter<LineDrawing> _lineDrawingPainter = const LineDrawingPainter();
  final DrawingPainter<TextDrawing> _textDrawingPainter = const TextDrawingPainter();

  Drawings get drawings => List.from(_drawings);

  @protected
  Drawings get mutableDrawing => _drawings;

  Drawing? get currentlyActiveDrawing => _currentlyActiveDrawing;

  set currentlyActiveDrawing(Drawing? value) {
    _currentlyActiveDrawing = value;
    notifyListeners();
  }

  final List<DrawingMode> _actionStack = List.from([]);

  void addTextItem({
    required String text,
    required DrawingTextStyle style,
    required PointDouble point,
  }) {
    _drawings = List.from([
      ...drawings,
      TextDrawing(
        id: const Uuid().v4(),
        style: style,
        text: text,
        deltas: [DrawingDelta(point: point)],
      ),
    ]);
    notifyListeners();
  }

  void editTextItem({
    required String id,
    required String text,
    required DrawingTextStyle style,
  }) {
    _drawings = _drawings.map((item) {
      if (item.id == id) {
        return (item as TextDrawing).copyWith(text: text, style: style);
      } else {
        return item;
      }
    }).toList();
    notifyListeners();
  }

  void onLongPressStart(PointDouble point) {
    if (drawingMode == DrawingMode.edit) {
      final touchedDrawing = _findTouchedShape(drawings: drawings, touchPoint: point);
      if (touchedDrawing != null && touchedDrawing is TextDrawing) {
        onEditTextItem(touchedDrawing);
      }
    }
  }

  void onTapDown(PointDouble point) {
    if (drawingMode == DrawingMode.text) {
      onAddTextItem(point);
    }
  }

  void onPanStart(DrawingDelta delta) {
    if (drawingMode == DrawingMode.edit) {
      final Drawing? touchedDrawing =
          _findTouchedShape(drawings: drawings, touchPoint: delta.point);

      if (touchedDrawing != null) {
        _editDrawingItem = EditDrawingItem(id: touchedDrawing.id, startPoint: delta.point);
      }
    } else {
      draw(delta);
    }
  }

  void onPanEnd(DrawingDelta delta) {
    if (drawingMode == DrawingMode.erase) return;

    if (drawingMode == DrawingMode.edit) {
      _editDrawingItem = null;
    } else {
      draw(delta);
    }
  }

  void onPanUpdate(DrawingDelta delta) {
    if (drawingMode == DrawingMode.edit) {
      if (_editDrawingItem != null) {
        final offsetToMove = delta.point.toOffset - _editDrawingItem!.startPoint.toOffset;
        _move(_editDrawingItem!.id, Point(offsetToMove.dx, offsetToMove.dy));
        _editDrawingItem = _editDrawingItem!.copyWith(delta.point);
      }
    } else {
      draw(delta);
    }
  }

  void _move(String id, PointDouble offset) {
    _drawings = List.from(
      drawings.map((drawing) {
        if (drawing.id == id) {
          return drawing.move(delta: offset);
        } else {
          return drawing;
        }
      }),
    );
    notifyListeners();
  }

  void startDrawing() {
    currentlyActiveDrawing = switch (drawingMode) {
      DrawingMode.shape => ShapeDrawing(
          id: const Uuid().v4(),
          metadata: metadataFor(),
          shape: shape,
          deltas: [],
        ),
      DrawingMode.line => LineDrawing(
          id: const Uuid().v4(),
          deltas: [],
          metadata: metadataFor(),
        ),
      _ => SketchDrawing(
          id: const Uuid().v4(),
          metadata: metadataFor(),
          deltas: [],
        ),
    };
  }

  late DrawingMetadata lineMetadata;
  late DrawingMetadata shapeMetadata;
  late DrawingMetadata sketchMetadata;
  late Shape shape;

  /// this method is for to get metadata according to the current or last valid
  /// drawing mode
  DrawingMetadata metadataFor([DrawingMode? mode]) {
    switch (_actionStack.lastOrNull) {
      case DrawingMode.sketch:
        return sketchMetadata;
      case DrawingMode.shape:
        return shapeMetadata;
      case DrawingMode.line:
        return lineMetadata;
      case DrawingMode.text:
      case DrawingMode.edit:
      case DrawingMode.erase:
      case null:
        return const DrawingMetadata();
    }
  }

  bool _initialized = false;

  bool get initialized => _initialized;

  /// This method is used to initialize the controller with the required parameters.
  ///
  /// It can/must be called only once.
  void initialize({
    Color? color,
    DrawingMode? drawingMode,
    DrawingMetadata? lineMetadata,
    DrawingMetadata? shapeMetadata,
    DrawingMetadata? sketchMetadata,
    Shape? shape,
    Drawings? drawings,
  }) {
    if (_initialized) return;
    _drawings = drawings ?? _drawings;

    this.shape = shape ?? Shape.rectangle;

    this.lineMetadata = lineMetadata ??
        DrawingMetadata(
          color: color ?? Colors.black,
          strokeWidth: 4,
        );
    this.shapeMetadata = shapeMetadata ??
        DrawingMetadata(
          color: color ?? Colors.black,
          strokeWidth: 4,
        );
    this.sketchMetadata = sketchMetadata ??
        DrawingMetadata(
          color: color ?? Colors.black,
          strokeWidth: 4,
        );

    this.drawingMode = drawingMode ?? DrawingMode.sketch;

    _actionStack.add(this.drawingMode);
    _initialized = true;
  }

  void changeDrawingMode(DrawingMode mode) {
    if (_actionStack.contains(mode)) _actionStack.remove(mode);
    _actionStack.add(mode);

    drawingMode = _actionStack.lastOrNull ?? mode;
    notifyListeners();
  }

  void changeShape(Shape newShape) {
    if (shape == newShape) return;
    shape = newShape;
    notifyListeners();
  }

  void changeColor(Color color) {
    sketchMetadata = sketchMetadata.copyWith(color: color);
    shapeMetadata = shapeMetadata.copyWith(color: color);
    lineMetadata = lineMetadata.copyWith(color: color);
    notifyListeners();
  }

  void changeStrokeWidth(double strokeWidth) {
    sketchMetadata = sketchMetadata.copyWith(strokeWidth: strokeWidth);
    shapeMetadata = shapeMetadata.copyWith(strokeWidth: strokeWidth);
    lineMetadata = lineMetadata.copyWith(strokeWidth: strokeWidth);

    notifyListeners();
  }

  void changeDrawings(Drawings drawings) {
    if (drawings.isEmpty) {
      changeDrawingMode(_actionStack.lastOrNull ?? DrawingMode.sketch);
    }
    _drawings = List.from(drawings);
    notifyListeners();
  }

  void draw(DrawingDelta delta) {
    Drawings drawings = List.from(_drawings);
    if (delta.operation == DrawingOperation.start) {
      startDrawing();
    }
    Drawing? drawing = currentlyActiveDrawing;

    switch (drawingMode) {
      case DrawingMode.erase:
        drawings = _erase(delta.point);
        break;
      case DrawingMode.sketch:
        drawing = _sketch(delta, drawing!);
        break;
      case DrawingMode.shape:
        {
          if (delta.operation == DrawingOperation.end) {
            drawing = drawing!.copyWith(
              deltas: List.from(drawing.deltas)
                ..replaceRange(
                  drawing.deltas.lastIndex,
                  drawing.deltas.lastIndex,
                  [
                    drawing.deltas.last.copyWith(
                      operation: DrawingOperation.end,
                    )
                  ],
                ),
            );
            break;
          }
          drawing = _drawShape(delta, drawing!);
          break;
        }
      case DrawingMode.line:
        drawing = _drawLine(delta, drawing!);
        break;
      case DrawingMode.edit:
      case DrawingMode.text:
        return;
    }
    //adds drawing if it's the last operation in the drawing, else updates the current drawing
    if (delta.operation == DrawingOperation.end) {
      drawings.add(drawing!);
      currentlyActiveDrawing = null;
      changeDrawings(drawings);
    } else {
      if (drawingMode == DrawingMode.erase) {
        changeDrawings(drawings);
      }

      currentlyActiveDrawing = drawing;
    }
  }

  void clearDrawings() {
    if (_actionStack.lastOrNull == DrawingMode.erase) _actionStack.removeLast();
    changeDrawingMode(_actionStack.lastOrNull ?? DrawingMode.sketch);

    changeDrawings([]);

    notifyListeners();
  }

  Drawing _sketch(DrawingDelta delta, Drawing drawing) {
    drawing = drawing.copyWith(
      deltas: List.from(drawing.deltas)..add(delta),
    );
    return drawing;
  }

  Drawings _erase(PointDouble point) {
    final copy = drawings.toList();
    final Drawing? drawingToRemove = _findTouchedShape(drawings: drawings, touchPoint: point);
    if (drawingToRemove != null) {
      copy.removeWhere((element) => element.id == drawingToRemove.id);
    }
    return copy;
  }

  Drawing _drawLine(DrawingDelta delta, Drawing drawing) {
    drawing = drawing.copyWith(
      deltas: List.from(drawing.deltas)..add(delta),
    );
    return drawing;
  }

  Drawing _drawShape(DrawingDelta delta, Drawing drawing) {
    final Drawing drawnDrawings = drawing.copyWith(
      deltas: List.from(drawing.deltas)..add(delta),
    );
    return drawnDrawings;
  }

  Color get color {
    return sketchMetadata.color ?? shapeMetadata.color ?? lineMetadata.color ?? Colors.black;
  }

  Drawing? _findTouchedShape({required List<Drawing> drawings, required Point<double> touchPoint}) {
    for (Drawing drawing in drawings) {
      switch (drawing) {
        case ShapeDrawing():
          if (_shapeDrawingPainter.contains(touchPoint, drawing)) {
            return drawing;
          }
          break;
        case LineDrawing():
          if (_lineDrawingPainter.contains(touchPoint, drawing)) {
            return drawing;
          }
        case SketchDrawing():
          if (_sketchDrawingPainter.contains(touchPoint, drawing)) {
            return drawing;
          }
        case TextDrawing():
          if (_textDrawingPainter.contains(touchPoint, drawing)) {
            return drawing;
          }
      }
    }
    return null;
  }
}
