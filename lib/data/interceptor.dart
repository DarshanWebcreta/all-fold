

import 'package:all_fold/core/key/storage_keys.dart';
import 'package:all_fold/core/routes/route_name.dart';
import 'package:all_fold/core/storage/app_storage.dart';
import 'package:all_fold/core/utils/function_component.dart';
import 'package:dio/dio.dart';
import 'package:get/get_core/src/get_main.dart' show Get;
import 'package:get/get_navigation/src/extension_navigation.dart';

class DefaultInterceptor extends Interceptor {
  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    // options.headers[ApiStrings.contentType] = ApiStrings.applicationXWWW;
    //options.headers[ApiStrings.accept] = ApiStrings.applicationJson;
// aana lidhe request ma issue jai saka chhe dhyan rakhvu pade
    options.connectTimeout = const Duration(milliseconds: 20000);
    options.sendTimeout = const Duration(milliseconds: 20000);
    options.receiveTimeout = const Duration(milliseconds: 20000);

    String? authToken = StorageManager.readData(StoreKeys.token);

    if (authToken != null && authToken.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $authToken';
    }

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    handler.next(response);
  }

  @override
  void onError(DioException? err, ErrorInterceptorHandler handler) {
    handler.next(err!);

    if(err.response!=null) {
      if (err.response!.statusMessage == 'Unauthorized') {
        Get.offAllNamed(RoutesNames.login);
        StorageManager.deleteAllData();
        FunctionalWidget.showSnackBar(
            title: "Unauthorized please login again", success: false);

      }}
  }
}
