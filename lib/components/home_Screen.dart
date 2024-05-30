import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:image_gallery_saver/image_gallery_saver.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _controller = TextEditingController();
  Uint8List? _generatedImageBytes;
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _generateTattoo(String prompt) async {
    setState(() {
      _isLoading = true;
      _generatedImageBytes = null;
      _errorMessage = null;
    });

    const apiEndpoint = 'https://api.stability.ai/v1/generation/stable-diffusion-xl-1024-v1-0/text-to-image';
    const apiKey = ''; //Replace with your Stability API key

    try {
      final response = await http.post(
        Uri.parse(apiEndpoint),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Accept': 'image/png',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'text_prompts': [
            {'text': prompt, 'weight': 1.0},
          ],
          'height': 1024,
          'width': 1024,
          'cfg_scale': 7,
          'samples': 1,
          'steps': 30,
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          _generatedImageBytes = response.bodyBytes;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to generate image: ${response.body}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }

   Future<void> _downloadImage(Uint8List generatedImageBytes) async {
  setState(() {
    _isLoading = true;
    _errorMessage = null;
  });

  try {
    final result = await ImageGallerySaver.saveImage(
      generatedImageBytes,
    );

    setState(() {
      _isLoading = false;
      _errorMessage = 'Image downloaded successfully: $result';
    });
  } catch (e) {
    setState(() {
      _isLoading = false;
      _errorMessage = 'Error downloading image: $e';
    });
  }
}

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/home.jpg',
              fit: BoxFit.fill,
            ),
          ),
          // Centered text box and generate button
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 100.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Text input box
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: CupertinoTextField(
                      controller: _controller,
                      placeholder: 'What kind of tattoo should I generate for you?',
                      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color.fromARGB(255, 183, 210, 232), width: 4.0),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      style: GoogleFonts.jetBrainsMono(
                          fontSize: 16.0, color: const Color.fromARGB(255, 247, 231, 175)),
                      placeholderStyle: GoogleFonts.jetBrainsMono(color: Colors.grey, fontSize: 11.0),
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  // Generate button
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
                ],
              ),
            ),
          ),
          // Bottom right round button with download arrow
          Positioned(
            bottom: 20,
            right: 20,
            child: CupertinoButton(
              onPressed: () {
                if (_generatedImageBytes != null) {
                  _downloadImage(_generatedImageBytes!);
                }
              },
              padding: const EdgeInsets.all(16.0),
              color: CupertinoColors.activeBlue,
              borderRadius: BorderRadius.circular(30.0),
              child: const Icon(
                CupertinoIcons.arrow_down_circle,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
