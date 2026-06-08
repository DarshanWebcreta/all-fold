import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:all_fold/core/routes/pages.dart';
import 'package:all_fold/core/routes/route_name.dart';
import 'package:all_fold/core/storage/app_storage.dart';
import 'package:all_fold/core/theme/app_colors.dart';
import 'package:all_fold/core/key/storage_keys.dart';

import 'package:all_fold/core/di/service_locator.dart';
import 'package:all_fold/featute/auth/controller/auth_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Setup dependency injection locator
  setupLocator();
  
  // Initialize local storage box for GetX session persistence
  await GetStorage.init();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Check if token exists to auto-authenticate user session
    final String? token = StorageManager.readData(StoreKeys.token);
    final String initialRoute = (token != null && token.isNotEmpty) 
        ? RoutesNames.bulkDashboard 
        : RoutesNames.login;

    return GlobalLoaderOverlay(
      overlayWidgetBuilder: (_) => const Center(
        child: SpinKitDoubleBounce(
          color: AppColors.orange,
          size: 50.0,
        ),
      ),
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'ALLFOLD Manufacturing',
        initialBinding: BindingsBuilder(() {
          Get.put(AuthController(), permanent: true);
        }),
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: AppColors.bgColor,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.orange,
            primary: AppColors.orange,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: AppColors.white,
            foregroundColor: AppColors.black,
            elevation: 0.5,
          ),
        ),
        initialRoute: initialRoute,
        getPages: AppPages.pages,
      ),
    );
  }
}
