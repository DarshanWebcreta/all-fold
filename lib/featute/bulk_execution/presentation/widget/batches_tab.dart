import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:all_fold/core/theme/app_colors.dart';
import 'package:all_fold/core/component/text_widget.dart';
import 'package:all_fold/core/utils/font_size.dart';
import 'package:all_fold/core/utils/font_weight.dart';
import 'package:all_fold/featute/bulk_execution/controller/bulk_execution_controller.dart';
import 'package:all_fold/featute/bulk_execution/presentation/widget/api_batch_card.dart';
import 'package:all_fold/core/component/error_box_widget.dart';

class BatchesTab extends StatefulWidget {
  final bool isHistory;
  const BatchesTab({super.key, this.isHistory = false});

  @override
  State<BatchesTab> createState() => _BatchesTabState();
}

class _BatchesTabState extends State<BatchesTab> {
  final ScrollController _scrollController = ScrollController();
  final searchQuery = "".obs;
  late TextEditingController searchController;
  late Worker _scrollWorker;
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();

    final controller = Get.find<BulkExecutionController>();

    // Listen to changes in isLoadingBatches to perform auto-scroll
    _scrollWorker = ever(controller.isLoadingBatches, (isLoading) {
      if (isLoading) {
        _searchFocusNode.unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      }
      if (!isLoading && controller.lastOperatedBatchId.value != null) {
        final targetId = controller.lastOperatedBatchId.value!;

        // Wait for list items to render in layout
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final queryVal = searchQuery.value.toLowerCase();
          final batchesList = controller.activeApiBatches.where((b) {
            final matchesQuery = (b.batchNo ?? "").toLowerCase().contains(queryVal) ||
                   (b.batchName ?? "").toLowerCase().contains(queryVal) ||
                   (b.productName ?? "").toLowerCase().contains(queryVal) ||
                   (b.sku ?? "").toLowerCase().contains(queryVal);
            final matchesStatus = widget.isHistory 
                ? (b.status == "completed") 
                : (b.status != "completed");
            return matchesQuery && matchesStatus;
          }).toList();

          final index = batchesList.indexWhere((b) => b.batchId == targetId);
          if (index != -1 && _scrollController.hasClients) {
            // Ensure the target batch is expanded so its components are rendered
            if (!controller.expandedBatchIds.contains(targetId)) {
              controller.expandedBatchIds.add(targetId);
            }

            double offset = 0.0;
            for (int i = 0; i < index; i++) {
              final b = batchesList[i];
              final isExpanded = controller.expandedBatchIds.contains(b.batchId);
              if (isExpanded) {
                final isCompleted = b.status == "completed";
                final hasButton = !isCompleted;
                final baseHeight = hasButton ? 284.0 : 184.0;
                final compCount = b.components?.length ?? 0;
                double cardHeight = baseHeight + (compCount * 272.0);
                if (compCount > 0) {
                  cardHeight -= 12.0; // Subtract last component's separator
                }
                offset += cardHeight + 12.0; // 12.0 is separator height
              } else {
                // Collapsed card height
                offset += 96.0 + 12.0;
              }
            }

            double componentOffset = 0.0;
            if (controller.lastOperatedComponentId.value != null) {
              final targetCompId = controller.lastOperatedComponentId.value!;
              final targetBatch = batchesList[index];
              final comps = targetBatch.components ?? [];
              int compIndex = comps.indexWhere((c) => c.componentId == targetCompId);
              if (compIndex != -1) {
                final comp = comps[compIndex];
                // Check if this component is now fully completed
                final stagesList = comp.pipelineStages ?? [];
                final lastStageId = stagesList.isNotEmpty
                    ? stagesList.map((s) => s.stageId ?? 0).reduce((max, val) => val > max ? val : max)
                    : 0;
                final isJobCompleted = comp.jobStatus == "completed";
                final isFullyCompleted = isJobCompleted && (comp.currentStageId ?? 0) == lastStageId;

                // If fully completed and there is a next component, target the next component
                if (isFullyCompleted && compIndex + 1 < comps.length) {
                  compIndex = compIndex + 1;
                }

                // Scroll to the targeted component inside the expanded batch card.
                // 184.0 is the estimated header height before the components list.
                // Each component card is 260.0 + 12.0 separator = 272.0.
                componentOffset = 184.0 + (compIndex * 272.0);
              }
            }

            final finalOffset = offset + componentOffset;

            Future.delayed(const Duration(milliseconds: 100), () {
              if (_scrollController.hasClients) {
                _scrollController.animateTo(
                  finalOffset,
                  duration: const Duration(milliseconds: 450),
                  curve: Curves.easeOut,
                );
              }
            });
          }
          // Reset the last operated batch and component IDs so they don't trigger scroll again
          controller.lastOperatedBatchId.value = null;
          controller.lastOperatedComponentId.value = null;
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    searchController.dispose();
    _scrollWorker.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BulkExecutionController>();

    return Column(
      children: [
        // Real-time Search Input Field
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: TextField(
            controller: searchController,
            focusNode: _searchFocusNode,
            onChanged: (val) => searchQuery.value = val,
            style: const TextStyle(fontFamily: "Outfit", fontSize: FontSizes.small),
            decoration: InputDecoration(
              hintText: "Search by batch name, batch number, SKU...",
              hintStyle: const TextStyle(color: AppColors.grey, fontSize: FontSizes.small),
              prefixIcon: const Icon(Icons.search, color: AppColors.orange, size: 20),
              suffixIcon: Obx(() {
                if (searchQuery.value.isEmpty) return const SizedBox();
                return IconButton(
                  icon: const Icon(Icons.clear, color: AppColors.grey, size: 18),
                  onPressed: () {
                    searchController.clear();
                    searchQuery.value = "";
                  },
                );
              }),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              filled: true,
              fillColor: AppColors.white,
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: AppColors.borderClr),
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: AppColors.orange, width: 1.5),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
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
              return ErrorBoxWidget(
                errorMessage: "Please contact administrative support if the issue persists.",
                title: "Unable to Load Batches",
                onRefresh: () => controller.fetchActiveBatches(),
              );
            }

            final searchQueryVal = searchQuery.value.toLowerCase();
            final batchesList = controller.activeApiBatches.where((b) {
              final matchesQuery = (b.batchNo ?? "").toLowerCase().contains(searchQueryVal) ||
                     (b.batchName ?? "").toLowerCase().contains(searchQueryVal) ||
                     (b.productName ?? "").toLowerCase().contains(searchQueryVal) ||
                     (b.sku ?? "").toLowerCase().contains(searchQueryVal);
              final matchesStatus = widget.isHistory 
                  ? (b.status == "completed") 
                  : (b.status != "completed");
              return matchesQuery && matchesStatus;
            }).toList();

            if (batchesList.isEmpty) {
              return RefreshIndicator(
                onRefresh: () => controller.fetchActiveBatches(),
                color: AppColors.orange,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.25),
                    Center(
                      child: TextWidget(
                        text: searchQuery.value.isEmpty 
                            ? (widget.isHistory 
                                ? "No completed batches found." 
                                : "No active production batches found.")
                            : "No batches match search query.",
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
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 80),
                itemCount: batchesList.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return ApiBatchCard(batch: batchesList[index]);
                },
              ),
            );
          }),
        ),
      ],
    );
  }
}
