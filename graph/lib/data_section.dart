import 'package:flutter/material.dart';

class DataSection
    extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xFF14274E),
      child: Center(
        child: Container(
          margin: EdgeInsets.only(
              top: 15,
              right: 15,
              bottom:
                  15), // Add margin of 20 on all sides
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.circular(
                    15),
          ),
        ),
      ),
    );
  }
}
