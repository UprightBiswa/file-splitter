import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app/routes/app_routes.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../widgets/custom_button.dart';
import 'result_controller.dart';

class ResultPage extends GetView<ResultController> {
  const ResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.resultTitle),
        centerTitle: true,
        // Disable back button if you want user to only navigate via specific buttons
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700), // Max width for content
            child: Obx(
              () => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    AppStrings.downloadParts,
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  if (controller.splitResults.isEmpty)
                    Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      color: AppColors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Text(
                          AppStrings.noSplitResults,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    )
                  else
                    // List of downloadable files
                    ListView.builder(
                      shrinkWrap: true, // Important for ListView inside SingleChildScrollView
                      physics: const NeverScrollableScrollPhysics(), // Disable internal scrolling
                      itemCount: controller.splitResults.length,
                      itemBuilder: (context, index) {
                        final result = controller.splitResults[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          elevation: 3,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          color: AppColors.white,
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                            leading: const Icon(Icons.file_download, color: AppColors.primary, size: 32),
                            title: Text(
                              result.filename,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            trailing: CustomButton(
                              text: "Download",
                              onPressed: () => controller.downloadFile(result.url),
                              backgroundColor: AppColors.secondary,
                              textColor: AppColors.textPrimary,
                              height: 40,
                              width: 120,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                              textStyle: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  const SizedBox(height: 32),
                  // Button to navigate back to home
                  CustomButton(
                    text: AppStrings.navigateHome,
                    onPressed: () {
                      Get.offAllNamed(AppRoutes.home); // Navigate back to home and clear stack
                    },
                    backgroundColor: AppColors.primary,
                    icon: const Icon(Icons.home, color: AppColors.white),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
