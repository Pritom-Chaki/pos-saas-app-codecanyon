class InvoiceModel {
  InvoiceModel({
    this.phoneNumber,
    this.companyName,
    this.pictureUrl,
    this.emailAddress,
    this.address
  });

  InvoiceModel.fromJson(dynamic json) {
    phoneNumber = json['phoneNumber'] ?? '';
    companyName = json['companyName'] ??'';
    pictureUrl = json['pictureUrl']??'';
    emailAddress = json['emailAddress']??'';
    address = json['address']??'';
  }
  dynamic phoneNumber;
  String? companyName;
  String? pictureUrl;
  String? emailAddress;
  String? address;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['phoneNumber'] = phoneNumber;
    map['companyName'] = companyName;
    map['pictureUrl'] = pictureUrl;
    map['emailAddress'] = emailAddress;
    map['address'] = address;
    return map;
  }
}