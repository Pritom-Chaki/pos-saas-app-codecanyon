import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_pos/model/transition_model.dart';

import '../Repo/purchase_return_repo.dart';

PurchaseReturnRepo salesReturnRepo = PurchaseReturnRepo();
final purchaseReturnProvider = FutureProvider<List<PurchaseTransactionModel>>((ref) => salesReturnRepo.getAllTransition());
