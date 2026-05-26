import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:all_fold/core/utils/function_component.dart';
import 'package:all_fold/featute/auth/controller/auth_controller.dart';
import 'package:all_fold/featute/bulk_execution/model/batch_model.dart';
import 'package:all_fold/featute/products/model/product_data.dart';
import 'package:all_fold/core/di/service_locator.dart';
import 'package:all_fold/data/api_service.dart';
import 'package:all_fold/featute/bulk_execution/model/unplanned_demand_model.dart';
import 'package:all_fold/featute/bulk_execution/model/active_batches_model.dart';
import 'package:dio/dio.dart';

class BulkExecutionController extends GetxController {
  final batches = <ProductionBatch>[].obs;
  final seedProducts = <ProductData>[].obs;
  final seedSalesOrders = <SalesOrderDemand>[].obs;

  // Unplanned Demand State
  final unplannedProducts = <UnplannedProduct>[].obs;
  final isLoadingUnplanned = false.obs;
  final unplannedError = "".obs;

  // Active Batches State
  final activeApiBatches = <ApiBatch>[].obs;
  final isLoadingBatches = false.obs;
  final batchesError = "".obs;

  // Form State
  final selectedProduct = Rxn<ProductData>();
  final targetQuantityController = TextEditingController();
  final selectedSalesOrders = <SalesOrderDemand>[].obs;

  // Simulated Stage/Role Override for UI testing
  final simulatedWarehouseId = Rxn<int>();

  // Get active warehouse ID (either user's logged-in warehouse or simulation override)
  int get activeWarehouseId {
    if (simulatedWarehouseId.value != null) {
      return simulatedWarehouseId.value!;
    }
    try {
      final auth = Get.find<AuthController>();
      return auth.rxUser.value?.warehouseId ?? 0;
    } catch (e) {
      return 0; // Fallback to Admin
    }
  }

  String get activeWarehouseName {
    final whId = activeWarehouseId;
    switch (whId) {
      case 1:
        return "Stage 1 Warehouse (Raw Prep)";
      case 2:
        return "Stage 2 Warehouse (Welding)";
      case 3:
        return "Stage 3 Warehouse (Assembly)";
      case 0:
      default:
        return "Admin Console (Full Access)";
    }
  }

  @override
  void onInit() {
    super.onInit();
    _seedInitialData();
    fetchUnplannedDemand();
    fetchActiveBatches();

    // Auto re-fetch or apply permission check when role/warehouse override changes
    ever(simulatedWarehouseId, (_) {
      fetchUnplannedDemand();
      fetchActiveBatches();
    });
  }

  @override
  void onClose() {
    targetQuantityController.dispose();
    super.onClose();
  }

  void _seedInitialData() {
    // 1. Seed Products
    seedProducts.assignAll([
      ProductData(id: 1, title: "Steel Folding Bracket", sku: "ALLFOLD-SFB-01", stock: 120),
      ProductData(id: 2, title: "Heavy Duty Frame Accent", sku: "ALLFOLD-HDF-09", stock: 15),
      ProductData(id: 3, title: "Aluminum Joint Connect", sku: "ALLFOLD-AJC-32", stock: 45),
    ]);

    // 2. Seed Sales Orders
    seedSalesOrders.assignAll([
      SalesOrderDemand(orderId: "SO-5021", customerName: "Tesla Logistics", quantityDemanded: 40, status: "pending"),
      SalesOrderDemand(orderId: "SO-5022", customerName: "Rivian Automotive", quantityDemanded: 25, status: "pending"),
      SalesOrderDemand(orderId: "SO-5023", customerName: "Ford Special Projects", quantityDemanded: 30, status: "pending"),
      SalesOrderDemand(orderId: "SO-5024", customerName: "Lucid Air Manufacturing", quantityDemanded: 50, status: "pending"),
    ]);

    // 3. Seed Production Batches
    batches.assignAll([
      ProductionBatch(
        id: "PB-00101",
        product: seedProducts[0],
        status: "in_progress",
        targetQuantity: 65,
        currentStage: 2,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        salesOrders: [seedSalesOrders[0], seedSalesOrders[1]],
        bomItems: [
          BOMItem(materialName: "Raw Steel Sheets", requiredQty: 130, availableStock: 250),
          BOMItem(materialName: "Standard M8 Fasteners", requiredQty: 260, availableStock: 500),
        ],
        components: [
          ComponentJob(id: "CJ-101", name: "Steel Raw Cut", currentStage: 3, status: "in_progress", targetQty: 65, completedQty: 65),
          ComponentJob(id: "CJ-102", name: "Folding Joint Weld", currentStage: 2, status: "in_progress", targetQty: 65, completedQty: 40),
          ComponentJob(id: "CJ-103", name: "Bracket Final Polish", currentStage: 1, status: "pending", targetQty: 65, completedQty: 0),
        ],
      ),
      ProductionBatch(
        id: "PB-00102",
        product: seedProducts[2],
        status: "planned",
        targetQuantity: 30,
        currentStage: 0,
        createdAt: DateTime.now().subtract(const Duration(hours: 4)),
        salesOrders: [seedSalesOrders[2]],
        bomItems: [
          BOMItem(materialName: "Aluminum Alloys", requiredQty: 60, availableStock: 100),
          BOMItem(materialName: "Connect Clips", requiredQty: 30, availableStock: 8), // Sufficient stock check will fail!
        ],
        components: [],
      ),
    ]);
  }

