import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:all_fold/core/theme/app_colors.dart';
import 'package:all_fold/core/component/card_widget.dart';
import 'package:all_fold/core/component/status_card.dart';
import 'package:all_fold/core/component/text_widget.dart';
import 'package:all_fold/core/utils/font_size.dart';
import 'package:all_fold/core/utils/font_weight.dart';
import 'package:all_fold/featute/bulk_execution/model/batch_model.dart';
import 'package:all_fold/core/routes/route_name.dart';

class BatchCard extends StatelessWidget {
  final ProductionBatch batch;
  const BatchCard({super.key, required this.batch});

  @override
  Widget build(BuildContext context) {
    // Check if BOM stock guard is failing (only relevant in planned status)
    final isBlocked = batch.status == "planned" && batch.bomItems.any((item) => !item.isStockSufficient);
    final displayStatus = isBlocked ? "needs_adjustment" : batch.status;

    return InkWell(
      onTap: () {
        Get.toNamed(RoutesNames.batchDetail, arguments: batch.id);
      },
      child: CardWidget(
        verticalPadding: 16,
        horiZontalPadding: 16,
        bgClr: AppColors.white,
        borderClr: isBlocked ? AppColors.red.withValues(alpha:0.4) : AppColors.borderClr,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextWidget(
                      text: batch.id,
                      fontSize: FontSizes.large,
                      fontWeight: FontWeights.bold,
                      clr: AppColors.black,
                    ),
                    TextWidget(
                      text: "SKU: ${batch.product.sku}",
                      fontSize: FontSizes.small,
                      fontWeight: FontWeights.small,
                      clr: AppColors.grey,
                    ),
                  ],
                ),
                StatusCard(
                  status: displayStatus,
                  radius: 6,
                  fontSize: FontSizes.tiny,
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextWidget(
              text: batch.product.title ?? "Unknown Product",
              fontSize: FontSizes.mediuam,
              fontWeight: FontWeights.bold,
              clr: AppColors.black,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextWidget(
                  text: "Target Quantity: ${batch.targetQuantity}",
                  fontSize: FontSizes.small,
                  fontWeight: FontWeights.medium,
                  clr: AppColors.black,
                ),
                TextWidget(
                  text: "Orders: ${batch.salesOrders.length}",
                  fontSize: FontSizes.small,
                  fontWeight: FontWeights.medium,
                  clr: AppColors.grey,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: batch.progressPercentage,
                      backgroundColor: AppColors.lightGrey,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isBlocked ? AppColors.red : AppColors.orange,
                      ),
                      minHeight: 6,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                TextWidget(
                  text: "${(batch.progressPercentage * 100).toInt()}%",
                  fontSize: FontSizes.small,
                  fontWeight: FontWeights.bold,
                  clr: isBlocked ? AppColors.red : AppColors.black,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
