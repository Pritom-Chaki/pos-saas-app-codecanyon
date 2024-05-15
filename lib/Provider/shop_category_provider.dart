
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../Repository/shop_category_repo.dart';
import '../model/shop_category_model.dart';

ShopCategoryRepo categoryRepo = ShopCategoryRepo();
final shopCategoryProvider = FutureProvider<List<ShopCategoryModel>>((ref) => categoryRepo.getAllCategory());