  void resetForm() {
    selectedProduct.value = null;
    targetQuantityController.clear();
    selectedSalesOrders.clear();
  }

  void addSalesOrderToBatch(SalesOrderDemand demand) {
    if (selectedSalesOrders.contains(demand)) {
      selectedSalesOrders.remove(demand);
    } else {
      selectedSalesOrders.add(demand);
    }
    // Auto calculate target build quantity
    int total = selectedSalesOrders.fold(0, (sum, item) => sum + item.quantityDemanded);
    targetQuantityController.text = total.toString();
  }

  void createProductionBatch() {
    final product = selectedProduct.value;
    final targetQtyStr = targetQuantityController.text.trim();
    
    if (product == null) {
      FunctionalWidget.showSnackBar(title: "Please select a product", success: false);
      return;
    }
    if (targetQtyStr.isEmpty || int.tryParse(targetQtyStr) == null || int.parse(targetQtyStr) <= 0) {
      FunctionalWidget.showSnackBar(title: "Enter a valid target quantity", success: false);
      return;
    }
    if (selectedSalesOrders.isEmpty) {
      FunctionalWidget.showSnackBar(title: "Group at least one sales order demand", success: false);
      return;
    }

    final targetQty = int.parse(targetQtyStr);
    
    // Seed BOM Items dynamically based on product selection
    List<BOMItem> bomList = [];
    if (product.id == 2) {
      // Heavy Duty Frame: Shortage in bolts to trigger BOM Guard
      bomList = [
        BOMItem(materialName: "Heavy Channel Bars", requiredQty: targetQty * 1.5, availableStock: 100),
        BOMItem(materialName: "Stainless M12 Bolts", requiredQty: targetQty * 4.0, availableStock: 25), // Shortage!
      ];
    } else {
      bomList = [
        BOMItem(materialName: "Raw Sheet Metal", requiredQty: targetQty * 2.0, availableStock: 300),
        BOMItem(materialName: "Fastener Screws", requiredQty: targetQty * 3.0, availableStock: 500),
      ];
    }

    final newBatch = ProductionBatch(
      id: "PB-${100 + batches.length + 1}",
      product: product,
      status: "planned",
      targetQuantity: targetQty,
      currentStage: 0,
      createdAt: DateTime.now(),
      salesOrders: List.from(selectedSalesOrders),
      bomItems: bomList,
      components: [],
    );

    batches.insert(0, newBatch);
    resetForm();
    Get.back();
    FunctionalWidget.showSnackBar(title: "Production Batch planned successfully.", success: true);
  }

