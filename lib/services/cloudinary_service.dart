import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CloudinaryService {
  static const String cloudName = 'dqmlxpime';
  static const String uploadPreset = 'flutter_upload';

  static Future<String?> uploadImage(XFile imageFile) async {
    try {
      final uri = Uri.parse(
        'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
      );

      final bytes = await imageFile.readAsBytes();

      var request = http.MultipartRequest('POST', uri);
      request.fields['upload_preset'] = uploadPreset;
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: imageFile.name,
        ),
      );

      var streamedResponse = await request.send();
      var resStr = await streamedResponse.stream.bytesToString();
      var jsonData = json.decode(resStr);

      print("STATUS: ${streamedResponse.statusCode}");
      print("RESPONSE: $jsonData");

      if (streamedResponse.statusCode == 200) {
        return jsonData['secure_url'];
      } else {
        print("Upload failed: $jsonData");
        return null;
      }
    } catch (e) {
      print("ERROR: $e");
      return null;
    }
  }
}