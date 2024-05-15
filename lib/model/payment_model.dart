import 'package:mobile_pos/model/paypal_info_model.dart';

class PaymentModel{
  PaypalInfoModel paypalInfoModel;
  StripeInfoModel stripeInfoModel;
  SSLInfoModel sslInfoModel;
  FlutterWaveInfoModel flutterWaveInfoModel;
  RazorpayInfoModel razorpayInfoModel;
  TapInfoModel tapInfoModel;
  KkiPayInfoModel kkiPayInfoModel;
  PayStackInfoModel payStackInfoModel;
  BillPlzInfoModel billplzInfoModel;
  CashFreeInfoModel cashFreeInfoModel;
  IyzicoInfoModel iyzicoInfoModel;

  PaymentModel({
    required this.paypalInfoModel,
    required this.stripeInfoModel,
    required this.sslInfoModel,
    required this.flutterWaveInfoModel,
    required this.razorpayInfoModel,
    required this.tapInfoModel,
    required this.kkiPayInfoModel,
    required this.payStackInfoModel,
    required this.billplzInfoModel,
    required this.cashFreeInfoModel,
    required this.iyzicoInfoModel,
  });


}