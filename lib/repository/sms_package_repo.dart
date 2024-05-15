import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:mobile_pos/model/sms_subscription_plan_model.dart';

class SMSPackageRepo {
  Future<List<SmsSubscriptionPlanModel>> getAllSMSPackage() async {
    List<SmsSubscriptionPlanModel> smsPackageList = [];
    await FirebaseDatabase.instance.ref().child('Admin Panel').child('Sms Package Plan').orderByKey().get().then((value) {
      for (var element in value.children) {
        var data = SmsSubscriptionPlanModel.fromJson(jsonDecode(jsonEncode(element.value)));
        if (data.smsPackName != 'Free') {
          smsPackageList.add(data);
        }
      }
    });
    return smsPackageList;
  }
}
