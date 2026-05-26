import 'package:flutter/material.dart';

import 'package:all_fold/core/component/text_widget.dart';
import 'package:all_fold/core/theme/app_colors.dart';

import 'package:all_fold/core/utils/font_size.dart';
import 'package:all_fold/core/utils/font_weight.dart';
import 'package:all_fold/core/utils/function_component.dart';

class ExpansionWidget extends StatelessWidget {
  final String title;
  final List<Widget> childrens;
  final Widget? widget;
  final Widget? titleWidget;
  final ExpansibleController? controller; // <-- Add this

  const ExpansionWidget({
    super.key,
    required this.title,
    this.widget,
    this.titleWidget,
    required this.childrens,
    this.controller, // <-- Add to constructor
  });

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
        controller: controller, // <-- Use the controller here
        tilePadding: const EdgeInsets.symmetric(horizontal: 12),
        expansionAnimationStyle:
        const AnimationStyle(duration: Duration(milliseconds: 200)),
        minTileHeight: 45,
        collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: AppColors.borderClr, width: 1)),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: AppColors.borderClr, width: 1)),
        backgroundColor: AppColors.white,
        collapsedBackgroundColor: AppColors.white,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            widget ?? const SizedBox(),
            FunctionalWidget.customCircleAvtar(),
          ],
        ),
        title: titleWidget??TextWidget(
          text: title,
          fontWeight: FontWeights.large,
          fontSize: FontSizes.small,
        ),
        children: childrens);
  }
}