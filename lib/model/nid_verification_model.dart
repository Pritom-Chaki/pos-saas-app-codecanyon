class NIDVerificationModel {
  late String sellerName, sellerPhone, sellerID, shopName, nidFrontPart, nidBackPart, verificationStatus, verificationAttemptsDate;
  String? key;
  NIDVerificationModel({
    required this.sellerName,
    required this.sellerPhone,
    required this.sellerID,
    required this.shopName,
    required this.nidBackPart,
    required this.nidFrontPart,
    required this.verificationStatus,
    required this.verificationAttemptsDate,
    this.key,
  });

  NIDVerificationModel.fromJson(Map<dynamic, dynamic> json)
      : sellerName = json['sellerName'],
        sellerPhone = json['sellerPhone'],
        shopName = json['shopName'],
        sellerID = json['sellerID'],
        nidBackPart = json['nidBackPart'],
        nidFrontPart = json['nidFrontPart'],
        verificationStatus = json['verificationStatus'],
        verificationAttemptsDate = json['verificationAttemptsDate'];

  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
    'sellerName': sellerName,
    'sellerPhone': sellerPhone,
    'shopName': shopName,
    'sellerID': sellerID,
    'nidBackPart': nidBackPart,
    'nidFrontPart': nidFrontPart,
    'verificationStatus': verificationStatus,
    'verificationAttemptsDate': verificationAttemptsDate,
  };
}