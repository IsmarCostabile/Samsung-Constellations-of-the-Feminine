import 'package:flutter/material.dart';

class InfoCard extends StatelessWidget {
  final String title;
  final String description;
  final String?
      imageUrl; // Make imageUrl optional
  final bool isSelected;

  InfoCard({
    required this.title,
    required this.description,
    this.imageUrl, // Make imageUrl optional
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isSelected
          ? const Color.fromARGB(
              255, 181, 255, 217)
          : Colors.white,
      child: Padding(
        padding:
            const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration:
                      BoxDecoration(
                    color: Colors.grey,
                    borderRadius:
                        BorderRadius
                            .circular(
                                8),
                  ),
                  child: ClipRRect(
                    borderRadius:
                        BorderRadius
                            .circular(
                                8),
                    child: imageUrl !=
                                null &&
                            imageUrl!
                                .isNotEmpty
                        ? Image.network(
                            imageUrl!,
                            fit: BoxFit
                                .cover,
                          )
                        : Icon(
                            Icons.image,
                            size: 50,
                            color: Colors
                                .white,
                          ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      Text(
                        title,
                        style:
                            TextStyle(
                          fontSize: 18,
                          fontWeight:
                              FontWeight
                                  .bold,
                        ),
                      ),
                      Text(
                        description,
                        style:
                            TextStyle(
                          fontSize: 14,
                        ),
                        overflow:
                            TextOverflow
                                .ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
