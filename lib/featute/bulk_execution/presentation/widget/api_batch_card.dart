import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:all_fold/core/theme/app_colors.dart';
import 'package:all_fold/core/component/card_widget.dart';
import 'package:all_fold/core/component/text_widget.dart';
import 'package:all_fold/core/utils/font_size.dart';
import 'package:all_fold/core/utils/font_weight.dart';
import 'package:all_fold/featute/bulk_execution/model/active_batches_model.dart';
import 'package:all_fold/featute/bulk_execution/controller/bulk_execution_controller.dart';
import 'package:all_fold/featute/bulk_execution/presentation/batch_history_screen.dart';
import 'package:all_fold/featute/bulk_execution/presentation/widget/batch_card_components/api_batch_component_tracker.dart';

class ApiBatchCard extends StatelessWidget {
  final ApiBatch batch;

  const ApiBatchCard({super.key, required this.batch});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BulkExecutionController>();

    return Obx(() {
      final isExpanded = controller.expandedBatchIds.contains(batch.batchId);

      // Status color/label
      final String statusLabel = (batch.status ?? "planned").replaceAll('_', ' ');
      final Color statusClr = batch.status == "completed"
          ? AppColors.green
          : batch.status == "in_progress"
              ? AppColors.blue
              : AppColors.orange;
      final Color statusBg = batch.status == "completed"
          ? AppColors.lightGreen
          : batch.status == "in_progress"
              ? AppColors.lightBlue
              : const Color(0xFFFFF3E0);

      // Ready summary for collapsed view
      final comps = batch.components ?? [];
      final readyCount = comps.where((c) => c.isFullyCompleted).length;

      return CardWidget(
        verticalPadding: 12,
        horiZontalPadding: 14,
        bgClr: AppColors.white,
        borderClr: AppColors.borderClr,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Tappable header ──────────────────────────────────────────
            InkWell(
              onTap: () {
                if (batch.batchId == null) return;
                if (controller.expandedBatchIds.contains(batch.batchId)) {
                  controller.expandedBatchIds.remove(batch.batchId);
                } else {
                  controller.expandedBatchIds.add(batch.batchId!);
                }
              },
              borderRadius: BorderRadius.circular(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Batch number badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: AppColors.lightBlue, borderRadius: BorderRadius.circular(4)),
                        child: TextWidget(text: "#${batch.batchNo}", fontSize: FontSizes.small, fontWeight: FontWeights.bold, clr: AppColors.blue),
                      ),
                      const SizedBox(width: 8),
                      // Batch name
                      Expanded(
                        child: TextWidget(text: batch.batchName ?? "Unnamed Batch", fontSize: FontSizes.large, fontWeight: FontWeights.bold, clr: AppColors.black),
                      ),
                      // History icon
                      GestureDetector(
                        onTap: () {
                          if (batch.batchId != null) Get.to(() => BatchHistoryScreen(batchId: batch.batchId!, batchNo: batch.batchNo ?? ""));
                        },
                        child: const Padding(
                          padding: EdgeInsets.all(4),
                          child: Icon(Icons.history_rounded, color: AppColors.orange, size: 18),
                        ),
                      ),
                      const SizedBox(width: 4),
                      AnimatedRotation(
                        turns: isExpanded ? 0.5 : 0.0,
                        duration: const Duration(milliseconds: 200),
                        child: const Icon(Icons.keyboard_arrow_down, color: AppColors.grey, size: 22),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Expanded(
                        child: TextWidget(text: "${batch.productName ?? ''} · ${batch.sku ?? ''}", fontSize: FontSizes.small, fontWeight: FontWeights.medium, clr: AppColors.grey),
                      ),
                      const SizedBox(width: 8),
                      // Status badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(20)),
                        child: TextWidget(text: statusLabel, fontSize: FontSizes.small, fontWeight: FontWeights.bold, clr: statusClr),
                      ),
                      const SizedBox(width: 8),
                      // Ready count (collapsed only)
                      if (!isExpanded)
                        TextWidget(text: "$readyCount/${comps.length} ready", fontSize: FontSizes.small, fontWeight: FontWeights.medium, clr: AppColors.grey),
                    ],
                  ),
                ],
              ),
            ),

            // ── Expanded content ─────────────────────────────────────────
            if (isExpanded) ...[
              const SizedBox(height: 10),
              const Divider(color: AppColors.borderClr, height: 1),
              const SizedBox(height: 10),

              // Batch summary stats — 3 pill chips in a row
              Row(
                children: [
                  _statChip("Batch Size", "${batch.plannedQty ?? 0}", AppColors.lightBlue, AppColors.blue),
                  const SizedBox(width: 8),
                  _statChip("Components", "${comps.length}", AppColors.lightGrey, AppColors.grey),
                  const SizedBox(width: 8),
                  _statChip("Ready", "$readyCount / ${comps.length}",
                      readyCount == comps.length ? AppColors.lightGreen : AppColors.lightGrey,
                      readyCount == comps.length ? AppColors.green : AppColors.grey),
                ],
              ),

              if (comps.isNotEmpty) ...[
                const SizedBox(height: 16),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: comps.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (ctx, idx) {
                    bool allPrev = true;
                    for (int i = 0; i < idx; i++) {
                      if (comps[i].jobStatus != "completed") { allPrev = false; break; }
                    }
                    return ApiBatchComponentTracker(batch: batch, component: comps[idx], allPrevCompleted: allPrev);
                  },
                ),
              ],

              // ── Assemble button ────────────────────────────────────────
              if (batch.status != "completed")
                Obx(() {
                  final allReady = comps.isNotEmpty && comps.every((c) => c.isFullyCompleted);
                  final ctrl = Get.find<BulkExecutionController>();
                  final isPrepared = ctrl.preparedBatches.contains(batch.batchId) || batch.status == "prepared";
                  return Column(
                    children: [
                      const SizedBox(height: 14),
                      const Divider(color: AppColors.borderClr, height: 1),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: allReady ? (isPrepared ? AppColors.green : AppColors.orange) : AppColors.lightGrey,
                            foregroundColor: allReady ? AppColors.white : AppColors.grey,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: allReady ? Colors.transparent : AppColors.borderClr)),
                          ),
                          onPressed: allReady ? () {
                            FocusScope.of(context).unfocus();
                            isPrepared ? ctrl.assembleBatch(batch.batchId ?? 0) : ctrl.prepareBatch(batch.batchId ?? 0);
                          } : null,
                          icon: Icon(isPrepared ? Icons.check_circle_outline : Icons.precision_manufacturing, size: 18),
                          label: Text(isPrepared ? "Confirm Final Assembly" : "Start Assemble (Prepare Batch)", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: FontSizes.mediuam)),
                        ),
                      ),
                    ],
                  );
                }),
            ],
          ],
        ),
      );
    });
  }

  Widget _statChip(String label, String value, Color bg, Color clr) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextWidget(text: label, fontSize: FontSizes.tiny, fontWeight: FontWeights.medium, clr: clr.withValues(alpha: 0.7)),
          const SizedBox(height: 1),
          TextWidget(text: value, fontSize: FontSizes.small, fontWeight: FontWeights.bold, clr: clr),
        ],
      ),
    );
  }
}
