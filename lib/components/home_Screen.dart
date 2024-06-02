import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:artbox/openai_service.dart';
import 'edit_tattoo_screen.dart';
import 'package:image_picker/image_picker.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _controller = TextEditingController();
  Uint8List? _generatedImageBytes;
  Uint8List? _selectedPhotoBytes;
  Uint8List? _sampleImageBytes;
  bool _isLoading = false;
  String? _errorMessage;

  final OpenAIService openAIService = OpenAIService(''); // Replace with your OpenAI API key

  Offset _imageOffset = Offset.zero;
  double _imageScale = 1.0;
  double _previousScale = 1.0;

  @override
  void initState() {
    super.initState();
    _loadSampleImage();
  }

  Future<void> _loadSampleImage() async {
    final ByteData data = await rootBundle.load('assets/images/sample.png');
    setState(() {
      _sampleImageBytes = data.buffer.asUint8List();
    });
  }

  Future<void> _generateTattoo(String prompt) async {
    setState(() {
      _isLoading = true;
      _generatedImageBytes = null;
      _errorMessage = null;
    });

    try {
      final generatedImageBytes = await openAIService.generateImage(prompt);

      setState(() {
        _generatedImageBytes = generatedImageBytes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await ImagePicker().pickImage(source: source);
      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _selectedPhotoBytes = bytes;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
      });
    }
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

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    const double padding = 16.0;

    return CupertinoPageScaffold(
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/home.jpg',
              fit: BoxFit.fill,
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 100.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: padding),
                      child: CupertinoTextField(
                        controller: _controller,
                        placeholder: 'What kind of tattoo should I generate for you?',
                        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color.fromARGB(255, 183, 210, 232), width: 4.0),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 16.0,
                          color: const Color.fromARGB(255, 247, 231, 175),
                        ),
                        placeholderStyle: GoogleFonts.jetBrainsMono(color: Colors.grey, fontSize: 11.0),
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    CupertinoButton.filled(
                      onPressed: () {
                        final prompt = _controller.text;
                        if (prompt.isNotEmpty) {
                          _generateTattoo(prompt);
                        }
                      },
                      child: Text(
                        'Generate',
                        style: GoogleFonts.jetBrainsMono(),
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    if (_isLoading) const CircularProgressIndicator(),
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: CupertinoColors.destructiveRed),
                        ),
                      ),
                    InteractiveViewer(
                      boundaryMargin: const EdgeInsets.all(double.infinity),
                      minScale: 0.1,
                      maxScale: 10.0,
                      child: GestureDetector(
                        onScaleStart: (details) {
                          _previousScale = _imageScale;
                        },
                        onScaleUpdate: (details) {
                          setState(() {
                            _imageScale = _previousScale * details.scale;
                            _imageOffset += details.focalPointDelta;
                          });
                        },
                        child: SizedBox(
                          width: double.infinity,
                          height: 600.0,
                          child: Transform.translate(
                            offset: _imageOffset,
                            child: Transform.scale(
                              scale: _imageScale,
                              child: _generatedImageBytes != null
                                  ? Image.memory(
                                      _generatedImageBytes!,
                                      height: 300,
                                      width: 300,
                                      fit: BoxFit.contain,
                                    )
                                  : Image.asset(
                                      'assets/images/sample.png',
                                      height: 300,
                                      width: 300,
                                      fit: BoxFit.contain,
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: CupertinoButton(
              onPressed: () {
                Uint8List imageToPass;
                if (_generatedImageBytes != null) {
                  imageToPass = _generatedImageBytes!;
                } else if (_selectedPhotoBytes != null) {
                  imageToPass = _selectedPhotoBytes!;
                } else if (_sampleImageBytes != null) {
                  imageToPass = _sampleImageBytes!;
                } else {
                  _errorMessage = 'Sample image could not be loaded';
                  return;
                }
                Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => EditTattooScreen(imageBytes: imageToPass),
                  ),
                );
              },
              padding: const EdgeInsets.all(16.0),
              color: CupertinoColors.activeBlue,
              borderRadius: BorderRadius.circular(30.0),
              child: const Icon(
                CupertinoIcons.arrow_right,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
