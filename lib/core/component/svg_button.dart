import 'package:flutter/material.dart';
import 'package:all_fold/core/component/card_widget.dart';
import 'package:all_fold/core/component/svg_widget.dart';
import 'package:all_fold/core/component/text_widget.dart';
import 'package:all_fold/core/theme/app_colors.dart';
class SvgButton extends StatelessWidget {


  final VoidCallback onPress;
  final double verPadding ;
  final double horPadding ;
  final double height ;
  final double width ;
  final String  svgPath ;
  final String?  text ;
  final Color  borderClr ;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: onPress,
        child:  CardWidget(borderClr: borderClr,horiZontalPadding:horPadding , verticalPadding: verPadding, child:

        text!=null?TextWidget(text: "-",fontSize: height,fontWeight: FontWeight.w400,): SvgWidget(width: width, height: height, path: svgPath)));
  }

  SvgButton(
      {required this.onPress,
        this.verPadding = 9 ,
        this.horPadding = 9,
        this.text,
        this.borderClr =  AppColors.transparent,
        this.height = 25,
        this.width = 25, required this.svgPath,
      });
}