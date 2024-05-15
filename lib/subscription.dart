// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import 'package:nb_utils/nb_utils.dart';

import 'Screens/subscription/package_screen.dart';
import 'currency.dart';
import 'model/subscription_model.dart';
import 'model/subscription_plan_model.dart';

class Subscription {
  static List<SubscriptionPlanModel> subscriptionPlan = [];

  static SubscriptionModel freeSubscriptionModel = SubscriptionModel(
    dueNumber: 0,
    duration: 0,
    partiesNumber: 0,
    products: 0,
    purchaseNumber: 0,
    saleNumber: 0,
    subscriptionDate: DateTime.now().toString(),
    subscriptionName: 'Free',
  );
  static String selectedItem = 'Year';

  static bool isExpiringInFiveDays = false;
  static bool isExpiringInOneDays = false;
  static Map<String, Map<String, String>> subscriptionPlansService = {
    'Free': {
      'Sales': '50',
      'Purchase': '50',
      'Due Collection': '50',
      'Parties': '50',
      'Products': '50',
      'Duration': '30',
    },
    'Month': {
      'Sales': 'unlimited',
      'Purchase': 'unlimited',
      'Due Collection': 'unlimited',
      'Parties': 'unlimited',
      'Products': 'unlimited',
      'Duration': '30',
    },
    'Year': {
      'Sales': 'unlimited',
      'Purchase': 'unlimited',
      'Due Collection': 'unlimited',
      'Parties': 'unlimited',
      'Products': 'unlimited',
      'Duration': '365',
    },
    'Lifetime': {
      'Sales': 'unlimited',
      'Purchase': 'unlimited',
      'Due Collection': 'unlimited',
      'Parties': 'unlimited',
      'Products': 'unlimited',
      'Duration': 'unlimited',
    },
  };
  static Map<String, Map<String, double>> subscriptionAmounts = {
    'Free': {
      'Amount': 0,
    },
    'Month': {
      'Amount': 9.99,
    },
    'Year': {
      'Amount': 99.99,
    },
    'Lifetime': {
      'Amount': 999.99,
    },
  };

  static SubscriptionModel subscriptionModel = SubscriptionModel(
    subscriptionName: 'Free',
    subscriptionDate: DateTime.now().toString(),
    saleNumber: int.parse(Subscription.subscriptionPlansService['Free']!['Sales']!),
    purchaseNumber: int.parse(Subscription.subscriptionPlansService['Free']!['Purchase']!),
    partiesNumber: int.parse(Subscription.subscriptionPlansService['Free']!['Parties']!),
    dueNumber: int.parse(Subscription.subscriptionPlansService['Free']!['Due Collection']!),
    duration: 30,
    products: int.parse(Subscription.subscriptionPlansService['Free']!['Products']!),
  );
  static late SubscriptionModel dataModel;
  static late String subscriptionName;
  static late int remainingSales;
  static late int remainingPurchase;
  static late int remainingParties;
  static late int remainingDue;
  static late int remainingProducts;
  static late Duration remainingTime;

