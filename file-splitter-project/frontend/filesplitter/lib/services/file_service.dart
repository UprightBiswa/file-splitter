import 'package:dio/dio.dart' as dio;
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';

import '../constants/app_urls.dart';
import '../models/split_result_model.dart';
import '../utils/logger.dart';
import 'dio_service.dart';

class FileService extends GetxService {
  late DioService _dioService;

  @override
  void onInit() {
    super.onInit();
    _dioService = Get.find<DioService>();
  }

  /// Uploads a file to the backend for splitting.
  ///
  /// [file]: The PlatformFile object to upload.
  /// [chunkSize]: The desired chunk size in MB.
  /// [smartSplit]: A boolean indicating whether to use smart splitting.
  /// [onSendProgress]: Callback for upload progress.
  Future<bool> uploadFile(
    PlatformFile file,
    int chunkSize,
    bool smartSplit, {
    Function(int sent, int total)? onSendProgress,
  }) async {
    try {
      // Create FormData to send the file and other parameters
      dio.FormData formData = dio.FormData.fromMap({
        "file": dio.MultipartFile.fromBytes(
          file.bytes!, // Use bytes for web, as path is not available or useful
          filename: file.name,
        ),
        "chunkSize": chunkSize,
        "smartSplit": smartSplit,
      });

      // Make the POST request to the upload endpoint
      final response = await _dioService.dio.post(
        AppUrls.uploadFile,
        data: formData,
        onSendProgress: onSendProgress, // Pass the progress callback
      );

      if (response.statusCode == 200) {
        Logger.debug("File upload successful: ${response.data}");
        // Optionally handle the response data if the upload endpoint returns immediate results
        return true;
      } else {
        Logger.error("File upload failed with status: ${response.statusCode}");
        return false;
      }
    } on dio.DioException catch (e) {
      Logger.error("DioException during file upload: ${e.message}", error: e, stackTrace: e.stackTrace);
      // Error handling is already done in DioService interceptor,
      // but you can add specific logic here if needed.
      return false;
    } catch (e, st) {
      Logger.error("Unknown error during file upload: $e", error: e, stackTrace: st);
      return false;
    }
  }

  /// Fetches the list of downloadable split file parts.
  Future<List<SplitResultModel>> fetchSplitResults() async {
    try {
      final response = await _dioService.dio.get(AppUrls.fetchSplits);

      if (response.statusCode == 200 && response.data != null) {
        // Assuming the response data is a List of Maps
        List<dynamic> data = response.data;
        return data.map((json) => SplitResultModel.fromJson(json)).toList();
      } else {
        Logger.error("Failed to fetch split results: ${response.statusCode}");
        return [];
      }
    } on dio.DioException catch (e) {
      Logger.error("DioException during fetching split results: ${e.message}", error: e, stackTrace: e.stackTrace);
      return [];
    } catch (e, st) {
      Logger.error("Unknown error during fetching split results: $e", error: e, stackTrace: st);
      return [];
    }
  }
}
