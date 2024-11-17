import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math';
import 'canvas_painter.dart';
import 'widgets/info_card.dart';
import 'models/node_data.dart';
import 'widgets/add_node_dialog.dart';

// Add these imports at the top
import 'dart:async';

class DraggableCanvas
    extends StatefulWidget {
  static final selectedNodeController =
      StreamController<
          NodeData?>.broadcast();

  const DraggableCanvas({super.key});

  @override
  _DraggableCanvasState createState() =>
      _DraggableCanvasState();
}

class _DraggableCanvasState
    extends State<DraggableCanvas> {
  // Remove the static selectedNodeController from here since it's moved to the widget class

  List<(Offset, NodeData)> nodes = [];
  List<List<int>> connections = [];
  List<String> nodeTypes =
      []; // Add this line
  Offset? dragStartOffset;
  Size canvasSize = Size.zero;
  bool isEraserEnabled = false;
  bool isEditEnabled = false;
  int? selectedNodeIndex;
  double scale = 1.0;
  Offset canvasOffset = Offset.zero;
  Offset? lastFocalPoint;
  bool isPlaying = true;
  int? selectedConnection;

  @override
  void initState() {
    super.initState();
    Timer.periodic(
        const Duration(
            milliseconds: 16), (timer) {
      _applyForces();
      _centerGraph();
    });
  }

  @override
  void dispose() {
    DraggableCanvas
        .selectedNodeController
        .close(); // Updated to use the widget's controller
    super.dispose();
  }

  Future<void>
      _showAddNodeDialog() async {
    final nodeData =
        await showAddNodeDialog(
            context);
    if (nodeData != null) {
      _addNode(
        Offset(canvasSize.width / 2,
            canvasSize.height / 2),
        nodeData,
      );
    }
  }

  void _addNode(
      Offset position, NodeData data) {
    final random = Random();
    setState(() {
      nodes.add((
        Offset(
          position.dx +
              (random.nextDouble() -
                      0.5) *
                  10,
          position.dy +
              (random.nextDouble() -
                      0.5) *
                  10,
        ),
        data
      ));
      nodeTypes.add(
          data.type); // Add this line
    });
  }

  void _startDragging(
      int index, Offset startPosition) {
    setState(() {
      dragStartOffset =
          nodes[index].$1 -
              startPosition;
    });
  }

  void _updateNodePosition(
      int index, Offset newPosition) {
    setState(() {
      nodes[index] = (
        newPosition + dragStartOffset!,
        nodes[index].$2
      );
    });
  }

  void _stopDragging() {
    setState(() {
      dragStartOffset = null;
    });
  }

  Future<bool> _showDeleteConfirmation(
      BuildContext context,
      String type) async {
    String itemType = type == 'node'
        ? 'nodo'
        : 'connessione';
    return await showDialog(
          context: context,
          builder:
              (BuildContext context) {
            return AlertDialog(
              title: Text(
                  'Conferma l\'eliminazione'),
              content: Text(
                  'Sei sicuro/a di voler eliminare questo $itemType?'),
              actions: [
                TextButton(
                  onPressed: () =>
                      Navigator.of(
                              context)
                          .pop(false),
                  child:
                      Text('Annulla'),
                  style: TextButton
                      .styleFrom(
                    foregroundColor:
                        Colors
                            .grey[600],
                  ),
                ),
                TextButton(
                  onPressed: () =>
                      Navigator.of(
                              context)
                          .pop(true),
                  child:
                      Text('Elimina'),
                  style: TextButton
                      .styleFrom(
                    foregroundColor:
                        Colors.red,
                  ),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  void _removeNode(int index) async {
    bool confirmed =
        await _showDeleteConfirmation(
            context, 'node');
    if (!confirmed) return;

    setState(() {
      nodes.removeAt(index);
      nodeTypes.removeAt(index);

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

      selectedNodeIndex = null;
      DraggableCanvas
          .selectedNodeController
          .add(null);
    });
  }

  void _removeConnection(
      int index) async {
    bool confirmed =
        await _showDeleteConfirmation(
            context, 'connection');
    if (!confirmed) return;

    setState(() {
      connections.removeAt(index);
      selectedConnection = null;
    });
  }

  bool _areNodesConnected(
      int node1, int node2) {
    return connections.any(
        (connection) =>
            (connection[0] == node1 &&
                connection[1] ==
                    node2) ||
            (connection[0] == node2 &&
                connection[1] ==
                    node1));
  }

  void _addConnection(
      int startIndex, int endIndex) {
    if (startIndex != endIndex &&
        !_areNodesConnected(
            startIndex, endIndex)) {
      setState(() {
        connections.add(
            [startIndex, endIndex]);
      });
    }
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
            nodes[i].$1 - nodes[j].$1;
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
        nodes[i] = (
          nodes[i].$1 + forces[i],
          nodes[i].$2
        );
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
          nodes[endIndex].$1 -
              nodes[startIndex].$1;
      double distance =
          direction.distance - 100;
      if (distance > 0) {
        Offset attraction = direction /
            distance *
            attractionStrength *
            distance;
        setState(() {
          nodes[startIndex] = (
            nodes[startIndex].$1 +
                attraction,
            nodes[startIndex].$2
          );
          nodes[endIndex] = (
            nodes[endIndex].$1 -
                attraction,
            nodes[endIndex].$2
          );
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
        nodes[i] = (
          nodes[i].$1 * dampingFactor +
              nodes[i].$1 *
                  (1 - dampingFactor),
          nodes[i].$2
        );
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

        var p1 =
            nodes[connection1[0]].$1;
        var p2 =
            nodes[connection1[1]].$1;
        var p3 =
            nodes[connection2[0]].$1;
        var p4 =
            nodes[connection2[1]].$1;

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
              nodes[connection1[0]] = (
                nodes[connection1[0]]
                        .$1 -
                    displacement,
                nodes[connection1[0]].$2
              );
              nodes[connection1[1]] = (
                nodes[connection1[1]]
                        .$1 +
                    displacement,
                nodes[connection1[1]].$2
              );
              nodes[connection2[0]] = (
                nodes[connection2[0]]
                        .$1 +
                    displacement,
                nodes[connection2[0]].$2
              );
              nodes[connection2[1]] = (
                nodes[connection2[1]]
                        .$1 -
                    displacement,
                nodes[connection2[1]].$2
              );
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
        return (
          Offset(
            canvasSize.width / 2 +
                (random.nextDouble() -
                        0.5) *
                    10,
            canvasSize.height / 2 +
                (random.nextDouble() -
                        0.5) *
                    10,
          ),
          node.$2
        );
      }).toList();
    });
  }

  void _adjustScaleToFitNodes() {
    if (nodes.isEmpty) return;

    double minX = nodes
        .map((node) => node.$1.dx)
        .reduce(min);
    double maxX = nodes
        .map((node) => node.$1.dx)
        .reduce(max);
    double minY = nodes
        .map((node) => node.$1.dy)
        .reduce(min);
    double maxY = nodes
        .map((node) => node.$1.dy)
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
        .map((node) => node.$1.dx)
        .reduce(min);
    double maxX = nodes
        .map((node) => node.$1.dx)
        .reduce(max);
    double minY = nodes
        .map((node) => node.$1.dy)
        .reduce(min);
    double maxY = nodes
        .map((node) => node.$1.dy)
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
      selectedConnection = null;
      DraggableCanvas
          .selectedNodeController
          .add(null); // Add this line
    });
  }

  Widget _buildNode(int index,
      (Offset, NodeData) node) {
    return Positioned(
      left: (node.$1.dx * scale +
              canvasOffset.dx) -
          100,
      top: (node.$1.dy * scale +
              canvasOffset.dy) -
          37.5,
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedConnection =
                null; // Clear selected edge when a node is clicked
          });

          if (isEraserEnabled) {
            _removeNode(index);
          } else {
            if (selectedNodeIndex ==
                null) {
              selectedNodeIndex = index;
              DraggableCanvas
                  .selectedNodeController
                  .add(node
                      .$2); // Updated to use the widget's controller
            } else if (!isPlaying) {
              selectedNodeIndex = index;
              DraggableCanvas
                  .selectedNodeController
                  .add(node
                      .$2); // Updated to use the widget's controller
            } else {
              _addConnection(
                  selectedNodeIndex!,
                  index);
              // Update these lines to select the second node after connection
              selectedNodeIndex = index;
              DraggableCanvas
                  .selectedNodeController
                  .add(node.$2);
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
            type: node.$2.type,
            title: node.$2.title,
            description:
                node.$2.description,
            imageUrl: node.$2.images
                    .isNotEmpty
                ? node.$2.images[0]
                : null, // Fix: remove nodeData reference
            isSelected:
                selectedNodeIndex ==
                    index,
          ),
        ),
      ),
    );
  }

  Widget _buildEdgeContainer(int index,
      Offset start, Offset end) {
    Offset midPoint = (start + end) / 2;
    double angle = atan2(
        end.dy - start.dy,
        end.dx - start.dx);
    double distance =
        (start - end).distance;

    return Positioned(
      left: (midPoint.dx * scale +
              canvasOffset.dx) -
          distance / 2,
      top: (midPoint.dy * scale +
              canvasOffset.dy) -
          12.5, // Adjust height
      child: Transform.rotate(
        angle: angle,
        child: GestureDetector(
          onTap: () {
            if (isEraserEnabled) {
              _removeConnection(index);
            } else {
              setState(() {
                selectedConnection =
                    index;
                selectedNodeIndex =
                    null; // Clear selected node when edge is clicked
              });
            }
          },
          child: Container(
            width: distance,
            height: 25, // Adjust height
            color: Colors
                .transparent, // Make hit boxes invisible
            child: Center(
              child:
                  selectedConnection ==
                          index
                      ? Container(
                          width:
                              distance,
                          height:
                              5, // Adjust height for highlight
                          color: Colors
                                  .green[
                              200],
                        )
                      : null,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildControlPanel() {
    return Positioned(
      bottom:
          20, // Changed from 15 to 20
      right:
          20, // Changed from 15 to 20
      child: Container(
        padding:
            const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(15),
          // Add shadow to match data section style
          boxShadow: [
            BoxShadow(
              color: Colors.black
                  .withOpacity(0.15),
              blurRadius: 12,
              offset:
                  const Offset(0, 6),
            ),
          ],
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
            _buildIconButton(
              Icons.add,
              _showAddNodeDialog,
            ),
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
      margin:
          const EdgeInsets.symmetric(
              horizontal: 5),
      decoration: BoxDecoration(
        color:
            color ?? Colors.grey[200],
        borderRadius:
            BorderRadius.circular(15),
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
        return Focus(
          autofocus: true,
          onKeyEvent: (node, event) {
            if (event.logicalKey ==
                    LogicalKeyboardKey
                        .delete ||
                event.logicalKey ==
                    LogicalKeyboardKey
                        .backspace) {
              if (selectedNodeIndex !=
                  null) {
                _removeNode(
                    selectedNodeIndex!);
                setState(() {
                  selectedNodeIndex =
                      null;
                });
                return KeyEventResult
                    .handled;
              } else if (selectedConnection !=
                  null) {
                _removeConnection(
                    selectedConnection!);
                setState(() {
                  selectedConnection =
                      null;
                });
                return KeyEventResult
                    .handled;
              }
            }
            return KeyEventResult
                .ignored;
          },
          child: GestureDetector(
            onTap: _onCanvasTap,
            onScaleStart: _onScaleStart,
            onScaleUpdate:
                _onScaleUpdate,
            onScaleEnd: _onScaleEnd,
            child: Container(
              color: const Color(
                  0xFF14274E),
              child: Stack(
                children: [
                  Transform(
                    transform: Matrix4
                        .identity()
                      ..translate(
                          canvasOffset
                              .dx,
                          canvasOffset
                              .dy)
                      ..scale(scale),
                    child: CustomPaint(
                      painter:
                          CanvasPainter(
                        nodes
                            .map((node) =>
                                node.$1)
                            .toList(),
                        connections,
                        nodeTypes, // Add this line
                      ),
                      child:
                          Container(),
                    ),
                  ),
                  ...connections
                      .asMap()
                      .entries
                      .map((entry) {
                    int index =
                        entry.key;
                    List<int>
                        connection =
                        entry.value;
                    Offset start = nodes[
                            connection[
                                0]]
                        .$1;
                    Offset end = nodes[
                            connection[
                                1]]
                        .$1;
                    return _buildEdgeContainer(
                        index,
                        start,
                        end);
                  }),
                  ...nodes
                      .asMap()
                      .entries
                      .map((entry) {
                    int index =
                        entry.key;
                    (
                      Offset,
                      NodeData
                    ) node =
                        entry.value;
                    return _buildNode(
                        index, node);
                  }),
                  _buildControlPanel(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
