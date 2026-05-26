import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:all_fold/core/theme/app_colors.dart';
import 'package:all_fold/core/component/custom_button.dart';
import 'package:all_fold/core/component/sizebox_widget.dart';
import 'package:all_fold/core/component/text_field_widget.dart';
import 'package:all_fold/core/component/text_widget.dart';
import 'package:all_fold/core/utils/font_size.dart';
import 'package:all_fold/core/utils/font_weight.dart';
import 'package:all_fold/featute/bulk_execution/controller/bulk_execution_controller.dart';
import 'package:all_fold/featute/bulk_execution/presentation/widget/sales_order_selector.dart';
import 'package:all_fold/featute/products/model/product_data.dart';

class CreateBatchScreen extends StatelessWidget {
  const CreateBatchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BulkExecutionController>();

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: AppColors.black),
        title: const TextWidget(
          text: "Plan Production Batch",
          fontSize: FontSizes.large,
          fontWeight: FontWeights.bold,
          clr: AppColors.black,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderClr),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const TextWidget(
                    text: "Product Selection",
                    fontSize: FontSizes.small,
                    fontWeight: FontWeights.large,
                  ).paddingOnly(bottom: 6),
                  Obx(() {
                    return DropdownButtonFormField<ProductData>(
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: AppColors.borderClr),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: AppColors.orange),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      value: controller.selectedProduct.value,
                      hint: const TextWidget(text: "Select a Product", clr: AppColors.grey),
                      dropdownColor: AppColors.white,
                      onChanged: (val) {
                        controller.selectedProduct.value = val;
                      },
                      items: controller.seedProducts.map((p) {
                        return DropdownMenuItem<ProductData>(
                          value: p,
                          child: TextWidget(text: "${p.title} (SKU: ${p.sku})"),
                        );
                      }).toList(),
                    );
                  }),
                  const CustomSizeBox(height: 16, width: 0),
                  TextFieldWidget(
                    controller: controller.targetQuantityController,
                    labelTxt: "Target Build Quantity",
                    hintTxt: "Auto-calculated from selected orders",
                    textinput: TextInputType.number,
                  ),
                ],
              ),
            ),
            const CustomSizeBox(height: 16, width: 0),
            const SalesOrderSelector(),
            const CustomSizeBox(height: 24, width: 0),
            SizedBox(
              height: 48,
              child: CustomButton(
                text: "PLAN PRODUCTION BATCH",
                color: AppColors.orange,
                fontWeight: FontWeights.bold,
                callback: () {
                  controller.createProductionBatch();
                },
              ),
            ),
            const CustomSizeBox(height: 40, width: 0),
          ],
        ),
      ),
    );
  }
}
