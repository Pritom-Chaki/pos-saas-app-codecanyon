import 'dart:convert';
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_pos/Provider/profile_provider.dart';
import 'package:mobile_pos/model/product_model.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:restart_app/restart_app.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Screens/tax report/tax_model.dart';
import 'currency.dart';
import 'model/DailyTransactionModel.dart';
import 'model/add_to_cart_model.dart';

// const kMainColor = Color(0xFF3F8CFF);
// const kMainColor = Color(0xff3949AB);
// const kMainColor = Color(0xff04A65A);

const kMainColor = Color(0xff8a059e);
const kGreyTextColor = Color(0xFF828282);
const kBorderColorTextField = Color(0xFFC2C2C2);
const kBorderColor = Color(0xff7D7D7D);
const kDarkWhite = Color(0xFFF1F7F7);
const kTitleColor = Color(0xFF000000);
const kWhite = Color(0xFFFFFFFF);
const kAlertColor = Color(0xFFFF8C34);
const kPremiumPlanColor = Color(0xFF8752EE);
const kPremiumPlanColor2 = Color(0xFFFF5F00);
List<String> selectedNumbers = [];

String calculateProductVat({required AddToCartModel product}) {
  if (product.taxType == 'Inclusive') {
    double taxRate = double.parse(product.groupTaxRate.toString()) / 100;
    return (((double.tryParse(product.productPurchasePrice.toString()) ?? 0) /
                    (taxRate + 1) *
                    taxRate) *
                product.quantity) >
            0
        ? (((double.tryParse(product.productPurchasePrice.toString()) ?? 0) /
                    (taxRate + 1) *
                    taxRate) *
                product.quantity)
            .toStringAsFixed(2)
        : '';
  } else {
    return (((double.parse(product.groupTaxRate.toString()) *
                        (double.tryParse(
                                product.productPurchasePrice.toString()) ??
                            0)) /
                    100) *
                int.parse(product.quantity.toString())) >
            0
        ? (((double.parse(product.groupTaxRate.toString()) *
                        (double.tryParse(
                                product.productPurchasePrice.toString()) ??
                            0)) /
                    100) *
                int.parse(product.quantity.toString()))
            .toStringAsFixed(2)
        : '';
  }
}

String calculateProductVatPurchase({required ProductModel product}) {
  if (product.taxType == 'Inclusive') {
    double taxRate = double.parse(product.groupTaxRate.toString()) / 100;
    return (((double.tryParse(product.productPurchasePrice) ?? 0) /
                (taxRate + 1) *
                taxRate) *
            (double.tryParse(product.productStock) ?? 0))
        .toStringAsFixed(2);
  } else {
    return (((double.parse(product.groupTaxRate.toString()) *
                    (double.tryParse(product.productPurchasePrice) ?? 0)) /
                100) *
            (double.tryParse(product.productStock) ?? 0))
        .toStringAsFixed(2);
  }
}

bool isVatAdded({required List<AddToCartModel> products}) {
  return products
      .any((element) => double.parse(element.groupTaxRate.toString()) > 0);
}

///________Demo_mode__________________
String appName = 'PosX';
String invoiceName = 'Pos_Saas';
String splashScreenLogo = 'images/logo1.png';
String loginScreenLogo = 'images/sblogo.png';
bool isDemo = false;
String demoText = 'You Can\'t change anything in demo mode';

void postDailyTransaction(
    {required DailyTransactionModel dailyTransactionModel}) async {
  final DatabaseReference personalInformationRef = FirebaseDatabase.instance
      .ref()
      .child(constUserId)
      .child('Personal Information');
  num remainingBalance = 0;
  personalInformationRef.keepSynced(true);

  await personalInformationRef.get().then((value) {
    var data = jsonDecode(jsonEncode(value.value));
    remainingBalance =
        num.tryParse(data['remainingShopBalance'].toString()) ?? 0;
  });

  if (dailyTransactionModel.type == 'Sale' ||
      dailyTransactionModel.type == 'Due Collection' ||
      dailyTransactionModel.type == 'Income') {
    remainingBalance += dailyTransactionModel.paymentIn;
  } else {
    remainingBalance -= dailyTransactionModel.paymentOut;
  }

  dailyTransactionModel.remainingBalance = remainingBalance;

  ///________post_remaining Balance_on_personal_information___________________________________________________
  personalInformationRef.update({'remainingShopBalance': remainingBalance});

  ///_________dailyTransaction_Posting________________________________________________________________________
  DatabaseReference dailyTransactionRef =
      FirebaseDatabase.instance.ref("$constUserId/Daily Transaction");
  await dailyTransactionRef.push().set(dailyTransactionModel.toJson());
  dailyTransactionRef.keepSynced(true);
}

