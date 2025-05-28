import 'dart:convert';
import 'dart:typed_data';

// A utility class for converting images to/from Base64 strings.
class ImageConverter {
  ImageConverter._(); // private constructor: static-only

  /// Converts a [Uint8List] of image bytes into a Base64-encoded string.

  static String imageToBase64(Uint8List imageBytes) {
    // Encode bytes as Base64
    return base64Encode(imageBytes);
  }

  /// Converts a Base64-encoded [String] back into a [Uint8List] of bytes.

  static Uint8List base64ToImage(String base64String) {
    // Decode Base64 into bytes
    return base64Decode(base64String);
  }
}
