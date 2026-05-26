import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:all_fold/core/theme/app_colors.dart';
import 'package:all_fold/core/component/text_widget.dart';
import 'package:all_fold/core/utils/font_size.dart';
import 'package:all_fold/core/utils/font_weight.dart';
import 'package:all_fold/featute/bulk_execution/controller/bulk_execution_controller.dart';
import 'package:all_fold/featute/bulk_execution/presentation/widget/api_batch_card.dart';

class BatchesTab extends StatelessWidget {
  const BatchesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BulkExecutionController>();
    final selectedFilter = "planned".obs;

    return Column(
      children: [
        // Horizontal Filter Chips
        Obx(() {
          return Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _buildFilterChip("Planned", "planned", selectedFilter.value, () => selectedFilter.value = "planned"),
              const SizedBox(width: 8),
              _buildFilterChip("Active WIP", "in_progress", selectedFilter.value, () => selectedFilter.value = "in_progress"),
              const SizedBox(width: 8),
              _buildFilterChip("Completed", "completed", selectedFilter.value, () => selectedFilter.value = "completed"),
            ],
          ).paddingSymmetric(vertical: 8);
        }),
        const SizedBox(height: 8),
        // Batches List
        Expanded(
          child: Obx(() {
            if (controller.isLoadingBatches.value) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.orange),
                ),
              );
            }

            if (controller.batchesError.value.isNotEmpty) {
              return Center(
                child: TextWidget(
                  text: controller.batchesError.value,
                  clr: AppColors.red,
                  fontSize: FontSizes.mediuam,
                  fontWeight: FontWeights.medium,
                ),
              );
            }

            final filterVal = selectedFilter.value;
            final filteredList = controller.activeApiBatches.where((b) => b.status == filterVal).toList();

            if (filteredList.isEmpty) {
              return RefreshIndicator(
                onRefresh: () => controller.fetchActiveBatches(),
                color: AppColors.orange,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.25),
                    const Center(
                      child: TextWidget(
                        text: "No production batches in this stage.",
                        clr: AppColors.grey,
                        fontSize: FontSizes.mediuam,
                        fontWeight: FontWeights.medium,
                      ),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () => controller.fetchActiveBatches(),
              color: AppColors.orange,
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 80),
                itemCount: filteredList.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return ApiBatchCard(batch: filteredList[index]);
                },
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildFilterChip(
    String label,
    String value,
    String selectedValue,
    VoidCallback onTap,
  ) {
    final isSelected = value == selectedValue;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.orange : AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.orange : AppColors.borderClr,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.orange.withValues(alpha:0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  )
                ]
              : [],
        ),
        child: TextWidget(
          text: label,
          fontSize: FontSizes.small,
          fontWeight: FontWeights.bold,
          clr: isSelected ? AppColors.white : AppColors.grey,
        ),
      ),
    );
  }
}
