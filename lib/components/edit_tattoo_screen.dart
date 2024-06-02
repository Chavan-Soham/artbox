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
  String? _errorMessage;

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
        _errorMessage = 'Error: $e';
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
          if (_selectedPhotoBytes != null)
            Positioned.fill(
              top: 30.0,
              child: Image.memory(
                _selectedPhotoBytes!,
                  fit: BoxFit.fill,
                  width: 200.0,
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
                children: [
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
                  // Add more widgets here if needed
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableImage(_EditableImage item) {
    return Positioned(
      left: item.offset.dx,
      top: item.offset.dy,
      child: GestureDetector(
        onScaleUpdate: (details) {
          setState(() {
            item.offset += details.focalPointDelta;
            item.scale = details.scale;
          });
        },
        child: Transform(
          transform: Matrix4.identity()
            ..translate(item.offset.dx, item.offset.dy)
            ..scale(item.scale),
          child: Image.memory(
            item.bytes,
            width: 100,
            height: 100,
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

  _EditableImage(this.bytes, {this.offset = const Offset(50, 50), this.scale = 1.0});
}