import 'package:flutter/material.dart';


class ImageWidget extends StatelessWidget {
  final String path;
  final BoxFit fit;
  const ImageWidget({
    super.key,
     this.fit = BoxFit.contain,
    required this.path
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      path,
      fit: fit,
    );
  }
}