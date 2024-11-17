class NodeData {
  String title;
  String description;
  List<String> images;
  String type; // Add this line

  NodeData({
    required this.title,
    required this.description,
    this.images = const [],
    this.type = 'default', // Add this line
  });

  void update({
    String? title,
    String? description,
    List<String>? images,
    String? type, // Add this line
  }) {
    this.title = title ?? this.title;
    this.description = description ?? this.description;
    this.images = images ?? this.images;
    this.type = type ?? this.type; // Add this line
  }
}
