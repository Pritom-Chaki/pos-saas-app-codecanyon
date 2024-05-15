import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:mobile_pos/model/subscription_model.dart';
import 'package:mobile_pos/subscription.dart';

import '../currency.dart';
import '../model/subscription_plan_model.dart';

class SubscriptionRepo {
  static Future<SubscriptionModel> getSubscriptionData() async {
    DatabaseReference ref = FirebaseDatabase.instance.ref('$constUserId/Subscription');
    ref.keepSynced(true);
    final model = await ref.get();
    var data = jsonDecode(jsonEncode(model.value));
    Subscription.selectedItem = SubscriptionModel.fromJson(data).subscriptionName;
    return SubscriptionModel.fromJson(data);
  }
}


class SubscriptionPlanRepo {
  Future<List<SubscriptionPlanModel>> getAllSubscriptionPlans() async {
    List<SubscriptionPlanModel> planList = [];
    await FirebaseDatabase.instance.ref().child('Admin Panel').child('Subscription Plan').orderByKey().get().then((value) {
      for (var element in value.children) {
        planList.add(SubscriptionPlanModel.fromJson(jsonDecode(jsonEncode(element.value))));
      }
    });
    return planList;
  }
}


