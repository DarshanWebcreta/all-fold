import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:all_fold/core/theme/app_colors.dart';
import 'package:all_fold/core/component/card_widget.dart';
import 'package:all_fold/core/component/text_widget.dart';
import 'package:all_fold/core/utils/font_size.dart';
import 'package:all_fold/core/utils/font_weight.dart';
import 'package:all_fold/featute/bulk_execution/model/batch_model.dart';

class BOMGuardWidget extends StatelessWidget {
  final List<BOMItem> bomItems;
  const BOMGuardWidget({super.key, required this.bomItems});

  @override
  Widget build(BuildContext context) {
    final hasShortage = bomItems.any((item) => !item.isStockSufficient);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const TextWidget(
              text: "BOM Stock Guard Check",
              fontSize: FontSizes.large,
              fontWeight: FontWeights.bold,
              clr: AppColors.black,
            ),
            Icon(
              hasShortage ? Icons.gpp_bad : Icons.gpp_good,
              color: hasShortage ? AppColors.red : AppColors.green,
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Prominent Warning if stock is insufficient
        if (hasShortage)
          CardWidget(
            bgClr: AppColors.lightRed,
            horiZontalPadding: 12,
            verticalPadding: 10,
            child: Row(
              spacing: 10,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Icon(Icons.warning_amber_rounded, color: AppColors.red, size: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 2,
                    children: [
                      TextWidget(
                        text: "PRODUCTION LOCKED",
                        fontSize: FontSizes.mediuam,
                        fontWeight: FontWeights.bold,
                        clr: AppColors.red,
                      ),
                      TextWidget(
                        text: "BOM Stock Guard check failed. One or more components have insufficient raw material stock. Contact an Administrator to adjust inventory.",
                        maxLine: 4,
                        fontSize: FontSizes.small,
                        clr: AppColors.red,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ).paddingOnly(bottom: 12),

        // List of materials
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: bomItems.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final item = bomItems[index];
            return CardWidget(
              verticalPadding: 12,
              horiZontalPadding: 16,
              bgClr: AppColors.white,
              borderClr: item.isStockSufficient ? AppColors.borderClr : AppColors.red.withValues(alpha:0.4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextWidget(
                          text: item.materialName,
                          fontSize: FontSizes.mediuam,
                          fontWeight: FontWeights.bold,
                          clr: AppColors.black,
                        ),
                        TextWidget(
                          text: "Required: ${item.requiredQty.toInt()}",
                          fontSize: FontSizes.small,
                          clr: AppColors.grey,
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      TextWidget(
                        text: "Stock: ${item.availableStock.toInt()}",
                        fontSize: FontSizes.mediuam,
                        fontWeight: FontWeights.bold,
                        clr: item.isStockSufficient ? AppColors.green : AppColors.red,
                      ),
                      TextWidget(
                        text: item.isStockSufficient ? "Available" : "Shortage",
                        fontSize: FontSizes.tiny,
                        fontWeight: FontWeights.medium,
                        clr: item.isStockSufficient ? AppColors.green : AppColors.red,
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
