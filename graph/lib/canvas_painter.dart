import 'package:flutter/material.dart';

class CanvasPainter
    extends CustomPainter {
  final List<Offset> nodes;
  final List<List<int>> connections;
  final List<String> nodeTypes;

  CanvasPainter(this.nodes,
      this.connections, this.nodeTypes);

  @override
  void paint(Canvas canvas, Size size) {
    // Draw connections first (so they appear behind nodes)
    final connectionPaint = Paint()
      ..color =
          Colors.white.withOpacity(0.5)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    // Draw all connections with validation
    for (var connection
        in connections) {
      // Skip invalid connections
      if (connection.length != 2 ||
          connection[0] >=
              nodes.length ||
          connection[1] >=
              nodes.length ||
          connection[0] < 0 ||
          connection[1] < 0) {
        continue;
      }

      final startNode =
          nodes[connection[0]];
      final endNode =
          nodes[connection[1]];

      final startRect = Rect.fromCenter(
        center: startNode,
        width: 200,
        height: 75,
      );
      final endRect = Rect.fromCenter(
        center: endNode,
        width: 200,
        height: 75,
      );

      final startPoint =
          _getEdgeIntersection(
              startRect, endNode);
      final endPoint =
          _getEdgeIntersection(
              endRect, startNode);

      canvas.drawLine(startPoint,
          endPoint, connectionPaint);
    }

    // Draw nodes (dots) on top of connections
    final nodePaint = Paint()
      ..style = PaintingStyle.fill;

    for (int i = 0;
        i < nodes.length;
        i++) {
      switch (nodeTypes[i]) {
        case 'super-node':
          nodePaint.color =
              Colors.yellow;
          break;
        case 'parent':
          nodePaint.color = Colors.blue;
          break;
        default:
          nodePaint.color =
              Colors.white;
      }
      canvas.drawCircle(
          nodes[i], 5.0, nodePaint);
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
