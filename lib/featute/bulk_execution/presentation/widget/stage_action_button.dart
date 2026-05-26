import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:all_fold/core/theme/app_colors.dart';
import 'package:all_fold/core/component/custom_button.dart';
import 'package:all_fold/core/component/text_widget.dart';
import 'package:all_fold/core/utils/font_size.dart';
import 'package:all_fold/core/utils/font_weight.dart';
import 'package:all_fold/featute/bulk_execution/controller/bulk_execution_controller.dart';
import 'package:all_fold/featute/bulk_execution/model/batch_model.dart';

class StageActionButton extends StatelessWidget {
  final String batchId;
  final int componentIndex;
  final ComponentJob component;

  const StageActionButton({
    super.key,
    required this.batchId,
    required this.componentIndex,
    required this.component,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BulkExecutionController>();

    if (component.currentStage == 4) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.check_circle, color: AppColors.green, size: 16),
          SizedBox(width: 4),
          TextWidget(
            text: "Completed",
            fontSize: FontSizes.small,
            fontWeight: FontWeights.bold,
            clr: AppColors.green,
          ),
        ],
      );
    }

    return Obx(() {
      final activeWH = controller.activeWarehouseId;
      final reqWH = component.currentStage;
      final isAuthorized = (activeWH == 0 || activeWH == reqWH);

      return SizedBox(
        height: 32,
        child: CustomButton(
          text: "MOVE STAGE",
          fontSize: FontSizes.mini,
          fontWeight: FontWeights.bold,
          radius: 6,
          color: isAuthorized ? AppColors.orange : AppColors.grey,
          callback: () {
            // Trigger move. The controller will show snackbar details if unauthorized
            controller.moveStage(batchId, componentIndex);
          },
        ),
      );
    });
  }
}
