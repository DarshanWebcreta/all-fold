import 'package:all_fold/featute/products/model/product_data.dart';

class ProductionBatch {
  String id;
  ProductData product;
  String status; // 'planned' | 'in_progress' | 'completed'
  int targetQuantity;
  int currentStage; // 0 (Planned/Staging), 1 (Raw Prep), 2 (Welding & WIP), 3 (Assembly), 4 (Completed)
  List<ComponentJob> components;
  List<SalesOrderDemand> salesOrders;
  List<BOMItem> bomItems;
  DateTime createdAt;

  ProductionBatch({
    required this.id,
    required this.product,
    required this.status,
    required this.targetQuantity,
    required this.currentStage,
    required this.components,
    required this.salesOrders,
    required this.bomItems,
    required this.createdAt,
  });

  // Calculate percentage overall completion
  double get progressPercentage {
    if (status == 'completed') return 1.0;
    if (status == 'planned') return 0.0;
    if (components.isEmpty) return 0.0;
    double totalProgress = 0;
    for (var comp in components) {
      // Each component contributes progress based on its stage
      totalProgress += (comp.currentStage - 1) / 3.0; // Stage 1=0, 2=0.33, 3=0.66, Completed=1.0
    }
    return totalProgress / components.length;
  }
}

class ComponentJob {
  String id;
  String name;
  int currentStage; // 1 (Raw Prep), 2 (Welding & WIP), 3 (Assembly), 4 (Completed at Stage 3/Ready)
  String status; // 'pending' | 'in_progress' | 'completed'
  int targetQty;
  int completedQty;

  ComponentJob({
    required this.id,
    required this.name,
    required this.currentStage,
    required this.status,
    required this.targetQty,
    required this.completedQty,
  });

  String get stageName {
    switch (currentStage) {
      case 1:
        return "Raw Prep";
      case 2:
        return "Welding & WIP";
      case 3:
        return "Assembly";
      case 4:
        return "Completed";
      default:
        return "Unknown";
    }
  }
}

class BOMItem {
  String materialName;
  double requiredQty;
  double availableStock;

  BOMItem({
    required this.materialName,
    required this.requiredQty,
    required this.availableStock,
  });

  bool get isStockSufficient => availableStock >= requiredQty;
}

class SalesOrderDemand {
  String orderId;
  String customerName;
  int quantityDemanded;
  String status; // 'pending' | 'completed'

  SalesOrderDemand({
    required this.orderId,
    required this.customerName,
    required this.quantityDemanded,
    required this.status,
  });
}
