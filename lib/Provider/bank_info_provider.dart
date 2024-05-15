import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/bank_info_model.dart';
import '../repository/bank_info_repo.dart';

BankInfoRepo bankRepo = BankInfoRepo();
final bankInfoProvider = FutureProvider<BankInfoModel>((ref) => bankRepo.getPaypalInfo());
