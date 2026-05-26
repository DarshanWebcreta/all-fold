import 'package:flutter/material.dart';
import 'package:all_fold/core/theme/app_colors.dart';
import 'package:all_fold/core/component/text_widget.dart';
import 'package:all_fold/core/utils/font_size.dart';
import 'package:all_fold/core/utils/font_weight.dart';

class PipelineStepper extends StatelessWidget {
  final int activeStage; // 0, 1, 2, 3, 4
  const PipelineStepper({super.key, required this.activeStage});

  @override
  Widget build(BuildContext context) {
    final stages = [
      _StepInfo(title: "Raw Prep", stepNum: 1),
      _StepInfo(title: "Welding WIP", stepNum: 2),
      _StepInfo(title: "Assembly", stepNum: 3),
      _StepInfo(title: "Completed", stepNum: 4),
    ];

    return Row(
      children: List.generate(stages.length * 2 - 1, (index) {
        if (index.isOdd) {
          // Line separator
          final stepIndex = index ~/ 2;
          final isPassed = activeStage > stages[stepIndex].stepNum;
          return Expanded(
            child: Container(
              height: 3,
              color: isPassed ? AppColors.orange : AppColors.borderClr,
            ),
          );
        } else {
          // Step circle & text
          final stepIndex = index ~/ 2;
          final step = stages[stepIndex];
          final isCurrent = activeStage == step.stepNum;
          final isPassed = activeStage >= step.stepNum;

          return Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isCurrent 
                      ? AppColors.orange 
                      : (isPassed ? AppColors.lightOrange : AppColors.lightGrey),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isPassed ? AppColors.orange : AppColors.borderClr,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: step.stepNum == 4 && activeStage == 4
                      ? const Icon(Icons.check, color: AppColors.white, size: 16)
                      : TextWidget(
                          text: "${step.stepNum}",
                          fontSize: FontSizes.small,
                          fontWeight: FontWeights.bold,
                          clr: isCurrent 
                              ? AppColors.white 
                              : (isPassed ? AppColors.orange : AppColors.grey),
                        ),
                ),
              ),
              const SizedBox(height: 6),
              TextWidget(
                text: step.title,
                fontSize: FontSizes.tiny,
                fontWeight: isCurrent ? FontWeights.bold : FontWeights.medium,
                clr: isCurrent ? AppColors.orange : AppColors.grey,
              ),
            ],
          );
        }
      }),
    );
  }
}

class _StepInfo {
  final String title;
  final int stepNum;
  _StepInfo({required this.title, required this.stepNum});
}
