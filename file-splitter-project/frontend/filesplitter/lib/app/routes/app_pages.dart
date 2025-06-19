import 'package:get/get.dart';

import '../../bindings/home_binding.dart';
import '../../bindings/result_binding.dart';
import '../../pages/home/home_page.dart';
import '../../pages/result/result_page.dart';

import 'app_routes.dart';

class AppPages {
  AppPages._(); // Private constructor

  // Initial route for the application
  static const INITIAL = AppRoutes.home;

  static final routes = [
    GetPage(
      name: AppRoutes.home,
      page: () => const HomePage(),
      binding: HomeBinding(), // Define this binding in lib/bindings/
    ),
    GetPage(
      name: AppRoutes.result,
      page: () => const ResultPage(),
      binding: ResultBinding(), // Define this binding in lib/bindings/
    ),
  ];
}
