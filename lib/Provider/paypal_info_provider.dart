import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/paypal_info_model.dart';
import '../repository/paypal_info_repo.dart';

PaypalInfoRepo paypalRepo = PaypalInfoRepo();
StripeInfoRepo stripeInfoRepo = StripeInfoRepo();
SSLInfoRepo sslInfoRepo = SSLInfoRepo();
FlutterWaveInfoRepo flutterWaveInfoRepo = FlutterWaveInfoRepo();
RazorpayInfoRepo razorpayInfoRepo = RazorpayInfoRepo();
TapInfoRepo tapInfoRepo = TapInfoRepo();
KkiPayInfoRepo kkiPayInfoRepo = KkiPayInfoRepo();
PayStackInfoRepo payStackInfoRepo = PayStackInfoRepo();
BillplzInfoRepo billplzInfoRepo = BillplzInfoRepo();
CashFreeInfoRepo cashFreeInfoRepo = CashFreeInfoRepo();
IyzicoInfoRepo iyzicoInfoRepo = IyzicoInfoRepo();


final paypalInfoProvider = FutureProvider<PaypalInfoModel>((ref) => paypalRepo.getPaypalInfo());
final stripeInfoProvider = FutureProvider<StripeInfoModel>((ref) => stripeInfoRepo.getStripeInfo());
final sslInfoProvider = FutureProvider<SSLInfoModel>((ref) => sslInfoRepo.getSSLInfo());
final flutterWaveInfoProvider = FutureProvider<FlutterWaveInfoModel>((ref) => flutterWaveInfoRepo.getFlutterWaveInfo());
final razorpayInfoProvider = FutureProvider<RazorpayInfoModel>((ref) => razorpayInfoRepo.getRazorpayInfo());
final tapInfoProvider = FutureProvider<TapInfoModel>((ref) => tapInfoRepo.getTapInfo());
final kkiPayInfoProvider = FutureProvider<KkiPayInfoModel>((ref) => kkiPayInfoRepo.getKkiPayInfo());
final payStackInfoProvider = FutureProvider<PayStackInfoModel>((ref) => payStackInfoRepo.getPayStackInfo());
final billplzInfoProvider = FutureProvider<BillPlzInfoModel>((ref) => billplzInfoRepo.getBillplzInfo());
final cashFreeInfoProvider = FutureProvider<CashFreeInfoModel>((ref) => cashFreeInfoRepo.getCashFreeInfo());
final iyzicoInfoProvider = FutureProvider<IyzicoInfoModel>((ref) => iyzicoInfoRepo.getIyzicoInfo());