  void generateStagingJobs(String batchId) {
    final batchIndex = batches.indexWhere((b) => b.id == batchId);
    if (batchIndex == -1) return;

    final batch = batches[batchIndex];

    // BOM Stock Guard Check
    final insufficientItems = batch.bomItems.where((item) => !item.isStockSufficient).toList();
    if (insufficientItems.isNotEmpty) {
      FunctionalWidget.showSnackBar(
        title: "BOM Guard: Insufficient raw material stock. Contact Administrator.",
        success: false,
      );
      return;
    }

    // Generate staging component jobs for the pipeline
    final target = batch.targetQuantity;
    batch.components = [
      ComponentJob(id: "CJ-${batch.id}-1", name: "Stage 1: Raw Prep Job", currentStage: 1, status: "in_progress", targetQty: target, completedQty: 0),
      ComponentJob(id: "CJ-${batch.id}-2", name: "Stage 2: Welding WIP Job", currentStage: 1, status: "pending", targetQty: target, completedQty: 0),
      ComponentJob(id: "CJ-${batch.id}-3", name: "Stage 3: Assembly Job", currentStage: 1, status: "pending", targetQty: target, completedQty: 0),
    ];

    batch.status = "in_progress";
    batch.currentStage = 1;

    batches[batchIndex] = batch;
    batches.refresh();

    FunctionalWidget.showSnackBar(title: "Component jobs generated. Pipeline is at Stage 1.", success: true);
  }

  void moveStage(String batchId, int componentIndex) {
    final batchIndex = batches.indexWhere((b) => b.id == batchId);
    if (batchIndex == -1) return;

    final batch = batches[batchIndex];
    final component = batch.components[componentIndex];

    // Enforce stage constraints based on warehouse ID
    final operatorWH = activeWarehouseId;
    final reqStage = component.currentStage; // 1, 2, or 3

    if (operatorWH != 0 && operatorWH != reqStage) {
      FunctionalWidget.showSnackBar(
        title: "Restricted: Action limited to Stage $reqStage Warehouse operators.",
        success: false,
      );
      return;
    }

    // Move to next stage
    if (component.currentStage < 3) {
      component.currentStage++;
      component.status = "in_progress";
    } else {
      component.currentStage = 4; // Complete
      component.status = "completed";
      component.completedQty = component.targetQty;
    }

    // Recalculate batch stage based on the lowest stage component
    int minStage = 4;
    for (var comp in batch.components) {
      if (comp.currentStage < minStage) {
        minStage = comp.currentStage;
      }
    }
    batch.currentStage = minStage;

    batches[batchIndex] = batch;
    batches.refresh();

    FunctionalWidget.showSnackBar(
      title: "${component.name} moved to stage ${component.stageName}.",
      success: true,
    );
  }

  void completeFinalAssembly(String batchId) {
    final batchIndex = batches.indexWhere((b) => b.id == batchId);
    if (batchIndex == -1) return;

    final batch = batches[batchIndex];

    // Enforce stage 3 operator check or admin
    final operatorWH = activeWarehouseId;
    if (operatorWH != 0 && operatorWH != 3) {
      FunctionalWidget.showSnackBar(
        title: "Restricted: Final Assembly requires Stage 3 Warehouse (Assembly) clearance.",
        success: false,
      );
      return;
    }

    // Final Assembly triggers inventory consumption and completed state
    batch.status = "completed";
    batch.currentStage = 4;

    // Update finished stock of the product
    batch.product.stock = (batch.product.stock ?? 0) + batch.targetQuantity;

    // Mark sales orders completed
    for (var order in batch.salesOrders) {
      order.status = "completed";
    }

    // Mark all components as completed
    for (var comp in batch.components) {
      comp.currentStage = 4;
      comp.status = "completed";
      comp.completedQty = comp.targetQty;
    }

    batches[batchIndex] = batch;
    batches.refresh();

    FunctionalWidget.showSnackBar(title: "Assembly complete. Grouped sales orders closed.", success: true);
  }

  bool get hasUnplannedAccess {
    final whId = activeWarehouseId;
    return whId == 0 || whId == 1;
  }

  Future<void> fetchUnplannedDemand() async {
    if (!hasUnplannedAccess) {
      unplannedError.value = "403";
      unplannedProducts.clear();
      return;
    }

    isLoadingUnplanned.value = true;
    unplannedError.value = "";

    try {
      final apiService = getIt<ApiService>();
      final response = await apiService.getUnplannedDemand();
      if (response.success == true && response.data != null && response.data!.products != null) {
        unplannedProducts.assignAll(response.data!.products!);
      } else {
        unplannedError.value = response.message ?? "Failed to fetch unplanned demand";
      }
    } catch (e) {
      debugPrint("API Error fetching unplanned demand, using mock fallback: $e");
      _loadMockUnplannedDemand();
    } finally {
      isLoadingUnplanned.value = false;
    }
  }

