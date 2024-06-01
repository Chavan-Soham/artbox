import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:typed_data';

class OpenAIService {
  final String apiKey;

  OpenAIService(this.apiKey);

  Future<Uint8List> generateImage(String prompt) async {
    const apiUrl = 'https://api.openai.com/v1/images/generations';
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'model': 'dall-e-3',
        'prompt': prompt,
        'n': 1,
        'size': '1024x1024',
        'response_format': 'b64_json',
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final String base64Image = data['data'][0]['b64_json'];
      return base64Decode(base64Image);
    } else {
      throw Exception('Failed to generate image: ${response.body}');
    }
  }
}
