import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:intern_management_app/api_key.dart';

class CloudinaryService {


  /// Upload Image
  Future<Map<String, String>?> uploadImage(File file, String resourceType) async {
    try {
      final uri = Uri.parse("https://api.cloudinary.com/v1_1/$cloudinaryName/$resourceType/upload");

      final request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = "internee-app"
        ..files.add(await http.MultipartFile.fromPath('file', file.path));

      final response = await request.send();

      if (response.statusCode == 200) {
        final res = await http.Response.fromStream(response);
        final data = jsonDecode(res.body);

        final url = data['secure_url'] ?? "";
        final publicId = data['public_id'] ?? "";

        print("✅ Uploaded URL: $url");
        print("✅ Public ID: $publicId");

        return {"url": url, "public_id": publicId};
      } else {
        print("❌ Upload failed: ${response.statusCode}");
        final res = await http.Response.fromStream(response);
        print(res.body);
      }
    } catch (e) {
      print("❌ Error uploading image: $e");
    }
    return null;
  }



  /// Delete image from Cloudinary
  Future<void> deleteImageFromCloudinary(String publicId,String resourceType) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      // Signature generate
      final String signatureRaw = "public_id=$publicId&timestamp=$timestamp$cloudinarySecretKey";
      final String signature = sha1.convert(utf8.encode(signatureRaw)).toString();

      // API endpoint
      final url = Uri.parse("https://api.cloudinary.com/v1_1/$cloudinaryName/$resourceType/destroy");

      // Request body
      final body = {
        "public_id": publicId,
        "api_key": cloudinaryAPIKey,
        "timestamp": timestamp.toString(),
        "signature": signature,
      };

      // POST request
      final response = await http.post(url, body: body);

      if (response.statusCode == 200) {
        print("🗑️ Image deleted successfully from Cloudinary");
      } else {
        print("❌ Delete failed: ${response.body}");
      }
    } catch (e) {
      print("❌ Delete error: $e");
    }
  }

}
