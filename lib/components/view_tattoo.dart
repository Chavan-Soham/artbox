import 'dart:typed_data';

import 'package:flutter/cupertino.dart';

class ViewTattoo extends StatelessWidget {
  final Uint8List imageBytes;

  const ViewTattoo({super.key, required this.imageBytes});

  @override
  Widget build(BuildContext context) {
    return const CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('View Tattoo'),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // You can display the image if needed for debugging purposes
            // Image.memory(imageBytes),
            Text(
              'Tattoo with transparent background is ready!',
              style: TextStyle(fontSize: 18.0, color: CupertinoColors.black),
            ),
          ],
        ),
      ),
    );
  }
}
