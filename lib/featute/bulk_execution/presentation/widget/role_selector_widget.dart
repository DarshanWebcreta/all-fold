import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:all_fold/core/theme/app_colors.dart';
import 'package:all_fold/core/component/text_widget.dart';
import 'package:all_fold/core/utils/font_size.dart';
import 'package:all_fold/core/utils/font_weight.dart';
import 'package:all_fold/featute/bulk_execution/controller/bulk_execution_controller.dart';

class RoleSelectorWidget extends StatelessWidget {
  const RoleSelectorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BulkExecutionController>();

    return Obx(() {
      final currentWH = controller.activeWarehouseId;
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderClr),
        ),
        child: Row(
          children: [
            const Icon(Icons.badge_outlined, color: AppColors.orange, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const TextWidget(
                    text: "Active Operator Terminal",
                    fontSize: FontSizes.tiny,
                    fontWeight: FontWeights.medium,
                    clr: AppColors.grey,
                  ),
                  TextWidget(
                    text: controller.activeWarehouseName,
                    fontSize: FontSizes.mediuam,
                    fontWeight: FontWeights.bold,
                    clr: AppColors.black,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            DropdownButton<int>(
              value: controller.simulatedWarehouseId.value ?? -1,
              underline: const SizedBox(),
              icon: const Icon(Icons.tune, color: AppColors.orange),
              dropdownColor: AppColors.white,
              borderRadius: BorderRadius.circular(8),
              onChanged: (val) {
                if (val == -1) {
                  controller.simulatedWarehouseId.value = null;
                } else {
                  controller.simulatedWarehouseId.value = val;
                }
              },
              items: const [
                DropdownMenuItem(value: -1, child: Text("Use Logged In User")),
                DropdownMenuItem(value: 0, child: Text("Simulate Admin")),
                DropdownMenuItem(value: 1, child: Text("Simulate Stage 1")),
                DropdownMenuItem(value: 2, child: Text("Simulate Stage 2")),
                DropdownMenuItem(value: 3, child: Text("Simulate Stage 3")),
              ],
            ),
          ],
        ),
      );
    });
  }
}
