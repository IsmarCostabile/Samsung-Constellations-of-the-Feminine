import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'canvas_painter.dart';
import 'info_card.dart';

class DraggableCanvas
    extends StatefulWidget {
  @override
  _DraggableCanvasState createState() =>
      _DraggableCanvasState();
}

class _DraggableCanvasState
    extends State<DraggableCanvas> {
  List<Offset> nodes = [];
  List<List<int>> connections = [];
  Offset? dragStartOffset;
  Size canvasSize = Size.zero;
  bool isEraserEnabled = false;
  bool isEditEnabled = false;
  int? selectedNodeIndex;
  double scale = 1.0;
  Offset canvasOffset = Offset.zero;
  Offset? lastFocalPoint;
  bool isPlaying = true;
  List<int>? selectedConnection;

  @override
  void initState() {
    super.initState();
    Timer.periodic(
        Duration(milliseconds: 16),
        (timer) {
      _applyForces();
      _centerGraph();
    });
  }

  void _addNode(Offset position) {
    final random = Random();
    setState(() {
      nodes.add(Offset(
        position.dx +
            (random.nextDouble() -
                    0.5) *
                10,
        position.dy +
            (random.nextDouble() -
                    0.5) *
                10,
      ));
    });
  }

  void _startDragging(
      int index, Offset startPosition) {
    setState(() {
      dragStartOffset =
          nodes[index] - startPosition;
    });
  }

  void _updateNodePosition(
      int index, Offset newPosition) {
    setState(() {
      nodes[index] = newPosition +
          dragStartOffset!;
    });
  }

  void _stopDragging() {
    setState(() {
      dragStartOffset = null;
    });
  }

  void _removeNode(int index) {
    setState(() {
      nodes.removeAt(index);
      connections.removeWhere(
          (connection) => connection
              .contains(index));
      for (var connection
          in connections) {
        if (connection[0] > index)
          connection[0]--;
        if (connection[1] > index)
          connection[1]--;
      }
    });
  }

  void _addConnection(
      int startIndex, int endIndex) {
    if (startIndex != endIndex) {
      setState(() {
        connections.add(
            [startIndex, endIndex]);
      });
    }
  }

  void _removeConnection(int index) {
    setState(() {
      connections.removeAt(index);
    });
  }

  void _onScaleStart(
      ScaleStartDetails details) {
    lastFocalPoint = details.focalPoint;
  }

  void _onScaleUpdate(
      ScaleUpdateDetails details) {
    setState(() {
      scale *= details.scale;
      canvasOffset +=
          details.focalPoint -
              lastFocalPoint!;
      lastFocalPoint =
          details.focalPoint;
    });
  }

  void _onScaleEnd(
      ScaleEndDetails details) {
    lastFocalPoint = null;
  }

  void _applyForces() {
    _applyRepulsion();
    _applyAttraction();
    _applyDamping();
    _applyEdgeCrossingReduction();
  }

  void _applyRepulsion() {
    const double repulsionStrength =
        100000.0;
    const double minDistance = 50.0;
    const double maxDistance = 300.0;

    List<Offset> forces = List.generate(
        nodes.length,
        (_) => Offset.zero);

    for (int i = 0;
        i < nodes.length;
        i++) {
      for (int j = i + 1;
          j < nodes.length;
          j++) {
        Offset direction =
            nodes[i] - nodes[j];
        double distance =
            direction.distance - 100;
        if (distance < minDistance) {
          distance = minDistance;
        }
        if (distance < maxDistance) {
          Offset repulsion = direction /
              distance *
              repulsionStrength /
              (distance * distance);
          forces[i] += repulsion;
          forces[j] -= repulsion;
        }
      }
    }

    setState(() {
      for (int i = 0;
          i < nodes.length;
          i++) {
        nodes[i] += forces[i];
      }
    });
  }

  void _applyAttraction() {
    const double attractionStrength =
        0.01;

    for (var connection
        in connections) {
      int startIndex = connection[0];
      int endIndex = connection[1];
      Offset direction =
          nodes[endIndex] -
              nodes[startIndex];
      double distance =
          direction.distance - 100;
      if (distance > 0) {
        Offset attraction = direction /
            distance *
            attractionStrength *
            distance;
        setState(() {
          nodes[startIndex] +=
              attraction;
          nodes[endIndex] -= attraction;
        });
      }
    }
  }

  void _applyDamping() {
    const double dampingFactor = 0.9;
    setState(() {
      for (int i = 0;
          i < nodes.length;
          i++) {
        nodes[i] =
            nodes[i] * dampingFactor +
                nodes[i] *
                    (1 - dampingFactor);
      }
    });
  }

  void _applyEdgeCrossingReduction() {
    const double
        edgeCrossingReductionStrength =
        0.1;

    for (int i = 0;
        i < connections.length;
        i++) {
      for (int j = i + 1;
          j < connections.length;
          j++) {
        var connection1 =
            connections[i];
        var connection2 =
            connections[j];

        var p1 = nodes[connection1[0]];
        var p2 = nodes[connection1[1]];
        var p3 = nodes[connection2[0]];
        var p4 = nodes[connection2[1]];

        if (_doEdgesIntersect(
            p1, p2, p3, p4)) {
          var mid1 = (p1 + p2) / 2;
          var mid2 = (p3 + p4) / 2;

          var direction = mid2 - mid1;
          var distance =
              direction.distance;

          if (distance > 0) {
            var displacement = direction /
                distance *
                edgeCrossingReductionStrength;
            setState(() {
              nodes[connection1[0]] -=
                  displacement;
              nodes[connection1[1]] +=
                  displacement;
              nodes[connection2[0]] +=
                  displacement;
              nodes[connection2[1]] -=
                  displacement;
            });
          }
        }
      }
    }
  }

  bool _doEdgesIntersect(Offset p1,
      Offset p2, Offset p3, Offset p4) {
    double d1 = _direction(p3, p4, p1);
    double d2 = _direction(p3, p4, p2);
    double d3 = _direction(p1, p2, p3);
    double d4 = _direction(p1, p2, p4);

    if (((d1 > 0 && d2 < 0) ||
            (d1 < 0 && d2 > 0)) &&
        ((d3 > 0 && d4 < 0) ||
            (d3 < 0 && d4 > 0))) {
      return true;
    }

    return false;
  }

  double _direction(
      Offset pi, Offset pj, Offset pk) {
    return (pk.dx - pi.dx) *
            (pj.dy - pi.dy) -
        (pj.dx - pi.dx) *
            (pk.dy - pi.dy);
  }

  void _randomizeNodePositions() {
    final random = Random();
    setState(() {
      nodes = nodes.map((node) {
        return Offset(
          canvasSize.width / 2 +
              (random.nextDouble() -
                      0.5) *
                  10,
          canvasSize.height / 2 +
              (random.nextDouble() -
                      0.5) *
                  10,
        );
      }).toList();
    });
  }

  void _adjustScaleToFitNodes() {
    if (nodes.isEmpty) return;

    double minX = nodes
        .map((node) => node.dx)
        .reduce(min);
    double maxX = nodes
        .map((node) => node.dx)
        .reduce(max);
    double minY = nodes
        .map((node) => node.dy)
        .reduce(min);
    double maxY = nodes
        .map((node) => node.dy)
        .reduce(max);

    double graphWidth = maxX - minX;
    double graphHeight = maxY - minY;

    double scaleX =
        canvasSize.width / graphWidth;
    double scaleY =
        canvasSize.height / graphHeight;

    setState(() {
      scale = min(scaleX, scaleY)
          .clamp(0.5, 1.0);
    });
  }

  void _centerGraph() {
    if (nodes.isEmpty) return;

    double minX = nodes
        .map((node) => node.dx)
        .reduce(min);
    double maxX = nodes
        .map((node) => node.dx)
        .reduce(max);
    double minY = nodes
        .map((node) => node.dy)
        .reduce(min);
    double maxY = nodes
        .map((node) => node.dy)
        .reduce(max);

    double graphWidth = maxX - minX;
    double graphHeight = maxY - minY;

    Offset graphCenter = Offset(
        minX + graphWidth / 2,
        minY + graphHeight / 2);
    Offset canvasCenter = Offset(
        canvasSize.width / 2,
        canvasSize.height / 2);

    setState(() {
      canvasOffset = canvasCenter -
          graphCenter * scale;
    });

    _adjustScaleToFitNodes();
  }

  void _onCanvasTap() {
    setState(() {
      selectedNodeIndex = null;
    });
  }

  Widget _buildNode(
      int index, Offset position) {
    return Positioned(
      left: (position.dx * scale +
              canvasOffset.dx) -
          100,
      top: (position.dy * scale +
              canvasOffset.dy) -
          37.5,
      child: GestureDetector(
        onTap: () {
          if (isEraserEnabled) {
            _removeNode(index);
          } else {
            if (selectedNodeIndex ==
                null) {
              selectedNodeIndex = index;
              if (!isPlaying) {
                print(
                    'Node $index: $position');
              }
            } else if (!isPlaying) {
              selectedNodeIndex = index;
              print(
                  'Node $index: $position');
            } else {
              _addConnection(
                  selectedNodeIndex!,
                  index);
              selectedNodeIndex = null;
            }
          }
        },
        onPanStart: (details) {
          if (!isEraserEnabled) {
            _startDragging(index,
                details.localPosition);
          }
        },
        onPanUpdate: (details) {
          if (!isEraserEnabled) {
            _updateNodePosition(index,
                details.localPosition);
          }
        },
        onPanEnd: (details) {
          if (!isEraserEnabled) {
            _stopDragging();
          }
        },
        child: SizedBox(
          width: 200,
          height: 75,
          child: InfoCard(
            title: 'title',
            description: 'description',
            isSelected:
                selectedNodeIndex ==
                    index,
          ),
        ),
      ),
    );
  }

  Widget _buildControlPanel() {
    return Positioned(
      bottom: 15,
      right: 15,
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(15),
        ),
        child: Row(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            _buildIconButton(
              isPlaying
                  ? Icons.pause
                  : Icons.play_arrow,
              () {
                setState(() {
                  isPlaying =
                      !isPlaying;
                });
              },
              isPlaying
                  ? Colors.red[200]
                  : Colors.green[200],
            ),
            _buildIconButton(
              Icons.delete,
              () {
                setState(() {
                  isEraserEnabled =
                      !isEraserEnabled;
                });
              },
              isEraserEnabled
                  ? Colors.red[200]
                  : Colors.grey[200],
            ),
            _buildIconButton(Icons.add,
                () {
              _addNode(Offset(
                  canvasSize.width / 2,
                  canvasSize.height /
                      2));
            }),
            _buildIconButton(
                Icons.shuffle,
                _randomizeNodePositions),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton(IconData icon,
      VoidCallback onPressed,
      [Color? color]) {
    return Container(
      margin: EdgeInsets.symmetric(
          horizontal: 5),
      decoration: BoxDecoration(
        color:
            color ?? Colors.grey[200],
        borderRadius:
            BorderRadius.circular(10),
      ),
      child: IconButton(
        icon: Icon(icon),
        onPressed: onPressed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        canvasSize = Size(
            constraints.maxWidth,
            constraints.maxHeight);
        return GestureDetector(
          onTap: _onCanvasTap,
          onScaleStart: _onScaleStart,
          onScaleUpdate: _onScaleUpdate,
          onScaleEnd: _onScaleEnd,
          child: Container(
            color: Color(0xFF14274E),
            child: Stack(
              children: [
                Transform(
                  transform:
                      Matrix4.identity()
                        ..translate(
                            canvasOffset
                                .dx,
                            canvasOffset
                                .dy)
                        ..scale(scale),
                  child: CustomPaint(
                    painter:
                        CanvasPainter(
                            nodes,
                            connections),
                    child: Container(),
                  ),
                ),
                ...nodes
                    .asMap()
                    .entries
                    .map((entry) {
                  int index = entry.key;
                  Offset position =
                      entry.value;
                  return _buildNode(
                      index, position);
                }).toList(),
                _buildControlPanel(),
              ],
            ),
          ),
        );
      },
    );
  }
}
