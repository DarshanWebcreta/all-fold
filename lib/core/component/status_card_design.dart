
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:all_fold/core/component/status_card.dart';
import 'package:all_fold/core/theme/app_colors.dart';
import 'package:all_fold/core/utils/font_size.dart';
import 'package:all_fold/core/utils/font_weight.dart';

class StatusCardDesign extends StatelessWidget {


  final String status;
  final String selected;

  @override
  Widget build(BuildContext context) {
    return StatusCard(weight: FontWeights.small,fontSize: FontSizes.small,status: status.capitalizeFirst!,bgClr: selected==status?AppColors.themeColor:AppColors.white,fontClr: selected==status?AppColors.white:AppColors.themeColor,radius: 70,horiZontalPadding: 14,verticalPadding: 4,);
  }

  StatusCardDesign({required this.selected, required this.status});
}
