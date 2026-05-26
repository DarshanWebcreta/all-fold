import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:all_fold/core/component/svg_widget.dart';
import 'package:all_fold/core/component/text_widget.dart';
import 'package:all_fold/core/theme/app_colors.dart';
import 'package:all_fold/core/utils/font_size.dart';
import 'package:all_fold/core/utils/font_weight.dart';




class EmptyWidget extends StatelessWidget {
  const EmptyWidget({super.key,this.callbackAction,required this.title, this.description,this.error = false });
  final String title;
  final String ?description;

  final bool error;
  final VoidCallback ? callbackAction;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: ListView(
        shrinkWrap: true,
        children: [
          SvgWidget(width: 120, height: 120, path:'',),
          Center(child: TextWidget(text:"No $title found!",fontSize: FontSizes.mediuam,clr: AppColors.black,fontWeight: FontWeights.medium, ).paddingOnly(bottom: 8)),
          Center(child: TextWidget(text:error?"${description??"Something went wrong"}":'No $title available at the moment , Please try after sometime.',fontSize: FontSizes.small,clr: AppColors.black,fontWeight: FontWeights.small,textAlign: TextAlign.center,maxLine: 15, )),

          if(error) GestureDetector(
            onTap: callbackAction,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.refresh,color:AppColors.themeColor,size: 26 ,),
                const TextWidget(text: " Retry",fontSize: FontSizes.mediuam,clr: AppColors.themeColor,fontWeight: FontWeights.medium,)
              ],
            ).paddingOnly(top: 14),
          )
        ],
      ).paddingSymmetric(horizontal: 16),
    ).paddingOnly(bottom: 100);
  }
}
