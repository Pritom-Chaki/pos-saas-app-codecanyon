import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_pos/model/transition_model.dart';

import '../repository/transactions_repo.dart';

TransitionRepo transitionRepo = TransitionRepo();
final transitionProvider = FutureProvider.autoDispose<List<SalesTransitionModel>>((ref) => transitionRepo.getAllTransition());

PurchaseTransitionRepo purchaseTransitionRepo = PurchaseTransitionRepo();
final purchaseTransitionProvider = FutureProvider.autoDispose<List<dynamic>>((ref) => purchaseTransitionRepo.getAllTransition());