Future<String?> getSaleID({required String id}) async {
  String? key;
  await FirebaseDatabase.instance
      .ref()
      .child('Admin Panel')
      .child('Seller List')
      .orderByKey()
      .get()
      .then((value) async {
    for (var element in value.children) {
      var data = jsonDecode(jsonEncode(element.value));
      if (data['userId'].toString() == id) {
        key = element.key.toString();
      }
    }
  });
  return key;
}

void increaseStock(String productCode, num quantity) async {
  final ref = FirebaseDatabase.instance.ref(constUserId).child('Products');
  ref.keepSynced(true);

  ref.orderByKey().get().then((value) {
    for (var element in value.children) {
      var data = jsonDecode(jsonEncode(element.value));
      if (data['productCode'] == productCode) {
        String? key = element.key;
        num previousStock =
            num.tryParse(element.child('productStock').value.toString()) ?? 0;
        print(previousStock);
        num remainStock = previousStock + quantity;
        ref.child(key!).update({'productStock': '$remainStock'});
      }
    }
  });
// final userId = FirebaseAuth.instance.currentUser!.uid;
// final ref = FirebaseDatabase.instance.ref('$userId/Products/');
//
// var data = await ref.orderByChild('productCode').equalTo(productCode).once();
// String productPath = data.snapshot.value.toString().substring(1, 21);
//
// var data1 = await ref.child('$productPath/productStock').once();
// int stock = int.parse(data1.snapshot.value.toString());
// int remainStock = stock + quantity;
//
// ref.child(productPath).update({'productStock': '$remainStock'});
}

void decreaseStock(String productCode, num quantity) async {
  final ref = FirebaseDatabase.instance.ref(constUserId).child('Products');
  ref.keepSynced(true);

  ref.orderByKey().get().then((value) {
    for (var element in value.children) {
      var data = jsonDecode(jsonEncode(element.value));
      if (data['productCode'] == productCode) {
        String? key = element.key;
        num previousStock =
            num.tryParse(element.child('productStock').value.toString()) ?? 0;
        print(previousStock);
        num remainStock = previousStock - quantity;
        ref.child(key!).update({'productStock': '$remainStock'});
      }
    }
  });
}

void updateFromShopRemainBalance(
    {required num paidAmount,
    required bool isFromPurchase,
    required WidgetRef t}) async {
  if (paidAmount > 0) {
    t.watch(profileDetailsProvider).when(
          data: (data) {
            final ref = FirebaseDatabase.instance
                .ref('$constUserId/Personal Information');
            ref.keepSynced(true);

            ref.update({
              'remainingShopBalance': isFromPurchase
                  ? (data.remainingShopBalance ?? 0) + paidAmount
                  : (data.remainingShopBalance ?? 0) - paidAmount
            });
          },
          error: (error, stackTrace) {},
          loading: () {},
        );
  }
}

void getSpecificCustomersDueUpdate(
    {required String phoneNumber,
    required bool isDuePaid,
    required num due}) async {
  final ref = FirebaseDatabase.instance.ref(constUserId).child('Customers');
  ref.keepSynced(true);
  String? key;

  ref.orderByKey().get().then((value) {
    for (var element in value.children) {
      var data = jsonDecode(jsonEncode(element.value));
      if (data['phoneNumber'] == phoneNumber) {
        key = element.key;
        num previousDue = element.child('due').value.toString().toInt();

        num totalDue;

        isDuePaid ? totalDue = previousDue + due : totalDue = previousDue - due;
        ref.child(key!).update({'due': '$totalDue'});
      }
    }
  });
}

