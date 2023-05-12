# flutter_drawio

A flutter package for drawing on a canvas with an api provided for serialization and deserialization
of the drawn data.

## Features

- Sketch scribbles
- Draw shapes (rectangle, circle, triangle, star)
- erasing
- supports erase by area or drawing
- serialization and deserialization of drawn data

[video example here](https://user-images.githubusercontent.com/89414401/232181623-b4e9f934-e8fd-4fe5-889b-30c589c6b4f6.mov)

## Getting started

Add it to your pubspec.yaml file under dependencies like so:

```yaml
dependencies:
  flutter_drawio: ^1.0.0
```

or use commandline

```bash
flutter pub add flutter_drawio
```

then import it in your dart file

```dart
import 'package:flutter_drawio/flutter_drawio.dart';
```

## Usage

```dart

final DrawingController controller = DrawingController();

@override
void dispose() {
  //don't forget to dispose the controller
  controller.dispose();
  super.dispose();
}

@override
Widget build(BuildContext context) {
  return Scaffold(
    body: DrawingCanvas(
      //required param
      size: Size(
        MediaQuery
            .of(context)
            .size
            .width * 0.9,
        MediaQuery
            .of(context)
            .size
            .height * 0.9,
      ),
      controller: controller,
    ),
  );
}
```

## Additional information

To create issues, prs or otherwise contribute in anyway
see [contribution guide](https://github.com/folaoluwafemi/flutter_drawio/blob/main/CONTRIBUTION_GUIDE.md)
.
See our roadmap [here](https://github.com/folaoluwafemi/flutter_drawio/blob/main/ROADMAP.md)
