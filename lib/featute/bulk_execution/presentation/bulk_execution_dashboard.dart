import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:all_fold/core/theme/app_colors.dart';
import 'package:all_fold/core/component/text_widget.dart';
import 'package:all_fold/core/utils/font_size.dart';
import 'package:all_fold/core/utils/font_weight.dart';
import 'package:all_fold/core/utils/function_component.dart';
import 'package:all_fold/featute/auth/controller/auth_controller.dart';
import 'package:all_fold/featute/bulk_execution/controller/bulk_execution_controller.dart';
import 'package:all_fold/featute/bulk_execution/presentation/widget/unplanned_demand_tab.dart';
import 'package:all_fold/featute/bulk_execution/presentation/widget/batches_tab.dart';
import 'package:all_fold/core/routes/route_name.dart';

class BulkExecutionDashboard extends StatelessWidget {
  const BulkExecutionDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    // Inject Controller
    final controller = Get.put(BulkExecutionController());
    final authController = Get.find<AuthController>();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.bgColor,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0.5,
          title: Row(
            spacing: 8,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(color: AppColors.orange, shape: BoxShape.circle),
                child: const Icon(Icons.token, color: AppColors.white, size: 18),
              ),
              const TextWidget(text: "ALLFOLD Console", fontSize: FontSizes.large, fontWeight: FontWeights.bold, clr: AppColors.orange),
            ],
          ),
          actions: [
            Obx(() {
              final user = authController.rxUser.value;
              if (user == null) return const SizedBox();
              return Row(
                spacing: 8,
                children: [
                  FunctionalWidget.nickName(name: user.name ?? "User", size: 16, font: FontSizes.small),
                  IconButton(
                    icon: const Icon(Icons.logout_outlined, color: AppColors.red),
                    tooltip: "Disconnect Terminal",
                    onPressed: () => authController.logout(),
                  ),
                ],
              );
            }),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            spacing: 12,
            children: [
              const TabBar(
                labelColor: AppColors.orange,
                unselectedLabelColor: AppColors.grey,
                indicatorColor: AppColors.orange,
                indicatorSize: TabBarIndicatorSize.tab,
                tabs: [
                  Tab(text: "Unplanned Demand"),
                  Tab(text: "Batches"),
                ],
              ),
              const Expanded(
                child: TabBarView(
                  children: [
                    UnplannedDemandTab(),
                    BatchesTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: AppColors.orange,
          tooltip: "Plan Production Batch",
          onPressed: () {
            controller.resetForm();
            Get.toNamed(RoutesNames.createBatch);
          },
          child: const Icon(Icons.add, color: AppColors.white),
        ),
      ),
    );
  }
}
