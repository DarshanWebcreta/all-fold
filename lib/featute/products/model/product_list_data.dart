
import 'package:all_fold/featute/products/model/product_data.dart';

class ProductListData {
  String? status;
  int? statusCode;
  int? totalPages;
  String? message;
  List<ProductData>? data;

  ProductListData({this.status, this.totalPages,this.statusCode, this.message, this.data});
}


