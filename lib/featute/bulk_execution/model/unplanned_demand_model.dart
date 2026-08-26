class UnplannedDemandResponse {
  bool? success;
  UnplannedDemandData? data;
  String? message;

  UnplannedDemandResponse({this.success, this.data, this.message});

  UnplannedDemandResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null ? UnplannedDemandData.fromJson(json['data']) : null;
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

class UnplannedDemandData {
  List<UnplannedProduct>? products;

  UnplannedDemandData({this.products});

  UnplannedDemandData.fromJson(Map<String, dynamic> json) {
    if (json['products'] != null) {
      products = <UnplannedProduct>[];
      json['products'].forEach((v) {
        products!.add(UnplannedProduct.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (products != null) {
      data['products'] = products!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class UnplannedProduct {
  int? productId;
  String? productName;
  String? sku;
  int? totalOrdered;
  int? totalReserved;
  int? pendingQty;
  int? readyStock;
  List<UnplannedComponent>? components;

  UnplannedProduct({
    this.productId,
    this.productName,
    this.sku,
    this.totalOrdered,
    this.totalReserved,
    this.pendingQty,
    this.readyStock,
    this.components,
  });

  UnplannedProduct.fromJson(Map<String, dynamic> json) {
    productId = (json['product_id'] as num?)?.toInt();
    productName = json['product_name']?.toString();
    sku = json['sku']?.toString();
    totalOrdered = (json['total_ordered'] as num?)?.toInt();
    totalReserved = (json['total_reserved'] as num?)?.toInt();
    pendingQty = (json['pending_qty'] as num?)?.toInt();
    readyStock = (json['ready_stock'] as num?)?.toInt();
    if (json['components'] != null) {
      components = <UnplannedComponent>[];
      json['components'].forEach((v) {
        components!.add(UnplannedComponent.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['product_id'] = productId;
    data['product_name'] = productName;
    data['sku'] = sku;
    data['total_ordered'] = totalOrdered;
    
    data['total_reserved'] = totalReserved;
    data['pending_qty'] = pendingQty;
    data['ready_stock'] = readyStock;
    if (components != null) {
      data['components'] = components!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class UnplannedComponent {
  int? id;
  String? name;
  int? qtyPerPc;
  int? totalNeeded;
  Map<String, int>? stageStock;
  num? rawStockKg;
  String? rawName;

  UnplannedComponent({
    this.id,
    this.name,
    this.qtyPerPc,
    this.totalNeeded,
    this.stageStock,
    this.rawStockKg,
    this.rawName,
  });

  UnplannedComponent.fromJson(Map<String, dynamic> json) {
    id = (json['id'] as num?)?.toInt();
    name = json['name']?.toString();
    qtyPerPc = (json['qty_per_pc'] as num?)?.toInt();
    totalNeeded = (json['total_needed'] as num?)?.toInt();
    if (json['stage_stock'] != null) {
      stageStock = {};
      json['stage_stock'].forEach((k, v) {
        stageStock![k] = (v as num?)?.toInt() ?? int.tryParse(v.toString()) ?? 0;
      });
    }
    rawStockKg = (json['raw_stock_kg'] as num?);
    rawName = json['raw_name']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['qty_per_pc'] = qtyPerPc;
    data['total_needed'] = totalNeeded;
    if (stageStock != null) {
      data['stage_stock'] = stageStock;
    }
    data['raw_stock_kg'] = rawStockKg;
    data['raw_name'] = rawName;
    return data;
  }
}
