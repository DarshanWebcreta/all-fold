

import 'package:flutter/material.dart';

class AppColors {
  AppColors._();
  static const Color bgColor = Color(0xFFF2F2F2);
  static const Color themeColor = Color(0xFF004aad);
  static const  Color borderClr = Color(0xFFDBDBDB);
  static const  Color orange = Color(0xFFe0620d);

  static   Color lightOrange = Colors.orange.withValues(alpha: 0.3);
  // static const Color darkBlue = Color(0xFF659FFF);
  static const Color black = Color(0xFF1E1E1E);
  static const Color grey = Color(0xFF797979);
  static const Color borderGrey = Color(0xFFdbe0de);
  static const Color lightGrey = Color(0xFFF9F9F9);
  static const Color lightBlue = Color(0xFFEEF1FF);
  static const Color blue = Colors.blue;


  static const Color lightBitBlue = Color(0xFFcce6ff);

  static const Color brinjalClr = Color(0xFF6C6FFF);
  static const Color inactiveClr = Color(0xFFa7b3bd);
  static const Color white = Colors.white;
  static const Color green = Colors.green;
  static const Color lightGreen = Color(0xFFd1ffc7);
  static  Color shimmerClr = Colors.grey[300]!;
  static const Color fulfillClr =  Color(0xFFd5ebff);
  static const Color unFulfillClr =  Color(0xFFaffebf);


  static const Color red = Color(0xFFc20404);
  static const Color lightRed = Color(0xFFffcccc);
  static const Color transparent = Colors.transparent;


  static const Color partialPickedBg = Color(0xFFE1D9FF);
  static const Color partialPickedText = Color(0xFF7126FF);

  static const Color openBg = Color(0xFFAFFEBF);
  static const Color openText = Color(0xFF014B40);

  static const Color pickedBg = Color(0xFFD5EBFF);
  static const Color pickedText = Color(0xFF003A5A);

  static const Color closedBg = Color(0xFFFFD5D5);
  static const Color closedText = Color(0xFF5A0000);


  static   LinearGradient gradiant() {
    return   LinearGradient(
      colors: [

        const  Color.fromRGBO(0, 62, 144, 1), // Medium Blue
        const  Color.fromRGBO(2, 0, 36, 1),   // Dark Blue
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
  }

}
