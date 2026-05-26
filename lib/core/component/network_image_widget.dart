// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:all_fold/core/component/image_widget.dart';
// import 'package:all_fold/core/key/image_keys.dart';
// import 'package:all_fold/core/theme/app_colors.dart';
//
// class NetworkImageWidget extends StatelessWidget {
//   final double radius;
//   final String path;
//
//   const NetworkImageWidget({super.key,required this.path,this.radius = 8});
//
//   @override
//   Widget build(BuildContext context) {
//     return  CachedNetworkImage(
//       imageUrl: path,
//       imageBuilder: (context, imageProvider) => Container(
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(radius),
//           image: DecorationImage(
//             image: imageProvider,
//             fit: BoxFit.fill,
//           ),
//         ),
//       ),
//       placeholder: (context, url) => Center(
//         child: SizedBox(
//           width: 20.0,
//           height: 20.0,
//           child: const CircularProgressIndicator(
//             color: AppColors.themeColor,
//             strokeWidth: 2,
//           ),
//         ),
//       ),
//       errorWidget: (context, url, error) => ClipRRect(borderRadius: BorderRadiusGeometry.circular(radius),child: Center(child: SizedBox(height: 50,width: 50,child:const ImageWidget(path:ImageStrings.appLogo)  ,))),
//
//     );
//   }
// }
