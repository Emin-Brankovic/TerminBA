import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';

class ImageValidator {
  static const int maxImageSizeBytes = 3 * 1024 * 1024;
  static const List<String> allowedImageExtensions = [
    '.jpg',
    '.jpeg',
    '.png',
  ];

  static String? validatePickedImage(PlatformFile file) {
    if (file.size == 0 || file.bytes == null) {
      return 'File is empty or not readable.';
    }

    if (file.size > maxImageSizeBytes) {
      return 'File size exceeds 3MB.';
    }

    final extension = _getFileExtension(file.name);
    if (!allowedImageExtensions.contains(extension)) {
      return 'Unsupported file extension.';
    }

    if (!_isValidImageHeader(file.bytes!)) {
      return 'File content does not match common image formats.';
    }

    return null;
  }

  static String _getFileExtension(String name) {
    final dotIndex = name.lastIndexOf('.');
    if (dotIndex == -1 || dotIndex == name.length - 1) {
      return '';
    }
    return name.substring(dotIndex).toLowerCase();
  }

  static bool _isValidImageHeader(Uint8List bytes) {
    if (bytes.length < 4) {
      return false;
    }

    // JPEG: FF D8 FF
    if (bytes[0] == 0xFF && bytes[1] == 0xD8 && bytes[2] == 0xFF) {
      return true;
    }

    // PNG: 89 50 4E 47
    if (bytes[0] == 0x89 && bytes[1] == 0x50 && bytes[2] == 0x4E && bytes[3] == 0x47) {
      return true;
    }

    return false;
  }
}
