import 'package:get/get.dart';

import '../pages/result/result_controller.dart';
import '../services/dio_service.dart';
import '../services/file_service.dart';

class ResultBinding extends Bindings {
  @override
  void dependencies() {
    // DioService and FileService should ideally be initialized once globally
    // if they are used across multiple controllers, but Get.find() will fetch
    // the existing instance if it's already "put" or "lazyPut" by another binding.
    // Ensure they are available by being put in HomeBinding or a global binding.
    Get.lazyPut<DioService>(() => DioService());
    Get.lazyPut<FileService>(() => FileService());

    Get.put<ResultController>(ResultController());
  }
}
