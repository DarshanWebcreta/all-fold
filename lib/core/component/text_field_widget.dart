import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:all_fold/core/component/text_widget.dart';
import 'package:all_fold/core/theme/app_colors.dart';
import 'package:all_fold/core/utils/font_size.dart';
import 'package:all_fold/core/utils/font_weight.dart';
import 'package:all_fold/core/utils/text_styles.dart';


class TextFieldWidget extends StatelessWidget {
  const TextFieldWidget({super.key,this.verticalPad = 14,this.height = 50,this.enable =true,this.errorDisplay =false,this.filledClr= AppColors.lightGrey,  this.controller, this.textInputAction= TextInputAction.next, this.textinput= TextInputType.text,
    this.validator,  this.hintTxt = "Search here", this.fontSize = FontSizes.small, this.weight= FontWeight.w500, this.filled = false,
    this.obscureTxt= false, this.labelTxt = '', this.maxLine= 1, this.inputFormater,
    this.suffix, this.prefix,this.centerTitle =false, this.onChanged});

  final TextEditingController? controller; // Optional controller
  final    TextInputAction textInputAction ;
  final TextInputType textinput;
  final   String? Function(String?)? validator;
  final    String hintTxt;
  final   double fontSize ;
  final   double height  ;
  final   double verticalPad  ;
  final FontWeight weight ;
  final  bool filled;
  final  bool errorDisplay;
  final  Color filledClr ;
  final  bool obscureTxt ;
  final  bool centerTitle ;
  final  bool enable ;
  final String labelTxt ;
  final    int maxLine ;
  final  List<TextInputFormatter>? inputFormater;
  final    Widget? suffix;
  final Widget? prefix;
  final    Function(String)? onChanged;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if(labelTxt.isNotEmpty)  TextWidget(text: labelTxt,fontSize: FontSizes.small,fontWeight: FontWeights.large,).paddingOnly(bottom: 6),
        TextFormField(

          readOnly: !enable,
          obscureText: obscureTxt,
          inputFormatters: inputFormater ?? [],
          autovalidateMode: AutovalidateMode.onUserInteraction,
          controller: controller, // Controller can be null
          textInputAction: textInputAction,
          maxLines: maxLine,
          keyboardType: textinput,
          textAlign:centerTitle? TextAlign.center:TextAlign.left,
          validator: validator,
          onChanged: onChanged, // onChanged callback
          style: textStyle(clr: AppColors.grey,size:fontSize,weight: weight,),
          decoration: InputDecoration(

            errorStyle:  TextStyle(fontSize: !errorDisplay?12:0),
            focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: AppColors.black),borderRadius: BorderRadius.circular(8)),
            enabledBorder:OutlineInputBorder(borderSide: const BorderSide(color: AppColors.borderClr),borderRadius: BorderRadius.circular(8)) ,

            filled: filled,
            fillColor:filledClr ,
            contentPadding: EdgeInsets.symmetric(vertical: verticalPad, horizontal: 16),
            hintText: hintTxt,
            hintStyle:textStyle(clr: AppColors.grey,size: FontSizes.small,weight: FontWeights.medium,),
            suffixIcon: suffix?.paddingOnly(right: 16),
            prefixIcon: prefix,
            suffixIconConstraints: const BoxConstraints(),
            border: OutlineInputBorder(

              borderRadius: BorderRadius.circular(8),
              borderSide: !filled || !errorDisplay
                  ? BorderSide(color: AppColors.grey.withValues(alpha:0.5))
                  : BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }


}
