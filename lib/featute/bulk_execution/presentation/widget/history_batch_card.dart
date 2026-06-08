import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:all_fold/core/theme/app_colors.dart';
import 'package:all_fold/core/component/card_widget.dart';
import 'package:all_fold/core/component/text_widget.dart';
import 'package:all_fold/core/utils/font_size.dart';
import 'package:all_fold/core/utils/font_weight.dart';
import 'package:all_fold/featute/bulk_execution/model/bulk_history_model.dart';
import 'package:all_fold/featute/bulk_execution/presentation/batch_history_screen.dart';

class HistoryBatchCard extends StatelessWidget {
  final BulkHistoryBatch batch;

  const HistoryBatchCard({super.key, required this.batch});

  @override
  Widget build(BuildContext context) {
    final statusColor = batch.status == "completed"
        ? AppColors.green
        : batch.status == "in_progress"
            ? AppColors.blue
            : AppColors.orange;

    final statusBgColor = batch.status == "completed"
        ? AppColors.lightGreen
        : batch.status == "in_progress"
            ? AppColors.lightBlue
            : AppColors.lightOrange;

    return CardWidget(
      verticalPadding: 14,
      horiZontalPadding: 16,
      bgClr: AppColors.white,
      borderClr: AppColors.borderClr,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Batch Number & Status Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  spacing: 8,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.lightBlue,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: TextWidget(
                        text: "#${batch.batchNo ?? ''}",
                        fontSize: FontSizes.tiny,
                        fontWeight: FontWeights.bold,
                        clr: AppColors.blue,
                      ),
                    ),
                    Flexible(
                      child: TextWidget(
                        text: batch.batchName ?? "Unnamed Batch",
                        fontSize: FontSizes.large,
                        fontWeight: FontWeights.bold,
                        clr: AppColors.black,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                spacing: 8,
                children: [
                  IconButton(
                    icon: const Icon(Icons.history, color: AppColors.orange, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    tooltip: "Batch History Log",
                    onPressed: () {
                      if (batch.id != null) {
                        Get.to(() => BatchHistoryScreen(batchId: batch.id!, batchNo: batch.batchNo ?? ""));
                      }
                    },
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusBgColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: TextWidget(
                      text: (batch.status ?? "UNKNOWN").toUpperCase(),
                      fontSize: FontSizes.tiny,
                      fontWeight: FontWeights.bold,
                      clr: statusColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Product Name and SKU
          TextWidget(
            text: "${batch.productName} (SKU: ${batch.sku})",
            fontSize: FontSizes.small,
            fontWeight: FontWeights.medium,
            clr: AppColors.grey,
          ),
          const SizedBox(height: 12),
          const Divider(color: AppColors.borderClr, height: 1),
          const SizedBox(height: 12),

          // Details: Qty, Creator, and Created At
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const TextWidget(
                    text: "PLANNED QTY",
                    fontSize: FontSizes.tiny,
                    fontWeight: FontWeights.medium,
                    clr: AppColors.grey,
                  ),
                  const SizedBox(height: 2),
                  TextWidget(
                    text: batch.plannedQty?.toStringAsFixed(2) ?? '0.00',
                    fontSize: FontSizes.mediuam,
                    fontWeight: FontWeights.bold,
                    clr: AppColors.themeColor,
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TextWidget(
                    text: "By: ${batch.createdBy ?? 'Unknown'}",
                    fontSize: FontSizes.tiny,
                    fontWeight: FontWeights.medium,
                    clr: AppColors.black,
                  ),
                  const SizedBox(height: 2),
                  TextWidget(
                    text: batch.createdAt ?? "",
                    fontSize: FontSizes.tiny,
                    fontWeight: FontWeights.medium,
                    clr: AppColors.grey,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
