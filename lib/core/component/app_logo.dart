import 'package:flutter/material.dart';
import 'package:all_fold/core/component/image_widget.dart';
import 'package:all_fold/core/component/sizebox_widget.dart';
import 'package:all_fold/core/key/image_keys.dart';

class AppLogo extends StatelessWidget {
  final double? height;
  final double? width;
  const AppLogo({
    super.key,
    this.height ,
    this.width ,
  });

  @override
  Widget build(BuildContext context) {
    return  CustomSizeBox(width:width??126,height: height??126 ,child: ImageWidget(path: ImageStrings.appLogo,),);
  }
}