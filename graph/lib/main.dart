import 'package:flutter/material.dart';
import 'draggable_canvas.dart';
import 'data_section.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Row(
          children: [
            Expanded(
              flex: 2,
              child: DraggableCanvas(),
            ),
            Expanded(
              flex: 1,
              child: DataSection(),
            ),
          ],
        ),
      ),
    );
  }
}
