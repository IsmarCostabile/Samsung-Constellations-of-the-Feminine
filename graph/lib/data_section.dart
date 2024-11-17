import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:ui' as ui;
import 'dart:typed_data'; // Add this import
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:shimmer/shimmer.dart';
import '../models/node_data.dart';
import 'draggable_canvas.dart';

class DataSection
    extends StatefulWidget {
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

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startImageTimer(
      int imageCount) {
    _timer?.cancel();
    _timer = Timer.periodic(
        Duration(seconds: 10), (timer) {
      if (_currentPage <
          imageCount - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      _pageController.animateToPage(
        _currentPage,
        duration:
            Duration(milliseconds: 500),
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

  Widget _buildShimmerContainer(
      {required double height}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: double.infinity,
        height: height,
        margin:
            EdgeInsets.only(bottom: 16),
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
      final titleHeight = 100.0;
      final imageHeight = 400.0;
      final totalPadding =
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

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xFF14274E),
      child: Center(
        child: Container(
          height: MediaQuery.of(context)
                  .size
                  .height -
              30, // Full height minus margins
          margin: EdgeInsets.only(
              top: 15,
              right: 15,
              bottom: 15),
          padding: EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.circular(
                    15),
          ),
          child:
              StreamBuilder<NodeData?>(
            stream: DraggableCanvas
                .selectedNodeController
                .stream,
            builder:
                (context, snapshot) {
              if (!snapshot.hasData) {
                return _buildPlaceholderContainers();
              }

              final node =
                  snapshot.data!;
              if (node
                  .images.isNotEmpty) {
                _startImageTimer(
                    node.images.length);
              }
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    Container(
                      width: double
                          .infinity,
                      margin: EdgeInsets
                          .only(
                              bottom:
                                  16),
                      padding:
                          EdgeInsets
                              .all(16),
                      decoration:
                          BoxDecoration(
                        color: Colors
                            .grey[100],
                        borderRadius:
                            BorderRadius
                                .circular(
                                    12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors
                                .black12,
                            blurRadius:
                                4,
                            offset:
                                Offset(
                                    0,
                                    2),
                          ),
                        ],
                      ),
                      child: Text(
                        node.title,
                        style:
                            TextStyle(
                          fontSize: 32,
                          fontWeight:
                              FontWeight
                                  .w800,
                          color: Color(
                              0xFF14274E),
                        ),
                      ),
                    ),
                    if (node.images
                        .isNotEmpty)
                      LayoutBuilder(
                        builder: (context,
                            constraints) {
                          return Container(
                            width: double
                                .infinity,
                            height:
                                constraints.maxWidth -
                                    32,
                            margin: EdgeInsets.only(
                                bottom:
                                    16),
                            padding:
                                EdgeInsets.all(
                                    16),
                            decoration:
                                BoxDecoration(
                              color: Colors
                                      .grey[
                                  100],
                              borderRadius:
                                  BorderRadius.circular(
                                      12),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      Colors.black12,
                                  blurRadius:
                                      4,
                                  offset: Offset(
                                      0,
                                      2),
                                ),
                              ],
                            ),
                            child:
                                Column(
                              children: [
                                Expanded(
                                  child:
                                      PageView.builder(
                                    controller:
                                        _pageController,
                                    onPageChanged:
                                        (index) {
                                      setState(() {
                                        _currentPage = index;
                                        _startImageTimer(node.images.length);
                                      });
                                    },
                                    itemCount:
                                        node.images.length,
                                    itemBuilder:
                                        (context, index) {
                                      return FutureBuilder<Uint8List>(
                                        future: _resizeImage(node.images[index], 800), // Resize to 800px width
                                        builder: (context, snapshot) {
                                          if (!snapshot.hasData) {
                                            return Center(child: CircularProgressIndicator());
                                          }
                                          return ClipRRect(
                                            borderRadius: BorderRadius.circular(8),
                                            child: Image.memory(
                                              snapshot.data!,
                                              fit: BoxFit.cover,
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ),
                                SizedBox(
                                    height:
                                        16),
                                Container(
                                  child:
                                      SmoothPageIndicator(
                                    controller:
                                        _pageController,
                                    count:
                                        node.images.length,
                                    effect:
                                        WormEffect(
                                      dotHeight: 8,
                                      dotWidth: 8,
                                      activeDotColor: Color(0xFF14274E),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    Container(
                      width: double
                          .infinity,
                      margin: EdgeInsets
                          .only(
                              bottom:
                                  16),
                      padding:
                          EdgeInsets
                              .all(16),
                      decoration:
                          BoxDecoration(
                        color: Colors
                            .grey[100],
                        borderRadius:
                            BorderRadius
                                .circular(
                                    12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors
                                .black12,
                            blurRadius:
                                4,
                            offset:
                                Offset(
                                    0,
                                    2),
                          ),
                        ],
                      ),
                      child: Text(
                        node.description,
                        style:
                            TextStyle(
                          fontSize: 20,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