// Future<void> welcomeEmail({required String email}) async {
//   final smtpServer = SmtpServer(
//     'smtp.stackmail.com',
//     port: 587,
//     username: 'hello@smartbiashara.com',
//     password: 'qwerty7890@',
//   );
//   final message = Message()
//     ..from = const Address('mhello@smartbiashara.com')
//     ..recipients.add(email)
//     ..subject = 'Welcome to SmartBiashara(POS)!'
//     ..html =
//         '<h3>Welcome to SmartBiashara(POS)!</h3><p>Were thrilled to have you join us on your journey to streamline and optimize your business operations.</p><p>Our powerful Point of Sale system is here to simplify transactions and boost your business efficiency.</p><p>Let\'s embark on this smart business adventure together!</p><p>Karibu Sana</p>';
//
//   try {
//     final sendReport = await send(message, smtpServer);
//     print('Message sent: ${sendReport.mail}');
//   } catch (e) {
//     print('Error sending email: $e');
//   }
// }

final kTextStyle = GoogleFonts.manrope(
  color: Colors.white,
);

bool connected = false;
bool isPrintEnable = true;
List<String> paymentsTypeList = ['Cash', 'Mobile Pay'];

const String onesignalAppId = '1549acc6-6958-4c79-bea0-b8fdae3cbdce';

bool isReportShow = false;

//___________currency__________________________

const String appVersion = '3.1.0';
const String playStoreUrl = "market://details?id=com.maantechnology.mobipos";

const String paypalClientId =
    'ASWARYNRARFIbKf8U4u5Bq9-8tYVszzpkfRhohErQil3izlffjVQE-L0K2M0_bobdPhj2Qyf7uHoGctI';
const String paypalClientSecret =
    'EDNYPyTGpziJzfVhqsf75iodgFGSCOZAKXTHuD9YR5PWt5ruwc1HIzgT6STEznFfGro5E8h466i0sPtb';
const bool sandbox = true;

const kButtonDecoration = BoxDecoration(
  borderRadius: BorderRadius.all(
    Radius.circular(5),
  ),
);

Future<String> getUserID() async {
  final prefs = await SharedPreferences.getInstance();
  final String? uid = prefs.getString('userId');

  return uid ?? '';
}

const kInputDecoration = InputDecoration(
  hintStyle: TextStyle(color: kBorderColorTextField),
  filled: true,
  fillColor: Colors.white70,
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(8.0)),
    borderSide: BorderSide(color: kBorderColorTextField, width: 2),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(6.0)),
    borderSide: BorderSide(color: kBorderColorTextField, width: 2),
  ),
);

OutlineInputBorder outlineInputBorder() {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(1.0),
    borderSide: const BorderSide(color: kBorderColorTextField),
  );
}

final otpInputDecoration = InputDecoration(
  contentPadding: const EdgeInsets.symmetric(vertical: 5.0),
  border: outlineInputBorder(),
  focusedBorder: outlineInputBorder(),
  enabledBorder: outlineInputBorder(),
);

final List<String> businessCategory = [
  'Bag & Luggage',
  'Books & Stationery',
  'Clothing',
  'Construction & Raw materials',
  'Coffee & Tea',
  'Cosmetic & Jewellery',
  'Computer & Electronic',
  'E-Commerce',
  'Furniture',
  'General Store',
  'Gift, Toys & flowers',
  'Grocery, Fruits & Bakery',
  'Handicraft',
  'Home & Kitchen',
  'Hardware & sanitary',
  'Internet, Dish & TV',
  'Laundry',
  'Manufacturing',
  'Mobile Top up',
  'Motorbike & parts',
  'Mobile & Gadgets',
  'Pharmacy',
  'Poultry & Agro',
  'Pet & Accessories',
  'Rice mill',
  'Super Shop',
  'Sunglasses',
  'Service & Repairing',
  'Sports & Exercise',
  'Shoes',
  'Saloon & Beauty Parlour',
  'Shop Rent & Office Rent',
  'Travel Ticket & Rental',
  'Trading',
  'Thai Aluminium & Glass',
  'Vehicles & Parts',
  'Others',
];

