import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_strings.dart';
import 'routes/app_pages.dart';
import 'theme/app_theme.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      theme: AppTheme.lightTheme,
      builder: (context, child) {
        return Material(
          child: DefaultTextStyle(
            style: GoogleFonts.poppins(
              color: AppTheme.lightTheme.textTheme.bodyMedium?.color,
            ),
            child: child!,
          ),
        );
      },
    );
  }
}
