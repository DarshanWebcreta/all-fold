import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:all_fold/core/theme/app_colors.dart';
import 'package:all_fold/core/component/text_widget.dart';
import 'package:all_fold/core/utils/font_size.dart';
import 'package:all_fold/core/utils/font_weight.dart';
import 'package:all_fold/featute/bulk_execution/controller/bulk_execution_controller.dart';
import 'package:all_fold/featute/bulk_execution/presentation/widget/history_batch_card.dart';
import 'package:all_fold/core/component/error_box_widget.dart';

class HistoryTab extends StatefulWidget {
  const HistoryTab({super.key});

  @override
  State<HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends State<HistoryTab> {
  final searchQuery = "".obs;
  late TextEditingController searchController;

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
  }

  @override
  void dispose() {
    searchController.dispose();
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
            onChanged: (val) => searchQuery.value = val,
            style: const TextStyle(fontFamily: "Outfit", fontSize: FontSizes.small),
            decoration: InputDecoration(
              hintText: "Search history by name, number, SKU...",
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

        // History list
        Expanded(
          child: Obx(() {
            if (controller.isLoadingHistory.value && controller.historyBatches.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.orange),
                ),
              );
            }

            if (controller.historyError.value.isNotEmpty && controller.historyBatches.isEmpty) {
              return ErrorBoxWidget(
                errorMessage: "Please contact support if issues persist.",
                title: "Unable to Load History",
                onRefresh: () => controller.fetchHistoryBatches(isRefresh: true),
              );
            }

            final searchQueryVal = searchQuery.value.toLowerCase();
            final list = controller.historyBatches.where((b) {
              return (b.batchNo ?? "").toLowerCase().contains(searchQueryVal) ||
                     (b.batchName ?? "").toLowerCase().contains(searchQueryVal) ||
                     (b.productName ?? "").toLowerCase().contains(searchQueryVal) ||
                     (b.sku ?? "").toLowerCase().contains(searchQueryVal);
            }).toList();

            if (list.isEmpty) {
              return RefreshIndicator(
                onRefresh: () => controller.fetchHistoryBatches(isRefresh: true),
                color: AppColors.orange,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.25),
                    Center(
                      child: TextWidget(
                        text: searchQuery.value.isEmpty
                            ? "No production history found."
                            : "No history matches search query.",
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
              onRefresh: () => controller.fetchHistoryBatches(isRefresh: true),
              color: AppColors.orange,
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 80),
                itemCount: list.length + (controller.historyCurrentPage.value < controller.historyLastPage.value ? 1 : 0),
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  if (index < list.length) {
                    return HistoryBatchCard(batch: list[index]);
                  }
                  
                  // Load more trigger
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: controller.isLoadingHistory.value
                          ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppColors.orange))
                          : TextButton.icon(
                              onPressed: () {
                                controller.fetchHistoryBatches(page: controller.historyCurrentPage.value + 1);
                              },
                              icon: const Icon(Icons.add, color: AppColors.orange),
                              label: const TextWidget(
                                text: "Load More",
                                clr: AppColors.orange,
                                fontWeight: FontWeights.bold,
                              ),
                            ),
                    ),
                  );
                },
              ),
            );
          }),
        ),
      ],
    );
  }
}
