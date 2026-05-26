import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:all_fold/core/theme/app_colors.dart';
import 'package:all_fold/core/component/card_widget.dart';
import 'package:all_fold/core/component/text_widget.dart';
import 'package:all_fold/core/utils/font_size.dart';
import 'package:all_fold/core/utils/font_weight.dart';
import 'package:all_fold/featute/bulk_execution/controller/bulk_execution_controller.dart';

class DashboardStats extends StatelessWidget {
  const DashboardStats({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BulkExecutionController>();

    return Obx(() {
      final total = controller.batches.length;
      final active = controller.batches.where((b) => b.status == "in_progress").length;
      final completed = controller.batches.where((b) => b.status == "completed").length;
      
      // Calculate blocked batches (where BOM stock is insufficient)
      final blocked = controller.batches.where((b) => 
        b.status == "planned" && b.bomItems.any((item) => !item.isStockSufficient)
      ).length;

      return Row(
        spacing: 12,
        children: [
          Expanded(
            child: _buildStatCard(
              title: "Active Batches",
              value: "$active / $total",
              icon: Icons.factory_outlined,
              color: AppColors.orange,
            ),
          ),
          Expanded(
            child: _buildStatCard(
              title: "BOM Blocked",
              value: "$blocked",
              icon: Icons.gpp_bad_outlined,
              color: blocked > 0 ? AppColors.red : AppColors.grey,
            ),
          ),
          Expanded(
            child: _buildStatCard(
              title: "Completed",
              value: "$completed",
              icon: Icons.task_alt_outlined,
              color: AppColors.green,
            ),
          ),
        ],
      );
    });
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return CardWidget(
      verticalPadding: 12,
      horiZontalPadding: 12,
      bgClr: AppColors.white,
      borderClr: AppColors.borderClr,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 20),
              TextWidget(
                text: value,
                fontSize: FontSizes.extraLarge,
                fontWeight: FontWeights.bold,
                clr: AppColors.black,
              ),
            ],
          ),
          const SizedBox(height: 6),
          TextWidget(
            text: title,
            fontSize: FontSizes.tiny,
            fontWeight: FontWeights.medium,
            clr: AppColors.grey,
          ),
        ],
      ),
    );
  }
}
