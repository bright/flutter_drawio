import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_drawio/src/drawing/drawing_barrel.dart';
import 'package:flutter_drawio/src/drawing/sub_features/history_manager/draw_operation.dart';
import 'package:flutter_drawio/src/drawing/sub_features/history_manager/drawing_history_manager.dart';
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

  Drawings _drawings = [];
  Drawing? _currentlyActiveDrawing;
  EditDrawingItem? _editDrawingItem;
  PointDouble? _lastTouchedPoint;
  final DrawingHistoryManager _drawingHistoryManager = DrawingHistoryManager();

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

  bool get canUndo => _drawingHistoryManager.canUndo;
  bool get canRedo => _drawingHistoryManager.canRedo;

  void undo() {
    final operation = _drawingHistoryManager.undo();
    if (operation != null) {
      _undo(operation);
    }
  }

  void redo() {
    final operation = _drawingHistoryManager.redo();
    if (operation != null) {
      _redo(operation);
    }
  }

  void addTextItem({
    required String text,
    required DrawingTextStyle style,
    required PointDouble point,
  }) {
    final item = TextDrawing(
      id: const Uuid().v4(),
      style: style,
      text: text,
      deltas: [DrawingDelta(point: point)],
    );

    _drawings = List.from([
      ...drawings,
      item,
    ]);

    _drawingHistoryManager.addOperation(AddObjectOperation(addedObject: item));

    notifyListeners();
  }

  void editTextItem({
    required String id,
    required String text,
    required DrawingTextStyle style,
  }) {
    _drawings = _drawings.map((item) {
      if (item.id == id) {
        final editedItem = (item as TextDrawing).copyWith(text: text, style: style);
        _drawingHistoryManager.addOperation(
          EditObjectOperation(
            id: item.id,
            objectBeforeEdit: item,
            objectAfterEdit: editedItem,
          ),
        );
        return editedItem;
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
    _lastTouchedPoint = point;

    if (drawingMode == DrawingMode.text) {
      onAddTextItem(point);
    }
  }

  void onPanStart(DrawingDelta delta) {
    if (drawingMode == DrawingMode.edit) {
      final point = _lastTouchedPoint ?? delta.point;
      final Drawing? touchedDrawing = _findTouchedShape(drawings: drawings, touchPoint: point);

      if (touchedDrawing != null) {
        _editDrawingItem = EditDrawingItem(
          id: touchedDrawing.id,
          startPoint: point,
          startDeltas: touchedDrawing.deltas,
        );
      }
    } else {
      draw(delta);
    }

    _lastTouchedPoint = null;
  }

  void onPanEnd(DrawingDelta delta) {
    if (drawingMode == DrawingMode.erase) return;

    if (drawingMode == DrawingMode.edit) {
      if (_editDrawingItem != null) {
        _drawingHistoryManager.addOperation(
          MoveObjectOperation(
            id: _editDrawingItem!.id,
            startDeltas: _editDrawingItem!.startDeltas,
            endDeltas: _drawings.firstWhere((item) => item.id == _editDrawingItem!.id).deltas,
          ),
        );
      }
      _editDrawingItem = null;
    } else {
      draw(delta);
    }

    _lastTouchedPoint = null;
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
          metadata: _drawingMetadata,
          shape: shape,
          deltas: [],
        ),
      DrawingMode.line => LineDrawing(
          id: const Uuid().v4(),
          deltas: [],
          metadata: _drawingMetadata,
        ),
      _ => SketchDrawing(
          id: const Uuid().v4(),
          metadata: _drawingMetadata,
          deltas: [],
        ),
    };
  }

  late DrawingMetadata _drawingMetadata;
  Shape shape = Shape.rectangle;

  bool _initialized = false;

  bool get initialized => _initialized;

  /// This method is used to initialize the controller with the required parameters.
  ///
  /// It can/must be called only once.
  void initialize({
    Color? color,
    DrawingMode? drawingMode,
    Shape? shape,
    Drawings? drawings,
  }) {
    if (_initialized) return;
    _drawings = drawings ?? _drawings;
    _drawingMetadata = const DrawingMetadata(color: Colors.black, strokeWidth: 4);
    _drawingMode = drawingMode ?? DrawingMode.sketch;
    _initialized = true;
  }

  void changeDrawingMode(DrawingMode mode) {
    _drawingMode = mode;
    notifyListeners();
  }

  void changeShape(Shape newShape) {
    if (shape == newShape) return;
    shape = newShape;
    notifyListeners();
  }

  void changeColor(Color color) {
    _drawingMetadata = _drawingMetadata.copyWith(color: color);
    notifyListeners();
  }

  void changeStrokeWidth(double strokeWidth) {
    _drawingMetadata = _drawingMetadata.copyWith(strokeWidth: strokeWidth);
    notifyListeners();
  }

  void changeDrawings(Drawings drawings) {
    _drawings = List.from(drawings);
    notifyListeners();
  }

  void clear() {
    _drawings = [];
    _drawingHistoryManager.clear();
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
      _drawingHistoryManager.addOperation(AddObjectOperation(addedObject: drawing));
      currentlyActiveDrawing = null;
      changeDrawings(drawings);
    } else {
      if (drawingMode == DrawingMode.erase) {
        changeDrawings(drawings);
      }

      currentlyActiveDrawing = drawing;
    }
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
      _drawingHistoryManager.addOperation(DeleteObjectOperation(deletedObject: drawingToRemove));
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

  Color get color => _drawingMetadata.color;

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

  void _undo(DrawOperation operation) {
    List<Drawing> drawingsCopy = drawings.toList();
    switch (operation) {
      case AddObjectOperation():
        drawingsCopy.removeWhere((item) => item.id == operation.addedObject.id);

      case MoveObjectOperation():
        drawingsCopy = drawingsCopy.map((item) {
          if (item.id == operation.id) {
            return item.copyWith(deltas: operation.startDeltas);
          } else {
            return item;
          }
        }).toList();

      case EditObjectOperation():
        drawingsCopy = drawingsCopy.map((item) {
          if (item.id == operation.id) {
            return operation.objectBeforeEdit;
          } else {
            return item;
          }
        }).toList();

      case DeleteObjectOperation():
        drawingsCopy.add(operation.deletedObject);
    }

    changeDrawings(drawingsCopy);
  }

  void _redo(DrawOperation operation) {
    List<Drawing> drawingsCopy = drawings.toList();
    switch (operation) {
      case AddObjectOperation():
        drawingsCopy.add(operation.addedObject);

      case MoveObjectOperation():
        drawingsCopy = drawingsCopy.map((item) {
          if (item.id == operation.id) {
            return item.copyWith(deltas: operation.endDeltas);
          } else {
            return item;
          }
        }).toList();

      case EditObjectOperation():
        drawingsCopy = drawingsCopy.map((item) {
          if (item.id == operation.id) {
            return operation.objectAfterEdit;
          } else {
            return item;
          }
        }).toList();

      case DeleteObjectOperation():
        drawingsCopy.removeWhere((item) => item.id == operation.deletedObject.id);
    }

    changeDrawings(drawingsCopy);
  }
}
