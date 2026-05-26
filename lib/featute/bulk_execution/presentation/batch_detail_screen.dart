import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:all_fold/core/theme/app_colors.dart';
import 'package:all_fold/core/component/card_widget.dart';
import 'package:all_fold/core/component/custom_button.dart';
import 'package:all_fold/core/component/sizebox_widget.dart';
import 'package:all_fold/core/component/text_widget.dart';
import 'package:all_fold/core/utils/font_size.dart';
import 'package:all_fold/core/utils/font_weight.dart';
import 'package:all_fold/featute/bulk_execution/controller/bulk_execution_controller.dart';
import 'package:all_fold/featute/bulk_execution/presentation/widget/bom_guard_widget.dart';
import 'package:all_fold/featute/bulk_execution/presentation/widget/pipeline_stepper.dart';
import 'package:all_fold/featute/bulk_execution/presentation/widget/role_selector_widget.dart';
import 'package:all_fold/featute/bulk_execution/presentation/widget/stage_action_button.dart';

class BatchDetailScreen extends StatelessWidget {
  const BatchDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final batchId = Get.arguments as String;
    final controller = Get.find<BulkExecutionController>();

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: AppColors.black),
        title: TextWidget(
          text: "Batch Details: $batchId",
          fontSize: FontSizes.large,
          fontWeight: FontWeights.bold,
          clr: AppColors.black,
        ),
      ),
      body: Obx(() {
        final batchIndex = controller.batches.indexWhere((b) => b.id == batchId);
        if (batchIndex == -1) {
          return const Center(child: TextWidget(text: "Batch not found."));
        }
        final batch = controller.batches[batchIndex];

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            spacing: 16,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Operator Console
              const RoleSelectorWidget(),

              // 2. Batch Summary Info Card
              CardWidget(
                verticalPadding: 16,
                horiZontalPadding: 16,
                bgClr: AppColors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 4,
                  children: [
                    TextWidget(text: batch.product.title ?? '', fontSize: FontSizes.large, fontWeight: FontWeights.bold),
                    TextWidget(text: "SKU: ${batch.product.sku}", fontSize: FontSizes.small, clr: AppColors.grey),
                    const Divider().paddingSymmetric(vertical: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextWidget(text: "Target build quantity: ${batch.targetQuantity}", fontWeight: FontWeights.medium),
                        TextWidget(
                          text: "Progress: ${(batch.progressPercentage * 100).toInt()}%",
                          fontWeight: FontWeights.bold,
                          clr: AppColors.orange,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // 3. Pipeline Stepper Progress
              CardWidget(
                verticalPadding: 16,
                horiZontalPadding: 16,
                bgClr: AppColors.white,
                child: PipelineStepper(activeStage: batch.currentStage),
              ),

              // 4. BOM Stock Guard Board
              BOMGuardWidget(bomItems: batch.bomItems),

              // 5. Component Staging Jobs List (Stage-by-Stage Tracking)
              if (batch.components.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 8,
                  children: [
                    const TextWidget(text: "Component Jobs Staging", fontSize: FontSizes.large, fontWeight: FontWeights.bold),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: batch.components.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final comp = batch.components[index];
                        return CardWidget(
                          verticalPadding: 12,
                          horiZontalPadding: 16,
                          bgClr: AppColors.white,
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    TextWidget(text: comp.name, fontSize: FontSizes.mediuam, fontWeight: FontWeights.bold),
                                    TextWidget(text: "Pipeline Stage: ${comp.stageName}", fontSize: FontSizes.small, clr: AppColors.grey),
                                  ],
                                ),
                              ),
                              StageActionButton(batchId: batch.id, componentIndex: index, component: comp),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),

              // 6. Action Triggers (Generate Component Jobs or Complete Final Assembly)
              if (batch.status == "planned")
                SizedBox(
                  height: 48,
                  child: CustomButton(
                    text: "GENERATE COMPONENT JOBS",
                    color: AppColors.orange,
                    fontWeight: FontWeights.bold,
                    callback: () => controller.generateStagingJobs(batch.id),
                  ),
                )
              else if (batch.status == "in_progress" && batch.currentStage == 3)
                SizedBox(
                  height: 48,
                  child: CustomButton(
                    text: "FINALIZE ASSEMBLY & COMPLETE",
                    color: AppColors.green,
                    fontWeight: FontWeights.bold,
                    callback: () => controller.completeFinalAssembly(batch.id),
                  ),
                )
              else if (batch.status == "completed")
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.lightGreen,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: TextWidget(
                      text: "BATCH COMPLETED & ARCHIVED",
                      fontWeight: FontWeights.bold,
                      clr: AppColors.green,
                    ),
                  ),
                ),
              const CustomSizeBox(height: 30, width: 0),
            ],
          ),
        );
      }),
    );
  }
}
