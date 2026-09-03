class ApiPath {
  ApiPath._();

  // Authentication
  static const String login = "login";
  static const String authLogin = "/api/auth/login";
  static const String getProfile = "/api/auth/me";
  static const String logout = "/api/auth/logout";
  static const String forgetPassword = "user/forgot-password";
  static const String changePassword = "user/change-password";

  // Products
  static const String productList = "products/get";
  static const String productView = "products/view";
  static const String getProductByBarcode = "products/scan-barcode";
  static const String barcodeManage = "products/update-barcode";
  static const String stockHistory = "products/stock-history";

  // Orders
  static const String orderList = "orders/get";
  static const String orderView = "orders/view";
  static const String orderViewMore = "orders/products";
  static const String processOrder = "orders/process";

  // Bulk Execution
  static const String createBatch = "batches/create";
  static const String generateJobs = "/api/v1/execution/batches/create-job";
  static const String moveStage = "batches/move-stage";
  static const String completeBatch = "batches/complete";
  static const String unplannedDemand = "/api/v1/execution/unplanned";
  static const String planBatch = "/api/v1/execution/batches/plan";
  static const String getBatches = "/api/v1/execution/batches";
  static const String moveStageApi = "/api/v1/execution/move-stage";
  static const String assembleBatchApi = "/api/v1/execution/process";
  static const String prepareBatchApi = "/api/v1/execution/prepare";
  static const String getBatchesHistory = "/api/v1/execution/batches/history";
  static const String assembleBatchPreview = "/api/v1/execution/batches/{batch_id}/assemble-preview";

  // Sales Orders
  static const String salesOrderList = "/api/v1/sales-orders";
  static const String salesOrderDetail = "/api/v1/sales-orders/{id}";
  static const String salesOrderDispatchPreview = "/api/v1/sales-orders/{id}/dispatch-preview";
  static const String salesOrderDispatch = "/api/v1/sales-orders/{id}/dispatch";
  static const String salesOrderAddShippingAddress = "/api/v1/sales-orders/{id}/dispatch-shipping-address";



}
