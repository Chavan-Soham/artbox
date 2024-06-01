import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:artbox/openai_service.dart';
import 'view_tattoo.dart';
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
  bool _isLoading = false;
  String? _errorMessage;

  final OpenAIService openAIService = OpenAIService('sk-proj-fQOo2JThyYnnz7QUGK4vT3BlbkFJIdNvFDwt5vPOkSE29acm'); // Replace with your OpenAI API key

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
    final double buttonWidth = (screenWidth - (3 * padding)) / 2;

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
                  if (_generatedImageBytes != null)
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.memory(
                        _generatedImageBytes!,
                        height: 300,
                        width: 300,
                        fit: BoxFit.contain,
                      ),
                    ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: buttonWidth,
                        child: CupertinoButton(
                          color: Colors.amberAccent,
                          onPressed: () {
                            _showImageSourceActionSheet();
                          },
                          child: const Text('Button 1', style: TextStyle(color: Colors.black)),
                        ),
                      ),
                      const SizedBox(width: padding), // Add some space between the buttons
                      SizedBox(
                        width: buttonWidth,
                        child: CupertinoButton(
                          color: Colors.amberAccent,
                          onPressed: () {
                            // Handle the action for the second button
                          },
                          child: const Text('Button 2', style: TextStyle(color: Colors.black)),
                        ),
                      ),
                    ],
                  ),
                  if (_selectedPhotoBytes != null)
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.memory(
                        _selectedPhotoBytes!,
                        height: 500,
                        width: 200,
                        fit: BoxFit.contain,
                      ),
                    ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: CupertinoButton(
              onPressed: () {
                if (_generatedImageBytes != null) {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => ViewTattoo(imageBytes: _generatedImageBytes!),
                    ),
                  );
                }
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
