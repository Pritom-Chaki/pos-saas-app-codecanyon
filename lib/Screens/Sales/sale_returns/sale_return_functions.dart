import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../constant.dart';
import '../../../model/product_model.dart';
import '../../../model/transition_model.dart';

class DeleteInvoice {
  Future<void> editStockAndSerial({
    required SalesTransitionModel saleTransactionModel,
  }) async {
    for (var element in saleTransactionModel.productList!) {
      final ref = FirebaseDatabase.instance.ref('${await getUserID()}/Products/');

      var data = await ref.orderByChild('productCode').equalTo(element.productId).once();
      String productPath = data.snapshot.value.toString().substring(1, 21);

      var data1 = await ref.child('$productPath/productStock').once();
      int stock = int.parse(data1.snapshot.value.toString());
      int remainStock = stock + int.parse(element.quantity.toString());

      await ref.child(productPath).update({'productStock': '$remainStock'});

      ///_____serial_add________________________________
      ProductModel? productData;

      final serialRef = FirebaseDatabase.instance.ref('${await getUserID()}/Products/$productPath');
      await serialRef.orderByKey().get().then((value) {
        productData = ProductModel.fromJson(jsonDecode(jsonEncode(value.value)));
      });

      for (var element in element.serialNumber ?? []) {
        productData!.serialNumber.add(element);
      }
      await serialRef.child('serialNumber').set(productData!.serialNumber.map((e) => e).toList());
    }
  }

  Future<void> editStockAndSerialForPurchase({required PurchaseTransactionModel saleTransactionModel}) async {
    for (var element in saleTransactionModel.productList!) {
      final ref = FirebaseDatabase.instance.ref('${await getUserID()}/Products/');

      var data = await ref.orderByChild('productCode').equalTo(element.productCode).once();
      String productPath = data.snapshot.value.toString().substring(1, 21);

      var data1 = await ref.child('$productPath/productStock').once();
      int stock = int.parse(data1.snapshot.value.toString());
      int remainStock = stock - int.parse(element.productStock.toString());

      await ref.child(productPath).update({'productStock': '$remainStock'});

      ///_____serial_remove________________________________
      ProductModel? productData;

      final serialRef = FirebaseDatabase.instance.ref('${await getUserID()}/Products/$productPath');
      await serialRef.orderByKey().get().then((value) {
        productData = ProductModel.fromJson(jsonDecode(jsonEncode(value.value)));
      });

      for (var element in element.serialNumber) {
        productData!.serialNumber.remove(element);
      }
      await serialRef.child('serialNumber').set(productData!.serialNumber.map((e) => e).toList());
    }
  }

  Future<void> customerDueUpdate({required String phone, required num due}) async {
    if (due > 0) {
      final ref = FirebaseDatabase.instance.ref('${await getUserID()}/Customers/');
      String? key;

      await FirebaseDatabase.instance.ref(await getUserID()).child('Customers').orderByKey().get().then((value) {
        for (var element in value.children) {
          var data = jsonDecode(jsonEncode(element.value));
          if (data['phoneNumber'] == phone) {
            key = element.key;
          }
        }
      });
      var data1 = await ref.child('$key/due').once();
      int previousDue = data1.snapshot.value.toString().toInt();

      int totalDue;

      totalDue = previousDue - due.toInt();
      await ref.child(key!).update({'due': '$totalDue'});
    }
  }

  Future<void> updateFromShopRemainBalance({required num paidAmount, required bool isFromPurchase}) async {
    if (paidAmount > 0) {
      final ref = FirebaseDatabase.instance.ref('${await getUserID()}/Personal Information');
      var data1 = await ref.child("remainingShopBalance").once();
      num previousBalance = data1.snapshot.value.toString().toInt();
      await ref.update({'remainingShopBalance': isFromPurchase ? previousBalance + paidAmount : previousBalance - paidAmount});
    }
  }

  Future<void> deleteDailyTransaction({required String invoice, required String status, required String field}) async {
    final ref = FirebaseDatabase.instance.ref('${await getUserID()}/Daily Transaction');
    String? key;

    await FirebaseDatabase.instance.ref(await getUserID()).child('Daily Transaction').orderByKey().get().then((value) {
      for (var element in value.children) {
        var data = jsonDecode(jsonEncode(element.value));
        if (data['type'] == status && data[field]['invoiceNumber'] == invoice) {
          key = element.key;
        }
      }
    });
    await ref.child(key!).remove();
  }
}
