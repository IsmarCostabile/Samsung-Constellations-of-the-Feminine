import 'package:flutter/material.dart';
import '../models/node_data.dart';
import 'dart:math';

class NodeController {
  List<(Offset, NodeData)> nodes = [];
  List<List<int>> connections = [];
  List<String> nodeTypes = [];

  void addNode(Offset position, NodeData data) {
    final random = Random();
    nodes.add((
      Offset(
        position.dx + (random.nextDouble() - 0.5) * 10,
        position.dy + (random.nextDouble() - 0.5) * 10,
      ),
      data
    ));
    nodeTypes.add(data.type);
  }

  void removeNode(int index) {
    nodes.removeAt(index);
    nodeTypes.removeAt(index);
    connections.removeWhere((connection) => connection.contains(index));

    for (var connection in connections) {
      if (connection[0] > index) connection[0]--;
      if (connection[1] > index) connection[1]--;
    }
  }

  void addConnection(int startIndex, int endIndex) {
    if (startIndex != endIndex) {
      final startNode = nodes[startIndex].$2;
      final endNode = nodes[endIndex].$2;

      if (!startNode.hasConnection(endNode.id)) {
        startNode.addConnection(endNode.id);
        endNode.addConnection(startNode.id);
        connections.add([startIndex, endIndex]);
      }
    }
  }

  void removeConnection(int index) {
    if (index < connections.length) {
      final startNode = nodes[connections[index][0]].$2;
      final endNode = nodes[connections[index][1]].$2;
      startNode.removeConnection(endNode.id);
      endNode.removeConnection(startNode.id);
      connections.removeAt(index);
    }
  }

  bool areNodesConnected(int node1, int node2) {
    if (node1 >= nodes.length || node2 >= nodes.length) return false;
    final node1Data = nodes[node1].$2;
    final node2Data = nodes[node2].$2;
    return node1Data.hasConnection(node2Data.id);
  }
}
