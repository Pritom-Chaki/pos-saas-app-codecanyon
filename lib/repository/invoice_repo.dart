import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:mobile_pos/model/invoice_model.dart';

import '../currency.dart';

class InvoiceRepo{

  static Future<InvoiceModel> getInvoiceSettings() async {
    DatabaseReference ref = FirebaseDatabase.instance.ref('$constUserId/Invoice Settings');
    ref.keepSynced(true);
    final model = await ref.get();
    var data = jsonDecode(jsonEncode(model.value));
    return InvoiceModel.fromJson(data);
  }

}