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

    final sourceStage = stages.firstWhereOrNull((s) => s.stageId == sourceStageId);
    
    final pendingQty = sourceStage?.pending ?? 0.0;
    final completedQty = sourceStage?.completed ?? 0.0;
    final hasNewFields = (sourceStage?.completed != null || sourceStage?.pending != null);

    // Determine default movementType
    if (hasNewFields) {
      if (pendingQty > 0.0 && completedQty == 0.0) {
        movementType = "Complete";
      } else if (completedQty > 0.0 && pendingQty == 0.0) {
        movementType = "Transfer";
      } else {
        // Both > 0 or both == 0: default to Complete
        movementType = "Complete";
      }
    } else {
      // Old fallback logic
      final isCompleted = c.jobStatus == "completed";
      final hasReservedQty = activeStagesWithQty.isNotEmpty;
      bool hasTransferredToNext = false;
      if (sourceStageId != null && sourceStageId! > 0) {
        hasTransferredToNext = stages.any((s) => (s.stageId ?? 0) > sourceStageId! && (s.reserved ?? 0) > 0);
      }
      if (!hasReservedQty) {
        movementType = "Complete";
      } else {
        if (isCompleted || hasTransferredToNext) {
          movementType = "Transfer";
        } else {
          movementType = "Complete";
        }
      }
    }

    // Determine targetStageId
    if (movementType == "Complete") {
      targetStageId = sourceStageId;
    } else {
      targetStageId = c.nextStageId ?? (sourceStageId != null ? sourceStageId! + 1 : null);
    }

    final hasReservedQty = activeStagesWithQty.isNotEmpty;
    final defaultQty = hasNewFields
        ? (movementType == "Complete" ? pendingQty : completedQty)
        : (!hasReservedQty 
            ? (c.totalNeeded ?? 0).toDouble() 
            : (sourceStage?.reserved ?? 0.0));

    qtyController = TextEditingController(text: defaultQty.toString());
    remarksController = TextEditingController();
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
    final sourceStage = stages.firstWhereOrNull((s) => s.stageId == sourceStageId);
    final pendingQty = sourceStage?.pending ?? 0.0;
    final completedQty = sourceStage?.completed ?? 0.0;
    final hasNewFields = (sourceStage?.completed != null || sourceStage?.pending != null);

    final double maxAvailable;
    if (hasNewFields) {
      maxAvailable = movementType == "Complete" ? pendingQty : completedQty;
    } else {
      final hasReservedQty = stages.any((s) => (s.reserved ?? 0.0) > 0.0);
      maxAvailable = !hasReservedQty 
          ? (c.totalNeeded ?? 0).toDouble() 
          : (sourceStage?.reserved ?? 0.0);
    }

    if (qty > maxAvailable) {
      FunctionalWidget.showSnackBar(
        title: "Quantity cannot exceed available units ($maxAvailable)",
        success: false,
      );
      return;
    }

    final remarks = remarksController.text.trim();

    FocusScope.of(context).unfocus();
    FocusManager.instance.primaryFocus?.unfocus();
    Get.back(); // Close dialog

    controller.moveComponentStage(
      batchId: widget.batchId,
      componentId: widget.component.componentId ?? 0,
      quantity: qty,
      toWarehouseId: movementType == "Complete" ? null : targetStageId,
      movementType: movementType,
      remarks: remarks.isEmpty ? "Marking component job as $movementType" : remarks,
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.component;
    final stages = c.pipelineStages ?? [];
    final sourceStage = stages.firstWhereOrNull((s) => s.stageId == sourceStageId);
    final pendingQty = sourceStage?.pending ?? 0.0;
    final completedQty = sourceStage?.completed ?? 0.0;
    final hasNewFields = (sourceStage?.completed != null || sourceStage?.pending != null);

    final double maxAvailable;
    if (hasNewFields) {
      maxAvailable = movementType == "Complete" ? pendingQty : completedQty;
    } else {
      final hasReservedQty = stages.any((s) => (s.reserved ?? 0.0) > 0.0);
      maxAvailable = !hasReservedQty 
          ? (c.totalNeeded ?? 0).toDouble() 
          : (sourceStage?.reserved ?? 0.0);
    }

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
                           final isFullyCompleted = c.isFullyCompleted;

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
                                text: movementType == "Complete"
                                    ? "To complete: $maxAvailable"
                                    : "To transfer: $maxAvailable",
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
                    TextWidget(
                      text: movementType == "Complete"
                          ? "Complete qty at this stage first. Transfer on the next action."
                          : "Qty completed. Transfer to the next stage.",
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
              else (() {
                final dropdownItems = <DropdownMenuItem<int>>[];
                for (var s in stages) {
                  if (s.stageId != null && s.stageId != 0) {
                    dropdownItems.add(
                      DropdownMenuItem<int>(
                        value: s.stageId!,
                        child: TextWidget(text: "${s.stageId}. ${s.stageName}"),
                      ),
                    );
                  }
                }
                if (targetStageId != null && !dropdownItems.any((item) => item.value == targetStageId)) {
                  String stageLabel = "Stage $targetStageId";
                  if (targetStageId == c.currentStageId) {
                    stageLabel = c.currentStageLabel ?? "Current Stage";
                  } else if (targetStageId == c.nextStageId) {
                    stageLabel = c.nextStageLabel ?? "Next Stage";
                  }
                  dropdownItems.add(
                    DropdownMenuItem<int>(
                      value: targetStageId!,
                      child: TextWidget(text: stageLabel.startsWith(RegExp(r'^\d+')) ? stageLabel : "$targetStageId. $stageLabel"),
                    ),
                  );
                }

                return DropdownButtonFormField<int>(
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
                  onChanged: null,
                  items: dropdownItems,
                );
              })(),
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
                        (() {
                          final showComplete = hasNewFields
                              ? (pendingQty > 0.0 || (pendingQty == 0.0 && completedQty == 0.0))
                              : true;
                          final showTransfer = hasNewFields
                              ? (completedQty > 0.0)
                              : true;

                          final menuItems = <DropdownMenuItem<String>>[];
                          if (showComplete) {
                            menuItems.add(const DropdownMenuItem(value: "Complete", child: TextWidget(text: "Complete")));
                          }
                          if (showTransfer) {
                            menuItems.add(const DropdownMenuItem(value: "Transfer", child: TextWidget(text: "Transfer")));
                          }
                          final canChangeMovement = hasNewFields && pendingQty > 0.0 && completedQty > 0.0;

                          return DropdownButtonFormField<String>(
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
                            onChanged: canChangeMovement
                                ? (val) {
                                    if (val != null) {
                                      setState(() {
                                        movementType = val;
                                        if (movementType == "Complete") {
                                          targetStageId = sourceStageId;
                                          qtyController.text = pendingQty.toString();
                                        } else {
                                          targetStageId = c.nextStageId ?? (sourceStageId != null ? sourceStageId! + 1 : null);
                                          qtyController.text = completedQty.toString();
                                        }
                                      });
                                    }
                                  }
                                : null,
                            items: menuItems,
                          );
                        })(),
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
