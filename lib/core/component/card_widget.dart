import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:all_fold/core/theme/app_colors.dart';

class CardWidget extends StatelessWidget {
  final double verticalPadding;
  final double horiZontalPadding;
  final double radius;
  final Color bgClr;
  final Color borderClr;
  final Widget child;
  const CardWidget({
    super.key,
    this.radius = 8,
    required this.child ,
     this.bgClr =  AppColors.white,
     this.borderClr =  AppColors.borderClr,
    required this.horiZontalPadding ,
    required this.verticalPadding
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: bgClr,
      shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius),side: BorderSide(color: borderClr,width: 1)) ,
      margin: EdgeInsets.zero,
      child:child.paddingSymmetric(horizontal: horiZontalPadding,vertical: verticalPadding),
    );
  }
}