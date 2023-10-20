import 'package:flutter_drawio/flutter_drawio.dart';

sealed class DrawOperation {}

class AddObjectOperation extends DrawOperation {
  final String id;

  AddObjectOperation({
    required this.id,
  });
}

class MoveObjectOperation extends DrawOperation {
  final String id;
  final List<DrawingDelta> startDeltas;

  MoveObjectOperation({
    required this.id,
    required this.startDeltas,
  });
}

class EditObjectOperation extends DrawOperation {
  final String id;
  final Drawing objectBeforeEdit;

  EditObjectOperation({
    required this.id,
    required this.objectBeforeEdit,
  });
}

class DeleteObjectOperation extends DrawOperation {
  final Drawing deletedObject;

  DeleteObjectOperation({
    required this.deletedObject,
  });
}
