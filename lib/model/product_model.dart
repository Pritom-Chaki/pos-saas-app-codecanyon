class ProductModel {
  late String productName,
      productCategory,
      size,
      color,
      weight,
      capacity,
      type,
      brandName,
      productCode,
      productStock,
      productUnit,
      productSalePrice,
      productPurchasePrice,
      productDiscount,
      productWholeSalePrice,
      productDealerPrice,
      productManufacturer,
      warehouseName,
      warehouseId,
      productPicture;
  String? expiringDate, manufacturingDate;
  late int lowerStockAlert;
  List<String> serialNumber = [];

  ProductModel({
    required this.productName,
    required this.productCategory,
    required this.size,
    required this.color,
    required this.weight,
    required this.capacity,
    required this.type,
    required this.brandName,
    required this.productCode,
    required this.productStock,
    required this.productUnit,
    required this.productSalePrice,
    required this.productPurchasePrice,
    required this.productDiscount,
    required this.productWholeSalePrice,
    required this.productDealerPrice,
    required this.productManufacturer,
    required this.warehouseName,
    required this.warehouseId,
    required this.productPicture,
    required this.serialNumber,
    this.expiringDate,
    required this.lowerStockAlert,
    this.manufacturingDate,
  });

  ProductModel.fromJson(Map<dynamic, dynamic> json) {
    productName = json['productName'] as String;
    productCategory = json['productCategory'].toString();
    size = json['size'].toString();
    color = json['color'].toString();
    weight = json['weight'].toString();
    capacity = json['capacity'].toString();
    type = json['type'].toString();
    brandName = json['brandName'].toString();
    productCode = json['productCode'].toString();
    productStock = json['productStock'].toString();
    productUnit = json['productUnit'].toString();
    productSalePrice = json['productSalePrice'].toString();
    productPurchasePrice = json['productPurchasePrice'].toString();
    productDiscount = json['productDiscount'].toString();
    productWholeSalePrice = json['productWholeSalePrice'].toString();
    productDealerPrice = json['productDealerPrice'].toString();
    productManufacturer = json['productManufacturer'].toString();
    warehouseName = json['warehouseName'].toString();
    warehouseId = json['warehouseId'].toString();
    productPicture = json['productPicture'].toString();
    if (json['serialNumber'] != null) {
      serialNumber = <String>[];
      json['serialNumber'].forEach((v) {
        serialNumber.add(v);
      });
    }
    expiringDate = json['expiringDate'];
    manufacturingDate = json['manufacturingDate'];
    lowerStockAlert = json['lowerStockAlert'] ?? 5;
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'productName': productName,
        'productCategory': productCategory,
        'size': size,
        'color': color,
        'weight': weight,
        'capacity': capacity,
        'type': type,
        'brandName': brandName,
        'productCode': productCode,
        'productStock': productStock,
        'productUnit': productUnit,
        'productSalePrice': productSalePrice,
        'productPurchasePrice': productPurchasePrice,
        'productDiscount': productDiscount,
        'productWholeSalePrice': productWholeSalePrice,
        'productDealerPrice': productDealerPrice,
        'productManufacturer': productManufacturer,
        'warehouseName': warehouseName,
        'warehouseId': warehouseId,
        'productPicture': productPicture,
        'serialNumber': serialNumber.map((e) => e).toList(),
        'manufacturingDate': manufacturingDate,
        'expiringDate': expiringDate,
        'lowerStockAlert': lowerStockAlert,
      };
}
