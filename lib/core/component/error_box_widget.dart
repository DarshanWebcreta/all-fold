import 'package:flutter/material.dart';
import 'package:all_fold/core/theme/app_colors.dart';
import 'package:all_fold/core/component/text_widget.dart';
import 'package:all_fold/core/utils/font_size.dart';
import 'package:all_fold/core/utils/font_weight.dart';

class ErrorBoxWidget extends StatelessWidget {
  final String? errorMessage;
  final String? title;
  final VoidCallback onRefresh;

  const ErrorBoxWidget({
    super.key,
    this.errorMessage,
    this.title,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Container(
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderClr, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: AppColors.lightRed,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline_rounded,
                  color: AppColors.red,
                  size: 40,
                ),
              ),
              const SizedBox(height: 16),
              TextWidget(
                text: title ?? "Connection Error",
                fontSize: FontSizes.large,
                fontWeight: FontWeights.bold,
                clr: AppColors.black,
              ),
              const SizedBox(height: 8),
              TextWidget(
                text: errorMessage != null && errorMessage!.isNotEmpty
                    ? errorMessage!
                    : "Something went wrong. Please check your connection or contact the administrator.",
                fontSize: FontSizes.small,
                fontWeight: FontWeights.medium,
                clr: AppColors.grey,
                textAlign: TextAlign.center,
                maxLine: 5,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.orange,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const TextWidget(
                  text: "Refresh",
                  fontWeight: FontWeights.bold,
                  fontSize: FontSizes.small,
                  clr: AppColors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
