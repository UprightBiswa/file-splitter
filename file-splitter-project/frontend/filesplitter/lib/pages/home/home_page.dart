import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../utils/helpers.dart';
import '../../widgets/custom_button.dart';
import 'home_controller.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Use LayoutBuilder for responsive design based on parent constraints
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.homeTitle),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600), // Max width for content
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // File Picker Section
                Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  color: AppColors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "Upload Your Document",
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        Obx(
                          () => CustomButton(
                            text: controller.selectedFile.value == null
                                ? AppStrings.selectFile
                                : controller.selectedFile.value!.name,
                            icon: controller.selectedFile.value == null
                                ? const Icon(Icons.upload_file, color: AppColors.white)
                                : const Icon(Icons.description, color: AppColors.white),
                            onPressed: controller.pickFile,
                            backgroundColor: controller.selectedFile.value == null
                                ? AppColors.primary
                                : AppColors.success, // Indicate file selected
                            width: double.infinity,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Obx(() => Text(
                              controller.selectedFile.value == null
                                  ? AppStrings.noFileSelected
                                  : "Size: ${FileHelpers.formatBytes(controller.selectedFile.value!.size, 2)}",
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            )),
                        const SizedBox(height: 24),
                        // Chunk Size Input
                        TextField(
                          controller: controller.chunkSizeController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: AppStrings.chunkSizeLabel,
                            hintText: 'e.g., 10',
                            prefixIcon: const Icon(Icons.aspect_ratio, color: AppColors.primary),
                          ),
                          style: GoogleFonts.poppins(color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 24),
                        // Smart Split Checkbox
                        Obx(
                          () => SwitchListTile(
                            title: Text(
                              AppStrings.smartSplitLabel,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            value: controller.smartSplit.value,
                            onChanged: controller.toggleSmartSplit,
                            activeColor: AppColors.secondary,
                            inactiveTrackColor: AppColors.divider,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Submit Button
                        Obx(
                          () => CustomButton(
                            text: AppStrings.submit,
                            onPressed: controller.submitFile,
                            isLoading: controller.isLoading.value,
                            width: double.infinity,
                            icon: const Icon(Icons.cloud_upload, color: AppColors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
