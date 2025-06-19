import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart'; // For launching URLs to download files

import '../../models/split_result_model.dart';
import '../../utils/logger.dart';
import '../../widgets/custom_snackbar.dart';

class ResultController extends GetxController {
  // Observable list to hold the split file results
  final RxList<SplitResultModel> splitResults = <SplitResultModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    // Retrieve arguments passed from the previous route (HomePage)
    if (Get.arguments != null && Get.arguments is List<SplitResultModel>) {
      splitResults.value = Get.arguments as List<SplitResultModel>;
      Logger.debug("Received ${splitResults.length} split results.");
    } else {
      Logger.info("No split results received.");
      CustomSnackbar.showError("No split results to display. Please try splitting a file again.");
    }
  }

  /// Launches the given URL to initiate file download.
  Future<void> downloadFile(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication); // Opens in a new tab/window
        Logger.debug("Launched URL for download: $url");
      } else {
        throw 'Could not launch $url';
      }
    } catch (e, st) {
      Logger.error("Error launching download URL: $e", error: e, stackTrace: st);
      CustomSnackbar.showError("Failed to download file: $e");
    }
  }
}
