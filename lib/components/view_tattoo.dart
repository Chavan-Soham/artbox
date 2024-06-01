import 'dart:typed_data';
import 'package:flutter/cupertino.dart';

class ViewTattoo extends StatelessWidget {
  final Uint8List imageBytes;

  const ViewTattoo({super.key, required this.imageBytes});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Generated Tattoo'),
      ),
      child: Center(
        child: Image.memory(
          imageBytes,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
