import 'package:all_fold/core/key/image_keys.dart';

class AppStrings{
  AppStrings._();
  static const homepageTitle = 'title';
  static const success = "success";
  static const String currencySymbol = '₹';
  static const String rightSymbol = '✓';
  static const int toasterTime = 3000;
  static const String loginSheetTitle = 'Login to Pickify';
  static const String loginSheetDesciption = 'Warehouse management dashboard';
  static const String exitTitle = "Do you really want to exit";
  static const String exitDes = 'Any unsaved changes may be lost.';
  static const String deleteBarcodeTitle = "Delete barcode !";
  static const String unlinkTitle = "Unlink location !";
  static const String unlinkDescription = "Do you really want to unlink this location?";
  static const String deleteBarcodeDescription = "Do you really want to delete this barcode?";

  static const String logoutTitle = "Do you really want to logout";
  static const String logoutDes = 'Any unsaved changes may be lost.';
  static const String forgetPassword = 'Forget password?';

  static const String submit = "Submit";
  static const String assignPickList = "Assigned Pick List";
  static const String noteForcustomerDetails = "Invoice & Delivery Address are the same";
  static const String registerEmailAddress = "Registered Email Address";
  static const String forgetPasswordDescription = "Please enter your email address to receive a verification code.";

  static const List<String> title = [
    "Home",
    "Products",
    "Picklist",
    "Orders",
  ];

  static const List<String> productListStatus = [
    "all",
    "active",
    "draft",
    "archived",
  ];

  static const List<String> orderListStatus = [
    "fulfilled",
    "unfulfilled",
  ];

  static const List<String> pickListStatus = [
    "assigned_me",
    "open",
    "picked",
    "partial_picked",
    "closed",
  ];

  static const List<String> orderStatusLabel = [
   "original", "modified", "cancelled"
  ];

  static const List<String> ascDscFilter = [
    "asc_by_name",
    "asc_by_stock",
    "desc_by_name",
    "desc_by_stock",
  ];

  static const List<String> latestOlder = [
    "latest",
    "older",
  ];
  static const List<int> brandFilter = [
   0,1,2,3,4,5,6,7
  ];

  static const String productTitle = "Products";
  static const String stockHistoryPageTitle = "Stock History";
  static const String picklistTitle = "Pick List";
  static const String orderListTitle = "Orders List";



  static const String emptyProductDes = "No products available at the moment , Please try after sometime.";
  static const String emptyProductTitle = "No categories found!";

  static const String accessDenied = "Access Denied!";
  static const String accessDeniedDescription = "Sorry, You don't have permission to edit or view this feature.";

}