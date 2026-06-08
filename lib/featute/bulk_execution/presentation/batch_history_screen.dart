import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:all_fold/core/theme/app_colors.dart';
import 'package:all_fold/core/component/text_widget.dart';
import 'package:all_fold/core/component/card_widget.dart';
import 'package:all_fold/core/utils/font_size.dart';
import 'package:all_fold/core/utils/font_weight.dart';
import 'package:all_fold/featute/bulk_execution/controller/bulk_execution_controller.dart';
import 'package:all_fold/core/component/error_box_widget.dart';

class BatchHistoryScreen extends StatefulWidget {
  final int batchId;
  final String batchNo;

  const BatchHistoryScreen({super.key, required this.batchId, required this.batchNo});

  @override
  State<BatchHistoryScreen> createState() => _BatchHistoryScreenState();
}

class _BatchHistoryScreenState extends State<BatchHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<BulkExecutionController>().fetchBatchMovementHistory(widget.batchId, isRefresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BulkExecutionController>();

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.black),
          onPressed: () => Get.back(),
        ),
        title: TextWidget(
          text: "Batch #${widget.batchNo} History",
          fontSize: FontSizes.large,
          fontWeight: FontWeights.bold,
          clr: AppColors.black,
        ),
      ),
      body: Obx(() {
        if (controller.isLoadingMovements.value && controller.batchMovements.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppColors.orange)),
          );
        }

        if (controller.movementsError.value.isNotEmpty && controller.batchMovements.isEmpty) {
          return ErrorBoxWidget(
            errorMessage: "Unable to load movements log.",
            title: "Error Loading Logs",
            onRefresh: () => controller.fetchBatchMovementHistory(widget.batchId, isRefresh: true),
          );
        }

        final list = controller.batchMovements;
        if (list.isEmpty) {
          return Center(
            child: TextWidget(
              text: "No movement history logs found for this batch.",
              clr: AppColors.grey,
              fontSize: FontSizes.mediuam,
              fontWeight: FontWeights.medium,
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.fetchBatchMovementHistory(widget.batchId, isRefresh: true),
          color: AppColors.orange,
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: list.length + (controller.movementsCurrentPage.value < controller.movementsLastPage.value ? 1 : 0),
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              if (index < list.length) {
                final m = list[index];
                return CardWidget(
                  verticalPadding: 12,
                  horiZontalPadding: 16,
                  bgClr: AppColors.white,
                  borderClr: AppColors.borderClr,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.lightOrange,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: TextWidget(
                              text: m.movementNo ?? "",
                              fontSize: FontSizes.tiny,
                              fontWeight: FontWeights.bold,
                              clr: AppColors.orange,
                            ),
                          ),
                          TextWidget(
                            text: m.createdAt ?? "",
                            fontSize: FontSizes.tiny,
                            clr: AppColors.grey,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextWidget(
                        text: m.componentName ?? "Component Job",
                        fontSize: FontSizes.mediuam,
                        fontWeight: FontWeights.bold,
                        clr: AppColors.black,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          TextWidget(text: m.fromStage ?? "", fontSize: FontSizes.small, clr: AppColors.grey, fontWeight: FontWeights.medium),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 6.0),
                            child: Icon(Icons.arrow_forward, size: 12, color: AppColors.grey),
                          ),
                          TextWidget(text: m.toStage ?? "", fontSize: FontSizes.small, clr: AppColors.themeColor, fontWeight: FontWeights.bold),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Divider(color: AppColors.borderClr, height: 1),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextWidget(text: "Quantity: ${m.quantity ?? 0.0}", fontSize: FontSizes.small, fontWeight: FontWeights.bold, clr: AppColors.black),
                          if (m.weight != null)
                            TextWidget(text: "Weight: ${m.weight} kg", fontSize: FontSizes.small, clr: AppColors.grey),
                        ],
                      ),
                      if (m.remarks != null && m.remarks!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        TextWidget(text: "Remarks: ${m.remarks}", fontSize: FontSizes.tiny, clr: AppColors.grey, maxLine: 2),
                      ],
                      const SizedBox(height: 4),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: TextWidget(text: "By: ${m.creatorName ?? 'System'}", fontSize: FontSizes.tiny, clr: AppColors.grey),
                      ),
                    ],
                  ),
                );
              }

              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: controller.isLoadingMovements.value
                      ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppColors.orange))
                      : TextButton.icon(
                          onPressed: () {
                            controller.fetchBatchMovementHistory(widget.batchId, page: controller.movementsCurrentPage.value + 1);
                          },
                          icon: const Icon(Icons.add, color: AppColors.orange),
                          label: const TextWidget(text: "Load More", clr: AppColors.orange, fontWeight: FontWeights.bold),
                        ),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
