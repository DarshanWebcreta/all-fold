import 'package:get/get.dart';
import 'package:all_fold/core/routes/route_name.dart';
import 'package:all_fold/featute/auth/presentation/login_screen.dart';
import 'package:all_fold/featute/bulk_execution/presentation/bulk_execution_dashboard.dart';
import 'package:all_fold/featute/bulk_execution/presentation/create_batch_screen.dart';
import 'package:all_fold/featute/bulk_execution/presentation/batch_detail_screen.dart';
import 'package:all_fold/featute/auth/presentation/profile_screen.dart';
import 'package:all_fold/featute/sales_order/presentation/sales_order_list_screen.dart';
import 'package:all_fold/featute/sales_order/presentation/sales_order_detail_screen.dart';
import 'package:all_fold/featute/sales_order/presentation/dispatch_preview_screen.dart';

abstract class AppPages {
  static final pages = [
    GetPage(
      name: RoutesNames.login,
      page: () => const LoginScreen(),
    ),
    GetPage(
      name: RoutesNames.bulkDashboard,
      page: () => const BulkExecutionDashboard(),
    ),
    GetPage(
      name: RoutesNames.createBatch,
      page: () => const CreateBatchScreen(),
    ),
    GetPage(
      name: RoutesNames.batchDetail,
      page: () => const BatchDetailScreen(),
    ),
    GetPage(
      name: RoutesNames.profile,
      page: () => const ProfileScreen(),
    ),

    // Sales Orders
    GetPage(
      name: RoutesNames.salesOrderList,
      page: () => const SalesOrderListScreen(),
    ),
    GetPage(
      name: RoutesNames.salesOrderDetail,
      page: () => const SalesOrderDetailScreen(),
    ),
    GetPage(
      name: RoutesNames.dispatchPreview,
      page: () => const DispatchPreviewScreen(),
    ),
  ];
}
