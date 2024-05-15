import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';

import '../currency.dart';
import '../model/expense_model.dart';

class ExpenseRepo {
  Future<List<ExpenseModel>> getAllExpense() async {
    List<ExpenseModel> allExpense = [];

   await FirebaseDatabase.instance.ref(constUserId).child('Expense').orderByKey().get().then((value) {
      for (var element in value.children) {
        var data = ExpenseModel.fromJson(jsonDecode(jsonEncode(element.value)));
        allExpense.add(data);
      }
    });
    final DatabaseReference ref = FirebaseDatabase.instance.ref(constUserId).child('Expense');
    ref.keepSynced(true);

    return allExpense;
  }
}
