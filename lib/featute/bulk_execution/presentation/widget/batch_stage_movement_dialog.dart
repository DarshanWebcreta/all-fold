import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:all_fold/core/theme/app_colors.dart';
import 'package:all_fold/core/component/text_widget.dart';
import 'package:all_fold/core/utils/font_size.dart';
import 'package:all_fold/core/utils/font_weight.dart';
import 'package:all_fold/core/utils/function_component.dart';
import 'package:all_fold/featute/bulk_execution/controller/bulk_execution_controller.dart';
import 'package:all_fold/featute/bulk_execution/model/active_batches_model.dart';

class BatchStageMovementDialog extends StatefulWidget {
  final int batchId;
  final ApiComponent component;

  const BatchStageMovementDialog({
    super.key,
    required this.batchId,
    required this.component,
  });

  @override
  State<BatchStageMovementDialog> createState() => _BatchStageMovementDialogState();
}

class _BatchStageMovementDialogState extends State<BatchStageMovementDialog> {
  late TextEditingController qtyController;
  late TextEditingController remarksController;
  String movementType = "Complete"; // "Complete" or "Transfer"
  int? targetStageId;
  int? sourceStageId;

  @override
  void initState() {
    super.initState();
    
    final c = widget.component;
    final stages = c.pipelineStages ?? [];
    final activeStagesWithQty = stages.where((s) => (s.reserved ?? 0) > 0).toList();
    final currentId = c.currentStageId ?? 0;
    final hasCurrentQty = activeStagesWithQty.any((s) => s.stageId == currentId);

    sourceStageId = hasCurrentQty 
        ? currentId 
        : (activeStagesWithQty.isNotEmpty ? activeStagesWithQty.first.stageId : currentId);

    final isCompleted = c.jobStatus == "completed";

    final sourceStage = stages.firstWhereOrNull((s) => s.stageId == sourceStageId);
    final defaultQty = sourceStageId == 0 
        ? (c.totalNeeded ?? 0) 
        : (sourceStage?.reserved ?? 0);

    qtyController = TextEditingController(text: defaultQty.toString());
    remarksController = TextEditingController();

    // Check if any stage after sourceStageId has reserved > 0
    bool hasTransferredToNext = false;
    if (sourceStageId! > 0) {
      hasTransferredToNext = stages.any((s) => (s.stageId ?? 0) > sourceStageId! && (s.reserved ?? 0) > 0);
    }

    // 1. Determine movementType
    if (sourceStageId == 0) {
      movementType = "Complete";
    } else {
      if (isCompleted || hasTransferredToNext) {
        movementType = "Transfer";
      } else {
        movementType = "Complete";
      }
    }

    // 2. Determine targetStageId
    if (sourceStageId == 0) {
      final hasStage1 = stages.any((s) => s.stageId == 1);
      targetStageId = hasStage1 ? 1 : (stages.isNotEmpty ? stages.first.stageId : null);
    } else {
      if (isCompleted || hasTransferredToNext) {
        final nextStageId = sourceStageId! + 1;
        final hasNextStage = stages.any((s) => s.stageId == nextStageId);
        targetStageId = hasNextStage ? nextStageId : (stages.isNotEmpty ? stages.first.stageId : null);
      } else {
        final hasCurrent = stages.any((s) => s.stageId == sourceStageId);
        targetStageId = hasCurrent ? sourceStageId : (stages.isNotEmpty ? stages.first.stageId : null);
      }
    }
  }

  @override
  void dispose() {
    qtyController.dispose();
    remarksController.dispose();
    super.dispose();
  }

