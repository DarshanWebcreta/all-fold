class ActiveBatchesResponse {
  bool? success;
  ActiveBatchesData? data;
  String? message;

  ActiveBatchesResponse({this.success, this.data, this.message});

  ActiveBatchesResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null ? ActiveBatchesData.fromJson(json['data']) : null;
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['message'] = message;
    return data;
  }
}

class ActiveBatchesData {
  List<ApiBatch>? batches;

  ActiveBatchesData({this.batches});

  ActiveBatchesData.fromJson(Map<String, dynamic> json) {
    if (json['batches'] != null) {
      batches = <ApiBatch>[];
      json['batches'].forEach((v) {
        batches!.add(ApiBatch.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (batches != null) {
      data['batches'] = batches!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ApiBatch {
  int? batchId;
  String? batchNo;
  String? batchName;
  int? productId;
  String? productName;
  String? sku;
  int? plannedQty;
  String? status;
  bool? isActionableForCurrentUser;
  List<ApiComponent>? components;

  ApiBatch({
    this.batchId,
    this.batchNo,
    this.batchName,
    this.productId,
    this.productName,
    this.sku,
    this.plannedQty,
    this.status,
    this.isActionableForCurrentUser,
    this.components,
  });

  ApiBatch.fromJson(Map<String, dynamic> json) {
    batchId = json['batch_id'];
    batchNo = json['batch_no'];
    batchName = json['batch_name'];
    productId = json['product_id'];
    productName = json['product_name'];
    sku = json['sku'];
    plannedQty = json['planned_qty'];
    status = json['status'];
    isActionableForCurrentUser = json['is_actionable_for_current_user'];
    if (json['components'] != null) {
      components = <ApiComponent>[];
      json['components'].forEach((v) {
        components!.add(ApiComponent.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['batch_id'] = batchId;
    data['batch_no'] = batchNo;
    data['batch_name'] = batchName;
    data['product_id'] = productId;
    data['product_name'] = productName;
    data['sku'] = sku;
    data['planned_qty'] = plannedQty;
    data['status'] = status;
    data['is_actionable_for_current_user'] = isActionableForCurrentUser;
    if (components != null) {
      data['components'] = components!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ApiComponent {
  int? componentId;
  String? componentName;
  int? qtyPerPc;
  int? totalNeeded;
  int? currentStageId;
  String? currentStageLabel;
  int? nextStageId;
  String? nextStageLabel;
  bool? isActionableForCurrentUser;
  String? jobStatus;
  List<PipelineStage>? pipelineStages;

  ApiComponent({
    this.componentId,
    this.componentName,
    this.qtyPerPc,
    this.totalNeeded,
    this.currentStageId,
    this.currentStageLabel,
    this.nextStageId,
    this.nextStageLabel,
    this.isActionableForCurrentUser,
    this.jobStatus,
    this.pipelineStages,
  });

  ApiComponent.fromJson(Map<String, dynamic> json) {
    componentId = json['component_id'];
    componentName = json['component_name'];
    qtyPerPc = json['qty_per_pc'];
    totalNeeded = json['total_needed'];
    currentStageId = json['current_stage_id'];
    currentStageLabel = json['current_stage_label'];
    nextStageId = json['next_stage_id'];
    nextStageLabel = json['next_stage_label'];
    isActionableForCurrentUser = json['is_actionable_for_current_user'];
    jobStatus = json['job_status'];
    if (json['pipeline_stages'] != null) {
      pipelineStages = <PipelineStage>[];
      json['pipeline_stages'].forEach((v) {
        pipelineStages!.add(PipelineStage.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['component_id'] = componentId;
    data['component_name'] = componentName;
    data['qty_per_pc'] = qtyPerPc;
    data['total_needed'] = totalNeeded;
    data['current_stage_id'] = currentStageId;
    data['current_stage_label'] = currentStageLabel;
    data['next_stage_id'] = nextStageId;
    data['next_stage_label'] = nextStageLabel;
    data['is_actionable_for_current_user'] = isActionableForCurrentUser;
    data['job_status'] = jobStatus;
    if (pipelineStages != null) {
      data['pipeline_stages'] = pipelineStages!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class PipelineStage {
  int? stageId;
  String? stageName;
  double? stock;
  double? reserved;
  double? completed;
  double? pending;

  PipelineStage({this.stageId, this.stageName, this.stock, this.reserved, this.completed, this.pending});

  PipelineStage.fromJson(Map<String, dynamic> json) {
    stageId = json['stage_id'];
    stageName = json['stage_name'];
    stock = (json['stock'] as num?)?.toDouble();
    reserved = (json['reserved'] as num?)?.toDouble();
    completed = (json['completed'] as num?)?.toDouble();
    pending = (json['pending'] as num?)?.toDouble();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['stage_id'] = stageId;
    data['stage_name'] = stageName;
    data['stock'] = stock;
    data['reserved'] = reserved;
    data['completed'] = completed;
    data['pending'] = pending;
    return data;
  }
}
