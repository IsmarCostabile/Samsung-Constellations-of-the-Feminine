import 'package:flutter/material.dart';
import '../models/node_data.dart';

class ForceSimulation {
  static void applyForces(List<(Offset, NodeData)> nodes, List<List<int>> connections) {
    applyRepulsion(nodes);
    applyAttraction(nodes, connections);
    applyDamping(nodes);
    applyEdgeCrossingReduction(nodes, connections);
  }

  static void applyRepulsion(List<(Offset, NodeData)> nodes) {
    const double repulsionStrength = 100000.0;
    const double minDistance = 50.0;
    const double maxDistance = 300.0;

    List<Offset> forces = List.generate(nodes.length, (_) => Offset.zero);

    for (int i = 0; i < nodes.length; i++) {
      for (int j = i + 1; j < nodes.length; j++) {
        Offset direction = nodes[i].$1 - nodes[j].$1;
        double distance = direction.distance - 100;
        if (distance < minDistance) distance = minDistance;
        if (distance < maxDistance) {
          Offset repulsion = direction / distance * repulsionStrength / (distance * distance);
          forces[i] += repulsion;
          forces[j] -= repulsion;
        }
      }
    }

    for (int i = 0; i < nodes.length; i++) {
      nodes[i] = (nodes[i].$1 + forces[i], nodes[i].$2);
    }
  }

  static void applyAttraction(List<(Offset, NodeData)> nodes, List<List<int>> connections) {
    const double attractionStrength = 0.01;

    for (var connection in connections) {
      int startIndex = connection[0];
      int endIndex = connection[1];
      Offset direction = nodes[endIndex].$1 - nodes[startIndex].$1;
      double distance = direction.distance - 100;
      if (distance > 0) {
        Offset attraction = direction / distance * attractionStrength * distance;
        nodes[startIndex] = (nodes[startIndex].$1 + attraction, nodes[startIndex].$2);
        nodes[endIndex] = (nodes[endIndex].$1 - attraction, nodes[endIndex].$2);
      }
    }
  }

  static void applyDamping(List<(Offset, NodeData)> nodes) {
    const double dampingFactor = 0.9;
    for (int i = 0; i < nodes.length; i++) {
      nodes[i] = (nodes[i].$1 * dampingFactor + nodes[i].$1 * (1 - dampingFactor), nodes[i].$2);
    }
  }

  static void applyEdgeCrossingReduction(List<(Offset, NodeData)> nodes, List<List<int>> connections) {
    const double edgeCrossingReductionStrength = 0.1;

    for (int i = 0; i < connections.length; i++) {
      for (int j = i + 1; j < connections.length; j++) {
        var connection1 = connections[i];
        var connection2 = connections[j];

        var p1 = nodes[connection1[0]].$1;
        var p2 = nodes[connection1[1]].$1;
        var p3 = nodes[connection2[0]].$1;
        var p4 = nodes[connection2[1]].$1;

        if (_doEdgesIntersect(p1, p2, p3, p4)) {
          var mid1 = (p1 + p2) / 2;
          var mid2 = (p3 + p4) / 2;

          var direction = mid2 - mid1;
          var distance = direction.distance;

          if (distance > 0) {
            var displacement = direction / distance * edgeCrossingReductionStrength;
            nodes[connection1[0]] = (nodes[connection1[0]].$1 - displacement, nodes[connection1[0]].$2);
            nodes[connection1[1]] = (nodes[connection1[1]].$1 + displacement, nodes[connection1[1]].$2);
            nodes[connection2[0]] = (nodes[connection2[0]].$1 + displacement, nodes[connection2[0]].$2);
            nodes[connection2[1]] = (nodes[connection2[1]].$1 - displacement, nodes[connection2[1]].$2);
          }
        }
      }
    }
  }

  static bool _doEdgesIntersect(Offset p1, Offset p2, Offset p3, Offset p4) {
    double d1 = _direction(p3, p4, p1);
    double d2 = _direction(p3, p4, p2);
    double d3 = _direction(p1, p2, p3);
    double d4 = _direction(p1, p2, p4);

    return ((d1 > 0 && d2 < 0) || (d1 < 0 && d2 > 0)) && ((d3 > 0 && d4 < 0) || (d3 < 0 && d4 > 0));
  }

  static double _direction(Offset pi, Offset pj, Offset pk) {
    return (pk.dx - pi.dx) * (pj.dy - pi.dy) - (pj.dx - pi.dx) * (pk.dy - pi.dy);
  }
}
