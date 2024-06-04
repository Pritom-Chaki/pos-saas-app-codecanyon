import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_pos/Screens/SplashScreen/on_board.dart';
import 'package:mobile_pos/constant.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import 'package:nb_utils/nb_utils.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../Language/language_provider.dart';
import '../../currency.dart';
import '../Home/home.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String newUpdateVersion = '1.1';
  var currentUser = FirebaseAuth.instance.currentUser;
  bool isUpdateAvailable = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  void showSnack(String text) {
    if (_scaffoldKey.currentContext != null) {
      ScaffoldMessenger.of(_scaffoldKey.currentContext!)
          .showSnackBar(SnackBar(content: Text(text)));
    }
  }

  void getPermission() async {
    await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.notification,
      Permission.storage
    ].request();
  }

  Future<void> updateNotifier() async {
    final prefs = await SharedPreferences.getInstance();
    isRtl = prefs.getBool('isRtl') ?? false;
    await Future.delayed(const Duration(seconds: 3));
    if (currentUser != null) {
      isPrintEnable = prefs.getBool('isPrintEnable') ?? false;
      const Home().launch(context, isNewTask: true);
    } else {
      isPrintEnable = prefs.getBool('isPrintEnable') ?? false;
      const OnBoard().launch(context, isNewTask: true);
    }
  }

  final CurrentUserData currentUserData = CurrentUserData();

  @override
  void initState() {
    super.initState();
    getPermission();
    setLanguage();
    updateNotifier();
    // getCurrency();
    currentUserData.getUserData();
  }

  void setLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    String selectedLanguage = prefs.getString('savedLanguage') ?? 'English';
    selectedLanguage == 'English'
        ? context.read<LanguageChangeProvider>().changeLocale("en")
        : selectedLanguage == "Swahili"
            ? context.read<LanguageChangeProvider>().changeLocale("sw")
            : selectedLanguage == 'Arabic'
                ? context.read<LanguageChangeProvider>().changeLocale("ar")
                : selectedLanguage == 'Spanish'
                    ? context.read<LanguageChangeProvider>().changeLocale("es")
                    : selectedLanguage == 'Hindi'
                        ? context
                            .read<LanguageChangeProvider>()
                            .changeLocale("hi")
                        : selectedLanguage == 'France'
                            ? context
                                .read<LanguageChangeProvider>()
                                .changeLocale("fr")
                            : selectedLanguage == "Bengali"
                                ? context
                                    .read<LanguageChangeProvider>()
                                    .changeLocale("bn")
                                : selectedLanguage == "Turkish"
                                    ? context
                                        .read<LanguageChangeProvider>()
                                        .changeLocale("tr")
                                    : selectedLanguage == "Chinese"
                                        ? context
                                            .read<LanguageChangeProvider>()
                                            .changeLocale("zh")
                                        : selectedLanguage == "Japanese"
                                            ? context
                                                .read<LanguageChangeProvider>()
                                                .changeLocale("ja")
                                            : selectedLanguage == "Romanian"
                                                ? context
                                                    .read<
                                                        LanguageChangeProvider>()
                                                    .changeLocale("ro")
                                                : selectedLanguage == "Germany"
                                                    ? context
                                                        .read<
                                                            LanguageChangeProvider>()
                                                        .changeLocale("de")
                                                    : selectedLanguage ==
                                                            "Vietnamese"
                                                        ? context
                                                            .read<
                                                                LanguageChangeProvider>()
                                                            .changeLocale("vi")
                                                        : selectedLanguage ==
                                                                "Italian"
                                                            ? context
                                                                .read<
                                                                    LanguageChangeProvider>()
                                                                .changeLocale(
                                                                    "it")
                                                            : selectedLanguage ==
                                                                    "Thai"
                                                                ? context
                                                                    .read<
                                                                        LanguageChangeProvider>()
                                                                    .changeLocale(
                                                                        "th")
                                                                : selectedLanguage ==
                                                                        "Portuguese"
                                                                    ? context.read<LanguageChangeProvider>().changeLocale("pt")
                                                                    : selectedLanguage == "Hebrew"
                                                                        ? context.read<LanguageChangeProvider>().changeLocale("he")
                                                                        : selectedLanguage == "Polish"
                                                                            ? context.read<LanguageChangeProvider>().changeLocale("pl")
                                                                            : selectedLanguage == "Hungarian"
                                                                                ? context.read<LanguageChangeProvider>().changeLocale("hu")
                                                                                : selectedLanguage == "Finland"
                                                                                    ? context.read<LanguageChangeProvider>().changeLocale("fi")
                                                                                    : selectedLanguage == "Korean"
                                                                                        ? context.read<LanguageChangeProvider>().changeLocale("ko")
                                                                                        : selectedLanguage == "Malay"
                                                                                            ? context.read<LanguageChangeProvider>().changeLocale("ms")
                                                                                            : selectedLanguage == "Indonesian"
                                                                                                ? context.read<LanguageChangeProvider>().changeLocale("id")
                                                                                                : selectedLanguage == "Ukrainian"
                                                                                                    ? context.read<LanguageChangeProvider>().changeLocale("uk")
                                                                                                    : selectedLanguage == "Bosnian"
                                                                                                        ? context.read<LanguageChangeProvider>().changeLocale("bs")
                                                                                                        : selectedLanguage == "Greek"
                                                                                                            ? context.read<LanguageChangeProvider>().changeLocale("el")
                                                                                                            : selectedLanguage == "Dutch"
                                                                                                                ? context.read<LanguageChangeProvider>().changeLocale("nl")
                                                                                                                : selectedLanguage == "Urdu"
                                                                                                                    ? context.read<LanguageChangeProvider>().changeLocale("ur")
                                                                                                                    : selectedLanguage == "Sinhala"
                                                                                                                        ? context.read<LanguageChangeProvider>().changeLocale("si")
                                                                                                                        : selectedLanguage == "Persian"
                                                                                                                            ? context.read<LanguageChangeProvider>().changeLocale("fa")
                                                                                                                            : selectedLanguage == "Serbian"
                                                                                                                                ? context.read<LanguageChangeProvider>().changeLocale("sr")
                                                                                                                                : selectedLanguage == "Khmer"
                                                                                                                                    ? context.read<LanguageChangeProvider>().changeLocale("km")
                                                                                                                                    : selectedLanguage == "Lao"
                                                                                                                                        ? context.read<LanguageChangeProvider>().changeLocale("lo")
                                                                                                                                        : selectedLanguage == "Russian"
                                                                                                                                            ? context.read<LanguageChangeProvider>().changeLocale("ru")
                                                                                                                                            : selectedLanguage == "Kannada"
                                                                                                                                                ? context.read<LanguageChangeProvider>().changeLocale("kn")
                                                                                                                                                : selectedLanguage == "Marathi"
                                                                                                                                                    ? context.read<LanguageChangeProvider>().changeLocale("mr")
                                                                                                                                                    : selectedLanguage == "Tamil"
                                                                                                                                                        ? context.read<LanguageChangeProvider>().changeLocale("ta")
                                                                                                                                                        : selectedLanguage == "Afrikaans"
                                                                                                                                                            ? context.read<LanguageChangeProvider>().changeLocale("af")
                                                                                                                                                            : selectedLanguage == "Czech"
                                                                                                                                                                ? context.read<LanguageChangeProvider>().changeLocale("cs")
                                                                                                                                                                : selectedLanguage == "Swedish"
                                                                                                                                                                    ? context.read<LanguageChangeProvider>().changeLocale("sv")
                                                                                                                                                                    : selectedLanguage == "Slovak"
                                                                                                                                                                        ? context.read<LanguageChangeProvider>().changeLocale("sk")
                                                                                                                                                                        : selectedLanguage == "Swahili"
                                                                                                                                                                            ? context.read<LanguageChangeProvider>().changeLocale("sw")
                                                                                                                                                                            : selectedLanguage == "Burmese"
                                                                                                                                                                                ? context.read<LanguageChangeProvider>().changeLocale("my")
                                                                                                                                                                                : selectedLanguage == "Albanian"
                                                                                                                                                                                    ? context.read<LanguageChangeProvider>().changeLocale("sq")
                                                                                                                                                                                    : selectedLanguage == "Danish"
                                                                                                                                                                                        ? context.read<LanguageChangeProvider>().changeLocale("da")
                                                                                                                                                                                        : selectedLanguage == "Azerbaijani"
                                                                                                                                                                                            ? context.read<LanguageChangeProvider>().changeLocale("az")
                                                                                                                                                                                            : selectedLanguage == "Kazakh"
                                                                                                                                                                                                ? context.read<LanguageChangeProvider>().changeLocale("kk")
                                                                                                                                                                                                : selectedLanguage == "Croatian"
                                                                                                                                                                                                    ? context.read<LanguageChangeProvider>().changeLocale("hr")
                                                                                                                                                                                                    : selectedLanguage == "Nepali"
                                                                                                                                                                                                        ? context.read<LanguageChangeProvider>().changeLocale("ne")
                                                                                                                                                                                                        : context.read<LanguageChangeProvider>().changeLocale("en");
    // selectedLanguage == 'Arabic' ? isArabic = true : isArabic = false;
  }

  // void getCurrency() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   String? data = prefs.getString('currency');
  //   if (!data.isEmptyOrNull) {
  //     currency = data!;
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Directionality(
        textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
        child: Scaffold(
          backgroundColor: kMainColor,
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),
              Container(
                height: 220,
                width: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: AssetImage(splashScreenLogo),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const Spacer(),
              Column(
                children: [
                  Center(
                    child: Text(
                      'Powered By $appName',
                      style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.normal,
                          fontSize: 17),
                    ),
                  ),
                  Center(
                    child: Text(
                      'V $appVersion',
                      style: GoogleFonts.poppins(
                          color: Colors.white, fontWeight: FontWeight.normal),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
