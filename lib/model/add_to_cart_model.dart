import 'dart:convert';

import '../Screens/tax report/tax_model.dart';

class AddToCartModel {
  AddToCartModel({
    this.uuid,
    this.productId,
    this.productName,
    required this.warehouseName,
    required this.warehouseId,
    this.unitPrice,
    this.subTotal,
    this.quantity = 1,
    this.productDetails,
    this.itemCartIndex = -1,
    this.uniqueCheck,
    this.productBrandName,
    this.stock,
    this.productPurchasePrice,
    required this.productImage,
    this.serialNumber,
    required this.taxType,
    required this.margin,
    required this.excTax,
    required this.incTax,
    required this.groupTaxName,
    required this.groupTaxRate,
    required this.subTaxes,
  });

  dynamic uuid;
  dynamic productId;
  String? productName;
  String? warehouseName;
  String? warehouseId;
  dynamic unitPrice;
  dynamic productPurchasePrice;
  dynamic subTotal;
  dynamic uniqueCheck;
  dynamic quantity = 1;
  dynamic productDetails;
  dynamic productBrandName;
  List<dynamic>? serialNumber;

  // Item store on which index of cart so we can update or delete cart easily, initially it is -1
  int itemCartIndex;
  dynamic? stock;
  late String productImage;
  late String taxType;
  late dynamic margin;
  late dynamic excTax;
  late dynamic incTax;
  late String groupTaxName;
  late dynamic groupTaxRate;
  late List<TaxModel> subTaxes;

  factory AddToCartModel.fromJson(String str) => AddToCartModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory AddToCartModel.fromMap(Map<String, dynamic> json) => AddToCartModel(
        uuid: json["uuid"],
        productId: json["product_id"],
        productName: json["product_name"],
        warehouseName: json["warehouseName"],
        warehouseId: json["warehouseId"] ,
        productBrandName: json["product_brand_name"],
        unitPrice: json["unit_price"]?? '0',
        subTotal: json["sub_total"] ?? '0',
        uniqueCheck: json["unique_check"],
        quantity: json["quantity"]?? '0',
        productImage: json["productImage"] ??
            'https://firebasestorage.googleapis.com/v0/b/maanpos.appspot.com/o/Product%20No%20Image%2Fno-image-found-360x250.png?alt=media&token=9299964e-22b3-4d88-924e-5eeb285ae672',
        productDetails: json["product_details"],
        itemCartIndex: json["item_cart_index"],
        stock: json["stock"],
        productPurchasePrice: json["productPurchasePrice"],
        serialNumber: json["serialNumber"],
        taxType: json['taxType'] ?? '',
        margin: json['margin'] ?? '0',
        excTax: json['excTax'] ?? '0',
        incTax: json['incTax'] ?? '0',
        groupTaxName: json['groupTaxName'] ?? '',
        groupTaxRate: json['groupTaxRate'] ?? '0',
        subTaxes: json['subTax'] != null ? List<TaxModel>.from(json['subTax'].map((x) => TaxModel.fromJson(x))) : [],
      );

  Map<String, dynamic> toMap() => {
        "uuid": uuid,
        "product_id": productId,
        "product_name": productName,
        "warehouseName": warehouseName,
        "warehouseId": warehouseId,
        "product_brand_name": productBrandName,
        "unit_price": unitPrice,
        "sub_total": subTotal,
        "unique_check": uniqueCheck,
        "quantity": quantity == 0 ? null : quantity,
        "item_cart_index": itemCartIndex,
        "stock": stock,
        "productPurchasePrice": productPurchasePrice,
        // ignore: prefer_null_aware_operators
        "product_details": productDetails == null ? null : productDetails.toJson(),
        'productImage': productImage,
        'serialNumber': serialNumber?.map((e) => e).toList(),
        'taxType': taxType,
        'margin': margin,
        'excTax': excTax,
        'incTax': incTax,
        'groupTaxName': groupTaxName,
        'groupTaxRate': groupTaxRate,
        'subTax': subTaxes.map((e) => e.toJson()).toList(),
      };
}
