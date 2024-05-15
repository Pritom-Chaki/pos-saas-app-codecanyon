import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_pos/Language/language_provider.dart';
import 'package:mobile_pos/Screens/Authentication/forgot_password.dart';
import 'package:mobile_pos/Screens/Authentication/login_form.dart';
import 'package:mobile_pos/Screens/Authentication/register_form.dart';
import 'package:mobile_pos/Screens/Authentication/sign_in.dart';
import 'package:mobile_pos/Screens/Authentication/success_screen.dart';
import 'package:mobile_pos/Screens/Customers/customer_list.dart';
import 'package:mobile_pos/Screens/Delivery/delivery_address_list.dart';
import 'package:mobile_pos/Screens/Expense/expense_list.dart';
import 'package:mobile_pos/Screens/Home/home.dart';
import 'package:mobile_pos/Screens/Loss_Profit/loss_profit_screen.dart';
import 'package:mobile_pos/Screens/Payment/payment_options.dart';
import 'package:mobile_pos/Screens/Products/product_list.dart';
import 'package:mobile_pos/Screens/Profile/profile_screen.dart';
import 'package:mobile_pos/Screens/Purchase/purchase_contact.dart';
import 'package:mobile_pos/Screens/Report/reports.dart';
import 'package:mobile_pos/Screens/Sales/add_discount.dart';
import 'package:mobile_pos/Screens/Sales/add_promo_code.dart';
import 'package:mobile_pos/Screens/Sales/sales_contact.dart';
import 'package:mobile_pos/Screens/Sales/sales_details.dart';
import 'package:mobile_pos/Screens/SplashScreen/on_board.dart';
import 'package:mobile_pos/Screens/SplashScreen/splash_screen.dart';
import 'package:mobile_pos/Screens/custom_print/custom_print.dart';
import 'package:mobile_pos/Screens/stock_list/stock_list.dart';
import 'package:mobile_pos/constant.dart';
import 'package:provider/provider.dart' as pro;

import 'Screens/Authentication/profile_setup.dart';
import 'Screens/Due Calculation/due_calculation_contact_screen.dart';
import 'Screens/Legder/ledger_screen.dart';
import 'Screens/Purchase List/purchase_list_screen.dart';
import 'Screens/Purchase/choose_supplier_screen.dart';
import 'Screens/Sales List/sales_list_screen.dart';
import 'Screens/Warranty/warranty_screen.dart';
import 'generated/l10n.dart';

void configLoading() {
  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 2000)
    ..indicatorType = EasyLoadingIndicatorType.fadingCircle
    ..loadingStyle = EasyLoadingStyle.dark
    ..indicatorSize = 45.0
    ..radius = 10.0
    ..progressColor = Colors.white
    ..backgroundColor = kMainColor
    ..indicatorColor = Colors.yellow
    ..textColor = Colors.white
    ..maskColor = kMainColor.withOpacity(0.5)
    ..userInteractions = true
    ..dismissOnTap = false;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseDatabase.instance.setPersistenceEnabled(true);
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return pro.ChangeNotifierProvider<LanguageChangeProvider>(
        create: (context) => LanguageChangeProvider(),
        child: Builder(
            builder: (context) => MaterialApp(
                  debugShowCheckedModeBanner: false,
                  locale: pro.Provider.of<LanguageChangeProvider>(context, listen: true).currentLocale,
                  localizationsDelegates: const [
                    S.delegate,
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                  ],
                  supportedLocales: S.delegate.supportedLocales,
                  title: 'Pix Pos',
                  initialRoute: '/',
                  builder: EasyLoading.init(),
                  routes: {
                    '/': (context) => const SplashScreen(),
                    // '/': (context) => const ProPackagesScreen(),
                    '/onBoard': (context) => const OnBoard(),
                    '/signIn': (context) => const SignInScreen(),
                    '/loginForm': (context) => const LoginForm(),
                    '/signup': (context) => const RegisterScreen(),
                    '/purchaseCustomer': (context) => const PurchaseContact(),
                    '/forgotPassword': (context) => const ForgotPassword(),
                    '/success': (context) => SuccessScreen(),
                    '/setupProfile': (context) => const ProfileSetup(),
                    '/home': (context) => const Home(),
                    '/profile': (context) => const ProfileScreen(),
                    // '/SMS': (context) => const SendSms(),
                    // ignore: missing_required_param

                    // '/AddProducts': (context) => AddProduct(),
                    // '/UpdateProducts': (context) => const UpdateProduct(),

                    '/Product': (context) => const ProductList(),
                    '/Sale List': (context) => const SalesListScreen(),
                    // ignore: missing_required_param
                    '/SalesDetails': (context) => SalesDetails(),
                    // ignore: prefer_const_constructors
                    '/salesCustomer': (context) => SalesContact(isFromHome: false),
                    '/addPromoCode': (context) => const AddPromoCode(),
                    '/addDiscount': (context) => const AddDiscount(),
                    '/Sales': (context) => const SalesContact(isFromHome: false),
                    '/Parties': (context) => const CustomerList(),
                    '/Expense': (context) => const ExpenseList(),
                    '/Stock List': (context) => const StockList(),
                    '/Purchase': (context) => const PurchaseContacts(),
                    '/Delivery': (context) => const DeliveryAddress(),
                    '/Reports': (context) => const Reports(isFromHome: false),
                    '/Due List': (context) => const DueCalculationContactScreen(),
                    '/PaymentOptions': (context) => const PaymentOptions(),
                    '/Sales List': (context) => const SalesListScreen(),
                    '/Purchase List': (context) => const PurchaseListScreen(),
                    '/Loss/Profit': (context) => const LossProfitScreen(),
                    '/Ledger': (context) => const LedgerScreen(),
                    '/CustomPrint': (context) => const CustomPrint(),
                    '/Warranty': (context) => const WarrantyScreen(),
                  },
                )));
  }
}
