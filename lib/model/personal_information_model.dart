class PersonalInformationModel {
  PersonalInformationModel({
    this.phoneNumber,
    this.companyName,
    this.pictureUrl,
    this.businessCategory,
    this.language,
    this.countryName,
    this.saleInvoiceCounter,
    this.purchaseInvoiceCounter,
    this.dueInvoiceCounter,
    this.shopOpeningBalance,
    this.remainingShopBalance,
    this.currency,
  });

  PersonalInformationModel.fromJson(dynamic json) {
    phoneNumber = json['phoneNumber'];
    companyName = json['companyName'];
    pictureUrl = json['pictureUrl'];
    businessCategory = json['businessCategory'];
    language = json['language'];
    countryName = json['countryName'];
    saleInvoiceCounter = json['saleInvoiceCounter'];
    purchaseInvoiceCounter = json['purchaseInvoiceCounter'];
    dueInvoiceCounter = json['dueInvoiceCounter'];
    shopOpeningBalance = json['shopOpeningBalance'];
    remainingShopBalance = json['remainingShopBalance'];
    currency = json['currency'] ?? '\$';
  }

  dynamic phoneNumber;
  String? companyName;
  String? pictureUrl;
  String? businessCategory;
  String? language;
  String? countryName;
  int? saleInvoiceCounter;
  int? purchaseInvoiceCounter;
  int? dueInvoiceCounter;
  num? shopOpeningBalance;
  num? remainingShopBalance;
  String? currency;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['phoneNumber'] = phoneNumber;
    map['companyName'] = companyName;
    map['pictureUrl'] = pictureUrl;
    map['businessCategory'] = businessCategory;
    map['language'] = language;
    map['countryName'] = countryName;
    map['saleInvoiceCounter'] = saleInvoiceCounter;
    map['purchaseInvoiceCounter'] = purchaseInvoiceCounter;
    map['dueInvoiceCounter'] = dueInvoiceCounter;
    map['shopOpeningBalance'] = shopOpeningBalance;
    map['remainingShopBalance'] = remainingShopBalance;
    map['currency'] = currency;
    return map;
  }
}
