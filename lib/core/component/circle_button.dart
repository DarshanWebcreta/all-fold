import 'package:flutter/material.dart';
import 'package:all_fold/core/component/svg_widget.dart';

class CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color iconColor;
  final double size;
  final double iconSize;
  final String svgPath;
  const CircleIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.backgroundColor = Colors.blue,
    this.iconColor = Colors.white,
    this.size = 50.0,
    this.svgPath = '',
    this.iconSize = 20.0,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: backgroundColor,
      child: IconButton(
        iconSize:iconSize ,
        icon:svgPath.isNotEmpty?SvgWidget(width: iconSize+2, height: iconSize, path: svgPath): Icon(icon),
        color: iconColor,
        onPressed: onPressed,
      ),
    );
  }
}
