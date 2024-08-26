class SellerInfoModel {
  SellerInfoModel({
    this.phoneNumber,
    this.companyName,
    this.pictureUrl,
    this.businessCategory,
    this.language,
    this.countryName,
    this.userID,
    this.subscriptionName,
    this.subscriptionDate,
    this.subscriptionMethod,
    this.userRegistrationDate,
    this.email,
    required this.gst,
  });

  SellerInfoModel.fromJson(dynamic json) {
    phoneNumber = json['phoneNumber'];
    companyName = json['companyName'];
    pictureUrl = json['pictureUrl'];
    businessCategory = json['businessCategory'];
    language = json['language'];
    countryName = json['countryName'];
    userID = json['userId'];
    subscriptionName = json['subscriptionName'];
    subscriptionDate = json['subscriptionDate'];
    userRegistrationDate = json['userRegistrationDate'];
    subscriptionMethod = json['subscriptionMethod'];
    email = json['email'];
    gst = json['gst'];
  }
  dynamic phoneNumber;
  String? companyName;
  String? pictureUrl;
  String? businessCategory;
  String? language;
  String? countryName;
  String? userID;
  String? subscriptionName;
  String? subscriptionDate;
  String? userRegistrationDate;
  String? subscriptionMethod;
  String? email;
  late String gst;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['phoneNumber'] = phoneNumber;
    map['companyName'] = companyName;
    map['pictureUrl'] = pictureUrl;
    map['businessCategory'] = businessCategory;
    map['language'] = language;
    map['countryName'] = countryName;
    map['userId'] = userID;
    map['subscriptionName'] = subscriptionName;
    map['subscriptionDate'] = subscriptionDate;
    map['userRegistrationDate'] = userRegistrationDate;
    map['subscriptionMethod'] = subscriptionMethod;
    map['email'] = email;
    map['gst'] = gst;
    return map;
  }
}
