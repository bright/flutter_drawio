import 'package:flutter_drawio/src/drawing/sub_features/history_manager/draw_operation.dart';

class DrawingHistoryManager {
  final int maxOperations;

  bool get canUndo => _undoStack.isNotEmpty;
  bool get canRedo => _redoStack.isNotEmpty;

  final List<DrawOperation> _undoStack = [];
  final List<DrawOperation> _redoStack = [];

  DrawingHistoryManager({this.maxOperations = 10});

  void addOperation(DrawOperation operation) {
    _undoStack.add(operation);

    _redoStack.clear();

    if (_undoStack.length > maxOperations) {
      _undoStack.removeAt(0);
    }
  }

  DrawOperation? undo() {
    if (canUndo) {
      final lastOperation = _undoStack.removeLast();
      _redoStack.add(lastOperation);
      return lastOperation;
    }
    return null;
  }

  DrawOperation? redo() {
    if (canRedo) {
      final lastRedoOperation = _redoStack.removeLast();
      _undoStack.add(lastRedoOperation);
      return lastRedoOperation;
    }
    return null;
  }

  void clear() {
    _undoStack.clear();
    _redoStack.clear();
  }
}
