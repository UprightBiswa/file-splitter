import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../../constants/app_urls.dart';
import '../../utils/logger.dart';
import '../widgets/custom_snackbar.dart';
import '../constants/app_strings.dart';

class DioService extends GetxService {
  late Dio _dio;

  Dio get dio => _dio; // Getter to access the Dio instance

  @override
  void onInit() {
    super.onInit();
    _initDio();
  }

  void _initDio() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppUrls.baseUrl,
        connectTimeout: const Duration(seconds: 15), // 15 seconds
        receiveTimeout: const Duration(seconds: 15), // 15 seconds
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptor for logging and error handling
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        Logger.debug('DIO REQUEST[${options.method}] => PATH: ${options.path}');
        Logger.debug('Headers: ${options.headers}');
        Logger.debug('Data: ${options.data}');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        Logger.debug(
            'DIO RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
        Logger.debug('Data: ${response.data}');
        return handler.next(response);
      },
      onError: (DioException e, handler) {
        Logger.error('DIO ERROR[${e.response?.statusCode}] => PATH: ${e.requestOptions.path}');
        Logger.error('Error message: ${e.message}');
        if (e.response != null) {
          Logger.error('Error response data: ${e.response?.data}');
        }

        String errorMessage = AppStrings.unknownError;
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.sendTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.unknown) {
          errorMessage = AppStrings.connectionError;
        } else if (e.response != null) {
          if (e.response!.statusCode! >= 400 && e.response!.statusCode! < 500) {
            // Client error
            errorMessage = e.response!.data['message'] ?? 'Client Error: ${e.response!.statusCode}';
          } else if (e.response!.statusCode! >= 500) {
            // Server error
            errorMessage = AppStrings.serverError;
          }
        }
        CustomSnackbar.showError("${AppStrings.dioError} $errorMessage");
        return handler.next(e); // Continue with the error
      },
    ));
  }
}