List<String> language = [
  'English',
  'Spanish',
  'Hindi',
  'Arabic',
  'France',
  'Bengali',
  'Turkish',
  'Chinese',
  'Japanese',
  'Romanian',
  'Germany',
  'Vietnamese',
  'Italian',
  'Thai',
  'Portuguese',
  'Hebrew',
  'Polish',
  'Hungarian',
  'Finland',
  'Korean',
  'Malay',
  'Indonesian',
  'Ukrainian',
  'Bosnian',
  'Greek',
  'Dutch',
  'Urdu',
  'Sinhala',
  'Persian',
  'Serbian',
  'Khmer',
  'Lao',
  'Russian',
  'Kannada',
  'Marathi',
  'Tamil',
  'Afrikaans',
  'Czech',
  'Swedish',
  'Slovak',
  'Swahili',
  'Albanian',
  'Danish',
  'Azerbaijani',
  'Kazakh',
  'Croatian',
  'Nepali'
];

List<String> baseFlagsCode = [
  'US',
  'ES',
  'IN',
  'SA',
  'FR',
  'BD',
  'TR',
  'CN',
  'JP',
  'RO',
  'DE',
  'VN',
  'IT',
  'TH',
  'PT',
  'IL',
  'PL',
  'HU',
  'FI',
  'KR',
  'MY',
  'ID',
  'UA',
  'BA',
  'GR',
  'NL',
  'Pk',
  'LK',
  'IR',
  'RS',
  'KH',
  'LA',
  'RU',
  'IN',
  'IN',
  'IN',
  'ZA',
  'CZ',
  'SE',
  'SK',
  'TZ',
  'AL',
  'DK',
  'AZ',
  'KZ',
  'HR',
  'NP'
];

List<String> productCategory = [
  'Fashion',
  'Electronics',
  'Computer',
  'Gadgets',
  'Watches',
  'Cloths'
];

List<String> userRole = [
  'Super Admin',
  'Admin',
  'User',
];

List<String> paymentType = [
  'Cheque',
  'Deposit',
  'Cash',
  'Transfer',
  'Sales',
];
List<String> posStats = [
  'Daily',
  'Monthly',
  'Yearly',
];
List<String> saleStats = [
  'Weekly',
  'Monthly',
  'Yearly',
];

bool isRtl = false;

///------------------Language---------------------------------
// List<String> countryList = [
//   'English',
//   'Spanish',
//   'Hindi',
//   'Arabic',
//   'France',
//   'Bengali',
//   'Turkish',
//   'Chinese',
//   'Japanese',
//   'Romanian',
//   'Germany',
//   'Vietnamese',
//   'Italian',
//   'Thai',
//   'Portuguese',
//   'Hebrew',
//   'Polish',
//   'Hungarian',
//   'Finland',
//   'Korean',
//   'Malay',
//   'Indonesian',
//   'Ukrainian',
//   'Bosnian',
//   'Greek',
//   'Dutch',
//   'Urdu',
//   'Sinhala',
//   'Persian',
//   'Serbian',
//   'Khmer',
//   'Lao',
//   'Russian',
//   'Kannada',
//   'Marathi',
//   'Tamil',
//   'Afrikaans',
//   'Czech',
//   'Swedish',
//   'Slovak',
//   'Swahili',
//   'Albanian',
//   'Danish',
//   'Azerbaijani',
//   'Kazakh',
//   'Croatian',
//   'Nepali'
// ];
// String selectedCountry = 'English';

void checkCurrentUserAndRestartApp() {
  final User? user = FirebaseAuth.instance.currentUser;
  if (user?.uid == null) {
    Restart.restartApp();
  }
}

List<TaxModel> getAllTaxFromCartList({required List<AddToCartModel> cart}) {
  List<TaxModel> data = [];
  for (var element in cart) {
    if (element.subTaxes.isNotEmpty) {
      for (var element1 in element.subTaxes) {
        if (!data.any(
          (element2) => element2.name == element1.name,
        )) {
          data.add(element1);
        }
      }
    }
  }
  return data;
}

//_______________________vat_percentage________________________________
String defaultVat = 'vat';
