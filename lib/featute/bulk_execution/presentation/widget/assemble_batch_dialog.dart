import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:all_fold/core/theme/app_colors.dart';
import 'package:all_fold/core/component/text_widget.dart';
import 'package:all_fold/core/utils/font_size.dart';
import 'package:all_fold/core/utils/font_weight.dart';
import 'package:all_fold/core/utils/function_component.dart';
import 'package:all_fold/featute/bulk_execution/controller/bulk_execution_controller.dart';
import 'package:all_fold/featute/bulk_execution/model/active_batches_model.dart';

class AssembleBatchDialog extends StatefulWidget {
  final ApiBatch batch;

  const AssembleBatchDialog({
    super.key,
    required this.batch,
  });

  @override
  State<AssembleBatchDialog> createState() => _AssembleBatchDialogState();
}

class _AssembleBatchDialogState extends State<AssembleBatchDialog> {
  late TextEditingController qtyController;

  String _formatNum(num? val) {
    if (val == null) return "0";
    if (val % 1 == 0) return val.toInt().toString();
    return val.toString();
  }

  num get _effectiveRemaining {
    final batch = widget.batch;
    if (batch.remainingQty != null) {
      return batch.remainingQty!;
    }
    if (batch.assembledQty != null && batch.plannedQty != null) {
      final rem = batch.plannedQty! - batch.assembledQty!;
      return rem > 0 ? rem : 0;
    }
    return batch.plannedQty ?? 0;
  }

  @override
  void initState() {
    super.initState();
    qtyController = TextEditingController();
    // Fetch material preview when dialog opens
    final batchId = widget.batch.batchId;
    if (batchId != null) {
      final controller = Get.find<BulkExecutionController>();
      controller.fetchAssemblePreview(batchId);
    }
  }

  @override
  void dispose() {
    qtyController.dispose();
    super.dispose();
  }

  void _submit() {
    final controller = Get.find<BulkExecutionController>();
    num? qty;
    final text = qtyController.text.trim();
    final remaining = _effectiveRemaining;

    if (text.isNotEmpty) {
      qty = num.tryParse(text);
      if (qty == null || qty <= 0) {
        FunctionalWidget.showSnackBar(title: "Please enter a valid quantity", success: false);
        return;
      }
      if (remaining > 0 && qty > remaining) {
        FunctionalWidget.showSnackBar(
          title: "Assemble quantity cannot exceed remaining batch quantity (${_formatNum(remaining)})",
          success: false,
        );
        return;
      }
    }

    FocusScope.of(context).unfocus();
    Get.back();

    controller.assembleBatch(
      batchId: widget.batch.batchId ?? 0,
      quantity: qty,
    );
  }

