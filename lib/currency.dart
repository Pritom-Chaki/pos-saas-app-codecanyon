import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'model/user_role_model.dart';


// getCurrency() async {
//   final prefs = await SharedPreferences.getInstance();
//   String? data = prefs.getString('currency');
//   if(data.isEmptyOrNull ){
//     currency = data!;
//   }
// }



String currency = '\$';
String currencyName = 'United States Dollar';





// List<String> items = [
//   '\$ (US Dollar)',
//   '৳ (Taka)',
//   "₹ (Rupee)",
//   "€ (Euro)",
//   "₽ (Ruble)",
//   "£ (UK Pound)",
//   "R (Rial)",
//   "؋( Af ⁄ Afs)",
//   "₺ (Turkish lira)",
//   "¥ (Japanese yen)",
//   "RON (Romanian leu)",
//   "₫ (Dong)",
//   "฿ (Baht)",
//   "zł (Polish złoty)",
//   "Ft (Forint)",
//   "₩ (Korean won)",
//   "RM (Malaysian Ringgit)",
//   "Rp (rupiah)",
//   "₴ (Ukrainian hryvnia)",
//   "KM (Bosnia-Herzegovina)",
//   "Rs (Pakistani rupee)",
//   "LKR (Sri Lankan Rupee)",
//   "﷼(Iranian Rial)",
//   "KHR (Cambodian riel)",
//   "LAK (Laotian Kip)",
//   "ZAR (Rand)",
//   "SEK (Swedish Krona)",
//   "ALL (Albanian Lek)",
//   "CHF (Swiss Franc)",
//   "AZN (Azerbaijani Manat)",
//   "₸ (Kazakhstani Tenge)",
//   "NPR (Nepalese Rupee)",
//   "K (Myanmar Kyat)",
//   "RMB(Renminbi)",
//   "Tsh (TZ Shillings)",
// ];

List<String> items = [
  '\$ (US Dollar)',
  "₹ (Rupee)",
  "€ (Euro)",
  "₽ (Ruble)",
  "£ (UK Pound)",
  '৳ (Taka)',
  "R (Rial)",
  "؋ (Afghani)",
  "Lek (Lek)",
  "د.ج (Algerian Dinar)",
  "Kz (Kwanza)",
  "EC\$ (East Caribbean Dollar)",
  "\$ (Argentine Peso)",
  "֏ (Armenian Dram)",
  "A\$ (Australian Dollar)",
  "₼ (Azerbaijani Manat)",
  "B\$ (Bahamian Dollar)",
  ".د.ب (Bahraini Dinar)",
  "৳ (Bangladeshi Taka)",
  "Bds\$ (Barbadian Dollar)",
  "Br (Belarusian Ruble)",
  "BZ\$ (Belize Dollar)",
  "CFA (West African CFA franc)",
  "FCFA (West African franc)",
  "Nu. (Bhutanese Ngultrum)",
  "Bs. (Bolivian Boliviano)",
  "KM (Bosnia and Herzegovina Convertible Mark)",
  "P (Botswana Pula)",
  "R\$ (Brazilian Real)",
  "B\$ (Brunei Dollar)",
  "лв (Bulgarian Lev)",
  "FBu (Burundian Franc)",
  "Esc (Cape Verdean Escudo)",
  "៛ (Cambodian Riel)",
  "CFA (Central African CFA franc)",
  "CA\$ (Canadian Dollar)",
  "\$ (Chilean Peso)",
  "¥ (Chinese Yuan)",
  "\$ (Colombian Peso)",
  "CF (Comorian Franc)",
  "FC (Congolese Franc)",
  "₡ (Costa Rican Colón)",
  "kn (Croatian Kuna)",
  "CUP (Cuban Peso)",
  "Kč (Czech Koruna)",
  "kr (Danish Krone)",
  "Fdj (Djiboutian Franc)",
  "RD\$ (Dominican Peso)",
  "US\$ (United States Dollar)",
  "\$ (United States Dollar)",
  "E£ (Egyptian Pound)",
  "Nfk (Eritrean Nakfa)",
  "E (Swazi Lilangeni)",
  "Br (Ethiopian Birr)",
  "FJ\$ (Fijian Dollar)",
  "D (Gambian Dalasi)",
  "₾ (Georgian Lari)",
  "GH₵ (Ghanaian Cedi)",
  "Q (Guatemalan Quetzal)",
  "GNF (Guinean Franc)",
  "GY\$ (Guyanese Dollar)",
  "G (Haitian Gourde)",
  "L (Honduran Lempira)",
  "Ft (Hungarian Forint)",
  "kr (Icelandic Króna)",
  "₹ (Indian Rupee)",
  "Rp (Indonesian Rupiah)",
  "﷼ (Iranian Rial)",
  "ع.د (Iraqi Dinar)",
  "₪ (Israeli New Shekel)",
  "J\$ (Jamaican Dollar)",
  "¥ (Japanese Yen)",
  "د.ا (Jordanian Dinar)",
  "₸ (Kazakhstani Tenge)",
  "KSh (Kenyan Shilling)",
  "AU\$ (Australian Dollar)",
  "د.ك (Kuwaiti Dinar)",
  "som (Kyrgyzstani Som)",
  "₭ (Laotian Kip)",
  "ل.ل (Lebanese Pound)",
  "L (Lesotho Loti)",
  "L\$ (Liberian Dollar)",
  "ل.د (Libyan Dinar)",
  "CHF (Swiss Franc)",
  "Ar (Malagasy Ariary)",
  "MK (Malawian Kwacha)",
  "RM (Malaysian Ringgit)",
  "Rf (Maldivian Rufiyaa)",
  "Ouguiya (Mauritanian Ouguiya)",
  "Rs (Mauritian Rupee)",
  "Mex\$ (Mexican Peso)",
  "lei (Moldovan Leu)",
  "₮ (Mongolian Tugrik)",
  "د.م. (Moroccan Dirham)",
  "MT (Mozambican Metical)",
  "K (Myanmar Kyat)",
  "N\$ (Namibian Dollar)",
  "रू (Nepalese Rupee)",
  "NZ\$ (New Zealand Dollar)",
  "C\$ (Nicaraguan Córdoba)",
  "₦ (Nigerian Naira)",
  "kr (Norwegian Krone)",
  "﷼ (Omani Rial)",
  "PKR (Pakistani Rupee)",
  "₱ (Philippine Peso)",
  "zł (Polish Złoty)",
  "﷼ (Qatari Riyal)",
  "lei (Romanian Leu)",
  "руб (Russian Ruble)",
  "RF (Rwandan Franc)",
  "₣ (Swiss Franc)",
  "₲ (Paraguayan Guarani)",
  "SR (Saudi Riyal)",
  "د.س (Sudanese Pound)",
  "\$ (Singapore Dollar)",
  "S (Solomon Islands Dollar)",
  "Sh (Somali Shilling)",
  "R (South African Rand)",
  "₩ (South Korean Won)",
  "£ (British Pound)",
  "\$ (Sri Lankan Rupee)",
  "L (Saint Helenian Pound)",
  "\$ (East Caribbean Dollar)",
  "kr (Swedish Krona)",
  "TJS (Tajikistani Somoni)",
  "TSh (Tanzanian Shilling)",
  "฿ (Thai Baht)",
  "T (Tongan Paʻanga)",
  "TTD (Trinidad and Tobago Dollar)",
  "XAf (XAf Central Africa)",
];

