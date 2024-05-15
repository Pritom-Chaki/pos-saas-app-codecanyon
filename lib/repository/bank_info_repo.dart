import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_database/firebase_database.dart';

import '../model/bank_info_model.dart';
import '../model/billplz_payment_model.dart';

class BankInfoRepo {
  Future<BankInfoModel> getPaypalInfo() async {
    DatabaseReference bankRef = FirebaseDatabase.instance.ref('Admin Panel/Bank Info');
    final bankData = await bankRef.get();
    BankInfoModel bankInfoModel = BankInfoModel.fromJson(jsonDecode(jsonEncode(bankData.value)));

    return bankInfoModel;
  }

  Future<BillplzPaymentModel> bilPlzPayment(String amount, String collectionId,String apiSecret, bool isLive) async {
    String url = isLive ? 'https://www.billplz.com/api/v3/bills' : 'https://www.billplz-sandbox.com/api/v3/bills';
    List<int> mydataint = utf8.encode(apiSecret);
    String bs64str = base64.encode(mydataint);

    final response = await http.post(Uri.parse(url),headers: {
      'Authorization': 'Basic $bs64str',
    }, body: {
      'collection_id': collectionId,
      'description': 'Maecenas eu placerat ante.',
      'email': 'api@billplz.com',
      'name': 'Sara',
      'amount': amount,
      'callback_url': 'http://example.com/webhook/'
    });
    final body = jsonDecode(response.body);
    print(body);
    BillplzPaymentModel billplzPaymentModel = BillplzPaymentModel.fromJson(body);
    return billplzPaymentModel;
  }

}
