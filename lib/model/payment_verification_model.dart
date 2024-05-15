

import 'package:mobile_pos/model/sms_subscription_plan_model.dart';

class PaymentVerificationModel {
  late String sellerName, sellerPhone, sellerID, shopName, paymentPhoneNumber, transactionId, paymentRef, verificationStatus, verificationAttemptsDate;
  late SmsSubscriptionPlanModel smsSubscriptionPlanModel;
  late dynamic paidAmount;
  String? key;
  PaymentVerificationModel({
    required this.sellerName,
    required this.sellerPhone,
    required this.sellerID,
    required this.shopName,
    required this.paymentPhoneNumber,
    required this.transactionId,
    required this.paymentRef,
    required this.paidAmount,
    required this.verificationStatus,
    required this.verificationAttemptsDate,
    required this.smsSubscriptionPlanModel,
    this.key,
  });

  PaymentVerificationModel.fromJson(Map<dynamic, dynamic> json)
      : sellerName = json['sellerName'],
        sellerPhone = json['sellerPhone'],
        shopName = json['shopName'],
        sellerID = json['sellerID'],
        paymentPhoneNumber = json['paymentPhoneNumber'],
        transactionId = json['transactionId'],
        paymentRef = json['paymentRef'],
        paidAmount = json['paidAmount'],
        verificationStatus = json['verificationStatus'],
        verificationAttemptsDate = json['verificationAttemptsDate'],
        smsSubscriptionPlanModel = SmsSubscriptionPlanModel.fromJson(json['smsSubscriptionPlanModel']);

  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
    'sellerName': sellerName,
    'sellerPhone': sellerPhone,
    'shopName': shopName,
    'sellerID': sellerID,
    'paymentPhoneNumber': paymentPhoneNumber,
    'transactionId': transactionId,
    'paymentRef': paymentRef,
    'paidAmount': paidAmount,
    'verificationStatus': verificationStatus,
    'verificationAttemptsDate': verificationAttemptsDate,
    'smsSubscriptionPlanModel': smsSubscriptionPlanModel.toJson(),
  };
}
