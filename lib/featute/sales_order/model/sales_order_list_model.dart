class SalesOrderListResponse {
  bool? success;
  SalesOrderListData? data;
  String? message;

  SalesOrderListResponse({this.success, this.data, this.message});

  SalesOrderListResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null ? SalesOrderListData.fromJson(json['data']) : null;
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

class SalesOrderListData {
  int? currentPage;
  List<SalesOrder>? data;
  int? total;
  int? lastPage;
  int? perPage;

  SalesOrderListData({this.currentPage, this.data, this.total, this.lastPage, this.perPage});

  SalesOrderListData.fromJson(Map<String, dynamic> json) {
    currentPage = (json['current_page'] as num?)?.toInt();
    total = (json['total'] as num?)?.toInt();
    lastPage = (json['last_page'] as num?)?.toInt();
    perPage = (json['per_page'] as num?)?.toInt();
    if (json['data'] != null) {
      data = <SalesOrder>[];
      json['data'].forEach((v) {
        data!.add(SalesOrder.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['current_page'] = currentPage;
    data['total'] = total;
    data['last_page'] = lastPage;
    data['per_page'] = perPage;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class SalesOrder {
  int? id;
  String? orderNo;
  String? orderDate;
  String? expectedDeliveryDate;
  String? orderStatus;
  String? orderStatusLabel;
  num? grandTotal;
  SalesOrderSupplier? supplier;
  num? totalOrderedQty;
  num? totalDispatchedQty;
  num? remainingDispatchQty;
  bool? canDispatch;
  String? dispatchStatus;
  List<SalesOrderItem>? items;

  SalesOrder({
    this.id,
    this.orderNo,
    this.orderDate,
    this.expectedDeliveryDate,
    this.orderStatus,
    this.orderStatusLabel,
    this.grandTotal,
    this.supplier,
    this.totalOrderedQty,
    this.totalDispatchedQty,
    this.remainingDispatchQty,
    this.canDispatch,
    this.dispatchStatus,
    this.items,
  });

  SalesOrder.fromJson(Map<String, dynamic> json) {
    id = (json['id'] as num?)?.toInt();
    orderNo = json['order_no']?.toString();
    orderDate = json['order_date']?.toString();
    expectedDeliveryDate = json['expected_delivery_date']?.toString();
    orderStatus = json['order_status']?.toString();
    orderStatusLabel = json['order_status_label']?.toString();
    grandTotal = json['grand_total'] as num?;
    supplier = json['supplier'] != null ? SalesOrderSupplier.fromJson(json['supplier']) : null;
    totalOrderedQty = json['total_ordered_qty'] as num?;
    totalDispatchedQty = json['total_dispatched_qty'] as num?;
    remainingDispatchQty = json['remaining_dispatch_qty'] as num?;
    canDispatch = json['can_dispatch'] == true || json['can_dispatch'] == 1;
    dispatchStatus = json['dispatch_status']?.toString();
    if (json['items'] != null) {
      items = <SalesOrderItem>[];
      json['items'].forEach((v) {
        items!.add(SalesOrderItem.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['order_no'] = orderNo;
    data['order_date'] = orderDate;
    data['expected_delivery_date'] = expectedDeliveryDate;
    data['order_status'] = orderStatus;
    data['order_status_label'] = orderStatusLabel;
    data['grand_total'] = grandTotal;
    if (supplier != null) data['supplier'] = supplier!.toJson();
    data['total_ordered_qty'] = totalOrderedQty;
    data['total_dispatched_qty'] = totalDispatchedQty;
    data['remaining_dispatch_qty'] = remainingDispatchQty;
    data['can_dispatch'] = canDispatch;
    data['dispatch_status'] = dispatchStatus;
    if (items != null) data['items'] = items!.map((v) => v.toJson()).toList();
    return data;
  }

  /// Returns a readable status badge label
  String get statusLabel => orderStatusLabel ?? _formatStatus(orderStatus);

  String _formatStatus(String? s) {
    if (s == null) return 'Unknown';
    return s[0].toUpperCase() + s.substring(1).replaceAll('_', ' ');
  }
}

class SalesOrderSupplier {
  int? id;
  String? name;
  String? code;

  SalesOrderSupplier({this.id, this.name, this.code});

  SalesOrderSupplier.fromJson(Map<String, dynamic> json) {
    id = (json['id'] as num?)?.toInt();
    name = json['name']?.toString();
    code = json['code']?.toString();
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'code': code};
}

class SalesOrderItem {
  int? id;
  int? productId;
  String? productName;
  String? sku;
  num? quantity;
  num? qtyDispatched;
  num? qtyRemaining;
  num? unitPrice;
  num? lineTotal;

  SalesOrderItem({
    this.id,
    this.productId,
    this.productName,
    this.sku,
    this.quantity,
    this.qtyDispatched,
    this.qtyRemaining,
    this.unitPrice,
    this.lineTotal,
  });

  SalesOrderItem.fromJson(Map<String, dynamic> json) {
    id = (json['id'] as num?)?.toInt();
    productId = (json['product_id'] as num?)?.toInt();
    productName = json['product_name']?.toString();
    sku = json['sku']?.toString();
    quantity = json['quantity'] as num?;
    qtyDispatched = json['qty_dispatched'] as num?;
    qtyRemaining = json['qty_remaining'] as num?;
    unitPrice = json['unit_price'] as num?;
    lineTotal = json['line_total'] as num?;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'product_id': productId,
        'product_name': productName,
        'sku': sku,
        'quantity': quantity,
        'qty_dispatched': qtyDispatched,
        'qty_remaining': qtyRemaining,
        'unit_price': unitPrice,
        'line_total': lineTotal,
      };
}
