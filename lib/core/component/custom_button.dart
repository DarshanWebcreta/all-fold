import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_common/get_reset.dart';
import 'package:all_fold/core/component/text_widget.dart';
import 'package:all_fold/core/theme/app_colors.dart';
import 'package:all_fold/core/utils/font_size.dart';
import 'package:all_fold/core/utils/font_weight.dart';

class CustomButton extends StatelessWidget {
  final double elevation ;
  final double radius;
  final double vertiCalPadding;
  final double horiZontalPadding;
  final Color color;
  final Color borderClr;
  final Color splashColor;
  final Color fontClr;
  final FontWeight fontWeight;
  final double fontSize;
  final String text;
  final VoidCallback callback;
  const CustomButton( {super.key,
    this.horiZontalPadding= 0,this.vertiCalPadding= 0,
    this.fontWeight = FontWeights.medium,required this.text, this.fontSize = FontSizes.mediuam,this.fontClr =AppColors.white,
    this.radius = 8,this.color = AppColors.themeColor,required this.callback,
    this.elevation = 4,this.splashColor = AppColors.lightGrey,this.borderClr = AppColors.transparent ,});

  @override
  Widget build(BuildContext context) {
    return Material(

      elevation: 0,
      shape: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide(color: borderClr,width: 1)),
      color: color,
      child: InkWell(
          borderRadius: BorderRadius.circular(radius),
          splashColor: splashColor,
          onTap: callback,
          child:  Center(
              child: TextWidget(
                text: text,
                fontSize: fontSize,
                clr:fontClr,
                fontWeight: fontWeight,
              ).paddingSymmetric(horizontal: horiZontalPadding,vertical:vertiCalPadding ))),
    );
  }
}