import 'package:flutter/material.dart';
import 'package:all_fold/core/theme/app_colors.dart';
import 'package:all_fold/core/utils/font_size.dart';
import 'package:all_fold/core/utils/text_styles.dart';



class TextWidget extends StatelessWidget {
  final TextAlign textAlign;
  final String text;
  final double fontSize;
  final int maxLine;
  final FontWeight fontWeight;
  final Color clr;
  final TextDecoration txtDecoration;

  const TextWidget(
      {super.key,
      this.textAlign = TextAlign.start,
      required this.text,
      this.fontSize = FontSizes.mediuam,
      this.maxLine = 1,
      this.clr = AppColors.black,
      this.fontWeight = FontWeight.w400,
      this.txtDecoration = TextDecoration.none});

  @override
  Widget build(BuildContext context) {
    return Text(
      textAlign: textAlign,
      text.toString(),
      maxLines: maxLine,
      softWrap: true,
      overflow: TextOverflow.ellipsis,
      style: textStyle(
          decor: txtDecoration, weight: fontWeight, clr: clr, size: fontSize),
    );
  }
}
