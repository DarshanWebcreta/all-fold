import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:all_fold/core/key/storage_keys.dart';
import 'package:all_fold/core/storage/app_storage.dart';
import 'package:all_fold/core/utils/function_component.dart';
import 'package:all_fold/core/di/service_locator.dart';
import 'package:all_fold/data/api_service.dart';
import 'package:all_fold/featute/auth/model/user_model.dart';
import 'package:all_fold/core/routes/route_name.dart';

class AuthController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  
  final isLoading = false.obs;

  // We expose a reactive user model
  final rxUser = Rxn<UserModel>();

  @override
  void onInit() {
    super.onInit();
    // Load persisted user if any
    final savedUserEmail = StorageManager.readData('user_email');
    if (savedUserEmail != null) {
      rxUser.value = UserModel(
        id: StorageManager.readData('user_id'),
        name: StorageManager.readData('user_name'),
        email: savedUserEmail,
        isAdmin: StorageManager.readData('is_admin') ?? false,
        warehouseId: StorageManager.readData('warehouse_id'),
        warehouseName: StorageManager.readData('warehouse_name'),
        roles: List<String>.from(StorageManager.readData(StoreKeys.roles) ?? []),
      );
      // Fetch latest profile from server in background
      fetchProfile();
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty) {
      FunctionalWidget.showSnackBar(title: "Email is required", success: false);
      return;
    }
    if (password.isEmpty) {
      FunctionalWidget.showSnackBar(title: "Password is required", success: false);
      return;
    }

    isLoading.value = true;
    FunctionalWidget.loaderHideShow(loaderShow: true);

    try {
      // Resolve ApiService from service locator
      final apiService = getIt<ApiService>();

      // Attempt actual API Call
      final response = await apiService.login({
        "email": email,
        "password": password,
      });

      if (response.success == true && response.data != null) {
        _handleSuccessLogin(response.data!.token!, response.data!.user!);
      } else {
        FunctionalWidget.showSnackBar(
          title: response.message ?? "Invalid email or password.",
          success: false,
        );
      }
    } catch (e) {
      // In case of error (network failure, server offline, etc.), check mock fallback
      _handleMockFallback(email, password, e);
    } finally {
      isLoading.value = false;
      FunctionalWidget.loaderHideShow(loaderShow: false);
    }
  }

  void _handleMockFallback(String email, String password, dynamic originalError) {
    // Define the mock database for offline demo
    final mockUsers = {
      "operator1@allfold.com": UserModel(
        id: 11,
        name: "John Raw Prep Operator",
        email: "operator1@allfold.com",
        isAdmin: false,
        warehouseId: 1,
        warehouseName: "Stage 1 Warehouse (Raw Prep)",
        roles: ["Warehouse Staff"],
      ),
      "operator2@allfold.com": UserModel(
        id: 12,
        name: "Jane Welding WIP Operator",
        email: "operator2@allfold.com",
        isAdmin: false,
        warehouseId: 2,
        warehouseName: "Stage 2 Warehouse (WIP)",
        roles: ["Warehouse Staff"],
      ),
      "operator3@allfold.com": UserModel(
        id: 13,
        name: "Bob Assembly Operator",
        email: "operator3@allfold.com",
        isAdmin: false,
        warehouseId: 3,
        warehouseName: "Stage 3 Warehouse (Assembly)",
        roles: ["Warehouse Staff"],
      ),
      "admin@allfold.com": UserModel(
        id: 10,
        name: "Super Admin User",
        email: "admin@allfold.com",
        isAdmin: true,
        warehouseId: 0,
        warehouseName: "Main HQ Office",
        roles: ["Administrator"],
      ),
    };

    if (mockUsers.containsKey(email) && password == "password123") {
      final user = mockUsers[email]!;
      final mockToken = "mock_token_for_${user.id}";
      _handleSuccessLogin(mockToken, user, isMock: true);
    } else {
      String msg = "Invalid email or password.";
      if (originalError is DioException) {
        final res = originalError.response;
        if (res != null && res.data != null && res.data['message'] != null) {
          msg = res.data['message'];
        }
      }
      FunctionalWidget.showSnackBar(title: msg, success: false);
    }
  }

  void _handleSuccessLogin(String token, UserModel user, {bool isMock = false}) {
    // Persist session details
    StorageManager.saveData(StoreKeys.token, token);
    StorageManager.saveData('user_id', user.id);
    StorageManager.saveData('user_name', user.name);
    StorageManager.saveData('user_email', user.email);
    StorageManager.saveData('is_admin', user.isAdmin);
    StorageManager.saveData('warehouse_id', user.warehouseId);
    StorageManager.saveData('warehouse_name', user.warehouseName);
    StorageManager.saveData(StoreKeys.roles, user.roles ?? []);

    rxUser.value = user;

    final modeMsg = isMock ? " (Simulated Mode)" : "";
    FunctionalWidget.showSnackBar(
      title: "Logged in successfully.$modeMsg",
      success: true,
    );

    // Go to Bulk dashboard
    Get.offAllNamed(RoutesNames.bulkDashboard);
  }

  Future<void> fetchProfile() async {
    try {
      final apiService = getIt<ApiService>();
      final response = await apiService.getProfile();
      if (response.success == true && response.data != null && response.data!.user != null) {
        final user = response.data!.user!;
        rxUser.value = user;
        
        // Persist updated details
        StorageManager.saveData('user_id', user.id);
        StorageManager.saveData('user_name', user.name);
        StorageManager.saveData('user_email', user.email);
        StorageManager.saveData('is_admin', user.isAdmin);
        StorageManager.saveData('warehouse_id', user.warehouseId);
        StorageManager.saveData('warehouse_name', user.warehouseName);
        StorageManager.saveData(StoreKeys.roles, user.roles ?? []);
      }
    } catch (e) {
      debugPrint("Failed to fetch profile: $e");
    }
  }

  Future<void> logout() async {
    FunctionalWidget.loaderHideShow(loaderShow: true);
    try {
      final apiService = getIt<ApiService>();
      await apiService.logout();
    } catch (e) {
      debugPrint("Failed to logout from server: $e");
    } finally {
      StorageManager.deleteAllData();
      rxUser.value = null;
      emailController.clear();
      passwordController.clear();
      FunctionalWidget.loaderHideShow(loaderShow: false);
      Get.offAllNamed(RoutesNames.login);
      FunctionalWidget.showSnackBar(title: "Logged out successfully.", success: true);
    }
  }
}
