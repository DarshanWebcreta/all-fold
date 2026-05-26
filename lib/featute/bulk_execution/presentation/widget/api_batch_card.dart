import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:all_fold/core/theme/app_colors.dart';
import 'package:all_fold/core/component/card_widget.dart';
import 'package:all_fold/core/component/text_widget.dart';
import 'package:all_fold/core/utils/font_size.dart';
import 'package:all_fold/core/utils/font_weight.dart';
import 'package:all_fold/featute/bulk_execution/model/active_batches_model.dart';
import 'package:all_fold/featute/bulk_execution/presentation/widget/batch_stage_movement_dialog.dart';
import 'package:all_fold/featute/bulk_execution/controller/bulk_execution_controller.dart';

class ApiBatchCard extends StatelessWidget {
  final ApiBatch batch;

  const ApiBatchCard({super.key, required this.batch});

  void _openMovementDialog(BuildContext context, ApiComponent component) {
    Get.dialog(
      BatchStageMovementDialog(
        batchId: batch.batchId ?? 0,
        component: component,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = batch.status == "completed"
        ? AppColors.green
        : batch.status == "in_progress"
            ? AppColors.blue
            : AppColors.orange;

    return CardWidget(
      verticalPadding: 16,
      horiZontalPadding: 16,
      bgClr: AppColors.white,
      borderClr: AppColors.borderClr,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Batch Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                spacing: 8,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.lightBlue,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: TextWidget(
                      text: "#${batch.batchNo}",
                      fontSize: FontSizes.tiny,
                      fontWeight: FontWeights.bold,
                      clr: AppColors.blue,
                    ),
                  ),
                  TextWidget(
                    text: batch.batchName ?? "Unnamed Batch",
                    fontSize: FontSizes.large,
                    fontWeight: FontWeights.bold,
                    clr: AppColors.black,
                  ),
                ],
              ),
              TextWidget(
                text: "Qty: ${batch.plannedQty ?? 0}",
                fontSize: FontSizes.small,
                fontWeight: FontWeights.bold,
                clr: AppColors.themeColor,
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Product Info
          TextWidget(
            text: "${batch.productName} (SKU: ${batch.sku})",
            fontSize: FontSizes.small,
            fontWeight: FontWeights.medium,
            clr: AppColors.grey,
          ),
          const SizedBox(height: 12),

          // Inventory Allocation Sub-Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.lightGrey,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.borderClr.withValues(alpha:0.5)),
            ),
            child: Row(
              children: [
                const Icon(Icons.layers_outlined, color: AppColors.blue, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontFamily: "Outfit",
                        fontSize: FontSizes.small,
                        color: AppColors.black,
                      ),
                      children: [
                        const TextSpan(text: "Inventory Allocation  "),
                        const TextSpan(
                          text: "Batch Size:",
                          style: TextStyle(color: AppColors.grey),
                        ),
                        TextSpan(
                          text: "${batch.plannedQty}.00  ",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const TextSpan(
                          text: "Status:",
                          style: TextStyle(color: AppColors.grey),
                        ),
                        TextSpan(
                          text: (batch.status ?? "PLANNED").toUpperCase(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Divider
          const Divider(color: AppColors.borderClr),
          const SizedBox(height: 8),

          // Components Staging Tracker Header
          const TextWidget(
            text: "Component Pipeline Tracking",
            fontSize: FontSizes.small,
            fontWeight: FontWeights.bold,
            clr: AppColors.orange,
          ),
          const SizedBox(height: 8),

          // Components List
          if (batch.components != null)
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: batch.components!.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, idx) {
                final comp = batch.components![idx];
                bool allPrevCompleted = true;
                for (int i = 0; i < idx; i++) {
                  if (batch.components![i].jobStatus != "completed") {
                    allPrevCompleted = false;
                    break;
                  }
                }
                return _buildComponentTracker(context, comp, allPrevCompleted);
              },
            ),

          // Final Assemble Button
          (() {
            final comps = batch.components ?? [];
            final allComponentsReady = comps.isNotEmpty && comps.every((c) {
              final stagesList = c.pipelineStages ?? [];
              final lastStageId = stagesList.isNotEmpty
                  ? stagesList.map((s) => s.stageId ?? 0).reduce((max, val) => val > max ? val : max)
                  : 0;
              return c.jobStatus == "completed" && (c.currentStageId ?? 0) == lastStageId;
            });
            if (batch.status == "completed") {
              return const SizedBox();
            }
            return Column(
              children: [
                const SizedBox(height: 16),
                const Divider(color: AppColors.borderClr),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: allComponentsReady ? AppColors.green : AppColors.lightGrey,
                      foregroundColor: allComponentsReady ? AppColors.white : AppColors.grey,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                          color: allComponentsReady ? Colors.transparent : AppColors.borderClr,
                        ),
                      ),
                    ),
                    onPressed: allComponentsReady
                        ? () {
                            final controller = Get.find<BulkExecutionController>();
                            controller.assembleBatch(batch.batchId ?? 0);
                          }
                        : null,
                    icon: Icon(
                      Icons.precision_manufacturing,
                      color: allComponentsReady ? AppColors.white : AppColors.grey,
                      size: 20,
                    ),
                    label: const Text(
                      "Final Assemble Batch",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: FontSizes.mediuam,
                      ),
                    ),
                  ),
                ),
              ],
            );
          })(),
        ],
      ),
    );
  }

  Widget _buildComponentTracker(BuildContext context, ApiComponent c, bool allPrevCompleted) {
    // Calculate reserved count from stage allocations
    double reserved = 0;
    if (c.pipelineStages != null) {
      for (var stage in c.pipelineStages!) {
        reserved += (stage.reserved ?? 0);
      }
    }

    // Calculate stage-wise progress: 25% per stage if 4 stages, 33.3% (approx 30%) if 3 stages, etc.
    final stagesList = c.pipelineStages ?? [];
    final totalStages = stagesList.where((s) => s.stageId != null && s.stageId != 0).length;
    int completedStages = 0;
    final currentStageId = c.currentStageId ?? 0;
    final isJobCompleted = c.jobStatus == "completed";

    final lastStageId = stagesList.isNotEmpty
        ? stagesList.map((s) => s.stageId ?? 0).reduce((max, val) => val > max ? val : max)
        : 0;
    final isFullyCompleted = isJobCompleted && currentStageId == lastStageId;

    if (currentStageId > 0) {
      if (isJobCompleted) {
        completedStages = currentStageId;
      } else {
        completedStages = currentStageId - 1;
      }
    }

    double progress = 0.0;
    if (totalStages > 0) {
      if (totalStages == 3) {
        progress = completedStages * 0.3333;
        if (completedStages >= 3) progress = 1.0;
      } else if (totalStages == 4) {
        progress = completedStages * 0.25;
      } else {
        progress = completedStages / totalStages;
      }
    }
    progress = progress.clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.lightGrey.withValues(alpha:0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderClr.withValues(alpha:0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Badge ID
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber[100],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: TextWidget(
                  text: "${c.componentId ?? 0}",
                  fontSize: FontSizes.tiny,
                  fontWeight: FontWeights.bold,
                  clr: Colors.orange[800]!,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextWidget(
                      text: c.componentName ?? "Component",
                      fontSize: FontSizes.mediuam,
                      fontWeight: FontWeights.bold,
                      clr: AppColors.black,
                    ),
                    TextWidget(
                      text: "${c.qtyPerPc ?? 1} per unit",
                      fontSize: FontSizes.tiny,
                      fontWeight: FontWeights.medium,
                      clr: AppColors.grey,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Component Status Badge
              (() {
                final status = c.jobStatus ?? "not_started";
                Color bg;
                Color textClr;
                String label;
                if (isFullyCompleted) {
                  bg = AppColors.lightGreen;
                  textClr = AppColors.green;
                  label = "Ready";
                } else if (status == "completed") {
                  bg = AppColors.lightBlue;
                  textClr = AppColors.blue;
                  label = "Completed";
                } else if (status == "processing") {
                  bg = Colors.orange[50]!;
                  textClr = Colors.orange;
                  label = "Processing";
                } else {
                  bg = AppColors.lightGrey;
                  textClr = AppColors.grey;
                  label = "Not Started";
                }
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: TextWidget(
                    text: label,
                    fontSize: FontSizes.tiny,
                    fontWeight: FontWeights.bold,
                    clr: textClr,
                  ),
                );
              })(),
            ],
          ),
          const SizedBox(height: 12),

          // Req Qty & Reserved Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const TextWidget(
                    text: "REQ. QTY",
                    fontSize: FontSizes.tiny,
                    fontWeight: FontWeights.medium,
                    clr: AppColors.grey,
                  ),
                  TextWidget(
                    text: "${c.totalNeeded ?? 0}",
                    fontSize: FontSizes.small,
                    fontWeight: FontWeights.bold,
                    clr: AppColors.black,
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const TextWidget(
                    text: "RESERVED STATUS",
                    fontSize: FontSizes.tiny,
                    fontWeight: FontWeights.medium,
                    clr: AppColors.grey,
                  ),
                  TextWidget(
                    text: "${reserved.toInt()} / ${c.totalNeeded ?? 0}",
                    fontSize: FontSizes.small,
                    fontWeight: FontWeights.bold,
                    clr: AppColors.grey,
                  ),
                  const SizedBox(height: 4),
                  // Progress bar
                  SizedBox(
                    width: 100,
                    height: 4,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: AppColors.borderClr,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.green),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Pipeline Stages
          const TextWidget(
            text: "STAGING PIPELINE TRACKING",
            fontSize: FontSizes.tiny,
            fontWeight: FontWeights.bold,
            clr: AppColors.grey,
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStageBox(1, c),
              const Icon(Icons.arrow_forward, color: AppColors.borderClr, size: 14),
              _buildStageBox(2, c),
              const Icon(Icons.arrow_forward, color: AppColors.borderClr, size: 14),
              _buildStageBox(3, c),
            ],
          ),
          const SizedBox(height: 16),

          // Operational Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const TextWidget(
                text: "OPERATIONAL ACTIONS",
                fontSize: FontSizes.tiny,
                fontWeight: FontWeights.bold,
                clr: AppColors.grey,
              ),
              Row(
                spacing: 8,
                children: [
                  // Move (yellow button)
                  if (c.isActionableForCurrentUser == true && !isFullyCompleted && allPrevCompleted)
                    InkWell(
                      onTap: () => _openMovementDialog(context, c),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.amber[100],
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.amber[300]!),
                        ),
                        child: const Row(
                          spacing: 4,
                          children: [
                            Icon(Icons.sync_alt, color: Colors.orange, size: 16),
                            TextWidget(
                              text: "Move",
                              fontSize: FontSizes.tiny,
                              fontWeight: FontWeights.bold,
                              clr: Colors.orange,
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.lightGrey,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: TextWidget(
                        text: isFullyCompleted ? "Ready" : "Read-Only",
                        fontSize: FontSizes.tiny,
                        fontWeight: FontWeights.medium,
                        clr: AppColors.grey,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStageBox(int stageId, ApiComponent c) {
    final stage = c.pipelineStages?.firstWhereOrNull((s) => s.stageId == stageId);
    final reservedVal = stage?.reserved ?? 0;
    final isCurrentStage = c.currentStageId == stageId;

    Color stageColor;
    Color bgClr;
    if (stageId == 1) {
      stageColor = Colors.orange[400]!;
      bgClr = Colors.orange[50]!;
    } else if (stageId == 2) {
      stageColor = Colors.blue[400]!;
      bgClr = Colors.blue[50]!;
    } else {
      stageColor = Colors.green[400]!;
      bgClr = Colors.green[50]!;
    }

    return Column(
      children: [
        Container(
          width: 80,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: bgClr,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: stageColor,
              width: 1.5,
              style: BorderStyle.solid,
            ),
          ),
          child: Center(
            child: TextWidget(
              text: "$reservedVal",
              fontSize: FontSizes.small,
              fontWeight: FontWeights.bold,
              clr: stageColor,
            ),
          ),
        ),
        const SizedBox(height: 4),
        // Active indicator dot
        if (isCurrentStage)
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: stageColor,
              shape: BoxShape.circle,
            ),
          )
        else
          const SizedBox(height: 6),
      ],
    );
  }
}
