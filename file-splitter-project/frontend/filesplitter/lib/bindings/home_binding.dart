import 'package:get/get.dart';

import '../pages/home/home_controller.dart';
import '../services/dio_service.dart';
import '../services/file_service.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // Lazy put for DioService and FileService:
    // They will be created only when they are first used (Get.find<Service>()).
    // This is useful for services that might not be needed immediately.
    Get.lazyPut<DioService>(() => DioService());
    Get.lazyPut<FileService>(() => FileService());

    // Fenix: true means the instance will be recreated if it's removed from memory,
    // useful for controllers on pages that might be revisited.
    Get.put<HomeController>(HomeController());
  }
}
