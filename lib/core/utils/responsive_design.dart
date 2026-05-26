import 'package:flutter/material.dart';

class ResponsiveDesign extends StatelessWidget {
  final Widget mobile;
  final Widget desktop;

  final Color bgcolor;
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 650;

  static bool isTablet(BuildContext context) =>

      MediaQuery.of(context).size.width >= 650;

  const ResponsiveDesign({required this.mobile,required this.desktop, this.bgcolor =Colors.white, super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if(constraints.maxWidth<600){
        return mobile;
      }
      else{
        return desktop;
      }
    },);
  }
}
