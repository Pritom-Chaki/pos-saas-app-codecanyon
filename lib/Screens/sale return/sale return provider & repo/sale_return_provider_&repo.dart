import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_pos/model/transition_model.dart';

import '../../../constant.dart';

SalesReturnRepo salesReturnRepo = SalesReturnRepo();
final saleReturnProvider = FutureProvider.autoDispose<List<SalesTransitionModel>>((ref) => salesReturnRepo.getAllTransition());

class SalesReturnRepo {
  Future<List<SalesTransitionModel>> getAllTransition() async {
    List<SalesTransitionModel> transitionList = [];
    await FirebaseDatabase.instance.ref(await getUserID()).child('Sales Return').orderByKey().get().then((value) {
      for (var element in value.children) {
        transitionList.add(SalesTransitionModel.fromJson(jsonDecode(jsonEncode(element.value))));
      }
    });
    return transitionList;
  }
}