  static Future<void> getUserLimitsData({required BuildContext context, required bool wannaShowMsg}) async {
    final prefs = await SharedPreferences.getInstance();

    DatabaseReference ref = FirebaseDatabase.instance.ref('$constUserId/Subscription');
    final model = await ref.get();
    var data = jsonDecode(jsonEncode(model.value));
    selectedItem = SubscriptionModel.fromJson(data).subscriptionName;
    dataModel = SubscriptionModel.fromJson(data);
    remainingTime = DateTime.parse(dataModel.subscriptionDate).difference(DateTime.now());

    subscriptionName = dataModel.subscriptionName;
    remainingSales = dataModel.saleNumber;
    remainingPurchase = dataModel.purchaseNumber;
    remainingParties = dataModel.partiesNumber;
    remainingDue = dataModel.dueNumber;
    remainingProducts = dataModel.products;
    if (subscriptionName != 'Lifetime' && wannaShowMsg) {
      if (remainingTime.inHours.abs().isBetween((dataModel.duration * 24) - 24, dataModel.duration * 24)) {
        await prefs.setBool('isFiveDayRemainderShown', false);
        isExpiringInOneDays = true;
        isExpiringInFiveDays = false;
      } else if (remainingTime.inHours.abs().isBetween((dataModel.duration * 24) - 120, dataModel.duration * 24)) {
        isExpiringInFiveDays = true;
        isExpiringInOneDays = false;
      }

      final bool isFiveDayRemainderShown = prefs.getBool('isFiveDayRemainderShown') ?? false;

      if (isExpiringInFiveDays && isFiveDayRemainderShown == false) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return Dialog(
              child: SizedBox(
                height: 200,
                width: 200,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      lang.S.of(context).yourPackageWillExpireinDay,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: () async {
                        await prefs.setBool('isFiveDayRemainderShown', true);
                        Navigator.pop(context);
                      },
                      child: Text(
                        lang.S.of(context).cacel,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }
      if (isExpiringInOneDays) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return Dialog(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: SizedBox(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        lang.S.of(context).YourPackageWillExpireTodayPleasePurchaseagain,
                        style: const TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      Column(
                        children: [
                          TextButton(
                            onPressed: () {
                              const PackageScreen().launch(context);
                            },
                            child: Text(lang.S.of(context).purchase),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text(
                              lang.S.of(context).cacel,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }
    }
  }

  static Future<bool> subscriptionChecker({
    required String item,
  }) async {
    final DatabaseReference subscriptionRef = FirebaseDatabase.instance.ref().child(constUserId).child('Subscription');

    if (subscriptionName == 'Free') {
      if (remainingTime.inHours.abs() > 720) {
        await subscriptionRef.set(subscriptionModel.toJson());
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isFiveDayRemainderShown', true);
      } else if (item == 'Sales' && remainingSales <= 0) {
        return false;
      } else if (item == 'Parties' && remainingParties <= 0) {
        return false;
      } else if (item == 'Purchase' && remainingPurchase <= 0) {
        return false;
      } else if (item == 'Products' && remainingProducts <= 0) {
        return false;
      } else if (item == 'Due List' && remainingDue <= 0) {
        return false;
      }
    } else if (subscriptionName == 'Month') {
      if (remainingTime.inHours.abs() > 720) {
        await subscriptionRef.set(subscriptionModel.toJson());
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isFiveDayRemainderShown', true);
      } else {
        return true;
      }
    } else if (subscriptionName == 'Year') {
      if (remainingTime.inHours.abs() > 8760) {
        await subscriptionRef.set(subscriptionModel.toJson());
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isFiveDayRemainderShown', true);
      } else {
        return true;
      }
      EasyLoading.dismiss();
    } else if (subscriptionName == 'Lifetime') {
      return true;
    }
    return true;
  }

  static Future<bool> availableLimit({required String itemType, required BuildContext? context}) async {
    final ref = await FirebaseDatabase.instance.ref(constUserId).child('Subscription');
    // ref.keepSynced(true);
    int beforeAction=0;
    await ref.child(itemType).get().then((value) {
      print(value.value);
       beforeAction = int.parse(value.value.toString());
    });
    if (beforeAction < 1 && beforeAction != -202) return false;
    return true;
  }

  static Future<bool> availableSubscription({required BuildContext? context}) async {
    final ref = await FirebaseDatabase.instance.ref(constUserId).child('Subscription');
    ref.keepSynced(true);
    late DateTime subscriptionDate ;
    DateTime currentDate = DateTime.now();
    int duration = 0;
    await ref.child("subscriptionDate").get().then((value) {
      print(value.value);
      subscriptionDate = DateTime.parse(value.value.toString());
    });

   await  ref.child("duration").get().then((value) {
      print(value.value);
      duration = int.parse(value.value.toString());
    });

    var from = DateTime(subscriptionDate.year, subscriptionDate.month, subscriptionDate.day);
    var to = DateTime(currentDate.year, currentDate.month, currentDate.day);
    int value = (to.difference(from).inHours / 24).round();
    print(value);
    if (value > duration) return false;
    // print(subscriptionDate);
    // print(value.value);
    // print(value.value);
    // 2024-02-13 17:05:05.864606
    return true;
  }

  int daysBetween(DateTime from, DateTime to) {
    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month, to.day);
    return (to.difference(from).inHours / 24).round();
  }

  static void decreaseSubscriptionLimits({required String itemType, required BuildContext? context}) async {
    final ref = FirebaseDatabase.instance.ref(constUserId).child('Subscription');
    ref.keepSynced(true);
    ref.child(itemType).get().then((value) {
      print(value.value);
      int beforeAction = int.parse(value.value.toString());
      if (beforeAction != -202) {
        int afterAction = beforeAction - 1;
        ref.update({itemType: afterAction});
      }

      context != null ? Subscription.getUserLimitsData(context: context, wannaShowMsg: false) : null;
    });
    // var data = await ref.once();
    // int beforeAction = int.parse(data.snapshot.value.toString());
    // int afterAction = beforeAction - 1;
    // FirebaseDatabase.instance.ref('$userId/Subscription').update({itemType: afterAction});
    // Subscription.getUserLimitsData(context: context, wannaShowMsg: false);
  }
}
