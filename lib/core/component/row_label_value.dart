import 'package:flutter/material.dart';

import 'package:all_fold/core/component/text_widget.dart';
import 'package:all_fold/core/theme/app_colors.dart';

import 'package:all_fold/core/utils/font_size.dart';
import 'package:all_fold/core/utils/font_weight.dart';
class RowLabelValue extends StatelessWidget {
  const RowLabelValue({
    super.key,
    required this.label,
    required this.value,
    this.weight  = FontWeights.small,
    this.opposite  = false,
  });
  final String label;
  final String value;

  final FontWeight weight ;
  final bool  opposite ;

  @override
  Widget build(BuildContext context) {
    return Row(

      mainAxisSize: MainAxisSize.min,
      children: [
        TextWidget(text: "$label : ",fontSize: FontSizes.small,clr: opposite?AppColors.black:AppColors.grey,fontWeight: FontWeights.large,),
        TextWidget(maxLine: 4,text: value,fontSize: FontSizes.small,clr: opposite?AppColors.grey:AppColors.black,fontWeight: weight,),
      ],
    );
  }
}