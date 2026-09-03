class AssemblePreviewResponse {
  bool? success;
  AssemblePreviewData? data;
  String? message;

  AssemblePreviewResponse({this.success, this.data, this.message});

  AssemblePreviewResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null ? AssemblePreviewData.fromJson(json['data']) : null;
    message = json['message'];
  }
}

class AssemblePreviewData {
  int? batchId;
  String? batchNo;
  num? plannedQty;
  num? assembledQty;
  num? remainingQty;
  List<Stage3UsedItem>? stage3UsedItems;
  AssembleTotalRequiredMaterials? totalRequiredMaterials;

  AssemblePreviewData({
    this.batchId,
    this.batchNo,
    this.plannedQty,
    this.assembledQty,
    this.remainingQty,
    this.stage3UsedItems,
    this.totalRequiredMaterials,
  });

  AssemblePreviewData.fromJson(Map<String, dynamic> json) {
    batchId = (json['batch_id'] as num?)?.toInt();
    batchNo = json['batch_no']?.toString();
    plannedQty = json['planned_qty'] as num?;
    assembledQty = json['assembled_qty'] as num?;
    remainingQty = json['remaining_qty'] as num?;
    totalRequiredMaterials = json['total_required_materials'] != null
        ? AssembleTotalRequiredMaterials.fromJson(json['total_required_materials'])
        : null;
    if (json['stage3_used_items'] != null) {
      stage3UsedItems = <Stage3UsedItem>[];
      json['stage3_used_items'].forEach((v) {
        stage3UsedItems!.add(Stage3UsedItem.fromJson(v));
      });
    }
  }
}

class Stage3UsedItem {
  int? rawMaterialId;
  int? readyToUsedId;
  bool? isReadyToUsed;
  String? name;
  String? displayName;
  num? requiredTotal;
  num? consumeForBatch;
  num? availableTotal;
  num? shortageTotal;
  String? unit;

  Stage3UsedItem({
    this.rawMaterialId,
    this.readyToUsedId,
    this.isReadyToUsed,
    this.name,
    this.displayName,
    this.requiredTotal,
    this.consumeForBatch,
    this.availableTotal,
    this.shortageTotal,
    this.unit,
  });

  Stage3UsedItem.fromJson(Map<String, dynamic> json) {
    rawMaterialId = (json['raw_material_id'] as num?)?.toInt();
    readyToUsedId = (json['ready_to_used_id'] as num?)?.toInt();
    isReadyToUsed = json['is_ready_to_used'] == true || json['is_ready_to_used'] == 1;
    name = json['name']?.toString();
    displayName = json['display_name']?.toString();
    requiredTotal = json['required_total'] as num?;
    consumeForBatch = json['consume_for_batch'] as num?;
    availableTotal = json['available_total'] as num?;
    shortageTotal = json['shortage_total'] as num?;
    unit = json['unit']?.toString();
  }

  bool get hasShortage => (shortageTotal ?? 0) > 0;
}

class AssembleTotalRequiredMaterials {
  num? totalItems;
  num? totalShortageItems;
  bool? canProceed;

  AssembleTotalRequiredMaterials({this.totalItems, this.totalShortageItems, this.canProceed});

  AssembleTotalRequiredMaterials.fromJson(Map<String, dynamic> json) {
    totalItems = json['total_items'] as num?;
    totalShortageItems = json['total_shortage_items'] as num?;
    canProceed = json['can_proceed'] == true || json['can_proceed'] == 1;
  }
}
