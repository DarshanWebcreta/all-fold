class BulkHistoryResponse {
  bool? success;
  BulkHistoryData? data;
  String? message;

  BulkHistoryResponse({this.success, this.data, this.message});

  BulkHistoryResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null ? BulkHistoryData.fromJson(json['data']) : null;
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

class BulkHistoryData {
  List<BulkHistoryBatch>? batches;
  PaginationInfo? pagination;

  BulkHistoryData({this.batches, this.pagination});

  BulkHistoryData.fromJson(Map<String, dynamic> json) {
    if (json['batches'] != null) {
      batches = <BulkHistoryBatch>[];
      json['batches'].forEach((v) {
        batches!.add(BulkHistoryBatch.fromJson(v));
      });
    }
    pagination = json['pagination'] != null ? PaginationInfo.fromJson(json['pagination']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (batches != null) {
      data['batches'] = batches!.map((v) => v.toJson()).toList();
    }
    if (pagination != null) {
      data['pagination'] = pagination!.toJson();
    }
    return data;
  }
}

class BulkHistoryBatch {
  int? id;
  String? batchNo;
  String? batchName;
  int? productId;
  String? productName;
  String? sku;
  double? plannedQty;
  String? status;
  String? createdBy;
  String? createdAt;

  BulkHistoryBatch({
    this.id,
    this.batchNo,
    this.batchName,
    this.productId,
    this.productName,
    this.sku,
    this.plannedQty,
    this.status,
    this.createdBy,
    this.createdAt,
  });

  BulkHistoryBatch.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    batchNo = json['batch_no'];
    batchName = json['batch_name'];
    productId = json['product_id'];
    productName = json['product_name'];
    sku = json['sku'];
    plannedQty = (json['planned_qty'] as num?)?.toDouble();
    status = json['status'];
    createdBy = json['created_by'];
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['batch_no'] = batchNo;
    data['batch_name'] = batchName;
    data['product_id'] = productId;
    data['product_name'] = productName;
    data['sku'] = sku;
    data['planned_qty'] = plannedQty;
    data['status'] = status;
    data['created_by'] = createdBy;
    data['created_at'] = createdAt;
    return data;
  }
}

class PaginationInfo {
  int? total;
  int? perPage;
  int? currentPage;
  int? lastPage;

  PaginationInfo({this.total, this.perPage, this.currentPage, this.lastPage});

  PaginationInfo.fromJson(Map<String, dynamic> json) {
    total = json['total'];
    perPage = json['per_page'];
    currentPage = json['current_page'];
    lastPage = json['last_page'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total'] = total;
    data['per_page'] = perPage;
    data['current_page'] = currentPage;
    data['last_page'] = lastPage;
    return data;
  }
}