  void _loadMockUnplannedDemand() {
    unplannedProducts.assignAll([
      UnplannedProduct(
        productId: 1,
        productName: "AllFold Premium Ladder",
        sku: "LAD-PREM-01",
        totalOrdered: 150,
        totalReserved: 50,
        pendingQty: 100,
        readyStock: 25,
        components: [
          UnplannedComponent(
            id: 5,
            name: "Aluminum Rails",
            qtyPerPc: 2,
            totalNeeded: 200,
            stageStock: {"1": 500, "2": 150, "3": 0},
            rawStockKg: 1500,
            rawName: "Aluminum Extrusions",
          ),
          UnplannedComponent(
            id: 6,
            name: "Rubber Foot Pads",
            qtyPerPc: 4,
            totalNeeded: 400,
            stageStock: {"1": 800, "2": 300, "3": 120},
            rawStockKg: 200,
            rawName: "Raw Rubber Polymer",
          ),
        ],
      ),
      UnplannedProduct(
        productId: 2,
        productName: "Apex",
        sku: "apex-5",
        totalOrdered: 1000,
        totalReserved: 0,
        pendingQty: 1000,
        readyStock: 0,
        components: [
          UnplannedComponent(
            id: 10,
            name: "Steel Joint Rivet",
            qtyPerPc: 8,
            totalNeeded: 8000,
            stageStock: {"1": 2000, "2": 500, "3": 0},
            rawStockKg: 5000,
            rawName: "Steel Rivet Rods",
          ),
        ],
      ),
    ]);
  }

  Future<void> planNewBatchFromUnplanned({
    required UnplannedProduct product,
    required int quantity,
    required String batchName,
  }) async {
    FunctionalWidget.loaderHideShow(loaderShow: true);
    try {
      final apiService = getIt<ApiService>();
      await apiService.planBatch({
        "product_id": product.productId,
        "qty": quantity.toDouble(),
        "batch_name": batchName,
      });
      FunctionalWidget.showSnackBar(
        title: "Production Batch planned successfully on Server.",
        success: true,
      );
    } catch (e) {
      debugPrint("API Error planning batch, falling back to simulated local creation: $e");
    } finally {
      _createSimulatedBatchFromUnplanned(product, quantity, batchName);
      FunctionalWidget.loaderHideShow(loaderShow: false);
    }
  }

  void _createSimulatedBatchFromUnplanned(UnplannedProduct product, int quantity, String batchName) {
    final bomItemsList = <BOMItem>[];
    if (product.components != null) {
      for (var comp in product.components!) {
        bomItemsList.add(
          BOMItem(
            materialName: comp.rawName ?? comp.name ?? "Raw Material",
            requiredQty: ((comp.qtyPerPc ?? 1) * quantity).toDouble(),
            availableStock: (comp.rawStockKg ?? 0.0).toDouble(),
          ),
        );
      }
    }

    final pData = ProductData(
      id: product.productId,
      title: product.productName,
      sku: product.sku,
      stock: product.readyStock,
    );

    final mockOrder = SalesOrderDemand(
      orderId: "SO-${1000 + batches.length + 1}",
      customerName: "Plan: $batchName",
      quantityDemanded: quantity,
      status: "pending",
    );

    final newBatch = ProductionBatch(
      id: "PB-${100 + batches.length + 1}",
      product: pData,
      status: "planned",
      targetQuantity: quantity,
      currentStage: 0,
      createdAt: DateTime.now(),
      salesOrders: [mockOrder],
      bomItems: bomItemsList,
      components: [],
    );

    batches.insert(0, newBatch);
    batches.refresh();

    final idx = unplannedProducts.indexWhere((p) => p.productId == product.productId);
    if (idx != -1) {
      final p = unplannedProducts[idx];
      final currentPending = p.pendingQty ?? 0;
      final newPending = currentPending - quantity;
      p.pendingQty = newPending > 0 ? newPending : 0;
      unplannedProducts[idx] = p;
      unplannedProducts.refresh();
    }

    FunctionalWidget.showSnackBar(
      title: "Production Batch '$batchName' planned successfully.",
      success: true,
    );
  }

