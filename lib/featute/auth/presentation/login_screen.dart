import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:all_fold/core/component/app_logo.dart';
import 'package:all_fold/core/component/custom_button.dart';
import 'package:all_fold/core/component/sizebox_widget.dart';
import 'package:all_fold/core/component/text_field_widget.dart';
import 'package:all_fold/core/component/text_widget.dart';
import 'package:all_fold/core/theme/app_colors.dart';
import 'package:all_fold/core/utils/font_size.dart';
import 'package:all_fold/core/utils/font_weight.dart';
import 'package:all_fold/featute/auth/controller/auth_controller.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Find AuthController (registered in initialBinding)
    final controller = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                const AppLogo(height: 60,width: 300,),
                const TextWidget(
                  text: "Bulk Manufacturing Control",
                  fontSize: FontSizes.mediuam,
                  fontWeight: FontWeights.medium,
                  clr: AppColors.grey,
                ),
                const CustomSizeBox(height: 36, width: 0),

                // Login Credentials Card
                Container(
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(color: AppColors.borderClr, width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const TextWidget(
                        text: "Login to Terminal",
                        fontSize: FontSizes.large,
                        fontWeight: FontWeights.bold,
                        clr: AppColors.black,
                      ),
                      const CustomSizeBox(height: 20, width: 0),

                      // Email input
                      TextFieldWidget(
                        controller: controller.emailController,
                        labelTxt: "Email Address",
                        hintTxt: "e.g., operator2@allfold.com",
                        textinput: TextInputType.emailAddress,
                      ),
                      const CustomSizeBox(height: 16, width: 0),

                      // Password input
                      TextFieldWidget(
                        controller: controller.passwordController,
                        labelTxt: "Password",
                        hintTxt: "••••••••",
                        obscureTxt: true,
                        textInputAction: TextInputAction.done,
                      ),
                      const CustomSizeBox(height: 24, width: 0),

                      // Submit Button
                      SizedBox(
                        height: 48,
                        child: CustomButton(
                          text: "Login",
                          color: AppColors.orange,
                          fontWeight: FontWeights.bold,
                          fontSize: FontSizes.mediuam,
                          vertiCalPadding: 10,
                          callback: () {
                            FocusScope.of(context).unfocus();
                            controller.login();
                          },
                        ),
                      ),
                    ],
                  ),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}
