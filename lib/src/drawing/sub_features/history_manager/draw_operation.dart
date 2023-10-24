import 'package:flutter_drawio/flutter_drawio.dart';

sealed class DrawOperation {}

class AddObjectOperation extends DrawOperation {
  final Drawing addedObject;

  AddObjectOperation({
    required this.addedObject,
  });
}

class MoveObjectOperation extends DrawOperation {
  final String id;
  final List<DrawingDelta> startDeltas;
  final List<DrawingDelta> endDeltas;

  MoveObjectOperation({
    required this.id,
    required this.startDeltas,
    required this.endDeltas,
  });
}

class EditObjectOperation extends DrawOperation {
  final String id;
  final Drawing objectBeforeEdit;
  final Drawing objectAfterEdit;

  EditObjectOperation({
    required this.id,
    required this.objectBeforeEdit,
    required this.objectAfterEdit,
  });
}

class DeleteObjectOperation extends DrawOperation {
  final Drawing deletedObject;

  DeleteObjectOperation({
    required this.deletedObject,
  });
}
