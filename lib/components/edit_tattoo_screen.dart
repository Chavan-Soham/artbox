import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';

class EditTattooScreen extends StatefulWidget {
  final Uint8List imageBytes;

  const EditTattooScreen({super.key, required this.imageBytes});

  @override
  State<EditTattooScreen> createState() => _EditTattooScreenState();
}

class _EditTattooScreenState extends State<EditTattooScreen> {
  Uint8List? _selectedPhotoBytes;
  final List<_EditableImage> _draggableItems = [];

  @override
  void initState() {
    super.initState();
    // Add the initial image bytes to the toolbar but not to the background
    if (widget.imageBytes.isNotEmpty) {
      _draggableItems.add(_EditableImage(widget.imageBytes));
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await ImagePicker().pickImage(source: source);
      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _selectedPhotoBytes = bytes;
          _draggableItems.clear();
        });
      }
    } catch (e) {
      setState(() {
        print('Error: $e');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Edit Tattoo'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => _showImageSourceActionSheet(),
          child: const Icon(CupertinoIcons.photo_camera),
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              color: Colors.white,
            ),
          ),
          if (_selectedPhotoBytes != null)
            Positioned.fill(
              child: Image.memory(
                _selectedPhotoBytes!,
                fit: BoxFit.cover,
              ),
            ),
          ..._draggableItems.map((item) => _buildEditableImage(item)).toList(),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              color: Colors.black.withOpacity(0.5),
              height: 100,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: _buildToolbarItems(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildToolbarItems() {
    return [
      GestureDetector(
        onTap: () {
          setState(() {
            _draggableItems.add(_EditableImage(widget.imageBytes));
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.memory(widget.imageBytes, width: 80, height: 80),
        ),
      ),
      GestureDetector(
        onTap: () async {
          final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
          if (pickedFile != null) {
            final bytes = await pickedFile.readAsBytes();
            setState(() {
              _selectedPhotoBytes = bytes;
            });
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(Icons.photo, size: 80, color: Colors.white),
        ),
      ),
    ];
  }

  Widget _buildEditableImage(_EditableImage item) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

  // Calculate the adjusted position to keep the image within the visible area
  final adjustedLeft = item.offset.dx.clamp(-800.0, screenWidth - 100.0); // 100.0 is the width of the image
  final adjustedTop = item.offset.dy.clamp(0.0, screenHeight - 100.0); 
    return Positioned(
      left: 0,
      top: adjustedTop,
      width: screenWidth,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            item.offset += details.delta;
          });
        },
        child: Container(
          constraints: BoxConstraints(
            minHeight: screenHeight, // Adjusted to screen height
            minWidth: screenWidth,
            maxWidth: double.infinity,
            maxHeight: double.infinity,
          ),
          child: InteractiveViewer(
            transformationController: item.transformationController,
            boundaryMargin: EdgeInsets.all(double.infinity),
            minScale: 0.1,
            maxScale: 10.0,
            child: Image.memory(
              item.bytes,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }

  void _showImageSourceActionSheet() {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: const Text('Select Image Source'),
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            child: const Text('Gallery'),
            onPressed: () {
              Navigator.pop(context);
              _pickImage(ImageSource.gallery);
            },
          ),
          CupertinoActionSheetAction(
            child: const Text('Camera'),
            onPressed: () {
              Navigator.pop(context);
              _pickImage(ImageSource.camera);
            },
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
}

class _EditableImage {
  Uint8List bytes;
  Offset offset;
  double scale;
  TransformationController transformationController;

  _EditableImage(this.bytes, {this.offset = const Offset(50, 50), this.scale = 1.0})
      : transformationController = TransformationController();
}

void main() {
  runApp(CupertinoApp(
    home: EditTattooScreen(imageBytes: Uint8List(0)), // Replace Uint8List(0) with your initial image bytes
  ));
}
