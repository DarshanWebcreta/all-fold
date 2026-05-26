import 'package:flutter/material.dart';
import 'package:all_fold/core/component/card_widget.dart';
import 'package:all_fold/core/component/custom_button.dart';
import 'package:all_fold/core/component/text_widget.dart';
import 'package:all_fold/core/theme/app_colors.dart';
import 'package:all_fold/core/utils/font_size.dart';
import 'package:all_fold/core/utils/font_weight.dart';
class TitleWithButton extends StatelessWidget {
  final String title;
  final String btnTitle;
  final VoidCallback onPress;
  final Color bgClr;
  final Color btnBgClr;


  const TitleWithButton({
    super.key,
    required this.onPress,
    required this.btnTitle,
    required this.title,
    this.btnBgClr = AppColors.themeColor,
    this.bgClr =  AppColors.white,

  });

  @override
  Widget build(BuildContext context) {
    return CardWidget(bgClr:bgClr,borderClr:  AppColors.borderClr ,horiZontalPadding: 12, verticalPadding: 8, child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextWidget(text: title,fontSize: FontSizes.small,fontWeight: FontWeights.large,),
        CustomButton(text: btnTitle,color: btnBgClr, fontWeight: FontWeights.large,fontSize: FontSizes.small,radius: 4,callback:onPress,vertiCalPadding: 6,horiZontalPadding: 8,)
      ],
    ));
  }
}