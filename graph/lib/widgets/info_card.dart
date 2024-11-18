import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart'; // Add this import

class InfoCard extends StatefulWidget {
  final String title;
  final String description;
  final String? imageUrl;
  final bool isSelected;
  final String type; // Add this line

  const InfoCard({
    super.key,
    required this.title,
    required this.description,
    this.imageUrl,
    this.isSelected = false,
    required this.type, // Add this line
  });

  @override
  State<InfoCard> createState() =>
      _InfoCardState();
}

class _InfoCardState
    extends State<InfoCard> {
  Uint8List? _imageData;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void didUpdateWidget(
      InfoCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl !=
        widget.imageUrl) {
      _loadImage();
    }
  }

  void _loadImage() {
    if (widget.imageUrl == null ||
        widget.imageUrl!.isEmpty) {
      setState(() {
        _imageData = null;
        _error = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      if (widget.imageUrl!
          .startsWith('data:image')) {
        final String base64String =
            widget.imageUrl!
                .split(',')[1];
        print(
            'Loading base64 image of length: ${base64String.length}');

        final decodedData =
            base64Decode(base64String);
        setState(() {
          _imageData = decodedData;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading image: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Widget _buildImage() {
    if (_isLoading) {
      return const Center(
          child:
              CircularProgressIndicator());
    }

    if (_error != null) {
      return Icon(Icons.error,
          color: Colors.red[300]);
    }

    if (_imageData != null) {
      return Image.memory(
        _imageData!,
        height: 50,
        width: 50,
        fit: BoxFit.cover,
        errorBuilder: (context, error,
            stackTrace) {
          print(
              'Error displaying image: $error');
          return Icon(Icons.error,
              color: Colors.red[300]);
        },
      );
    }

    return const Icon(Icons.image,
        size: 50, color: Colors.white);
  }

  Widget _buildShimmerBackground(
      Widget child) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius:
              BorderRadius.circular(8),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget cardContent = Padding(
      padding:
          const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius:
                  BorderRadius.circular(
                      8),
            ),
            child: ClipRRect(
              borderRadius:
                  BorderRadius.circular(
                      8),
              child: _buildImage(),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              mainAxisSize:
                  MainAxisSize.min,
              children: [
                Text(
                  widget.type == 'super-node' 
                      ? '✨ ${widget.title}'
                      : widget.title,
                  style:
                      const TextStyle(
                    fontSize: 18,
                    fontWeight:
                        FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow
                      .ellipsis,
                ),
                Text(
                  widget.description,
                  style:
                      const TextStyle(
                          fontSize: 14),
                  overflow: TextOverflow
                      .ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return Card(
      color: widget.isSelected
          ? const Color.fromARGB(
              255,
              181,
              255,
              217) // Selected nodes are always green
          : widget.type == 'parent'
              ? Colors.blue[
                  100] // Non-selected parent nodes are blue
              : widget.type ==
                      'super-node'
                  ? Colors.yellow[
                      100] // Non-selected super nodes are yellow
                  : Colors
                      .white, // Normal nodes are white
      child: Stack(
        children: [
          if (widget.type ==
              'super-node')
            Positioned.fill(
              child:
                  _buildShimmerBackground(
                      Container()),
            ),
          // Add blue overlay for parent nodes when selected
          if (widget.type == 'parent' &&
              widget.isSelected)
            Positioned.fill(
              child: Container(
                decoration:
                    BoxDecoration(
                  color:
                      Colors.blue[100],
                  borderRadius:
                      BorderRadius
                          .circular(8),
                ),
              ),
            ),
          if (widget.isSelected)
            Positioned.fill(
              child: Container(
                decoration:
                    BoxDecoration(
                  color: const Color
                          .fromARGB(255,
                          181, 255, 217)
                      .withOpacity(0.5),
                  borderRadius:
                      BorderRadius
                          .circular(8),
                ),
              ),
            ),
          cardContent,
        ],
      ),
    );
  }
}
