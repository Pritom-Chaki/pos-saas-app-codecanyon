import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:mobile_pos/model/transition_model.dart';

import '../currency.dart';
import '../model/due_transaction_model.dart';

class TransitionRepo {
  Future<List<SalesTransitionModel>> getAllTransition() async {
    List<SalesTransitionModel> transitionList = [];
    await FirebaseDatabase.instance.ref(constUserId).child('Sales Transition').orderByKey().get().then((value) {
      for (var element in value.children) {
        SalesTransitionModel data = SalesTransitionModel.fromJson(jsonDecode(jsonEncode(element.value)));
        data.key = element.key;
        transitionList.add(data);
      }
    });

    final transitionRef = FirebaseDatabase.instance.ref(constUserId).child('Sales Transition');
    transitionRef.keepSynced(true);
    return transitionList;
  }
}

class PurchaseTransitionRepo {
  Future<List<dynamic>> getAllTransition() async {
    List<dynamic> transitionList = [];
    await FirebaseDatabase.instance.ref(constUserId).child('Purchase Transition').orderByKey().get().then((value) {
      for (var element in value.children) {
        PurchaseTransactionModel data = PurchaseTransactionModel.fromJson(jsonDecode(jsonEncode(element.value)));
        data.key = element.key;
        transitionList.add(data);
      }
    });
    final purchaseTransitionRef = FirebaseDatabase.instance.ref(constUserId).child('Sales Transition');
    purchaseTransitionRef.keepSynced(true);
    return transitionList;
  }
}

class DueTransitionRepo {
  Future<List<DueTransactionModel>> getAllTransition() async {
    List<DueTransactionModel> transitionList = [];
    await FirebaseDatabase.instance.ref(constUserId).child('Due Transaction').orderByKey().get().then((value) {
      for (var element in value.children) {
        transitionList.add(DueTransactionModel.fromJson(jsonDecode(jsonEncode(element.value))));
      }
    });
    final dueTransitionRef = FirebaseDatabase.instance.ref(constUserId).child('Sales Transition');
    dueTransitionRef.keepSynced(true);
    return transitionList;
  }
}
