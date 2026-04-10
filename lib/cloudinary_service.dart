import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CloudinaryService {
  static const String cloudName = 'dqmlxpime';
  static const String uploadPreset = 'flutter_upload';

  static Future<String?> uploadImage(File imageFile) async {
    try {
      final uri = Uri.parse(
        'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
      );

      final request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = uploadPreset
        ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

      final response = await request.send();
      final responseData = await response.stream.toBytes();
      final jsonData = json.decode(String.fromCharCodes(responseData));

      if (response.statusCode == 200) {
        return jsonData['secure_url']; // ✅ returns image URL
      }
      return null;
    } catch (e) {
      print('Upload error: $e');
      return null;
    }
  }
}