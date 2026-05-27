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

    return Obx(() {
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

      final batchesList = controller.activeApiBatches;

      if (batchesList.isEmpty) {
        return RefreshIndicator(
          onRefresh: () => controller.fetchActiveBatches(),
          color: AppColors.orange,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.25),
              const Center(
                child: TextWidget(
                  text: "No production batches found.",
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
          itemCount: batchesList.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            return ApiBatchCard(batch: batchesList[index]);
          },
        ),
      );
    });
  }
}
