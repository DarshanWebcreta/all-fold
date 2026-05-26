// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';




TextStyle textStyle({double size = 12,Color clr = Colors.white,FontWeight weight= FontWeight.w400,TextDecoration decor= TextDecoration.none}) {
  return TextStyle(
      color: clr,
      fontSize: size,
      decoration: decor,
      fontWeight: weight,
      fontFamily: 'Raleway'
  );
  //   GoogleFonts.outfit(
  //   color: clr,
  //   fontSize: size,
  //   decoration: decor,
  //   fontWeight: weight,
  // );
  //
}