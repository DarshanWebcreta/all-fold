import 'package:flutter/material.dart';

class CustomSizeBox extends StatelessWidget {
  final Widget? child;
  final double height;
  final double width;
  const CustomSizeBox({
    super.key,
    required  this.height,
    required this.width,
     this.child
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height==0?null:height,
      width: width==0?null:width,
      child:child,
    );
  }
}
