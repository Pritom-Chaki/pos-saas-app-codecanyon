import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/terms_and_condition_model.dart';
import '../repository/terms_and_privacy_repo.dart';

TermsAndPrivacyRepo repo = TermsAndPrivacyRepo();
final privacyProvider = FutureProvider<TermsAanPrivacyModel>((ref) => repo.getPrivacy());
final termsProvider = FutureProvider<TermsAanPrivacyModel>((ref) => repo.getTerms());
