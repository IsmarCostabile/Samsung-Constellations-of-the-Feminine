import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:ui' as ui;
import 'dart:typed_data'; // Add this import
import 'dart:html' as html;
import 'dart:convert';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:shimmer/shimmer.dart';
import '../models/node_data.dart';
import 'draggable_canvas.dart';

class DataSection
    extends StatefulWidget {
  const DataSection({super.key});

  @override
  _DataSectionState createState() =>
      _DataSectionState();
}

class _DataSectionState
    extends State<DataSection> {
  final _pageController =
      PageController();
  Timer? _timer;
  int _currentPage = 0;
  bool _isEditing = false;
  final _titleController =
      TextEditingController();
  final _descriptionController =
      TextEditingController();
  List<String> _editedImages = [];
  String _editedType = 'normal';

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startImageTimer(
      int imageCount) {
    _timer?.cancel();
    _timer = Timer.periodic(
        const Duration(seconds: 10),
        (timer) {
      if (_currentPage <
          imageCount - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(
            milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  Future<Uint8List> _resizeImage(
      String imageData,
      int targetWidth) async {
    final original =
        await ui.instantiateImageCodec(
      Uri.parse(imageData)
          .data!
          .contentAsBytes(),
    );
    final frame =
        await original.getNextFrame();

    final height = (frame.image.height *
            targetWidth /
            frame.image.width)
        .round();

    final ui.PictureRecorder recorder =
        ui.PictureRecorder();
    final Canvas canvas =
        Canvas(recorder);

    canvas.drawImageRect(
      frame.image,
      Rect.fromLTWH(
          0,
          0,
          frame.image.width.toDouble(),
          frame.image.height
              .toDouble()),
      Rect.fromLTWH(
          0,
          0,
          targetWidth.toDouble(),
          height.toDouble()),
      Paint(),
    );

    final picture =
        recorder.endRecording();
    final resized = await picture
        .toImage(targetWidth, height);
    final byteData =
        await resized.toByteData(
            format:
                ui.ImageByteFormat.png);

    return byteData!.buffer
        .asUint8List();
  }

  Future<void>
      _handleImageUpload() async {
    final input =
        html.FileUploadInputElement()
          ..accept = 'image/*'
          ..multiple = true;

    input.click();

    await input.onChange.first;

    if (input.files?.isNotEmpty ??
        false) {
      for (var file in input.files!) {
        final reader =
            html.FileReader();
        reader.readAsDataUrl(file);
        await reader.onLoad.first;

        final base64Image =
            reader.result as String;
        setState(() {
          _editedImages
              .add(base64Image);
        });
      }
    }
  }

  void _startEditing(NodeData node) {
    setState(() {
      _isEditing = true;
      _titleController.text =
          node.title;
      _descriptionController.text =
          node.description;
      _editedImages =
          List.from(node.images);
      _editedType = node.type;
    });
  }

  void _saveChanges(NodeData node) {
    node.update(
      title: _titleController.text,
      description:
          _descriptionController.text,
      images: _editedImages,
      type: _editedType,
    );
    setState(() {
      _isEditing = false;
    });
    // Notify canvas of changes
    DraggableCanvas
        .selectedNodeController
        .add(node);
  }

  Widget _buildTitleSection(
      NodeData node) {
    return Container(
      margin: const EdgeInsets.only(
          bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius:
            BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black
                .withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _isEditing
                    ? TextField(
                        controller:
                            _titleController,
                        style:
                            const TextStyle(
                          fontSize: 32,
                          fontWeight:
                              FontWeight
                                  .w800,
                          color: Color(
                              0xFF14274E),
                        ),
                        decoration:
                            InputDecoration(
                          labelText:
                              'Title',
                          border:
                              OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(
                                    12),
                            borderSide:
                                BorderSide
                                    .none,
                          ),
                          filled: true,
                          fillColor:
                              Colors.grey[
                                  100],
                          contentPadding:
                              const EdgeInsets
                                  .all(
                                  16),
                          labelStyle: TextStyle(
                              color: Colors
                                      .grey[
                                  700]),
                          focusedBorder:
                              OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(
                                    12),
                            borderSide:
                                BorderSide(
                                    color:
                                        Colors.grey[700]!),
                          ),
                        ),
                      )
                    : Text(
                        node.title,
                        style:
                            const TextStyle(
                          fontSize: 32,
                          fontWeight:
                              FontWeight
                                  .w800,
                          color: Color(
                              0xFF14274E),
                        ),
                      ),
              ),
              _buildIconButton(
                _isEditing
                    ? Icons.save
                    : Icons.edit,
                () {
                  if (_isEditing) {
                    _saveChanges(node);
                  } else {
                    _startEditing(node);
                  }
                },
                _isEditing
                    ? Colors.green[200]
                    : Colors.grey[200],
              ),
              if (_isEditing)
                _buildIconButton(
                  Icons.close,
                  () => setState(() =>
                      _isEditing =
                          false),
                  Colors.grey[200],
                ),
            ],
          ),
          if (_isEditing) ...[
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius:
                    BorderRadius
                        .circular(12),
                border: Border.all(
                    color: Colors
                        .grey[300]!),
              ),
              child:
                  DropdownButtonFormField<
                      String>(
                value: _editedType,
                decoration:
                    InputDecoration(
                  labelText:
                      'Node Type',
                  border:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius
                            .circular(
                                12),
                    borderSide:
                        BorderSide.none,
                  ),
                  filled: true,
                  fillColor:
                      Colors.grey[100],
                  contentPadding:
                      const EdgeInsets
                          .all(16),
                ),
                items: const [
                  DropdownMenuItem(
                      value: 'normal',
                      child: Text(
                          'Normal')),
                  DropdownMenuItem(
                      value:
                          'super-node',
                      child: Text(
                          'Super Node')),
                ],
                onChanged: (value) {
                  setState(() {
                    _editedType =
                        value!;
                  });
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDescriptionSection(
      NodeData node) {
    return Container(
      margin: const EdgeInsets.only(
          bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius:
            BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black
                .withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: _isEditing
          ? TextField(
              controller:
                  _descriptionController,
              maxLines: 3,
              style: TextStyle(
                fontSize: 20,
                height: 1.5,
                color: Colors.grey[900],
              ),
              decoration:
                  InputDecoration(
                labelText:
                    'Description',
                border:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius
                          .circular(12),
                  borderSide:
                      BorderSide.none,
                ),
                filled: true,
                fillColor:
                    Colors.grey[100],
                contentPadding:
                    const EdgeInsets
                        .all(16),
                labelStyle: TextStyle(
                    color: Colors
                        .grey[700]),
                focusedBorder:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius
                          .circular(12),
                  borderSide:
                      BorderSide(
                          color: Colors
                                  .grey[
                              700]!),
                ),
              ),
            )
          : Text(
              node.description,
              style: TextStyle(
                fontSize: 20,
                height: 1.5,
                color: Colors.grey[900],
              ),
            ),
    );
  }

  Widget _buildShimmerContainer(
      {required double height}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: double.infinity,
        height: height,
        margin: const EdgeInsets.only(
            bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildPlaceholderContainers() {
    return LayoutBuilder(builder:
        (context, constraints) {
      const titleHeight = 100.0;
      const imageHeight = 400.0;
      const totalPadding =
          34.0; // Account for margins between containers
      final remainingHeight =
          constraints.maxHeight -
              titleHeight -
              imageHeight -
              totalPadding;

      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            _buildShimmerContainer(
                height: titleHeight),
            _buildShimmerContainer(
                height: imageHeight),
            _buildShimmerContainer(
                height:
                    remainingHeight),
          ],
        ),
      );
    });
  }

  Widget _buildImageSection(
      NodeData node) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final images = _isEditing
            ? _editedImages
            : node.images;
        if (images.isEmpty &&
            !_isEditing) {
          return const SizedBox
              .shrink();
        }

        return Container(
          width: double.infinity,
          height:
              constraints.maxWidth - 32,
          margin: const EdgeInsets.only(
              bottom: 24),
          padding:
              const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius:
                BorderRadius.circular(
                    16),
            boxShadow: [
              BoxShadow(
                color: Colors.black
                    .withOpacity(0.08),
                blurRadius: 8,
                offset:
                    const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Expanded(
                child: _isEditing
                    ? GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount:
                              3,
                          crossAxisSpacing:
                              8,
                          mainAxisSpacing:
                              8,
                        ),
                        itemCount:
                            _editedImages
                                .length,
                        itemBuilder:
                            (context,
                                index) {
                          return Column(
                            children: [
                              Expanded(
                                child:
                                    ClipRRect(
                                  borderRadius:
                                      BorderRadius.circular(8),
                                  child:
                                      Image.memory(
                                    base64Decode(_editedImages[index].split(',')[1]),
                                    fit:
                                        BoxFit.cover,
                                  ),
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets
                                    .only(
                                    top:
                                        4),
                                padding: const EdgeInsets
                                    .symmetric(
                                    horizontal:
                                        8,
                                    vertical:
                                        4),
                                decoration:
                                    BoxDecoration(
                                  color:
                                      Colors.grey[200],
                                  borderRadius:
                                      BorderRadius.circular(20),
                                ),
                                child:
                                    Row(
                                  mainAxisSize:
                                      MainAxisSize.min,
                                  children: [
                                    if (index >
                                        0)
                                      IconButton(
                                        icon: const Icon(Icons.arrow_left, size: 20),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        onPressed: () {
                                          setState(() {
                                            final image = _editedImages.removeAt(index);
                                            _editedImages.insert(index - 1, image);
                                          });
                                        },
                                      ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      onPressed: () {
                                        setState(() {
                                          _editedImages.removeAt(index);
                                        });
                                      },
                                    ),
                                    if (index <
                                        _editedImages.length - 1)
                                      IconButton(
                                        icon: const Icon(Icons.arrow_right, size: 20),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        onPressed: () {
                                          setState(() {
                                            final image = _editedImages.removeAt(index);
                                            _editedImages.insert(index + 1, image);
                                          });
                                        },
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      )
                    : PageView.builder(
                        controller:
                            _pageController,
                        onPageChanged:
                            (index) {
                          setState(() {
                            _currentPage =
                                index;
                            _startImageTimer(node
                                .images
                                .length);
                          });
                        },
                        itemCount: node
                            .images
                            .length,
                        itemBuilder:
                            (context,
                                index) {
                          return FutureBuilder<
                              Uint8List>(
                            future: _resizeImage(
                                node.images[
                                    index],
                                800), // Resize to 800px width
                            builder:
                                (context,
                                    snapshot) {
                              if (!snapshot
                                  .hasData) {
                                return const Center(
                                    child:
                                        CircularProgressIndicator());
                              }
                              return ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(8),
                                child: Image
                                    .memory(
                                  snapshot
                                      .data!,
                                  fit: BoxFit
                                      .cover,
                                ),
                              );
                            },
                          );
                        },
                      ),
              ),
              if (!_isEditing &&
                  images.length > 1)
                Container(
                  child:
                      SmoothPageIndicator(
                    controller:
                        _pageController,
                    count: node
                        .images.length,
                    effect:
                        const WormEffect(
                      dotHeight: 8,
                      dotWidth: 8,
                      activeDotColor:
                          Color(
                              0xFF14274E),
                    ),
                  ),
                ),
              if (_isEditing) ...[
                const SizedBox(
                    height: 16),
                ElevatedButton(
                  onPressed:
                      _handleImageUpload,
                  style: ElevatedButton
                      .styleFrom(
                    backgroundColor:
                        const Color(
                            0xFF14274E),
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius
                              .circular(
                                  12),
                    ),
                    padding:
                        const EdgeInsets
                            .symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: const Text(
                    'Upload Image',
                    style: TextStyle(
                      color:
                          Colors.white,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
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

  Widget _buildNavigationBreadcrumb() {
    return StreamBuilder<String>(
      stream: DraggableCanvas
          .navigationController.stream,
      initialData: 'Main Graph',
      builder: (context, snapshot) {
        return Container(
          margin: const EdgeInsets.only(
              bottom: 16),
          padding: const EdgeInsets
              .symmetric(
              horizontal: 12,
              vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius:
                BorderRadius.circular(
                    8),
          ),
          child: Text(
            snapshot.data ??
                'Main Graph',
            style: TextStyle(
              color: Colors.grey[700],
              fontWeight:
                  FontWeight.w500,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF14274E),
      child: Center(
        child: Container(
          height: MediaQuery.of(context)
                  .size
                  .height -
              40,
          margin:
              const EdgeInsets.all(20),
          padding:
              const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.circular(
                    20),
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
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment
                    .start,
            children: [
              _buildNavigationBreadcrumb(),
              Expanded(
                child: StreamBuilder<
                    NodeData?>(
                  stream: DraggableCanvas
                      .selectedNodeController
                      .stream,
                  builder: (context,
                      snapshot) {
                    if (!snapshot
                        .hasData) {
                      return _buildPlaceholderContainers();
                    }

                    final node =
                        snapshot.data!;
                    if (node.images
                        .isNotEmpty) {
                      _startImageTimer(
                          node.images
                              .length);
                    }
                    return SingleChildScrollView(
                      padding:
                          const EdgeInsets
                              .symmetric(
                              vertical:
                                  8),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        children: [
                          _buildTitleSection(
                              node),
                          _buildImageSection(
                              node),
                          _buildDescriptionSection(
                              node),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