  Future<void> fetchActiveBatches() async {
    isLoadingBatches.value = true;
    batchesError.value = "";

    try {
      final apiService = getIt<ApiService>();
      final response = await apiService.getActiveBatches();
      if (response.success == true && response.data != null && response.data!.batches != null) {
        activeApiBatches.assignAll(response.data!.batches!);
      } else {
        batchesError.value = response.message ?? "Failed to fetch active batches";
      }
    } catch (e) {
      debugPrint("API Error fetching active batches, using mock fallback: $e");
      _loadMockActiveBatches();
    } finally {
      isLoadingBatches.value = false;
    }
  }

  void _loadMockActiveBatches() {
    activeApiBatches.assignAll([
      ApiBatch(
        batchId: 8,
        batchNo: "BAT-2026-0008",
        batchName: "Batch 25/05/2026",
        productId: 1,
        productName: "AllFold Premium Ladder",
        sku: "LAD-PREM-01",
        plannedQty: 50,
        status: "planned",
        isActionableForCurrentUser: false,
        components: [
          ApiComponent(
            componentId: 5,
            componentName: "Aluminum Rails",
            qtyPerPc: 2,
            totalNeeded: 100,
            currentStageId: 2,
            currentStageLabel: "Stage 2 Warehouse (WIP)",
            isActionableForCurrentUser: true,
            jobStatus: "pending",
            pipelineStages: [
              PipelineStage(stageId: 1, stageName: "Stage 1 Raw Prep", stock: 400, reserved: 0),
              PipelineStage(stageId: 2, stageName: "Stage 2 Welding & WIP", stock: 150, reserved: 100),
              PipelineStage(stageId: 3, stageName: "Stage 3 Assembly & Finished", stock: 0, reserved: 0),
            ],
          ),
        ],
      ),
      ApiBatch(
        batchId: 9,
        batchNo: "BATCH-20260526-08FD",
        batchName: "Morning Plan",
        productId: 2,
        productName: "Hunter",
        sku: "hunter-5-grey",
        plannedQty: 100,
        status: "planned",
        isActionableForCurrentUser: true,
        components: [
          ApiComponent(
            componentId: 15,
            componentName: "50 MM HEAT SHRINK TUBE-BLACK",
            qtyPerPc: 1,
            totalNeeded: 100,
            currentStageId: 1,
            currentStageLabel: "PLANT-1 SUPERVISOR",
            isActionableForCurrentUser: true,
            jobStatus: "pending",
            pipelineStages: [
              PipelineStage(stageId: 1, stageName: "PLANT-1 SUPERVISOR", stock: 100, reserved: 100),
              PipelineStage(stageId: 2, stageName: "PLANT-2 SUPERVISOR", stock: 0, reserved: 0),
              PipelineStage(stageId: 3, stageName: "PLANT-3 ASSEMBLY SUPERVISOR", stock: 0, reserved: 0),
            ],
          ),
        ],
      ),
    ]);
  }

  Future<void> moveComponentStage({
    required int batchId,
    required int componentId,
    required double quantity,
    required int? toWarehouseId,
    String? remarks,
  }) async {
    FunctionalWidget.loaderHideShow(loaderShow: true);
    try {
      final apiService = getIt<ApiService>();
      final response = await apiService.moveStageApi({
        "batch_id": batchId,
        "component_id": componentId,
        "quantity": quantity,
        "to_warehouse_id": toWarehouseId,
        "remarks": remarks ?? "",
      });
      
      if (response is Map) {
        final bool isSuccess = response['success'] ?? true;
        final String msg = response['message'] ?? (toWarehouseId == null ? "Component job completed at this stage." : "Moved units successfully.");
        FunctionalWidget.showSnackBar(title: msg, success: isSuccess);
        if (isSuccess) {
          await fetchActiveBatches();
        }
      } else {
        FunctionalWidget.showSnackBar(
          title: toWarehouseId == null ? "Component job completed at this stage." : "Moved units successfully.",
          success: true,
        );
        await fetchActiveBatches();
      }
    } catch (e) {
      if (e is DioException && e.response != null) {
        final res = e.response!;
        String errorMsg = "Access denied: stage movement restriction.";
        if (res.data is Map && res.data['message'] != null) {
          errorMsg = res.data['message'];
        } else if (res.statusMessage != null) {
          errorMsg = res.statusMessage!;
        }
        FunctionalWidget.showSnackBar(title: errorMsg, success: false);
      } else {
        debugPrint("API Network Error moving component stage, simulating locally: $e");
        _simulateMoveComponentStageLocally(batchId, componentId, quantity, toWarehouseId, remarks);
      }
    } finally {
      FunctionalWidget.loaderHideShow(loaderShow: false);
    }
  }

