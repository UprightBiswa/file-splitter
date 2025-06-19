import 'package:file_picker/file_picker.dart';

import 'dart:math' as Math; // Import dart:math for log and pow

class FileHelpers {
  /// Validates if the given file type is supported for splitting.
  static bool isValidFileType(PlatformFile file) {
    final String? extension = file.extension?.toLowerCase();
    return extension == 'txt' || extension == 'doc' || extension == 'docx';
  }

  /// Checks if the file size is within acceptable limits for splitting.
  /// (e.g., min 1KB for splitting, max 100MB to prevent issues with large files)
  static bool isValidFileSize(PlatformFile file) {
    const int minSizeBytes = 1 * 1024; // 1 KB
    const int maxSizeBytes = 100 * 1024 * 1024; // 100 MB

    return file.size >= minSizeBytes && file.size <= maxSizeBytes;
  }

  /// Generates a readable file size string.
  static String formatBytes(int bytes, int decimals) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB"];
    var i = (bytes.logBase(1024)).floor();
    return '${(bytes / (1024).pow(i)).toStringAsFixed(decimals)} ${suffixes[i]}';
  }
}

extension on num {
  num logBase(num base) => Math.log(this) / Math.log(base);
  num pow(num exponent) => Math.pow(this, exponent);
}
