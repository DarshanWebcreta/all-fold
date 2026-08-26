import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:all_fold/core/theme/app_colors.dart';
import 'package:all_fold/core/component/text_widget.dart';
import 'package:all_fold/core/utils/font_size.dart';
import 'package:all_fold/core/utils/font_weight.dart';
import 'package:all_fold/featute/bulk_execution/model/active_batches_model.dart';
import 'package:all_fold/featute/bulk_execution/presentation/widget/batch_card_components/api_batch_component_action_banner.dart';
import 'package:all_fold/featute/bulk_execution/presentation/widget/batch_stage_movement_dialog.dart';

class ApiBatchComponentTracker extends StatelessWidget {
  final ApiBatch batch;
  final ApiComponent component;
  final bool allPrevCompleted;

  const ApiBatchComponentTracker({
    super.key,
    required this.batch,
    required this.component,
    required this.allPrevCompleted,
  });

  void _openMovementDialog(BuildContext context, ApiComponent comp) {
    FocusScope.of(context).unfocus();
    FocusManager.instance.primaryFocus?.unfocus();
    Get.dialog(BatchStageMovementDialog(batchId: batch.batchId ?? 0, component: comp));
  }

  @override
  Widget build(BuildContext context) {
    final c = component;
    final stagesList = List<PipelineStage>.from(c.pipelineStages ?? []);
    if (c.nextStageId != null && !stagesList.any((s) => s.stageId == c.nextStageId)) {
      stagesList.add(PipelineStage(
        stageId: c.nextStageId,
        stageName: c.nextStageLabel ?? "Stage ${c.nextStageId}",
        stock: 0,
        reserved: 0,
        completed: 0,
        pending: 0,
      ));
    }
    final totalStages = stagesList.length;
    final currentStageId = c.currentStageId ?? 0;
    final isFullyCompleted = c.isFullyCompleted;
    final currentStageIndex = stagesList.indexWhere((s) => s.stageId == currentStageId);

    // Status badge
    Color statusBg;
    Color statusClr;
    String statusLabel;
    if (isFullyCompleted) {
      statusBg = const Color(0xFFD1FAE5);
      statusClr = const Color(0xFF065F46);
      statusLabel = "Ready";
    } else if (c.jobStatus == "processing") {
      statusBg = const Color(0xFFFEF3C7);
      statusClr = const Color(0xFF92400E);
      statusLabel = "In Progress";
    } else if (c.jobStatus == "completed") {
      statusBg = const Color(0xFFDBEAFE);
      statusClr = const Color(0xFF1E40AF);
      statusLabel = "Completed";
    } else {
      statusBg = const Color(0xFFF3F4F6);
      statusClr = const Color(0xFF6B7280);
      statusLabel = "Not Started";
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderClr),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Name + status ─────────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextWidget(
                  text: c.componentName ?? "Component",
                  fontSize: FontSizes.mediuam,
                  fontWeight: FontWeights.bold,
                  clr: AppColors.black,
                  maxLine: 2,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(20)),
                child: TextWidget(
                  text: statusLabel,
                  fontSize: FontSizes.tiny,
                  fontWeight: FontWeights.bold,
                  clr: statusClr,
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),

          // ── Qty info ──────────────────────────────────────────────────
          TextWidget(
            text: "Qty: ${c.totalNeeded != null && c.totalNeeded! % 1 == 0 ? c.totalNeeded!.toInt() : c.totalNeeded ?? 0}  ·  ${c.qtyPerPc != null && c.qtyPerPc! % 1 == 0 ? c.qtyPerPc!.toInt() : c.qtyPerPc ?? 1}/unit",
            fontSize: FontSizes.small,
            fontWeight: FontWeights.medium,
            clr: AppColors.grey,
          ),

          // ── Stage stepper ─────────────────────────────────────────────
          if (totalStages > 0) ...[
            const SizedBox(height: 14),
            _buildStepper(stagesList, currentStageIndex, isFullyCompleted, totalStages),
          ],

          const SizedBox(height: 12),

          // ── Action banner ─────────────────────────────────────────────
          ApiBatchComponentActionBanner(
            component: c,
            isFullyCompleted: isFullyCompleted,
            onMoveTap: () => _openMovementDialog(context, c),
          ),
        ],
      ),
    );
  }

  Widget _buildStepper(
    List<PipelineStage> stages,
    int currentIdx,
    bool isFullyCompleted,
    int totalStages,
  ) {
    // ── Single stage: show as a simple inline row, no stepper needed ──
    if (stages.length == 1) {
      final stage = stages.first;
      final isActive = !isFullyCompleted;
      final Color bg = isFullyCompleted
          ? const Color(0xFFD1FAE5)
          : AppColors.lightBlue;
      final Color clr = isFullyCompleted
          ? const Color(0xFF065F46)
          : AppColors.themeColor;

      return Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
              child: Row(
                children: [
                  if (isFullyCompleted)
                    const Icon(Icons.check, size: 11, color: Color(0xFF065F46))
                  else
                    const SizedBox(),
                  if (isFullyCompleted) const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      (stage.stageName ?? "Stage").replaceFirst(RegExp(r'^\d+\.\s*'), ''),
                      style: TextStyle(
                        fontSize: 11,
                        fontFamily: "Outfit",
                        fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                        color: clr,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Dot-and-line row
        Row(
          children: List.generate(stages.length * 2 - 1, (i) {
            if (i.isOdd) {
              // Connector line between dots
              final leftStageIdx = i ~/ 2;
              final lineIsDone = isFullyCompleted ||
                  (currentIdx > 0 && leftStageIdx < currentIdx);
              return Expanded(
                child: Container(
                  height: 2,
                  color: lineIsDone ? AppColors.themeColor : AppColors.borderClr,
                ),
              );
            }

            final stageIdx = i ~/ 2;
            final stage = stages[stageIdx];
            final isCurrent = stageIdx == currentIdx && !isFullyCompleted;
            final isPast = isFullyCompleted ||
                (currentIdx > 0 && stageIdx < currentIdx);

            Color dotBg;
            Widget dotChild;
            if (isFullyCompleted || isPast) {
              dotBg = AppColors.themeColor;
              dotChild = const Icon(Icons.check, size: 10, color: Colors.white);
            } else if (isCurrent) {
              dotBg = AppColors.themeColor;
              dotChild = Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              );
            } else {
              dotBg = const Color(0xFF9CA3AF);
              dotChild = Text(
                "${stageIdx + 1}",
                style: const TextStyle(fontSize: 8, color: Colors.white, fontWeight: FontWeight.w700),
              );
            }

            return Tooltip(
              message: stage.stageName ?? "Stage ${stageIdx + 1}",
              child: Container(
                width: isCurrent ? 22 : 18,
                height: isCurrent ? 22 : 18,
                decoration: BoxDecoration(
                  color: dotBg,
                  shape: BoxShape.circle,
                  boxShadow: isCurrent
                      ? [BoxShadow(color: AppColors.themeColor.withValues(alpha: 0.35), blurRadius: 6, spreadRadius: 1)]
                      : null,
                ),
                alignment: Alignment.center,
                child: dotChild,
              ),
            );
          }),
        ),
        const SizedBox(height: 8),

        // Stage names row (truncated to fit)
        Row(
          children: List.generate(stages.length * 2 - 1, (i) {
            if (i.isOdd) return const Expanded(child: SizedBox());
            final stageIdx = i ~/ 2;
            final stage = stages[stageIdx];
            final isCurrent = stageIdx == currentIdx && !isFullyCompleted;
            final isPast = isFullyCompleted || (currentIdx > 0 && stageIdx < currentIdx);

            final nameColor = (isCurrent)
                ? AppColors.themeColor
                : (isPast || isFullyCompleted)
                    ? AppColors.grey
                    : const Color(0xFF6B7280);

            return Expanded(
              child: Text(
                stage.stageName ?? "Stage ${stageIdx + 1}",
                style: TextStyle(
                  fontSize: 9,
                  fontFamily: "Outfit",
                  fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w400,
                  color: nameColor,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            );
          }),
        ),
      ],
    );
  }
}
