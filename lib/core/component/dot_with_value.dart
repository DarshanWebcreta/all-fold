
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:all_fold/core/component/icon_widget.dart';

import 'package:all_fold/core/component/text_widget.dart';
import 'package:all_fold/core/theme/app_colors.dart';
import 'package:all_fold/core/utils/font_size.dart';
import 'package:all_fold/core/utils/font_weight.dart';

class DotWithValues extends StatelessWidget {
  final String leftValue;
  final String rightValue;
  final Color rightValueClr;
  final Color leftValueClr;
  final FontWeight rightValueFontWeight;
  final FontWeight leftValueFontWeight;

  final double rightFontSize;
  final double leftFontSize;
  const DotWithValues({
    super.key,
    required this.leftValue,
    required this.rightValue,
     this.rightFontSize =FontSizes.small ,
     this.leftFontSize =FontSizes.small ,
     this.rightValueFontWeight =FontWeights.large ,
     this.leftValueFontWeight =FontWeights.large,
     this.leftValueClr = AppColors.black,
    this.rightValueClr = AppColors.black,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        TextWidget(text: leftValue,fontWeight:leftValueFontWeight,fontSize: leftFontSize,clr: leftValueClr,),
      if(rightValue.isNotEmpty)  const IconWidget(icon: Icons.circle,size: 5,clr: AppColors.grey,).paddingSymmetric(horizontal: 6),
        Expanded(child: TextWidget(text: rightValue,clr: rightValueClr,fontWeight: rightValueFontWeight,fontSize: rightFontSize,)),
      ],
    );
  }
}