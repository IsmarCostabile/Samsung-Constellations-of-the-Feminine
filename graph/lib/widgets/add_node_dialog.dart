import 'package:flutter/material.dart';
import '../models/node_data.dart';
import 'dart:convert';
import 'dart:html' as html;
import '../widgets/info_card.dart';
import '../controllers/node_controller.dart';

Widget _buildIconButton(
    IconData icon,
    String label,
    VoidCallback onPressed,
    [Color? color]) {
  return Container(
    margin: const EdgeInsets.symmetric(
        horizontal: 8),
    decoration: BoxDecoration(
      color: color ?? Colors.grey[200],
      borderRadius:
          BorderRadius.circular(15),
    ),
    child: Padding(
      padding: const EdgeInsets.only(
          left: 8, right: 16),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(icon),
            onPressed: onPressed,
            padding: EdgeInsets.zero,
          ),
          Text(label),
        ],
      ),
    ),
  );
}

Future<NodeData?> showAddNodeDialog(
    BuildContext context,
    List<NodeData>
        existingNodes) async {
  String title = '';
  String description = '';
  List<String> images = [];
  String type = 'normal';
  bool isCreatingNew = true;
  NodeData? selectedNode;
  final ValueNotifier<List<String>>
      imagesNotifier =
      ValueNotifier<List<String>>([]);

  Future<void>
      handleImageUpload() async {
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
        images.add(base64Image);
      }
      imagesNotifier.value =
          List.from(images);
    }
  }

  return showDialog<NodeData>(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            shape:
                RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(
                      15),
            ),
            child: Container(
              width:
                  MediaQuery.of(context)
                          .size
                          .width *
                      0.4,
              padding:
                  const EdgeInsets.all(
                      24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius
                        .circular(15),
              ),
              child: Column(
                mainAxisSize:
                    MainAxisSize.min,
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                children: [
                  const Text(
                    'Add Node ✨',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight:
                          FontWeight
                              .w800,
                      color: Color(
                          0xFF14274E),
                    ),
                  ),
                  const SizedBox(
                      height: 24),

                  // Add toggle for new/existing node
                  Row(
                    children: [
                      Expanded(
                        child:
                            RadioListTile<
                                bool>(
                          title: const Text(
                              'Create New'),
                          value: true,
                          groupValue:
                              isCreatingNew,
                          onChanged:
                              (value) {
                            setState(
                                () {
                              isCreatingNew =
                                  value!;
                              selectedNode =
                                  null;
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child:
                            RadioListTile<
                                bool>(
                          title: const Text(
                              'Use Existing'),
                          value: false,
                          groupValue:
                              isCreatingNew,
                          onChanged:
                              (value) {
                            setState(
                                () {
                              isCreatingNew =
                                  value!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                      height: 16),

                  if (isCreatingNew) ...[
                    // Existing new node creation form
                    Container(
                      decoration:
                          BoxDecoration(
                        color: Colors
                            .grey[100],
                        borderRadius:
                            BorderRadius
                                .circular(
                                    12),
                        boxShadow: const [
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
                      child: TextField(
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
                        onChanged:
                            (value) =>
                                title =
                                    value,
                        cursorColor:
                            Colors.grey[
                                700],
                        style: TextStyle(
                            color: Colors
                                    .grey[
                                900]),
                      ),
                    ),
                    const SizedBox(
                        height: 16),
                    Container(
                      decoration:
                          BoxDecoration(
                        color: Colors
                            .grey[100],
                        borderRadius:
                            BorderRadius
                                .circular(
                                    12),
                        boxShadow: const [
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
                      child: TextField(
                        decoration:
                            InputDecoration(
                          labelText:
                              'Description',
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
                        onChanged: (value) =>
                            description =
                                value,
                        maxLines: 3,
                        cursorColor:
                            Colors.grey[
                                700],
                        style: TextStyle(
                            color: Colors
                                    .grey[
                                900]),
                      ),
                    ),
                    const SizedBox(
                        height: 16),
                    Container(
                      decoration:
                          BoxDecoration(
                        color: Colors
                            .grey[100],
                        borderRadius:
                            BorderRadius
                                .circular(
                                    12),
                        boxShadow: const [
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
                      child:
                          DropdownButtonFormField<
                              String>(
                        value: type,
                        decoration:
                            InputDecoration(
                          labelText:
                              'Type',
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
                        ),
                        items: const [
                          DropdownMenuItem(
                              value:
                                  'normal',
                              child: Text(
                                  'Normal')),
                          DropdownMenuItem(
                              value:
                                  'super-node',
                              child: Text(
                                  'Super Node')),
                        ],
                        onChanged:
                            (value) =>
                                type =
                                    value!,
                      ),
                    ),
                    const SizedBox(
                        height: 16),
                    ElevatedButton(
                      onPressed:
                          handleImageUpload,
                      style:
                          ElevatedButton
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
                        padding: const EdgeInsets
                            .symmetric(
                            horizontal:
                                24,
                            vertical:
                                12),
                      ),
                      child: const Text(
                        'Upload Image',
                        style:
                            TextStyle(
                          color: Colors
                              .white,
                        ),
                      ),
                    ),
                    ValueListenableBuilder<
                        List<String>>(
                      valueListenable:
                          imagesNotifier,
                      builder: (context,
                          imagesList,
                          child) {
                        if (imagesList
                            .isEmpty) {
                          return const SizedBox
                              .shrink();
                        }
                        return Container(
                          margin:
                              const EdgeInsets
                                  .only(
                                  top:
                                      16),
                          height: 200,
                          child: GridView
                              .builder(
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
                                imagesList
                                    .length,
                            itemBuilder:
                                (context,
                                    index) {
                              return Stack(
                                children: [
                                  Container(
                                    decoration:
                                        BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Colors.black12,
                                          blurRadius: 4,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child:
                                        ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.memory(
                                        base64Decode(imagesList[index].split(',')[1]),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    right:
                                        4,
                                    top:
                                        4,
                                    child:
                                        IconButton(
                                      icon: const Icon(Icons.close, color: Colors.white),
                                      onPressed: () {
                                        images.removeAt(index);
                                        imagesNotifier.value = List.from(images);
                                      },
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ] else ...[
                    // Existing node selection
                    Container(
                      decoration:
                          BoxDecoration(
                        color: Colors
                            .grey[100],
                        borderRadius:
                            BorderRadius
                                .circular(
                                    12),
                        boxShadow: const [
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
                      child:
                          DropdownButtonFormField<
                              NodeData>(
                        value:
                            selectedNode,
                        decoration:
                            InputDecoration(
                          labelText:
                              'Select Existing Node',
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
                        ),
                        items:
                            existingNodes
                                .map((node) =>
                                    DropdownMenuItem(
                                      value: node,
                                      child: Text(node.title),
                                    ))
                                .toList(),
                        onChanged:
                            (value) {
                          setState(() {
                            selectedNode =
                                value;
                          });
                        },
                      ),
                    ),
                  ],

                  const SizedBox(
                      height: 16),
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment
                            .end,
                    children: [
                      _buildIconButton(
                        Icons.close,
                        'Cancel',
                        () => Navigator.of(
                                context)
                            .pop(),
                        Colors
                            .grey[200],
                      ),
                      const SizedBox(
                          width: 10),
                      _buildIconButton(
                        Icons.check,
                        'Add',
                        () {
                          if (isCreatingNew &&
                              title
                                  .isNotEmpty) {
                            Navigator.of(
                                    context)
                                .pop(
                              NodeData(
                                title:
                                    title,
                                description:
                                    description,
                                images:
                                    images,
                                type:
                                    type,
                              ),
                            );
                          } else if (!isCreatingNew &&
                              selectedNode !=
                                  null) {
                            Navigator.of(
                                    context)
                                .pop(
                                    selectedNode);
                          }
                        },
                        Colors
                            .green[200],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
