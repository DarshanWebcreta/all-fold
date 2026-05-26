
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:loader_overlay/loader_overlay.dart';



import 'package:all_fold/core/component/card_widget.dart';
import 'package:all_fold/core/component/custom_button.dart';
import 'package:all_fold/core/component/icon_widget.dart';

import 'package:all_fold/core/component/text_widget.dart';
import 'package:all_fold/core/constant/app_strings.dart';
import 'package:all_fold/core/routes/route_name.dart';
import 'package:all_fold/core/storage/app_storage.dart';
import 'package:all_fold/core/theme/app_colors.dart';

import 'package:all_fold/core/utils/font_size.dart';
import 'package:all_fold/core/utils/font_weight.dart';
import 'package:all_fold/core/utils/operation_file.dart';



import 'dart:async';





class FunctionalWidget{


  FunctionalWidget._();
 static void loaderHideShow({required bool loaderShow}) {
    loaderShow?Get.context!.loaderOverlay.show():Get.context!.loaderOverlay.hide();
  }
 static Widget qtyDesign({ String? old, String? neW ,bool isQty =  true}) {
    return Row(
      spacing: 4,
      children: [
        productHistoryTxt(text: "${isQty?"Qty":"Price"} :"),
        if(old!=null&&old!='0')  productHistoryTxt(text: old,underLine: true),
        const IconWidget(icon: Icons.arrow_forward,clr: AppColors.grey,size: 12,),
        productHistoryTxt(text: neW.toString(),),
      ],
    );
  }

  static Widget productHistoryTxt({bool underLine = false,required String text}) => TextWidget(text:text ,fontSize: FontSizes.mini,fontWeight: FontWeights.medium,txtDecoration:underLine? TextDecoration.lineThrough:TextDecoration.none,);

  static Widget assignPickList() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const TextWidget(text: AppStrings.assignPickList,fontWeight: FontWeights.large,fontSize: FontSizes.mediuam,),
        Icon(Icons.arrow_forward_ios_rounded,color: AppColors.grey,size: 20,)
      ],
    ).paddingOnly(top: 24,bottom: 16);
  }
  static Future<dynamic> askUserDialog(
      { VoidCallback? cancel,
        required VoidCallback yes,
        required String title,
        bool subDec = false,
        required String des,
        String sDec = ''}) {
    return showDialog(

      context: Get.context!,
      builder: (context) {
        return AlertDialog(
          backgroundColor:AppColors.bgColor,
          // insetPadding: EdgeInsets.all(16),
          // contentPadding: EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.question_mark,
                  size: 60,
                  color: AppColors.themeColor,
                  weight: 5,
                ),
                const SizedBox(
                  height: 30,
                ),
                TextWidget(text: title,fontSize: FontSizes.mediuam,fontWeight: FontWeights.medium,maxLine: 4,textAlign: TextAlign.center,),
                TextWidget(text: des,fontSize: FontSizes.small,fontWeight: FontWeights.small,maxLine: 4,textAlign: TextAlign.center,clr: AppColors.grey,).paddingOnly(bottom: 38,top: 8, right: 10, left: 10),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 38,
                      width: 114,
                      child:CustomButton(text: "Cancel", callback: cancel??()=>{Get.back()},color: AppColors.bgColor,fontClr: AppColors.themeColor,borderClr: AppColors.themeColor,),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    SizedBox(
                      height: 38,
                      width: 114,
                      child:CustomButton(text: "Yes", callback: yes,color: AppColors.themeColor,fontClr: AppColors.white,),
                    ),

                  ],
                )
              ],
            ),
          ),
        );
      },
    );

  }
  static Widget  cancelProductLabel() {
    return Padding(
      padding:  const EdgeInsets.only(bottom: 4,top: 10),
      child: CardWidget(bgClr: AppColors.lightRed, horiZontalPadding: 10, verticalPadding: 10, child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: const [
          IconWidget(icon: Icons.notifications_none_sharp,clr: AppColors.red,size: 20,),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2,
              children: [
                TextWidget(text:'Order Cancellation Notice',fontSize: FontSizes.mediuam,clr: AppColors.red,fontWeight: FontWeights.medium),
                TextWidget(text:'The order has been cancelled. Product return to warehouse is required.',maxLine: 4,fontSize: FontSizes.small,fontWeight: FontWeights.small,clr: AppColors.red,),
              ],
            ),
          ),
        ],
      )),
    );
  }

 static String convertToTitleCase(String text) {
    return text.split('_') // Split the text by underscores
        .map((word) => word[0].toUpperCase() + word.substring(1)) // Capitalize each word
        .join(' '); // Combine them back with spaces
  }
  static Widget customCircleAvtar({double radius = 15,Color bgClr = AppColors.bgColor,double iconSize = 20,Color iconClr = AppColors.grey }) {
    return CircleAvatar(
      radius: radius,backgroundColor: bgClr,child:  IconWidget(icon: Icons.keyboard_arrow_down,size: iconSize,clr: iconClr,),
    );
  }
  static void unfocusKeyboard() => FocusManager.instance.primaryFocus?.unfocus();
