import 'package:flutter_drawio/src/drawing/sub_features/undo/draw_operation.dart';

class UndoManager {
  final int maxOperations;

  bool get canUndo => _operations.isNotEmpty;
  final List<DrawOperation> _operations = [];

  UndoManager({this.maxOperations = 10});

  void addOperation(DrawOperation operation) {
    _operations.add(operation);

    if (_operations.length > maxOperations) {
      _operations.removeAt(0);
    }
  }

  DrawOperation? undo() {
    if (canUndo) {
      final lastOperation = _operations.removeLast();
      return lastOperation;
    }
    return null;
  }

  void clear() {
    _operations.clear();
  }
}
