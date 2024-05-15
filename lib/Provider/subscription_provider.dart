import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/subscription_plan_model.dart';
import '../repository/subscription_repo.dart';

SubscriptionPlanRepo subscriptionRepo = SubscriptionPlanRepo();
final subscriptionPlanProvider = FutureProvider<List<SubscriptionPlanModel>>((ref) => subscriptionRepo.getAllSubscriptionPlans());
