

import 'package:all_fold/core/secrets/api_end_point.dart';
import 'package:all_fold/core/secrets/api_strings.dart';
import 'package:all_fold/data/interceptor.dart';
import 'package:all_fold/featute/products/model/product_list_model.dart';
import 'package:all_fold/featute/auth/model/user_model.dart';
import 'package:all_fold/featute/bulk_execution/model/unplanned_demand_model.dart';
import 'package:all_fold/featute/bulk_execution/model/active_batches_model.dart';
import 'package:all_fold/featute/bulk_execution/model/bulk_history_model.dart';
import 'package:all_fold/featute/bulk_execution/model/batch_movement_model.dart';
import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:retrofit/retrofit.dart';

part 'api_service.g.dart';

@RestApi(baseUrl: ApiStrings.baseUrl)
abstract class ApiService {
  factory ApiService(Dio dio) {
    final interceptor = DefaultInterceptor();
    dio.interceptors.add(interceptor);
    dio.interceptors.add(PrettyDioLogger(requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        compact: true,
        maxWidth: 90));
    return _ApiService(dio);
  }

  @POST(ApiPath.authLogin)
  Future<LoginResponseModel> login(@Body() Map<String, dynamic> body);

  @GET(ApiPath.getProfile)
  Future<ProfileResponseModel> getProfile();

  @POST(ApiPath.logout)
  Future<dynamic> logout();

  @POST(ApiPath.createBatch)
  Future<dynamic> createBatch(@Body() Map<String, dynamic> body);

  @POST(ApiPath.generateJobs)
  Future<dynamic> generateJobs(@Body() Map<String, dynamic> body);

  @POST(ApiPath.moveStage)
  Future<dynamic> moveStage(@Body() Map<String, dynamic> body);

  @POST(ApiPath.completeBatch)
  Future<dynamic> completeBatch(@Body() Map<String, dynamic> body);

  @GET(ApiPath.productList)
  Future<ProductListModel> getProducts({
    @Query("status") required String status,
    @Query("keyword") String? keyword,
    @Query("page") int? page,
    @Query("store_id") int? storeId,
    @Query("length") int? length,
    @Query("sort_by") String? sortBy,
    @Query("brand_id") int? brandId,
    @Query("supplier_id") int? supplierId,
  });

  @GET(ApiPath.unplannedDemand)
  Future<UnplannedDemandResponse> getUnplannedDemand();

  @POST(ApiPath.planBatch)
  Future<dynamic> planBatch(@Body() Map<String, dynamic> body);

  @GET(ApiPath.getBatches)
  Future<ActiveBatchesResponse> getActiveBatches();

  @POST(ApiPath.moveStageApi)
  Future<dynamic> moveStageApi(@Body() Map<String, dynamic> body);

  @POST(ApiPath.assembleBatchApi)
  Future<dynamic> assembleBatch(@Body() Map<String, dynamic> body);

  @POST(ApiPath.prepareBatchApi)
  Future<dynamic> prepareBatch(@Body() Map<String, dynamic> body);

  @GET(ApiPath.getBatchesHistory)
  Future<BulkHistoryResponse> getBatchesHistory({
    @Query("page") int? page,
    @Query("per_page") int? perPage,
  });

  @GET("/api/v1/execution/batches/{batch_id}/history")
  Future<BatchMovementHistoryResponse> getBatchMovementHistory({
    @Path("batch_id") required int batchId,
    @Query("page") int? page,
    @Query("per_page") int? perPage,
  });

  // ─── Assemble Preview ──────────────────────────────────────────────────────

  @GET("/api/v1/execution/batches/{batch_id}/assemble-preview")
  Future<dynamic> getAssemblePreview({
    @Path("batch_id") required int batchId,
  });

  // ─── Sales Orders ──────────────────────────────────────────────────────────

  @GET(ApiPath.salesOrderList)
  Future<dynamic> getSalesOrders({
    @Query("order_status") String? orderStatus,
    @Query("branch_id") int? branchId,
    @Query("search") String? search,
    @Query("per_page") int? perPage,
    @Query("page") int? page,
  });

  @GET("/api/v1/sales-orders/{id}")
  Future<dynamic> getSalesOrderDetail({
    @Path("id") required int id,
  });

  @GET("/api/v1/sales-orders/{id}/dispatch-preview")
  Future<dynamic> getSalesOrderDispatchPreview({
    @Path("id") required int id,
  });

  @POST("/api/v1/sales-orders/{id}/dispatch-shipping-address")
  Future<dynamic> addSalesOrderShippingAddress({
    @Path("id") required int id,
    @Body() required Map<String, dynamic> body,
  });

  @POST("/api/v1/sales-orders/{id}/dispatch")
  Future<dynamic> executeSalesOrderDispatch({
    @Path("id") required int id,
    @Body() required Map<String, dynamic> body,
  });
}
