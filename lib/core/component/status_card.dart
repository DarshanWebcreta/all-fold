import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:all_fold/core/component/card_widget.dart';
import 'package:all_fold/core/component/text_widget.dart';
import 'package:all_fold/core/theme/app_colors.dart';
import 'package:all_fold/core/utils/font_size.dart';
import 'package:all_fold/core/utils/font_weight.dart';
import 'package:all_fold/core/utils/operation_file.dart';

class StatusCard extends StatelessWidget {
  final String status;
  final double radius;
  final double fontSize;
  final double horiZontalPadding ;
  final double verticalPadding;
  final Color? bgClr;
  final Color borderClr;
  final Color? fontClr;
  final FontWeight weight;
  const StatusCard({
    super.key,
    required this.status,
     this.bgClr ,
     this.fontClr ,
     this.radius = 4,
     this.fontSize =  FontSizes.mini,
     this.borderClr =  AppColors.transparent,
     this.weight = FontWeights.medium,
     this.horiZontalPadding = 6,
     this.verticalPadding = 4,
  });

  @override
  Widget build(BuildContext context) {
    final value = Operation.formatStringWithSpaces(status.capitalizeFirst!);
    return CardWidget(borderClr: borderClr,radius: radius,bgClr:bgClr??Operation.getStatusColor(value).background , horiZontalPadding: horiZontalPadding, verticalPadding:verticalPadding, child: TextWidget(text:value,fontWeight:weight,fontSize: fontSize,clr: fontClr??Operation.getStatusColor(value).text,));
  }
}
