import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:all_fold/core/theme/app_colors.dart';
import 'package:all_fold/core/component/card_widget.dart';
import 'package:all_fold/core/component/text_widget.dart';
import 'package:all_fold/core/utils/font_size.dart';
import 'package:all_fold/core/utils/font_weight.dart';
import 'package:all_fold/core/utils/function_component.dart';
import 'package:all_fold/featute/bulk_execution/controller/bulk_execution_controller.dart';
import 'package:all_fold/featute/bulk_execution/model/unplanned_demand_model.dart';

class UnplannedDemandCard extends StatefulWidget {
  final UnplannedProduct product;
  const UnplannedDemandCard({super.key, required this.product});

  @override
  State<UnplannedDemandCard> createState() => _UnplannedDemandCardState();
}

class _UnplannedDemandCardState extends State<UnplannedDemandCard> {
  bool isExpanded = false;
  late TextEditingController qtyController;

  @override
  void initState() {
    super.initState();
    qtyController = TextEditingController(text: (widget.product.pendingQty ?? 0).toString());
  }

  @override
  void dispose() {
    qtyController.dispose();
    super.dispose();
  }

  void _incrementQty() {
    int val = int.tryParse(qtyController.text) ?? 0;
    setState(() {
      qtyController.text = (val + 10).toString();
    });
  }

  void _decrementQty() {
    int val = int.tryParse(qtyController.text) ?? 0;
    if (val > 0) {
      setState(() {
        qtyController.text = (val - 10 > 0 ? val - 10 : 0).toString();
      });
    }
  }

