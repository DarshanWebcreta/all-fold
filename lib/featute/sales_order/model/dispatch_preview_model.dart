class DispatchPreviewResponse {
  bool? success;
  DispatchPreviewData? data;
  String? message;

  DispatchPreviewResponse({this.success, this.data, this.message});

  DispatchPreviewResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null ? DispatchPreviewData.fromJson(json['data']) : null;
    message = json['message'];
  }
}

class DispatchPreviewData {
  int? orderId;
  String? orderNo;
  String? customerName;
  DispatchSupplierInfo? supplier;
  DispatchShippingInfo? shipping;
  List<ShippingAddress>? shippingAddresses;
  dynamic selectedShippingId;
  List<DispatchPreviewItem>? items;
  num? totalUnits;
  int? skuCount;
  bool? isPartialAllowed;

  DispatchPreviewData({
    this.orderId,
    this.orderNo,
    this.customerName,
    this.supplier,
    this.shipping,
    this.shippingAddresses,
    this.selectedShippingId,
    this.items,
    this.totalUnits,
    this.skuCount,
    this.isPartialAllowed,
  });

  DispatchPreviewData.fromJson(Map<String, dynamic> json) {
    orderId = (json['order_id'] as num?)?.toInt();
    orderNo = json['order_no']?.toString();
    customerName = json['customer_name']?.toString();
    supplier = json['supplier'] != null ? DispatchSupplierInfo.fromJson(json['supplier']) : null;
    shipping = json['shipping'] != null ? DispatchShippingInfo.fromJson(json['shipping']) : null;
    selectedShippingId = json['selected_shipping_id'];
    totalUnits = json['total_units'] as num?;
    skuCount = (json['sku_count'] as num?)?.toInt();
    isPartialAllowed = json['is_partial_allowed'] == true || json['is_partial_allowed'] == 1;

    if (json['shipping_addresses'] != null) {
      shippingAddresses = <ShippingAddress>[];
      json['shipping_addresses'].forEach((v) {
        shippingAddresses!.add(ShippingAddress.fromJson(v));
      });
    }

    if (json['items'] != null) {
      items = <DispatchPreviewItem>[];
      json['items'].forEach((v) {
        items!.add(DispatchPreviewItem.fromJson(v));
      });
    }
  }
}

class DispatchSupplierInfo {
  String? code;
  String? name;
  String? address;
  String? phone;

  DispatchSupplierInfo({this.code, this.name, this.address, this.phone});

  DispatchSupplierInfo.fromJson(Map<String, dynamic> json) {
    code = json['code']?.toString();
    name = json['name']?.toString();
    address = json['address']?.toString();
    phone = json['phone']?.toString();
  }
}

class DispatchShippingInfo {
  dynamic id;
  String? label;
  String? address;

  DispatchShippingInfo({this.id, this.label, this.address});

  DispatchShippingInfo.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    label = json['label']?.toString();
    address = json['address']?.toString();
  }
}

class ShippingAddress {
  dynamic id;
  String? label;
  String? address;
  String? contactName;
  String? phone;

  ShippingAddress({this.id, this.label, this.address, this.contactName, this.phone});

  ShippingAddress.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    label = json['label']?.toString();
    address = json['address']?.toString();
    contactName = json['contact_name']?.toString();
    phone = json['phone']?.toString();
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'address': address,
        'contact_name': contactName,
        'phone': phone,
      };
}

class DispatchPreviewItem {
  int? orderItemId;
  String? productName;
  String? sku;
  num? quantity;
  num? qtyDispatched;
  num? qtyRemaining;
  num? qtyReady;
  num? qtyDispatchDefault;

  DispatchPreviewItem({
    this.orderItemId,
    this.productName,
    this.sku,
    this.quantity,
    this.qtyDispatched,
    this.qtyRemaining,
    this.qtyReady,
    this.qtyDispatchDefault,
  });

  DispatchPreviewItem.fromJson(Map<String, dynamic> json) {
    orderItemId = (json['order_item_id'] as num?)?.toInt();
    productName = json['product_name']?.toString();
    sku = json['sku']?.toString();
    quantity = json['quantity'] as num?;
    qtyDispatched = json['qty_dispatched'] as num?;
    qtyRemaining = json['qty_remaining'] as num?;
    qtyReady = json['qty_ready'] as num?;
    qtyDispatchDefault = json['qty_dispatch_default'] as num?;
  }

  Map<String, dynamic> toJson() => {
        'order_item_id': orderItemId,
        'product_name': productName,
        'sku': sku,
        'quantity': quantity,
        'qty_dispatched': qtyDispatched,
        'qty_remaining': qtyRemaining,
        'qty_ready': qtyReady,
        'qty_dispatch_default': qtyDispatchDefault,
      };
}

// ─── Dispatch Execution Response ───────────────────────────────────────────

class DispatchResponse {
  bool? success;
  DispatchResponseData? data;
  String? message;

  DispatchResponse({this.success, this.data, this.message});

  DispatchResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null ? DispatchResponseData.fromJson(json['data']) : null;
    message = json['message'];
  }
}

class DispatchResponseData {
  String? dispatchNo;
  bool? partial;
  DispatchedOrderRef? salesOrder;

  DispatchResponseData({this.dispatchNo, this.partial, this.salesOrder});

  DispatchResponseData.fromJson(Map<String, dynamic> json) {
    dispatchNo = json['dispatch_no']?.toString();
    partial = json['partial'] == true || json['partial'] == 1;
    salesOrder = json['sales_order'] != null ? DispatchedOrderRef.fromJson(json['sales_order']) : null;
  }
}

class DispatchedOrderRef {
  int? id;
  String? orderNo;
  String? orderStatus;

  DispatchedOrderRef({this.id, this.orderNo, this.orderStatus});

  DispatchedOrderRef.fromJson(Map<String, dynamic> json) {
    id = (json['id'] as num?)?.toInt();
    orderNo = json['order_no']?.toString();
    orderStatus = json['order_status']?.toString();
  }
}

// ─── Dispatch Item Payload ──────────────────────────────────────────────────

class DispatchItemPayload {
  final int orderItemId;
  num quantity;

  DispatchItemPayload({required this.orderItemId, required this.quantity});

  Map<String, dynamic> toJson() => {
        'order_item_id': orderItemId,
        'quantity': quantity,
      };
}
