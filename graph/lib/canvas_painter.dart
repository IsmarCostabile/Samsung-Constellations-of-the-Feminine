import 'package:flutter/material.dart';

class CanvasPainter
    extends CustomPainter {
  final List<Offset> nodes;
  final List<List<int>> connections;

  CanvasPainter(
      this.nodes, this.connections);

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