  void _showPlanDialog(BuildContext context) {
    final controller = Get.find<BulkExecutionController>();
    final int qty = int.tryParse(qtyController.text) ?? 0;
    if (qty <= 0) {
      FunctionalWidget.showSnackBar(title: "Please enter a valid batch quantity", success: false);
      return;
    }

    final batchNameController = TextEditingController();

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: AppColors.white,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: TextWidget(
                  text: "Plan New Batch",
                  fontSize: FontSizes.extraLarge,
                  fontWeight: FontWeights.bold,
                  clr: AppColors.black,
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: const TextStyle(
                      fontFamily: "Outfit",
                      fontSize: FontSizes.mediuam,
                      color: AppColors.grey,
                    ),
                    children: [
                      const TextSpan(text: "Create a persistent production batch for "),
                      TextSpan(
                        text: "$qty",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.black,
                        ),
                      ),
                      const TextSpan(text: " units."),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const TextWidget(
                text: "Batch Name",
                fontSize: FontSizes.small,
                fontWeight: FontWeights.bold,
                clr: AppColors.black,
              ),
              const SizedBox(height: 6),
              TextField(
                controller: batchNameController,
                decoration: InputDecoration(
                  hintText: "e.g. Morning Shift",
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
                      child: const Text(
                        "Cancel",
                        style: TextStyle(fontWeight: FontWeights.medium, fontSize: FontSizes.small),
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
                      onPressed: () {
                        final name = batchNameController.text.trim();
                        if (name.isEmpty) {
                          FunctionalWidget.showSnackBar(title: "Batch name is required", success: false);
                          return;
                        }
                        Get.back(); // close dialog
                        controller.planNewBatchFromUnplanned(
                          product: widget.product,
                          quantity: qty,
                          batchName: name,
                        );
                      },
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text(
                        "Create Batch",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: FontSizes.small),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;

    return CardWidget(
      verticalPadding: 16,
      horiZontalPadding: 16,
      bgClr: AppColors.white,
      borderClr: AppColors.borderClr,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [

              // Product details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextWidget(
                      text: p.productName ?? "Unknown Product",
                      fontSize: FontSizes.large,
                      fontWeight: FontWeights.bold,
                      clr: AppColors.black,
                    ),
                    TextWidget(
                      text: "SKU: ${p.sku}",
                      fontSize: FontSizes.small,
                      fontWeight: FontWeights.small,
                      clr: AppColors.grey,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Quantities Grid
          Row(
            spacing: 12,
            children: [
              Expanded(child: _buildMetricTile("Total Ordered", "${p.totalOrdered ?? 0}", null, null)),
              Expanded(child: _buildMetricTile("Total Reserved", "${p.totalReserved ?? 0}", null, null)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            spacing: 12,
            children: [
              Expanded(
                child: _buildMetricTile(
                  "Pending Demand",
                  "${p.pendingQty ?? 0}",
                  AppColors.lightRed,
                  AppColors.red,
                ),
              ),
              Expanded(
                child: _buildMetricTile(
                  "Supervisor Stock",
                  "${p.readyStock ?? 0}",
                  AppColors.lightGrey,
                  AppColors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Planning Row
          Row(
            children: [
              // Qty field with up/down arrows
              Expanded(
                flex: 3,
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.lightGrey,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.borderClr),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        padding: EdgeInsets.zero,
                        icon: const Icon(Icons.arrow_drop_down, color: AppColors.grey),
                        onPressed: _decrementQty,
                      ),
                      Expanded(
                        child: TextField(
                          controller: qtyController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: "Outfit",
                            fontWeight: FontWeight.bold,
                            fontSize: FontSizes.mediuam,
                            color: AppColors.black,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                      IconButton(
                        padding: EdgeInsets.zero,
                        icon: const Icon(Icons.arrow_drop_up, color: AppColors.grey),
                        onPressed: _incrementQty,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Plan button
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 40,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.blue,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                    onPressed: () => _showPlanDialog(context),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text(
                      "Plan",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: FontSizes.small),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Components details collapsible list
          if (isExpanded && p.components != null && p.components!.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Divider(color: AppColors.borderClr),
            const SizedBox(height: 8),
            const TextWidget(
              text: "Component Bill of Materials & Stock",
              fontSize: FontSizes.small,
              fontWeight: FontWeights.bold,
              clr: AppColors.orange,
            ),
            const SizedBox(height: 8),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: p.components!.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, idx) {
                final c = p.components![idx];
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.lightGrey,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.borderClr.withValues(alpha:0.5)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: TextWidget(
                              text: c.name ?? "Component",
                              fontSize: FontSizes.mediuam,
                              fontWeight: FontWeights.bold,
                              clr: AppColors.black,
                            ),
                          ),
                          TextWidget(
                            text: "Qty: ${c.qtyPerPc} per pc",
                            fontSize: FontSizes.small,
                            fontWeight: FontWeights.medium,
                            clr: AppColors.grey,
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextWidget(
                            text: "Total Needed: ${c.totalNeeded}",
                            fontSize: FontSizes.small,
                            fontWeight: FontWeights.medium,
                            clr: AppColors.black,
                          ),
                          TextWidget(
                            text: "Raw Stock: ${c.rawStockKg} kg (${c.rawName ?? 'Raw'})",
                            fontSize: FontSizes.small,
                            fontWeight: FontWeights.small,
                            clr: AppColors.grey,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Stage Stocks list
                      Row(
                        children: [
                          const TextWidget(
                            text: "Stage Stocks:  ",
                            fontSize: FontSizes.tiny,
                            fontWeight: FontWeights.medium,
                            clr: AppColors.grey,
                          ),
                          if (c.stageStock != null)
                            ...c.stageStock!.entries.map((entry) {
                              Color badgeBg = AppColors.lightGrey;
                              Color badgeText = AppColors.black;
                              if (entry.key == "1") {
                                badgeBg = AppColors.lightOrange;
                                badgeText = AppColors.orange;
                              } else if (entry.key == "2") {
                                badgeBg = AppColors.lightBlue;
                                badgeText = AppColors.blue;
                              } else if (entry.key == "3") {
                                badgeBg = entry.value > 0 ? AppColors.lightGreen : AppColors.lightRed;
                                badgeText = entry.value > 0 ? AppColors.green : AppColors.red;
                              }

                              return Container(
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: badgeBg,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: TextWidget(
                                  text: "Stage ${entry.key}: ${entry.value}",
                                  fontSize: FontSizes.tiny,
                                  fontWeight: FontWeights.bold,
                                  clr: badgeText,
                                ),
                              );
                            }),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildMetricTile(String title, String value, Color? bgClr, Color? textClr) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgClr ?? AppColors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: bgClr == null ? AppColors.borderClr : AppColors.transparent),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextWidget(
            text: title,
            fontSize: FontSizes.tiny,
            fontWeight: FontWeights.medium,
            clr: textClr ?? AppColors.grey,
          ),
          const SizedBox(height: 4),
          TextWidget(
            text: value,
            fontSize: FontSizes.mediuam,
            fontWeight: FontWeights.bold,
            clr: textClr ?? AppColors.black,
          ),
        ],
      ),
    );
  }
}
