import 'package:flutter/material.dart';

import 'package:all_fold/core/common/shimmer_effect.dart';
import 'package:all_fold/core/utils/responsive_design.dart';

class CustomListShimmer extends StatelessWidget {
  const CustomListShimmer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(padding: EdgeInsets.symmetric(vertical: 0,horizontal:ResponsiveDesign.isMobile(context)?0:8 ),gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        mainAxisExtent: 110,
        crossAxisCount: ResponsiveDesign.isMobile(context)?1:2,
        mainAxisSpacing: 4,crossAxisSpacing:ResponsiveDesign.isMobile(context)?4:0 ),itemCount: 30,shrinkWrap: true, itemBuilder: (context, index) {
      return const ShimmerCard();
    },);
  }
}