import 'package:flutter/material.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:all_fold/core/component/card_widget.dart';
import 'package:all_fold/core/component/icon_widget.dart';
import 'package:all_fold/core/component/svg_button.dart';
import 'package:all_fold/core/component/svg_widget.dart';
import 'package:all_fold/core/component/text_field_widget.dart';
import 'package:all_fold/core/key/image_keys.dart';
import 'package:all_fold/core/theme/app_colors.dart';
class SearchWithFilter extends StatelessWidget {
  final    Function(String)? onChanged;
  final VoidCallback onPress;
  final TextEditingController? controller;
  final bool filter;

  const SearchWithFilter({
    super.key,
    required this.onChanged,
     this.filter = true,
     this.controller,
    required this.onPress,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: TextFieldWidget(controller: controller,onChanged: onChanged,filled: true,prefix: const IconWidget(
          icon: Icons.search_rounded,
        ),filledClr: AppColors.white,)),
       if(filter) SvgButton(height: 24,onPress: onPress,svgPath: '',).paddingOnly(left: 8)
      ],
    ).paddingOnly(top: 6);
  }
}