  void _submit() {
    final controller = Get.find<BulkExecutionController>();
    final double? qty = double.tryParse(qtyController.text);
    if (qty == null || qty <= 0) {
      FunctionalWidget.showSnackBar(title: "Please enter a valid quantity", success: false);
      return;
    }

    if (targetStageId == null) {
      FunctionalWidget.showSnackBar(title: "Please select a target stage", success: false);
      return;
    }

    final c = widget.component;
    final stages = c.pipelineStages ?? [];
    final currentStage = stages.firstWhereOrNull((s) => s.stageId == sourceStageId);
    final maxAvailable = sourceStageId == 0 
        ? (c.totalNeeded ?? 0) 
        : (currentStage?.reserved ?? 0);

    if (qty > maxAvailable) {
      FunctionalWidget.showSnackBar(
        title: "Quantity cannot exceed available units ($maxAvailable)",
        success: false,
      );
      return;
    }

    final remarks = remarksController.text.trim();

    Get.back(); // Close dialog

    controller.moveComponentStage(
      batchId: widget.batchId,
      componentId: widget.component.componentId ?? 0,
      quantity: qty,
      toWarehouseId: targetStageId,
      remarks: remarks.isEmpty ? "Marking component job as $movementType" : remarks,
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.component;
    final stages = c.pipelineStages ?? [];
    
    final currentStage = stages.firstWhereOrNull((s) => s.stageId == sourceStageId);
    final maxAvailable = sourceStageId == 0 
        ? (c.totalNeeded ?? 0) 
        : (currentStage?.reserved ?? 0);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: AppColors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const TextWidget(
                    text: "Batch Stage Movement",
                    fontSize: FontSizes.large,
                    fontWeight: FontWeights.bold,
                    clr: AppColors.black,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.grey),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Component Info Details Card (grey card)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.lightGrey,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderClr.withValues(alpha:0.5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const TextWidget(
                                text: "COMPONENT",
                                fontSize: FontSizes.tiny,
                                fontWeight: FontWeights.bold,
                                clr: AppColors.grey,
                              ),
                              const SizedBox(height: 4),
                              TextWidget(
                                text: c.componentName ?? "Component",
                                fontSize: FontSizes.mediuam,
                                fontWeight: FontWeights.bold,
                                clr: AppColors.black,
                                maxLine: 2,
                              ),
                            ],
                          ),
                        ),
                        // Status Badge
                        (() {
                          final status = c.jobStatus ?? "not_started";
                          final stagesList = c.pipelineStages ?? [];
                          final lastStageId = stagesList.isNotEmpty
                              ? stagesList.map((s) => s.stageId ?? 0).reduce((max, val) => val > max ? val : max)
                              : 0;
                          final isFullyCompleted = status == "completed" && (c.currentStageId ?? 0) == lastStageId;

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
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const TextWidget(
                                text: "CURRENT LOCATION",
                                fontSize: FontSizes.tiny,
                                fontWeight: FontWeights.bold,
                                clr: AppColors.grey,
                              ),
                              const SizedBox(height: 4),
                              TextWidget(
                                text: c.currentStageLabel ?? "Stage",
                                fontSize: FontSizes.small,
                                fontWeight: FontWeights.bold,
                                clr: AppColors.green,
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const TextWidget(
                                text: "AVAILABLE AT STAGE",
                                fontSize: FontSizes.tiny,
                                fontWeight: FontWeights.bold,
                                clr: AppColors.grey,
                              ),
                              const SizedBox(height: 4),
                              RichText(
                                text: TextSpan(
                                  style: const TextStyle(fontFamily: "Outfit", color: AppColors.black, fontSize: FontSizes.small),
                                  children: [
                                    TextSpan(
                                      text: "$maxAvailable ",
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    const TextSpan(
                                      text: "Units max",
                                      style: TextStyle(color: AppColors.grey),
                                    ),
                                  ],
                                ),
                              ),
                              TextWidget(
                                text: "To complete: $maxAvailable",
                                fontSize: FontSizes.tiny,
                                fontWeight: FontWeights.bold,
                                clr: AppColors.orange,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const TextWidget(
                      text: "Complete qty at this stage first. Transfer on the next action.",
                      fontSize: FontSizes.tiny,
                      fontWeight: FontWeights.medium,
                      clr: AppColors.grey,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),



              // Target Stage Dropdown
              const TextWidget(
                text: "Target Stage",
                fontSize: FontSizes.small,
                fontWeight: FontWeights.bold,
                clr: AppColors.black,
              ),
              const SizedBox(height: 6),
              if (stages.where((s) => s.stageId != null && s.stageId != 0).isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.lightGrey,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.borderClr),
                  ),
                  child: const TextWidget(
                    text: "No stages available",
                    fontSize: FontSizes.small,
                    clr: AppColors.grey,
                  ),
                )
              else
                DropdownButtonFormField<int>(
                  value: targetStageId,
                  hint: const TextWidget(
                    text: "Select Target Stage",
                    fontSize: FontSizes.small,
                    clr: AppColors.grey,
                  ),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: AppColors.borderClr),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: AppColors.blue),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  dropdownColor: AppColors.white,
                  onChanged: (val) {
                    setState(() {
                      targetStageId = val;
                    });
                  },
                  items: stages
                      .where((s) => s.stageId != null && s.stageId != 0)
                      .map((stage) {
                        return DropdownMenuItem<int>(
                          value: stage.stageId!,
                          child: TextWidget(text: "${stage.stageId}. ${stage.stageName}"),
                        );
                      }).toList(),
                ),
              const SizedBox(height: 16),

              // Movement Type & Qty to Move
              Row(
                spacing: 12,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const TextWidget(
                          text: "Movement Type",
                          fontSize: FontSizes.small,
                          fontWeight: FontWeights.bold,
                          clr: AppColors.black,
                        ),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          value: movementType,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: AppColors.borderClr),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: AppColors.blue),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          dropdownColor: AppColors.white,
                          // {
                          //       "component_id": 3,
                          //       "component_name": "CR STRIP 118 * 0.60",
                          //       "qty_per_pc": 1,
                          //       "total_needed": 90,
                          //       "current_stage_id": 1,
                          //       "current_stage_label": "1. PLANT-1 SUPERVISOR",
                          //       "is_actionable_for_current_user": true,
                          //       "job_status": "not_started",
                          //       "pipeline_stages": [
                          //        {stage_id: 1, stage_name: 1. PLANT-1 SUPERVISOR, stock: 0, reserved: 0},
                          //        {stage_id: 2, stage_name: 2. PLANT-2 SUPERVISOR, stock: 0, reserved: 0},
                          //        {stage_id: 3, stage_name: 3. PLANT-3 ASSEMBLY SUPERVISOR, stock: 0, reserved: 0}
                          //       ]
                          //  },
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                movementType = val;
                                if (movementType == "Complete") {
                                  if (sourceStageId == 0) {
                                    final hasStage1 = stages.any((s) => s.stageId == 1);
                                    targetStageId = hasStage1 ? 1 : (stages.isNotEmpty ? stages.first.stageId : null);
                                  } else {
                                    final hasCurrent = stages.any((s) => s.stageId == sourceStageId);
                                    targetStageId = hasCurrent ? sourceStageId : (stages.isNotEmpty ? stages.first.stageId : null);
                                  }
                                } else {
                                  final nextStageId = sourceStageId == 0 ? 2 : (sourceStageId! + 1);
                                  final hasNext = stages.any((s) => s.stageId == nextStageId);
                                  targetStageId = hasNext ? nextStageId : (stages.isNotEmpty ? stages.first.stageId : null);
                                }
                              });
                            }
                          },
                          items: const [
                            DropdownMenuItem(value: "Complete", child: TextWidget(text: "Complete")),
                            DropdownMenuItem(value: "Transfer", child: TextWidget(text: "Transfer")),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: const TextSpan(
                            style: TextStyle(fontFamily: "Outfit", fontSize: FontSizes.small, color: AppColors.black),
                            children: [
                              TextSpan(text: "Qty to Move", style: TextStyle(fontWeight: FontWeight.bold)),
                              TextSpan(text: " *", style: TextStyle(color: AppColors.red, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: qtyController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: AppColors.borderClr),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: AppColors.blue),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Transfer Remarks Remarks
              const TextWidget(
                text: "Transfer Remarks",
                fontSize: FontSizes.small,
                fontWeight: FontWeights.bold,
                clr: AppColors.black,
              ),
              const SizedBox(height: 6),
              TextField(
                controller: remarksController,
                decoration: InputDecoration(
                  hintText: "Notes for this batch movement",
                  hintStyle: const TextStyle(color: AppColors.grey, fontSize: FontSizes.small),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: AppColors.borderClr),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: AppColors.blue),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Cancel & Submit Action row
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: AppColors.lightGrey,
                        foregroundColor: AppColors.black,
                        side: BorderSide.none,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () => Get.back(),
                      child: const TextWidget(
                        text: "Cancel",
                        fontWeight: FontWeights.medium,
                        fontSize: FontSizes.small,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.blue,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                      ),
                      onPressed: _submit,
                      icon: Icon(
                        movementType == "Complete" ? Icons.check_circle_outline : Icons.sync_alt,
                        size: 18,
                      ),
                      label: Text(
                        movementType == "Complete" ? "Complete" : "Transfer",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: FontSizes.small),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
