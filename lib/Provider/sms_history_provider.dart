import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_pos/model/payment_verification_model.dart';
import 'package:mobile_pos/model/sms_model.dart';
import 'package:mobile_pos/repository/sms_repo.dart';

import '../model/sms_subscription_plan_model.dart';
import '../repository/sms_package_repo.dart';

SmsRepo smsRepo = SmsRepo();
final smsHistoryProvider = FutureProvider.autoDispose<List<SmsModel>>((ref) => smsRepo.getAllSms());
final transactionHistoryProvider = FutureProvider.autoDispose<List<PaymentVerificationModel>>((ref) => smsRepo.getAllTransaction());
SMSPackageRepo smsRepos = SMSPackageRepo();
final smsPackageProvider = FutureProvider<List<SmsSubscriptionPlanModel>>((ref) => smsRepos.getAllSMSPackage());