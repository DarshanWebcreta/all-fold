import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:all_fold/core/theme/app_colors.dart';
import 'package:all_fold/core/component/text_widget.dart';
import 'package:all_fold/core/utils/font_size.dart';
import 'package:all_fold/core/utils/font_weight.dart';
import 'package:all_fold/featute/bulk_execution/model/active_batches_model.dart';
import 'package:all_fold/featute/bulk_execution/controller/bulk_execution_controller.dart';
import 'package:all_fold/featute/auth/controller/auth_controller.dart';

class ApiBatchComponentActionBanner extends StatelessWidget {
  final ApiComponent component;
  final bool isFullyCompleted;
  final VoidCallback onMoveTap;
  final int batchId;

  const ApiBatchComponentActionBanner({
    super.key,
    required this.component,
    required this.isFullyCompleted,
    required this.onMoveTap,
    required this.batchId,
  });

  /// Returns true if the currently logged-in user has the "PLANT-1" role.
  bool get _isPlant1User {
    try {
      final auth = Get.find<AuthController>();
      final roles = auth.rxUser.value?.roles ?? [];
      return roles.any((r) => r.trim().toUpperCase() == 'PLANT-1');
    } catch (_) {
      return false;
    }
  }

  void _showNotStartedDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: AppColors.white,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.info_outline, color: AppColors.orange, size: 48),
              const SizedBox(height: 16),
              const TextWidget(text: "Job Not Started", fontSize: FontSizes.large, fontWeight: FontWeights.bold, clr: AppColors.black),
              const SizedBox(height: 12),
              const TextWidget(
                text: "Please ask the administrator to create a job for this component.",
                fontSize: FontSizes.mediuam,
                clr: AppColors.grey,
                textAlign: TextAlign.center,
                maxLine: 3,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.orange,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    elevation: 0,
                  ),
                  onPressed: () => Get.back(),
                  child: const TextWidget(text: "Okay", fontWeight: FontWeights.bold, clr: AppColors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onCreateJobTap() {
    final componentId = component.componentId;
    if (componentId == null) {
      return;
    }

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: AppColors.white,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.add_task, color: AppColors.themeColor, size: 48),
              const SizedBox(height: 16),
              const TextWidget(
                text: "Create Job",
                fontSize: FontSizes.large,
                fontWeight: FontWeights.bold,
                clr: AppColors.black,
              ),
              const SizedBox(height: 10),
              TextWidget(
                text: "Create a job for \"${component.componentName ?? 'this component'}\"?",
                fontSize: FontSizes.mediuam,
                clr: AppColors.grey,
                textAlign: TextAlign.center,
                maxLine: 3,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.borderClr),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () => Get.back(),
                      child: const TextWidget(text: "Cancel", fontWeight: FontWeights.medium, clr: AppColors.grey),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.themeColor,
                        foregroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                      ),
                      onPressed: () {
                        Get.back();
                        final controller = Get.find<BulkExecutionController>();
                        controller.createJobForComponent(
                          batchId: batchId,
                          componentId: componentId,
                        );
                      },
                      child: const TextWidget(text: "Create", fontWeight: FontWeights.bold, clr: AppColors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (component.isActionableForCurrentUser == true && !isFullyCompleted) {
      if (component.jobStatus == "not_started") {
        // PLANT-1 supervisors can create the job directly
        if (_isPlant1User) {
          return GestureDetector(
            onTap: _onCreateJobTap,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.themeColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_task, color: AppColors.white, size: 18),
                  SizedBox(width: 6),
                  TextWidget(
                    text: "Create Job",
                    fontSize: FontSizes.mediuam,
                    fontWeight: FontWeights.bold,
                    clr: AppColors.white,
                  ),
                ],
              ),
            ),
          );
        }

        // Other users: show info-only banner
        return GestureDetector(
          onTap: _showNotStartedDialog,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.orange.withValues(alpha: 0.3)),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.hourglass_empty, color: AppColors.orange, size: 17),
                SizedBox(width: 6),
                TextWidget(text: "Awaiting Job Creation", fontSize: FontSizes.mediuam, fontWeight: FontWeights.bold, clr: AppColors.orange),
              ],
            ),
          ),
        );
      }

      final bool hasNext = component.nextStageId != null;
      final String buttonText = hasNext ? "Transfer to Next Stage" : "Move to Next Stage";

      return GestureDetector(
        onTap: onMoveTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.themeColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.sync_alt, color: AppColors.white, size: 18),
              const SizedBox(width: 6),
              TextWidget(text: buttonText, fontSize: FontSizes.mediuam, fontWeight: FontWeights.bold, clr: AppColors.white),
            ],
          ),
        ),
      );
    }

    if (isFullyCompleted) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: const Color(0xFFD1FAE5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, color: Color(0xFF065F46), size: 17),
            SizedBox(width: 6),
            TextWidget(text: "Component Ready", fontSize: FontSizes.mediuam, fontWeight: FontWeights.bold, clr: Color(0xFF065F46)),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.lightGrey,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderClr.withValues(alpha: 0.5)),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lock_outline, color: AppColors.grey, size: 17),
          SizedBox(width: 6),
          TextWidget(text: "Read-Only", fontSize: FontSizes.mediuam, fontWeight: FontWeights.medium, clr: AppColors.grey),
        ],
      ),
    );
  }
}
