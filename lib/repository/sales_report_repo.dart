import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';

import '../Screens/Sales/Model/sales_report.dart';
import '../currency.dart';

class SalesReportRepo {
  Future<List<SalesReport>> getAllSalesReport() async {
    List<SalesReport> salesReportList = [];
    await FirebaseDatabase.instance.ref(constUserId).child('Sales Report').orderByKey().get().then((value) {
      for (var element in value.children) {
        salesReportList.add(SalesReport.fromJson(jsonDecode(jsonEncode(element.value))));
      }
    });
    final salesReportRef = FirebaseDatabase.instance.ref(constUserId).child('Sales Report');
    salesReportRef.keepSynced(true);
    return salesReportList;
  }
}
