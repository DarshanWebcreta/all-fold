import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:all_fold/core/theme/app_colors.dart';
import 'package:all_fold/core/component/text_widget.dart';
import 'package:all_fold/core/utils/font_size.dart';
import 'package:all_fold/core/utils/font_weight.dart';
import 'package:all_fold/featute/bulk_execution/controller/bulk_execution_controller.dart';
import 'package:all_fold/featute/bulk_execution/presentation/widget/unplanned_demand_card.dart';

class UnplannedDemandTab extends StatelessWidget {
  const UnplannedDemandTab({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BulkExecutionController>();

    return Obx(() {
      if (controller.unplannedError.value == "403") {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.lock_person_outlined,
                  color: AppColors.red,
                  size: 64,
                ),
                const SizedBox(height: 16),
                const TextWidget(
                  text: "Access Restricted",
                  fontSize: FontSizes.large,
                  fontWeight: FontWeights.bold,
                  clr: AppColors.red,
                ),
                const SizedBox(height: 8),
                const TextWidget(
                  text: "Unplanned Demand is limited to Admins and Stage 1 Warehouse users only. Stage 2/3 users are restricted.",
                  fontSize: FontSizes.small,
                  fontWeight: FontWeights.medium,
                  clr: AppColors.grey,
                  textAlign: TextAlign.center,
                  maxLine: 3,
                ),
              ],
            ),
          ),
        );
      }

      if (controller.isLoadingUnplanned.value) {
        return const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.orange),
          ),
        );
      }

      if (controller.unplannedProducts.isEmpty) {
        return RefreshIndicator(
          onRefresh: () => controller.fetchUnplannedDemand(),
          color: AppColors.orange,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.25),
              const Center(
                child: Column(
                  children: [
                    Icon(Icons.assignment_turned_in_outlined, color: AppColors.grey, size: 48),
                    SizedBox(height: 12),
                    TextWidget(
                      text: "No unplanned demand found.",
                      clr: AppColors.grey,
                      fontSize: FontSizes.mediuam,
                      fontWeight: FontWeights.medium,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () => controller.fetchUnplannedDemand(),
        color: AppColors.orange,
        child: ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(top: 8, bottom: 80),
          itemCount: controller.unplannedProducts.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            return UnplannedDemandCard(product: controller.unplannedProducts[index]);
          },
        ),
      );
    });
  }
}
