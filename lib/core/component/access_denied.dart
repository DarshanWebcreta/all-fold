
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:all_fold/core/component/svg_widget.dart';
import 'package:all_fold/core/component/text_widget.dart';
import 'package:all_fold/core/constant/app_strings.dart';
import 'package:all_fold/core/key/image_keys.dart';
import 'package:all_fold/core/theme/app_colors.dart';
import 'package:all_fold/core/utils/font_size.dart';
import 'package:all_fold/core/utils/font_weight.dart';




class AccessDenied extends StatelessWidget {
  const AccessDenied({super.key});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: ListView(
        shrinkWrap: true,
        children: [
          const SvgWidget(width: 100, height: 100, path:'',),
          Center(child: const TextWidget(text:AppStrings.accessDenied,fontSize: FontSizes.mediuam,clr: AppColors.black,fontWeight: FontWeights.medium, ).paddingOnly(bottom: 8)),
          const Center(child: TextWidget(text:AppStrings.accessDeniedDescription,fontSize: FontSizes.small,clr: AppColors.black,fontWeight: FontWeights.small,textAlign: TextAlign.center,maxLine: 15, )),
        ],
      ).paddingSymmetric(horizontal: 60),
    ).paddingOnly(bottom: 100);
  }
}
