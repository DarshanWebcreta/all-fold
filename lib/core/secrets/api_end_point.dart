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
  static const String generateJobs = "batches/create-job";
  static const String moveStage = "batches/move-stage";
  static const String completeBatch = "batches/complete";
  static const String unplannedDemand = "/api/v1/execution/unplanned";
  static const String planBatch = "/api/v1/execution/batches/plan";
  static const String getBatches = "/api/v1/execution/batches";
  static const String moveStageApi = "/api/v1/execution/move-stage";
  static const String assembleBatchApi = "/api/v1/execution/process";
  static const String prepareBatchApi = "/api/v1/execution/prepare";
  static const String getBatchesHistory = "/api/v1/execution/batches/history";


  // Picklists
  static const String pickList = "picklists/get";
  static const String forceAction = "picklists/force-action";
  static const String assignPickList = "picklists/assignee";
  static const String pickListUSer = "picklists/users";
  static const String pickListView = "picklists/view";
  static const String picklistProducts = "picklists/products";
  static const String pickHistory = "picklists/log-history";
  static const String closePick = "picklists/close";
  static const String addPickNote = "picklists/notes";
  static const String acceptAdjustment = "picklists/accept-adjustment";

  // Pickup
  static const String pickAll = "pickup/all";
  static const String pickByScan = "pickup/scan-barcode";
  static const String pickItem = "pickup/product";

  // Stock Management
  static const String stockMove = "stocks/move";
  static const String stockChange = "stocks/change";

  // Locations
  static const String linkLocation = "location/link";
  static const String unLinkLocation = "location/unlink";

  // Miscellaneous
  static const String brandSupplier = "filter-list";
  static const String dashboard = "dashboard";
}
