import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:mobile_pos/Screens/Customers/Model/customer_model.dart';
import 'package:nb_utils/nb_utils.dart';

import '../currency.dart';

class CustomerRepo {
  Future<List<CustomerModel>> getAllCustomers() async {
    List<CustomerModel> customerList = [];
    await FirebaseDatabase.instance.ref(constUserId).child('Customers').orderByKey().get().then((value) {
      for (var element in value.children) {
        var cust = CustomerModel.fromJson(jsonDecode(
          jsonEncode(element.value),
        ));
        if (cust.customerName.isEmptyOrNull) {
          print(cust.customerName);
          cust.customerName = '0';
          customerList.add(cust);
        } else {
          customerList.add(cust);
        }
      }
    });
    final customerRef = FirebaseDatabase.instance.ref(constUserId).child('Customers');
    customerRef.keepSynced(true);
    return customerList;
  }
}
