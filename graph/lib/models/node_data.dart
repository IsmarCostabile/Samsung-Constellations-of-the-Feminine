import 'package:flutter/material.dart';

class NodeData {
  String id;
  String title;
  String description;
  List<String> images;
  String type;
  NodeData? parent;
  Map<String, NodeData> children = {};
  Map<String, Set<String>> connections = {};
  Offset position;

  NodeData({
    String? id,
    required this.title,
    required this.description,
    this.images = const [],
    this.type = 'normal',
    this.parent,
    this.position = Offset.zero,
  }) : id = id ?? UniqueKey().toString() {
    assert(type == 'normal' || type == 'super-node' || type == 'parent');
  }

  void addChild(NodeData child) {
    children[child.id] = child;
    child.parent = this;
  }

  void removeChild(String childId) {
    children.remove(childId);
  }

  void addConnection(String targetId) {
    connections.putIfAbsent(id, () => {}).add(targetId);
  }

  void removeConnection(String targetId) {
    connections[id]?.remove(targetId);
  }

  bool hasConnection(String targetId) {
    return connections[id]?.contains(targetId) ?? false;
  }

  NodeData copy() {
    return NodeData(
      id: id,
      title: title,
      description: description,
      images: List.from(images),
      type: type,
      parent: parent,
      position: position,
    )
      ..children = Map.from(children)
      ..connections = Map.from(connections);
  }

  void update({
    String? title,
    String? description,
    List<String>? images,
    String? type,
    Offset? position,
  }) {
    if (title != null) this.title = title;
    if (description != null) this.description = description;
    if (images != null) this.images = List.from(images);
    if (type != null) {
      assert(type == 'normal' || type == 'super-node' || type == 'parent');
      this.type = type;
    }
    if (position != null) this.position = position;
  }

  void clearChildren() {
    children.clear();
  }
}
