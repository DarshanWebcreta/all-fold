import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:all_fold/core/theme/app_colors.dart';
import 'package:all_fold/core/component/card_widget.dart';
import 'package:all_fold/core/component/text_widget.dart';
import 'package:all_fold/core/utils/font_size.dart';
import 'package:all_fold/core/utils/font_weight.dart';
import 'package:all_fold/core/utils/function_component.dart';
import 'package:all_fold/featute/auth/controller/auth_controller.dart';
import 'package:all_fold/core/utils/operation_file.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Auto-fetch fresh profile data from GET /api/auth/me on screen mount
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<AuthController>().fetchProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: AppColors.black),
        title: const TextWidget(
          text: "User Profile",
          fontSize: FontSizes.large,
          fontWeight: FontWeights.bold,
          clr: AppColors.black,
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => authController.fetchProfile(),
        color: AppColors.orange,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20.0),
          child: Obx(() {
            final user = authController.rxUser.value;
            if (user == null) {
              return SizedBox(
                height: MediaQuery.of(context).size.height * 0.7,
                child: const Center(
                  child: TextWidget(
                    text: "No profile data available.",
                    clr: AppColors.grey,
                  ),
                ),
              );
            }

            final String initials = Operation.generateNickname(user.name ?? "U").toUpperCase();

            return Column(
              spacing: 20,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Profile Header Avatar Card
                CardWidget(
                  verticalPadding: 24,
                  horiZontalPadding: 20,
                  bgClr: AppColors.white,
                  borderClr: AppColors.borderClr,
                  child: Column(
                    children: [
                      // Avatar Circle with Orange/Blue Gradient border
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [AppColors.orange, AppColors.themeColor],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 46,
                          backgroundColor: AppColors.white,
                          child: CircleAvatar(
                            radius: 42,
                            backgroundColor: AppColors.themeColor,
                            child: TextWidget(
                              text: initials,
                              fontSize: 32,
                              fontWeight: FontWeights.bold,
                              clr: AppColors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextWidget(
                        text: user.name ?? "User",
                        fontSize: FontSizes.extraLarge,
                        fontWeight: FontWeights.bold,
                        clr: AppColors.black,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      TextWidget(
                        text: user.email ?? "",
                        fontSize: FontSizes.mediuam,
                        fontWeight: FontWeights.medium,
                        clr: AppColors.grey,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      // Status Role Badge (Admin or Staff)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: user.isAdmin == true
                              ? AppColors.lightOrange
                              : AppColors.lightBlue,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: TextWidget(
                          text: user.isAdmin == true ? "HQ Admin" : "Terminal Operator",
                          fontSize: FontSizes.small,
                          fontWeight: FontWeights.bold,
                          clr: user.isAdmin == true ? AppColors.orange : AppColors.themeColor,
                        ),
                      ),
                    ],
                  ),
                ),

                // 2. Terminal & Warehouse Details
                const TextWidget(
                  text: "Terminal assignment",
                  fontSize: FontSizes.mediuam,
                  fontWeight: FontWeights.bold,
                  clr: AppColors.grey,
                ),
                CardWidget(
                  verticalPadding: 16,
                  horiZontalPadding: 16,
                  bgClr: AppColors.white,
                  borderClr: AppColors.borderClr,
                  child: Column(
                    spacing: 12,
                    children: [
                      _buildDetailRow(
                        icon: Icons.warehouse_outlined,
                        title: "Active Warehouse",
                        value: user.warehouseName ?? "Not Assigned",
                        iconColor: AppColors.orange,
                      ),
                      const Divider(color: AppColors.borderClr),
                      _buildDetailRow(
                        icon: Icons.fingerprint_outlined,
                        title: "Warehouse ID",
                        value: user.warehouseId != null ? "#${user.warehouseId}" : "N/A",
                        iconColor: AppColors.themeColor,
                      ),
                      const Divider(color: AppColors.borderClr),
                      _buildDetailRow(
                        icon: Icons.admin_panel_settings_outlined,
                        title: "Access Permissions",
                        value: user.roles != null && user.roles!.isNotEmpty
                            ? user.roles!.join(", ")
                            : "Standard Staff Access",
                        iconColor: Colors.blue,
                      ),
                    ],
                  ),
                ),

                // 3. User Database ID
                CardWidget(
                  verticalPadding: 16,
                  horiZontalPadding: 16,
                  bgClr: AppColors.white,
                  borderClr: AppColors.borderClr,
                  child: _buildDetailRow(
                    icon: Icons.badge_outlined,
                    title: "Operator Account ID",
                    value: user.id != null ? "OP-${user.id}" : "N/A",
                    iconColor: Colors.purple,
                  ),
                ),

                const SizedBox(height: 20),

                // Logout Button
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.red,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {
                    // Open confirmation dialog
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
                                        Get.back(); // close confirm dialog
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
                  icon: const Icon(Icons.logout_outlined, size: 20),
                  label: const Text(
                    "Logout from Terminal",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: FontSizes.mediuam,
                    ),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String title,
    required String value,
    required Color iconColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextWidget(
                text: title,
                fontSize: FontSizes.tiny,
                fontWeight: FontWeights.medium,
                clr: AppColors.grey,
              ),
              const SizedBox(height: 2),
              TextWidget(
                text: value,
                fontSize: FontSizes.small,
                fontWeight: FontWeights.bold,
                clr: AppColors.black,
                maxLine: 2,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