// String localCurrency = 'Tsh';

// List<String> items = [
//   'Tsh (TZ Shillings)',
//   '\$ (US Dollar)',
//   ];

String constUserId = '';
bool isSubUser = false;
String subUserTitle = '';
String subUserEmail = '';
bool isSubUserDeleted = true;
//
String userPermissionErrorText = 'Access not granted';

UserRoleModel finalUserRoleModel = UserRoleModel(
  email: '',
  userTitle: '',
  databaseId: '',
  salePermission: true,
  partiesPermission: true,
  purchasePermission: true,
  productPermission: true,
  profileEditPermission: true,
  addExpensePermission: true,
  lossProfitPermission: true,
  dueListPermission: true,
  stockPermission: true,
  reportsPermission: true,
  salesListPermission: true,
  purchaseListPermission: true,
);

class CurrentUserData {
  void getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    constUserId = prefs.getString('userId') ?? '';
    isSubUser = prefs.getBool('isSubUser') ?? false;
    subUserEmail = prefs.getString('subUserEmail') ?? '';
    await updateData();
  }

  Future<void> updateData() async {
    final prefs = await SharedPreferences.getInstance();
    final ref = FirebaseDatabase.instance.ref(constUserId).child('User Role');
    ref.keepSynced(true);
    ref.orderByKey().get().then(
      (value) async {
        for (var element in value.children) {
          var data = UserRoleModel.fromJson(jsonDecode(jsonEncode(element.value)));
          if (data.email == subUserEmail) {
            isSubUserDeleted = false;
            finalUserRoleModel = data;
            await prefs.setString('userTitle', data.userTitle);
            subUserTitle = prefs.getString('userTitle') ?? '';
          }
        }
      },
    );
  }

  Future<bool> isSubUserEmailNotFound() async {
    bool isMailMatch = true;
    final ref = FirebaseDatabase.instance.ref(constUserId).child('User Role');

    await ref.orderByKey().get().then((value) async {
      for (var element in value.children) {
        var data = UserRoleModel.fromJson(jsonDecode(jsonEncode(element.value)));
        if (data.email == subUserEmail) {
          isMailMatch = false;
          return;
        }
      }
    });
    return isMailMatch;
  }

  void putUserData({required String userId, required bool subUser, required String title, required String email}) async {
    final prefs = await SharedPreferences.getInstance();
    constUserId = userId;
    isSubUser = subUser;

    await prefs.setString('userId', userId);
    await prefs.setString('subUserEmail', email);
    await prefs.setString('userTitle', title);
    await prefs.setBool('isSubUser', subUser);
    getUserData();
  }
}

bool newSelect = false;