static void logout(){
   StorageManager.deleteAllData();
   Get.offAllNamed(RoutesNames.login);
   FunctionalWidget.showSnackBar(title: 'Logout SuccessFully', success: false);
 }


    static void showSnackBar({required String title,required bool success, bool fullScreen =  false,}) {
   if(fullScreen){
     Operation.gotoSuccessPage(status: success, message: title);

   }
   else {
     Fluttertoast.cancel();
     Fluttertoast.showToast(
         msg: title,
         toastLength: Toast.LENGTH_SHORT,
         gravity: ToastGravity.TOP,

         timeInSecForIosWeb: 2,
         backgroundColor: success ? AppColors.green : AppColors.red,
         textColor: Colors.white,
         fontSize: 16.0
     );
   }
  }
 static String timeAgo(String dateString) {
    DateTime apiTime = DateTime.parse(dateString).toLocal();
    DateTime now = DateTime.now();

    Duration diff = now.difference(apiTime);

    if (diff.inSeconds < 60) {
      return "${diff.inSeconds} sec ago";
    } else if (diff.inMinutes < 60) {
      return "${diff.inMinutes} min ago";
    } else if (diff.inHours < 24) {
      return "${diff.inHours} hr ago";
    } else if (diff.inDays < 7) {
      return "${diff.inDays} day ago";
    } else if (diff.inDays < 30) {
      return "${(diff.inDays / 7).floor()} week ago";
    } else if (diff.inDays < 365) {
      return "${(diff.inDays / 30).floor()} month ago";
    } else {
      return "${(diff.inDays / 365).floor()} year ago";
    }
  }

  static  Future<dynamic> bottomSheet({required double height,
    Widget? header,
    required Widget child,Color? barrierClr,bool isDismissible =  true,
    double rightPadding = 16,double leftPadding =  16,double bottomPadding = 16,
    bool canPop =  true,required String title,String descriptrion = ''}) {
    return showModalBottomSheet(
      backgroundColor: AppColors.white,
      isDismissible: isDismissible,
      enableDrag: canPop,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20))),
      barrierColor:barrierClr,
      context: Get.context!,
      isScrollControlled: true,
      builder: (context) => PopScope(
        canPop: canPop,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SizedBox(
            height: height,
            width: double.infinity,
            child: Column(

              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                header?? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextWidget(
                          text: title,
                          fontSize: FontSizes.extraLarge,
                          fontWeight: FontWeights.bold,
                        ),
                        if(canPop)   InkWell(onTap: () {
                          Get.back();
                        },child: const IconWidget(icon: Icons.close,size: 25,clr: AppColors.black,),)
                      ],
                    ),
                    if(descriptrion.isNotEmpty)     TextWidget(
                      text: descriptrion,
                      fontSize: FontSizes.small,
                      fontWeight: FontWeights.small,
                      clr: AppColors.grey,
                    ).paddingOnly(
                      top: 8,
                    ),
                  ],
                ),
                Expanded(child: child.paddingOnly(top: 20))

              ],
            ).paddingOnly(
                top: 18,
                left:leftPadding,
                right: rightPadding,
                bottom:bottomPadding),
          ),
        ),
      ),
    );
  }
  static Widget textButton({required VoidCallback onpress,required String txt,double fontSize= FontSizes.small,double fontWeight = FontSizes.large,Color clr = AppColors.themeColor}) {
    return InkWell(
        onTap: onpress,
        child: const TextWidget(text: "Link Location",clr: AppColors.themeColor,fontWeight: FontWeights.large,fontSize: FontSizes.small,));
  }

  static Widget nickName(
      {required String name, required double size, required double font}) {
    return CircleAvatar(
      radius: size,
      backgroundColor:AppColors.themeColor,
      child:  TextWidget(text: Operation.generateNickname(name).toUpperCase() ??'',fontWeight: FontWeights.large,fontSize: font,clr: AppColors.white,),
    );
  }
  static   Widget warehouseButton({required String title,required VoidCallback onPressed,Color fontClr =AppColors.grey,Color borderClr = AppColors.grey,Color bgClr = AppColors.transparent }) {
    return CustomButton(horiZontalPadding: 12,vertiCalPadding: 6,text: title, callback: onPressed,fontSize: FontSizes.small,radius: 4,fontWeight:FontWeights.small,fontClr: fontClr,borderClr:borderClr,color: bgClr ,);
  }
  static Widget customDivider({required double height ,required double width,required Color clr}) => Container(height: height,width: width,color: clr,);

  static Widget titleWitValue({required String title,required String value,int maxline = 1}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextWidget(text:'$title : ' ,fontSize: FontSizes.small,fontWeight: FontWeights.large,),
        Expanded(child:  TextWidget(maxLine: maxline,text:value ,fontSize: FontSizes.small,clr: AppColors.grey,fontWeight: FontWeights.large,)),

      ],
    );
  }

}