  @override
  Widget build(BuildContext context) {
    final batch = widget.batch;
    final remaining = _effectiveRemaining;
    final assembled = batch.assembledQty ?? 0;

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
                    text: "Process Assembly",
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

              // Batch info card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.lightGrey,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderClr.withValues(alpha: 0.5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.lightBlue,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: TextWidget(
                            text: "#${batch.batchNo}",
                            fontSize: FontSizes.small,
                            fontWeight: FontWeights.bold,
                            clr: AppColors.blue,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextWidget(
                            text: batch.batchName ?? "Batch",
                            fontSize: FontSizes.mediuam,
                            fontWeight: FontWeights.bold,
                            clr: AppColors.black,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    TextWidget(
                      text: "${batch.productName ?? ''} · ${batch.sku ?? ''}",
                      fontSize: FontSizes.small,
                      fontWeight: FontWeights.medium,
                      clr: AppColors.grey,
                    ),
                    const SizedBox(height: 14),
                    const Divider(height: 1, color: AppColors.borderClr),
                    const SizedBox(height: 12),

                    // Quantities breakdown row
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const TextWidget(
                                text: "PLANNED",
                                fontSize: FontSizes.tiny,
                                fontWeight: FontWeights.bold,
                                clr: AppColors.grey,
                              ),
                              const SizedBox(height: 2),
                              TextWidget(
                                text: "${_formatNum(batch.plannedQty)} Units",
                                fontSize: FontSizes.small,
                                fontWeight: FontWeights.bold,
                                clr: AppColors.black,
                              ),
                            ],
                          ),
                        ),
                        if (batch.assembledQty != null || assembled > 0)
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const TextWidget(
                                  text: "ASSEMBLED",
                                  fontSize: FontSizes.tiny,
                                  fontWeight: FontWeights.bold,
                                  clr: AppColors.green,
                                ),
                                const SizedBox(height: 2),
                                TextWidget(
                                  text: "${_formatNum(assembled)} Units",
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
                                text: "REMAINING",
                                fontSize: FontSizes.tiny,
                                fontWeight: FontWeights.bold,
                                clr: AppColors.orange,
                              ),
                              const SizedBox(height: 2),
                              TextWidget(
                                text: "${_formatNum(remaining)} Units",
                                fontSize: FontSizes.small,
                                fontWeight: FontWeights.bold,
                                clr: AppColors.orange,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── Material Preview (Stage 3 Used Items) ─────────────────────
              Obx(() {
                final controller = Get.find<BulkExecutionController>();
                if (controller.isLoadingAssemblePreview.value) {
                  return Column(
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.science_outlined, size: 14, color: AppColors.grey),
                          SizedBox(width: 6),
                          TextWidget(
                            text: "Loading material requirements…",
                            fontSize: FontSizes.small,
                            clr: AppColors.grey,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const LinearProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.orange),
                        backgroundColor: AppColors.borderClr,
                      ),
                      const SizedBox(height: 16),
                    ],
                  );
                }

                final preview = controller.assemblePreviewData.value;
                if (preview == null) return const SizedBox();

                final rawItems = preview['stage3_used_items'] as List?;
                if (rawItems == null || rawItems.isEmpty) return const SizedBox();

                final totals = preview['total_required_materials'] as Map?;
                final hasShortage = (totals?['total_shortage_items'] as num? ?? 0) > 0;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          hasShortage ? Icons.warning_amber_rounded : Icons.check_circle_outline,
                          size: 16,
                          color: hasShortage ? AppColors.red : Colors.green,
                        ),
                        const SizedBox(width: 6),
                        TextWidget(
                          text: hasShortage ? "Material Shortage Detected" : "Materials Ready",
                          fontSize: FontSizes.small,
                          fontWeight: FontWeights.bold,
                          clr: hasShortage ? AppColors.red : Colors.green,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: hasShortage ? AppColors.lightRed : AppColors.borderClr),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: rawItems.asMap().entries.map((entry) {
                          final i = entry.key;
                          final raw = entry.value as Map;
                          final name = raw['display_name'] ?? raw['name'] ?? 'Material';
                          final available = raw['available_total'] as num? ?? 0;
                          final required = raw['required_total'] as num? ?? 0;
                          final shortage = raw['shortage_total'] as num? ?? 0;
                          final unit = raw['unit'] ?? '';
                          final itemHasShortage = shortage > 0;

                          String fmt(num v) {
                            if (v % 1 == 0) return v.toInt().toString();
                            return v.toStringAsFixed(2);
                          }

                          return Column(
                            children: [
                              if (i > 0) const Divider(color: AppColors.borderClr, height: 1),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                color: itemHasShortage ? AppColors.lightRed.withValues(alpha: 0.4) : null,
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          TextWidget(
                                            text: name,
                                            fontSize: FontSizes.xsmall,
                                            fontWeight: FontWeights.semiBold,
                                            clr: AppColors.black,
                                          ),
                                          if (unit.isNotEmpty)
                                            TextWidget(text: unit, fontSize: 9, clr: AppColors.grey),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          TextWidget(
                                            text: 'Need: ${fmt(required)}',
                                            fontSize: 9,
                                            clr: AppColors.grey,
                                          ),
                                          TextWidget(
                                            text: 'Avail: ${fmt(available)}',
                                            fontSize: 9,
                                            fontWeight: FontWeights.semiBold,
                                            clr: itemHasShortage ? AppColors.red : Colors.green,
                                          ),
                                          if (itemHasShortage)
                                            TextWidget(
                                              text: 'Short: ${fmt(shortage)}',
                                              fontSize: 9,
                                              fontWeight: FontWeights.bold,
                                              clr: AppColors.red,
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              }),

              // Quantity Input
              const TextWidget(
                text: "Quantity to Assemble",
                fontSize: FontSizes.small,
                fontWeight: FontWeights.bold,
                clr: AppColors.black,
              ),
              const SizedBox(height: 6),
              TextField(
                controller: qtyController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                ],
                decoration: InputDecoration(
                  hintText: "Leave empty for all remaining (${_formatNum(remaining)})",
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
              const SizedBox(height: 6),
              TextWidget(
                text: "Leave empty or pass null to assemble all remaining (${_formatNum(remaining)}) units.",
                fontSize: FontSizes.tiny,
                clr: AppColors.grey,
              ),
              const SizedBox(height: 24),

              // Action buttons
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
                        backgroundColor: AppColors.themeColor,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                      ),
                      onPressed: _submit,
                      icon: const Icon(Icons.precision_manufacturing, size: 18),
                      label: const Text(
                        "Assemble",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: FontSizes.small),
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
