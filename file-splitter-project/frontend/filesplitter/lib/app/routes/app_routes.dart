abstract class AppRoutes {
  AppRoutes._(); // Private constructor to prevent instantiation

  static const String home = _Paths.home;
  static const String result = _Paths.result;
}

abstract class _Paths {
  _Paths._(); // Private constructor to prevent instantiation

  static const String home = '/';
  static const String result = '/result';
}
