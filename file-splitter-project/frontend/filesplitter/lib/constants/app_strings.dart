class AppStrings {
  // Common
  static const String appName = "File Splitter Web";
  static const String ok = "OK";
  static const String cancel = "Cancel";

  // Home Page
  static const String homeTitle = "Split Your File";
  static const String selectFile = "Select File";
  static const String noFileSelected = "No file selected";
  static const String chunkSizeLabel = "Chunk Size (in MB)";
  static const String smartSplitLabel = "Smart Split (Experimental)";
  static const String submit = "Split File";
  static const String uploadingFile = "Uploading and Splitting...";
  static const String uploadSuccess = "File split successfully!";
  static const String uploadFailed = "File upload failed";
  static const String invalidChunkSize = "Please enter a valid chunk size.";
  static const String fileTypeError = "Unsupported file type. Please select .txt or .doc/.docx.";
  static const String fileSizeError = "File size exceeds limit or is too small for splitting.";

  // Result Page
  static const String resultTitle = "Split Results";
  static const String downloadParts = "Download File Parts";
  static const String navigateHome = "Split Another File";
  static const String noSplitResults = "No split results available.";

  // Error Messages
  static const String connectionError = "Connection Error. Please check your internet.";
  static const String serverError = "Server Error. Please try again later.";
  static const String unknownError = "An unexpected error occurred.";
  static const String dioError = "Network Error:";
}
