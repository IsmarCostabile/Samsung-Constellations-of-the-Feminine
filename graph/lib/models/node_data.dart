import 'dart:typed_data';

class NodeData {
  String title;
  String description;
  List<String> images;

  NodeData({
    required this.title,
    required this.description,
    this.images = const [],
  });
}
