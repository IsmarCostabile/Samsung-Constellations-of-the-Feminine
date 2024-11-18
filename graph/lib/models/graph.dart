import 'package:flutter/material.dart';
import 'node_data.dart';

class Graph {
  final Map<String, NodeData> nodes = {};
  final List<(String, String)> connections = [];
  final List<Graph> subGraphs = [];
  NodeData? parentNode;

  Graph({this.parentNode});

  void addNode(NodeData node) {
    nodes[node.id] = node;
    if (node.type == 'super-node') {
      subGraphs.add(Graph(parentNode: node));
    }
  }

  void removeNode(String nodeId) {
    final node = nodes[nodeId];
    if (node != null) {
      if (node.type == 'super-node') {
        subGraphs.removeWhere((graph) => graph.parentNode?.id == nodeId);
      }
      // Remove connections involving this node
      connections.removeWhere(
          (conn) => conn.$1 == nodeId || conn.$2 == nodeId);
      nodes.remove(nodeId);
    }
  }

  void addConnection(String sourceId, String targetId) {
    if (sourceId != targetId && 
        nodes.containsKey(sourceId) && 
        nodes.containsKey(targetId)) {
      connections.add((sourceId, targetId));
      nodes[sourceId]?.addConnection(targetId);
      nodes[targetId]?.addConnection(sourceId);
    }
  }

  void removeConnection(String sourceId, String targetId) {
    connections.removeWhere(
        (conn) => (conn.$1 == sourceId && conn.$2 == targetId) ||
                  (conn.$1 == targetId && conn.$2 == sourceId));
    nodes[sourceId]?.removeConnection(targetId);
    nodes[targetId]?.removeConnection(sourceId);
  }

  Graph getSubGraph(String superNodeId) {
    return subGraphs.firstWhere(
      (graph) => graph.parentNode?.id == superNodeId,
      orElse: () => Graph(parentNode: nodes[superNodeId]),
    );
  }

  List<(Offset, NodeData)> getNodesWithPositions() {
    return nodes.values
        .map((node) => (node.position, node))
        .toList();
  }

  List<List<int>> getConnectionIndices() {
    final nodesList = nodes.values.toList();
    return connections
        .map((conn) => [
              nodesList.indexWhere((n) => n.id == conn.$1),
              nodesList.indexWhere((n) => n.id == conn.$2),
            ])
        .where((indices) => indices[0] != -1 && indices[1] != -1)
        .toList();
  }

  void updateNodePosition(String nodeId, Offset position) {
    nodes[nodeId]?.position = position;
  }

  Graph copy() {
    final newGraph = Graph(parentNode: parentNode?.copy());
    nodes.forEach((id, node) => newGraph.nodes[id] = node.copy());
    newGraph.connections.addAll(connections);
    subGraphs.forEach((subGraph) => newGraph.subGraphs.add(subGraph.copy()));
    return newGraph;
  }
}
