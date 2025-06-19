class SplitResultModel {
  final String filename;
  final String url; // URL to download the split file part

  SplitResultModel({
    required this.filename,
    required this.url,
  });

  // Factory constructor to create a SplitResultModel from a JSON map
  factory SplitResultModel.fromJson(Map<String, dynamic> json) {
    return SplitResultModel(
      filename: json['filename'] as String,
      url: json['url'] as String,
    );
  }

  // Method to convert a SplitResultModel to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'filename': filename,
      'url': url,
    };
  }
}
