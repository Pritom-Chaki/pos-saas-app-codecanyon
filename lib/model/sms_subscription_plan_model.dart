class SmsSubscriptionPlanModel {
  late String smsPackName;
  late dynamic smsPackPrice;
  late dynamic smsPackOfferPrice;
  late int numberOfSMS;
  late int smsValidityInDay;

  SmsSubscriptionPlanModel({
    required this.smsPackName,
    required this.smsPackPrice,
    required this.smsPackOfferPrice,
    required this.numberOfSMS,
    required this.smsValidityInDay,
  });
  SmsSubscriptionPlanModel.fromJson(Map<dynamic, dynamic> json)
      : smsPackName = json['smsPackName'],
        smsPackPrice = json['smsPackPrice'],
        smsPackOfferPrice = json['smsPackOfferPrice'],
        numberOfSMS = json['numberOfSMS'],
        smsValidityInDay = json['smsValidityInDay'];

  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
    'smsPackName': smsPackName,
    'smsPackPrice': smsPackPrice,
    'smsPackOfferPrice': smsPackOfferPrice,
    'numberOfSMS': numberOfSMS,
    'smsValidityInDay': smsValidityInDay,
  };
}
