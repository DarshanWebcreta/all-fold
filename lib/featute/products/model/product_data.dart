class ProductData {
  int? id;
  String? brandName;
  String? supplierName;
  String? sku;
  String? status;
  String? title;
  int? stock;
  String? image;
  String? brandId;
  String? supplierId;

  ProductData(
      {this.id,
        this.brandName,
        this.supplierName,
        this.sku,
        this.status,
        this.title,
        this.stock,
        this.image,
        this.brandId,
        this.supplierId});

  ProductData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    brandName = json['brand_name'];
    supplierName = json['supplier_name'];
    sku = json['sku'];
    status = json['status'];
    title = json['title'];
    stock = json['stock'];
    image = json['image'];
    brandId = json['brand_id'];
    supplierId = json['supplier_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['brand_name'] = brandName;
    data['supplier_name'] = supplierName;
    data['sku'] = sku;
    data['status'] = status;
    data['title'] = title;
    data['stock'] = stock;
    data['image'] = image;
    data['brand_id'] = brandId;
    data['supplier_id'] = supplierId;
    return data;
  }
}