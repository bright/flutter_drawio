import 'package:flutter/material.dart';
import 'package:flutter_drawio/flutter_drawio.dart';

void main() {
  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const ExamplePage(),
      theme: ThemeData.dark(),
    );
  }
}

class ExamplePage extends StatefulWidget {
  const ExamplePage({Key? key}) : super(key: key);

  @override
  State<ExamplePage> createState() => _ExamplePageState();
}

class _ExamplePageState extends State<ExamplePage> {
  final DrawingController controller = DrawingController(
    onAddTextItem: (point) {},
    onEditTextItem: (item) {},
  )..initialize();

  @override
  void initState() {
    super.initState();
    controller.addListener(_update);
  }

  void _update() {
    setState(() {});
  }

  @override
  void dispose() {
    controller.removeListener(_update);
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.color_lens),
            onPressed: () => controller.changeColor(
              controller.color == Colors.red ? Colors.blue : Colors.red,
            ),
          ),
          IconButton(
            icon: switch (controller.drawingMode) {
              DrawingMode.line => const Icon(Icons.shape_line),
              DrawingMode.shape => const Icon(Icons.format_shapes),
              _ => const Icon(Icons.brush),
            },
            onPressed: () => controller.changeDrawingMode(
              switch (controller.drawingMode) {
                DrawingMode.line => DrawingMode.sketch,
                DrawingMode.shape => DrawingMode.line,
                _ => DrawingMode.shape,
              },
            ),
          ),
          //add icon buttons for all the shapes
          IconButton(
            icon: const Icon(Icons.circle_outlined),
            onPressed: () => controller.changeShape(Shape.circle),
          ),
          IconButton(
            icon: const Icon(Icons.star),
            onPressed: () => controller.changeShape(Shape.star),
          ),
          IconButton(
            icon: const Icon(Icons.crop_square),
            onPressed: () => controller.changeShape(Shape.rectangle),
          ),
          IconButton(
            icon: const Icon(Icons.signal_cellular_0_bar_rounded),
            onPressed: () => controller.changeShape(Shape.triangle),
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => controller.drawingMode == DrawingMode.edit
                ? controller.changeDrawingMode(DrawingMode.shape)
                : controller.changeDrawingMode(DrawingMode.edit),
          ),
          IconButton(
            icon: const Icon(Icons.text_fields_outlined),
            onPressed: () => controller.changeDrawingMode(DrawingMode.text),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => controller.changeDrawingMode(DrawingMode.erase),
          ),
          IconButton(
            icon: const Icon(Icons.undo),
            onPressed: controller.canUndo ? () => controller.undo() : null,
          ),

          const Spacer(),
        ],
      ),
      body: DrawingCanvas(
        size: Size(
          MediaQuery.of(context).size.width * 0.9,
          MediaQuery.of(context).size.height * 0.9,
        ),
        controller: controller,
      ),
    );
  }
}
