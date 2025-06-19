import 'package:flutter/material.dart';
import 'package:get/get.dart'; // Using GetX for overlay management
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_colors.dart';
import '../constants/app_strings.dart';

class LoadingOverlay {
  static void show({String message = AppStrings.uploadingFile}) {
    // Check if an overlay is already open to prevent multiple overlays
    if (Get.isSnackbarOpen || Get.isOverlaysOpen) {
      return;
    }

    Get.dialog(
      WillPopScope(
        onWillPop: () async => false, // Prevent dialog from being dismissed by back button
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            constraints: const BoxConstraints(maxWidth: 300), // Limit width on larger screens
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  strokeWidth: 4,
                ),
                const SizedBox(height: 20),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false, // Prevents closing by tapping outside
      useSafeArea: true,
    );
  }

  static void hide() {
    if (Get.isDialogOpen!) { // Check if a dialog (our overlay) is currently open
      Get.back(); // Dismiss the current dialog
    }
  }
}
