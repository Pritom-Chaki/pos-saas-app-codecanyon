import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:mobile_pos/Screens/Sales/sale%20setting/sale_setting_model.dart';

import '../../../currency.dart';

class SaleSettingRepo {
  DatabaseReference ref = FirebaseDatabase.instance.ref();

  Future<SaleSettingModel> getSaleSetting() async {
    final userRef = FirebaseDatabase.instance.ref(constUserId).child('Sale Setting');

    final model = await userRef.get();
    userRef.keepSynced(true);
    var data = jsonDecode(jsonEncode(model.value));
    if (data == null) {
      return SaleSettingModel.fromJson(data);
    } else {
      return SaleSettingModel.fromJson(data);
    }
  }

  // Future<List<SaleSettingModel>> getAllTransition() async {
  //   List<SaleSettingModel> saleSetting = [];
  //   await FirebaseDatabase.instance.ref(constUserId).child('Sale Setting').orderByKey().get().then((value) {
  //     for (var element in value.children) {
  //       SaleSettingModel data = SaleSettingModel.fromJson(jsonDecode(jsonEncode(element.value)));
  //       saleSetting.add(data);
  //     }
  //   });
  //
  //   final saleSettingRef = FirebaseDatabase.instance.ref(constUserId).child('Sale Setting');
  //   saleSettingRef.keepSynced(true);
  //   return saleSetting;
  // }
}
