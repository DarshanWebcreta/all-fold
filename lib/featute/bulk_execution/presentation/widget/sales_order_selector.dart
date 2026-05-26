import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:all_fold/core/theme/app_colors.dart';
import 'package:all_fold/core/component/card_widget.dart';
import 'package:all_fold/core/component/text_widget.dart';
import 'package:all_fold/core/utils/font_size.dart';
import 'package:all_fold/core/utils/font_weight.dart';
import 'package:all_fold/featute/bulk_execution/controller/bulk_execution_controller.dart';

class SalesOrderSelector extends StatelessWidget {
  const SalesOrderSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BulkExecutionController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const TextWidget(
          text: "Select Sales Orders to Group",
          fontSize: FontSizes.small,
          fontWeight: FontWeights.large,
        ).paddingOnly(bottom: 8),
        Obx(() {
          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.seedSalesOrders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final demand = controller.seedSalesOrders[index];
              final isSelected = controller.selectedSalesOrders.contains(demand);

              return InkWell(
                onTap: () => controller.addSalesOrderToBatch(demand),
                child: CardWidget(
                  verticalPadding: 10,
                  horiZontalPadding: 12,
                  bgClr: isSelected ? AppColors.lightOrange.withValues(alpha:0.1) : AppColors.white,
                  borderClr: isSelected ? AppColors.orange : AppColors.borderClr,
                  child: Row(
                    children: [
                      Checkbox(
                        activeColor: AppColors.orange,
                        value: isSelected,
                        onChanged: (_) => controller.addSalesOrderToBatch(demand),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextWidget(
                              text: demand.orderId,
                              fontSize: FontSizes.mediuam,
                              fontWeight: FontWeights.bold,
                              clr: AppColors.black,
                            ),
                            TextWidget(
                              text: "Customer: ${demand.customerName}",
                              fontSize: FontSizes.small,
                              fontWeight: FontWeights.small,
                              clr: AppColors.grey,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.lightGrey,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: TextWidget(
                          text: "Qty: ${demand.quantityDemanded}",
                          fontSize: FontSizes.small,
                          fontWeight: FontWeights.bold,
                          clr: AppColors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }),
      ],
    );
  }
}
