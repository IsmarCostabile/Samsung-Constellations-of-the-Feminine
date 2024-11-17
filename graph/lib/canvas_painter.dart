import 'package:flutter/material.dart';

class CanvasPainter
    extends CustomPainter {
  final List<Offset> nodes;
  final List<List<int>> connections;
  final List<String>
      nodeTypes; // Add this line

  CanvasPainter(
      this.nodes,
      this.connections,
      this.nodeTypes); // Update constructor

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.0;

    for (var connection
        in connections) {
      final startNode =
          nodes[connection[0]];
      final endNode =
          nodes[connection[1]];

      final startRect = Rect.fromCenter(
          center: startNode,
          width: 200,
          height: 75);
      final endRect = Rect.fromCenter(
          center: endNode,
          width: 200,
          height: 75);

      final startPoint =
          _getEdgeIntersection(
              startRect, endNode);
      final endPoint =
          _getEdgeIntersection(
              endRect, startNode);

      canvas.drawLine(
          startPoint, endPoint, paint);
    }

    for (int i = 0;
        i < nodes.length;
        i++) {
      final node = nodes[i];
      final nodeType = nodeTypes[i];
      final paint = Paint()
        ..color = nodeType == 'root'
            ? Colors.red
            : nodeType == 'branch'
                ? Colors.blue
                : Colors.white
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
          node, 10.0, paint);
    }
  }

  Offset _getEdgeIntersection(
      Rect rect, Offset target) {
    final center = rect.center;
    final width = rect.width / 2;
    final height = rect.height / 2;

    final dx = target.dx - center.dx;
    final dy = target.dy - center.dy;

    double scale;
    if (dx.abs() / width >
        dy.abs() / height) {
      scale = width / dx.abs();
    } else {
      scale = height / dy.abs();
    }

    return Offset(
        center.dx + dx * scale,
        center.dy + dy * scale);
  }

  @override
  bool shouldRepaint(
      CanvasPainter oldDelegate) {
    return oldDelegate.nodes != nodes ||
        oldDelegate.connections !=
            connections;
  }
}
