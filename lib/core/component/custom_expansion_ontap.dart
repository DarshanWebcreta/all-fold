

import 'package:flutter/material.dart';

import 'package:all_fold/core/component/card_widget.dart';

import 'package:all_fold/core/component/text_widget.dart';
import 'package:all_fold/core/theme/app_colors.dart';
import 'package:all_fold/core/utils/font_size.dart';
import 'package:all_fold/core/utils/font_weight.dart';
import 'package:all_fold/core/utils/function_component.dart';

class CustomExpantionTileWithOnTap extends StatelessWidget {
  const CustomExpantionTileWithOnTap({
    super.key,
    required this.title,
    required this.onPress,
  });
  final VoidCallback onPress;
  final String title;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPress,
      child: CardWidget(bgClr: AppColors.bgColor, horiZontalPadding: 12, verticalPadding: 10, child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextWidget(text: title,fontWeight: FontWeights.large,fontSize: FontSizes.small,),
          FunctionalWidget.customCircleAvtar(bgClr: AppColors.white)
        ],
      )),
    );
  }
}