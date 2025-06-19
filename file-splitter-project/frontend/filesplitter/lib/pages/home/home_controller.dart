import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import 'package:universal_html/html.dart' as html; // For web-specific file handling

import '../../constants/app_strings.dart';
import '../../models/split_result_model.dart';
import '../../services/file_service.dart';
import '../../utils/helpers.dart';
import '../../utils/logger.dart';
import '../../widgets/custom_snackbar.dart';
import '../../widgets/loading_overlay.dart';
import '../../app/routes/app_routes.dart';

class HomeController extends GetxController {
  // Observables for UI state
  final Rx<PlatformFile?> selectedFile = Rx<PlatformFile?>(null);
  final TextEditingController chunkSizeController = TextEditingController();
  final RxBool smartSplit = false.obs;
  final RxBool isLoading = false.obs;
  final RxDouble uploadProgress = 0.0.obs; // For showing upload progress

  // FileService instance via GetX dependency injection
  late FileService _fileService;

  @override
  void onInit() {
    super.onInit();
    _fileService = Get.find<FileService>(); // Get the FileService instance
    chunkSizeController.text = '10'; // Default chunk size
  }

  @override
  void onClose() {
    chunkSizeController.dispose();
    super.onClose();
  }

  /// Handles file picking using file_picker package.
  Future<void> pickFile() async {
    try {
      // Allow only .txt, .doc, .docx files
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['txt', 'doc', 'docx'],
        withData: true, // Important for web: returns bytes
      );

      if (result != null && result.files.single.bytes != null) {
        // file.single because we only allow single file selection
        final PlatformFile pickedFile = result.files.single;

        // Validate file type and size
        if (!FileHelpers.isValidFileType(pickedFile)) {
          CustomSnackbar.showError(AppStrings.fileTypeError);
          selectedFile.value = null; // Clear selection
          return;
        }

        if (!FileHelpers.isValidFileSize(pickedFile)) {
          CustomSnackbar.showError(AppStrings.fileSizeError);
          selectedFile.value = null; // Clear selection
          return;
        }

        selectedFile.value = pickedFile;
        Logger.debug("File picked: ${pickedFile.name}, size: ${pickedFile.size} bytes");
      } else {
        // User canceled the picker or file had no bytes (unlikely with withData: true)
        selectedFile.value = null;
        Logger.debug("File picking canceled or no file selected.");
      }
    } catch (e, st) {
      Logger.error("Error picking file: $e", error: e, stackTrace: st);
      CustomSnackbar.showError("Failed to pick file: $e");
    }
  }

  /// Toggles the smart split option.
  void toggleSmartSplit(bool? value) {
    if (value != null) {
      smartSplit.value = value;
      Logger.debug("Smart Split toggled: ${smartSplit.value}");
    }
  }

  /// Handles the file submission and upload process.
  Future<void> submitFile() async {
    if (selectedFile.value == null) {
      CustomSnackbar.showError("Please select a file first.");
      return;
    }

    final int? chunkSize = int.tryParse(chunkSizeController.text.trim());
    if (chunkSize == null || chunkSize <= 0) {
      CustomSnackbar.showError(AppStrings.invalidChunkSize);
      return;
    }

    isLoading.value = true;
    LoadingOverlay.show(message: AppStrings.uploadingFile);
    uploadProgress.value = 0.0; // Reset progress

    try {
      // Use the file bytes for web upload
      bool success = await _fileService.uploadFile(
        selectedFile.value!,
        chunkSize,
        smartSplit.value,
        onSendProgress: (sent, total) {
          if (total > 0) {
            uploadProgress.value = sent / total;
            Logger.debug("Upload Progress: ${(uploadProgress.value * 100).toStringAsFixed(2)}%");
            // Update overlay message with progress
            LoadingOverlay.show(message: "${AppStrings.uploadingFile} (${(uploadProgress.value * 100).toStringAsFixed(0)}%)");
          }
        },
      );

      if (success) {
        CustomSnackbar.showSuccess(AppStrings.uploadSuccess);
        // After successful upload, fetch results and navigate
        List<SplitResultModel> results = await _fileService.fetchSplitResults();
        if (results.isNotEmpty) {
          Get.toNamed(AppRoutes.result, arguments: results);
        } else {
          CustomSnackbar.showError(AppStrings.noSplitResults);
        }
      } else {
        CustomSnackbar.showError(AppStrings.uploadFailed);
      }
    } catch (e, st) {
      Logger.error("Error during file submission: $e", error: e, stackTrace: st);
      CustomSnackbar.showError("${AppStrings.uploadFailed}: $e");
    } finally {
      isLoading.value = false;
      LoadingOverlay.hide(); // Hide overlay regardless of success or failure
    }
  }

  /// Clears the selected file and resets chunk size.
  void clearSelection() {
    selectedFile.value = null;
    chunkSizeController.text = '10';
    smartSplit.value = false;
    uploadProgress.value = 0.0;
  }
}
