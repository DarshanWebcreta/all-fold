import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:all_fold/core/theme/app_colors.dart';
import 'package:all_fold/core/component/text_widget.dart';
import 'package:all_fold/core/utils/font_size.dart';
import 'package:all_fold/core/utils/font_weight.dart';
import 'package:all_fold/core/utils/function_component.dart';
import 'package:all_fold/featute/auth/controller/auth_controller.dart';
import 'package:all_fold/featute/bulk_execution/controller/bulk_execution_controller.dart';
import 'package:all_fold/featute/bulk_execution/presentation/widget/batches_tab.dart';
import 'package:all_fold/featute/bulk_execution/presentation/widget/history_tab.dart';
import 'package:all_fold/featute/sales_order/presentation/sales_order_list_screen.dart';
import 'package:all_fold/core/routes/route_name.dart';

class BulkExecutionDashboard extends StatelessWidget {
  const BulkExecutionDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    // Inject Controller
    Get.put(BulkExecutionController());
    final authController = Get.find<AuthController>();

    return Obx(() {
      final user = authController.rxUser.value;
      final bool canViewBatches = user?.canViewBatches ?? true;
      final bool canViewSalesOrders = user?.canViewSalesOrders ?? false;

      final List<Tab> tabs = [
        if (canViewBatches) const Tab(text: "Batched"),
        if (canViewSalesOrders) const Tab(text: "Sales Order"),
        if (canViewBatches) const Tab(text: "History"),
      ];

      final List<Widget> tabViews = [
        if (canViewBatches) const BatchesTab(isHistory: false),
        if (canViewSalesOrders) const SalesOrderListScreen(showAppBar: false),
        if (canViewBatches) const HistoryTab(),
      ];

      final tabKey = tabs.map((t) => t.text).join('_');

      return DefaultTabController(
        key: ValueKey('dashboard_tabs_$tabKey'),
        length: tabs.length,
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
              const TextWidget(text: "ALLFOLD", fontSize: FontSizes.large, fontWeight: FontWeights.bold, clr: AppColors.orange),
            ],
          ),
          actions: [
            if (user != null)
              Row(
                spacing: 8,
                children: [
                  GestureDetector(
                    onTap: () => Get.toNamed(RoutesNames.profile),
                    child: FunctionalWidget.nickName(name: user.name ?? "User", size: 16, font: FontSizes.small),
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout_outlined, color: AppColors.red),
                    tooltip: "Disconnect",
                    onPressed: () {
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
                                    text: "Confirm Logout",
                                    fontSize: FontSizes.extraLarge,
                                    fontWeight: FontWeights.bold,
                                    clr: AppColors.black,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                const Center(
                                  child: TextWidget(
                                    text: "Do you really want to logout?",
                                    fontSize: FontSizes.mediuam,
                                    clr: AppColors.grey,
                                    maxLine: 2,
                                    textAlign: TextAlign.center,
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
                                        child: const TextWidget(
                                          text: "Cancel",
                                          fontWeight: FontWeights.medium,
                                          fontSize: FontSizes.small,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.red,
                                          foregroundColor: AppColors.white,
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                          elevation: 0,
                                        ),
                                        onPressed: () {
                                          Get.back();
                                          authController.logout();
                                        },
                                        child: const TextWidget(
                                          text: "Logout",
                                          fontWeight: FontWeights.bold,
                                          fontSize: FontSizes.small,
                                          clr: AppColors.white,
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
                    },
                  ),
                  ],
                ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            spacing: 12,
            children: [
              TabBar(
                labelColor: AppColors.orange,
                unselectedLabelColor: AppColors.grey,
                indicatorColor: AppColors.orange,
                indicatorSize: TabBarIndicatorSize.tab,
                tabs: tabs,
              ),
              Expanded(
                child: TabBarView(
                  children: tabViews,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  });
  }
}
