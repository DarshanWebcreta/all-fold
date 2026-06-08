import 'package:all_fold/featute/bulk_execution/model/bulk_history_model.dart';

class BatchMovementHistoryResponse {
  bool? success;
  BatchMovementData? data;
  String? message;

  BatchMovementHistoryResponse({this.success, this.data, this.message});

  BatchMovementHistoryResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null ? BatchMovementData.fromJson(json['data']) : null;
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

class BatchMovementData {
  List<BatchMovement>? movements;
  PaginationInfo? pagination;

  BatchMovementData({this.movements, this.pagination});

  BatchMovementData.fromJson(Map<String, dynamic> json) {
    if (json['movements'] != null) {
      movements = <BatchMovement>[];
      json['movements'].forEach((v) {
        movements!.add(BatchMovement.fromJson(v));
      });
    }
    pagination = json['pagination'] != null ? PaginationInfo.fromJson(json['pagination']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (movements != null) {
      data['movements'] = movements!.map((v) => v.toJson()).toList();
    }
    if (pagination != null) {
      data['pagination'] = pagination!.toJson();
    }
    return data;
  }
}

class BatchMovement {
  int? id;
  String? movementNo;
  int? jobId;
  String? componentName;
  String? fromStage;
  String? toStage;
  String? movementType;
  double? quantity;
  double? weight;
  String? remarks;
  String? creatorName;
  String? createdAt;

  BatchMovement({
    this.id,
    this.movementNo,
    this.jobId,
    this.componentName,
    this.fromStage,
    this.toStage,
    this.movementType,
    this.quantity,
    this.weight,
    this.remarks,
    this.creatorName,
    this.createdAt,
  });

  BatchMovement.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    movementNo = json['movement_no'];
    jobId = json['job_id'];
    componentName = json['component_name'];
    fromStage = json['from_stage'];
    toStage = json['to_stage'];
    movementType = json['movement_type'];
    quantity = (json['quantity'] as num?)?.toDouble();
    weight = (json['weight'] as num?)?.toDouble();
    remarks = json['remarks'];
    creatorName = json['creator_name'];
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['movement_no'] = movementNo;
    data['job_id'] = jobId;
    data['component_name'] = componentName;
    data['from_stage'] = fromStage;
    data['to_stage'] = toStage;
    data['movement_type'] = movementType;
    data['quantity'] = quantity;
    data['weight'] = weight;
    data['remarks'] = remarks;
    data['creator_name'] = creatorName;
    data['created_at'] = createdAt;
    return data;
  }
}
