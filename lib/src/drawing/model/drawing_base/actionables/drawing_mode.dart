import 'package:flutter_drawio/src/utils/function/extensions/extensions.dart';

/// This defines the drawing mode of the [DrawingController].
enum DrawingMode {
  erase,
  sketch,
  shape,
  line,
  edit,
  text;

  factory DrawingMode.fromString(String data) {
    data = data.cleanLower;
    return DrawingMode.values.firstWhere(
      (element) => element.name.cleanLower == data,
    );
  }

  String get toSerializerString => name;
}
