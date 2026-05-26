

import 'package:get/get.dart';
import 'package:all_fold/core/key/storage_keys.dart';
import 'package:all_fold/core/storage/app_storage.dart';


import '../common/status_model.dart';
import '../routes/route_name.dart';
import '../theme/app_colors.dart';

class Operation {
  Operation._();
  static String generateNickname(String fullName) {
    List<String> parts = fullName.split(' ');

    String nickname = '';

    for (String part in parts) {
      if (part.isNotEmpty) {
        nickname += part[0].toUpperCase();
      }
    }

    return nickname;
  }

  static String formatStringWithSpaces(String input) {
    return input
        .split('_') // Split the string at underscores
        .map((word) =>
            word[0].toUpperCase() + word.substring(1)) // Capitalize each word
        .join(' '); // Join the words with spaces
  }

  static bool isPermission({required String enterPermission}) {
    final roles = StorageManager.readData(StoreKeys.roles);

    if (roles is List<dynamic>) {
      return roles.contains(enterPermission);
    }

    return false; // Return false if roles is null or not a list
  }
  // static Future<void> pickProductByScan({required WidgetRef ref,bool fromList = false}) async {
  //   String? result = await  FunctionalWidget.scanBarcode();
  //   if(result!=null&&result!="-1"){
  //     ref.read(pickByBarcodeControllerProvider.notifier).pickBybarcode(fromList: false,barcode: result, pickListId: widget.pickId);
  //
  //   }
  // }

  static StatusColor getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'archived'||'adjustment accepted':
        return const StatusColor(
          background: AppColors.partialPickedBg,
          text: AppColors.partialPickedText,
        );

      case 'partial picked':
        return const StatusColor(
          background: AppColors.partialPickedBg,
          text: AppColors.partialPickedText,
        );
      case 'active':
        return const StatusColor(
          background: AppColors.openBg,
          text: AppColors.openText,
        );
      case 'picked':
        return const StatusColor(
          background: AppColors.openBg,
          text: AppColors.openText,
        );
      case 'fulfilled':
        return const StatusColor(
          background: AppColors.openBg,
          text: AppColors.openText,
        );
      case 'draft':
        return const StatusColor(
          background: AppColors.pickedBg,
          text: AppColors.pickedText,
        );
      case 'open':
        return const StatusColor(
          background: AppColors.pickedBg,
          text: AppColors.pickedText,
        );

      case 'original'||'no change':
        return const StatusColor(
          background: AppColors.fulfillClr,
          text: AppColors.black,
        );
      case 'added':
        return const StatusColor(
          background: AppColors.openBg,
          text: AppColors.black,
        );


      case 'modified':
        return   StatusColor(
          background: AppColors.lightOrange,
          text: AppColors.orange,
        );


      case 'cancelled'||'canceled':
        return  const StatusColor(
          background: AppColors.lightRed,
          text: AppColors.red,
        );
      case 'unfulfilled':
        return const StatusColor(
          background: AppColors.pickedBg,
          text: AppColors.pickedText,
        );
      case 'closed'||'needs adjustment':
        return const StatusColor(
          background: AppColors.closedBg,
          text: AppColors.closedText,
        );

      case 'all':
        return const StatusColor(
          background: AppColors.themeColor,
          text: AppColors.white,
        );
      default:
        return const StatusColor(
          background: AppColors.white,
          text: AppColors.white,
        );
    }
  }




  static Future<dynamic>? gotoSuccessPage(
          {required bool status, required String message}) =>
      Get.toNamed(RoutesNames.fullStatusView, arguments: [status, message]);
}