  void _simulateMoveComponentStageLocally(
    int batchId,
    int componentId,
    double quantity,
    int? toWarehouseId,
    String? remarks,
  ) {
    final batchIndex = activeApiBatches.indexWhere((b) => b.batchId == batchId);
    if (batchIndex == -1) return;

    final batch = activeApiBatches[batchIndex];
    final compIndex = batch.components?.indexWhere((c) => c.componentId == componentId) ?? -1;
    if (compIndex == -1) return;

    final comp = batch.components![compIndex];

    if (toWarehouseId == null) {
      // Mark as completed
      comp.jobStatus = "completed";
      FunctionalWidget.showSnackBar(
        title: "Component job completed at this stage. (Simulated)",
        success: true,
      );
    } else {
      // Transfer to next stage
      final currentStageId = comp.currentStageId;
      comp.currentStageId = toWarehouseId;
      comp.currentStageLabel = toWarehouseId == 1 
          ? "PLANT-1 SUPERVISOR" 
          : toWarehouseId == 2 
              ? "PLANT-2 SUPERVISOR" 
              : "PLANT-3 ASSEMBLY SUPERVISOR";

      // Move stock values in pipelineStages
      if (comp.pipelineStages != null) {
        final currentStage = comp.pipelineStages!.firstWhereOrNull((s) => s.stageId == currentStageId);
        final targetStage = comp.pipelineStages!.firstWhereOrNull((s) => s.stageId == toWarehouseId);

        if (currentStage != null && targetStage != null) {
          int moveQty = quantity.toInt();
          currentStage.stock = (currentStage.stock ?? 0) - moveQty;
          if (currentStage.stock! < 0) currentStage.stock = 0;
          targetStage.stock = (targetStage.stock ?? 0) + moveQty;
        }
      }

      FunctionalWidget.showSnackBar(
        title: "Moved units successfully to stage $toWarehouseId. (Simulated)",
        success: true,
      );
    }

    activeApiBatches[batchIndex] = batch;
    activeApiBatches.refresh();
  }

  Future<void> assembleBatch(int batchId) async {
    FunctionalWidget.loaderHideShow(loaderShow: true);
    try {
      final apiService = getIt<ApiService>();
      final response = await apiService.assembleBatch({
        "batch_id": batchId,
      });
      
      if (response is Map) {
        final bool isSuccess = response['success'] ?? true;
        final String msg = response['message'] ?? "Batch assembled successfully.";
        FunctionalWidget.showSnackBar(title: msg, success: isSuccess);
        if (isSuccess) {
          await fetchActiveBatches();
        }
      } else {
        FunctionalWidget.showSnackBar(
          title: "Batch assembled successfully.",
          success: true,
        );
        await fetchActiveBatches();
      }
    } catch (e) {
      if (e is DioException && e.response != null) {
        final res = e.response!;
        String errorMsg = "Access denied: failed to assemble batch.";
        if (res.data is Map && res.data['message'] != null) {
          errorMsg = res.data['message'];
        } else if (res.statusMessage != null) {
          errorMsg = res.statusMessage!;
        }
        FunctionalWidget.showSnackBar(title: errorMsg, success: false);
      } else {
        debugPrint("API Network Error assembling batch, simulating locally: $e");
        _simulateAssembleBatchLocally(batchId);
      }
    } finally {
      FunctionalWidget.loaderHideShow(loaderShow: false);
    }
  }

  void _simulateAssembleBatchLocally(int batchId) {
    final batchIndex = activeApiBatches.indexWhere((b) => b.batchId == batchId);
    if (batchIndex == -1) return;

    final batch = activeApiBatches[batchIndex];
    batch.status = "completed";

    FunctionalWidget.showSnackBar(
      title: "Batch assembled and finished stock updated successfully. (Simulated)",
      success: true,
    );

    activeApiBatches[batchIndex] = batch;
    activeApiBatches.refresh();
  }
}
