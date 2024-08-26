import 'package:flag/flag_widget.dart';
import 'package:flutter/material.dart';
import 'package:mobile_pos/Screens/Home/home.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constant.dart';
import 'language_provider.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
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
    'NP',
    // 'MM'
  ];
  List<String> countryList = [
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
    'Nepali',
    // "Burmese",
  ];
  String selectedCountry = 'English';

  Future<void> saveData(String data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('savedLanguage', data);
  }

  getData() async {
    final prefs = await SharedPreferences.getInstance();
    selectedCountry = prefs.getString('savedLanguage') ?? selectedCountry;
    setState(() {});
  }

  Future<void> saveDataOnLocal({required String key, required String type, required dynamic value}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (type == 'bool') prefs.setBool(key, value);
    if (type == 'string') prefs.setString(key, value);
  }

  @override
  void initState() {
    getData();
    selectedCountry;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        title: Text(
          lang.S.of(context).language,
          style: const TextStyle(color: kWhite),
        ),
        iconTheme: const IconThemeData(color: kWhite),
      ),
      backgroundColor: kMainColor,
      body: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Container(
          decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              )),
          child: ListView.builder(
              itemCount: countryList.length,
              itemBuilder: (_, index) {
                return Padding(
                  padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white,
                      border: Border.all(color: kBorderColorTextField, width: 0.7),
                    ),
                    // boxShadow: const [BoxShadow(color: kDarkWhite, offset: Offset(5, 5), spreadRadius: 2.0, blurRadius: 10.0)]),
                    child: ListTile(
                      horizontalTitleGap: 5,
                      onTap: () {
                        setState(
                          () {
                            selectedCountry = countryList[index];
                            selectedCountry == 'English'
                                ? context.read<LanguageChangeProvider>().changeLocale("en")
                                : selectedCountry == "Swahili"
                                    ? context.read<LanguageChangeProvider>().changeLocale("sw")
                                    : selectedCountry == 'Arabic'
                                        ? context.read<LanguageChangeProvider>().changeLocale("ar")
                                        : selectedCountry == 'Spanish'
                                            ? context.read<LanguageChangeProvider>().changeLocale("es")
                                            : selectedCountry == 'Hindi'
                                                ? context.read<LanguageChangeProvider>().changeLocale("hi")
                                                : selectedCountry == 'France'
                                                    ? context.read<LanguageChangeProvider>().changeLocale("fr")
                                                    : selectedCountry == "Bengali"
                                                        ? context.read<LanguageChangeProvider>().changeLocale("bn")
                                                        : selectedCountry == "Turkish"
                                                            ? context.read<LanguageChangeProvider>().changeLocale("tr")
                                                            : selectedCountry == "Chinese"
                                                                ? context.read<LanguageChangeProvider>().changeLocale("zh")
                                                                : selectedCountry == "Japanese"
                                                                    ? context.read<LanguageChangeProvider>().changeLocale("ja")
                                                                    : selectedCountry == "Romanian"
                                                                        ? context.read<LanguageChangeProvider>().changeLocale("ro")
                                                                        : selectedCountry == "Germany"
                                                                            ? context.read<LanguageChangeProvider>().changeLocale("de")
                                                                            : selectedCountry == "Vietnamese"
                                                                                ? context.read<LanguageChangeProvider>().changeLocale("vi")
                                                                                : selectedCountry == "Italian"
                                                                                    ? context.read<LanguageChangeProvider>().changeLocale("it")
                                                                                    : selectedCountry == "Thai"
                                                                                        ? context.read<LanguageChangeProvider>().changeLocale("th")
                                                                                        : selectedCountry == "Portuguese"
                                                                                            ? context.read<LanguageChangeProvider>().changeLocale("pt")
                                                                                            : selectedCountry == "Hebrew"
                                                                                                ? context.read<LanguageChangeProvider>().changeLocale("he")
                                                                                                : selectedCountry == "Polish"
                                                                                                    ? context.read<LanguageChangeProvider>().changeLocale("pl")
                                                                                                    : selectedCountry == "Hungarian"
                                                                                                        ? context.read<LanguageChangeProvider>().changeLocale("hu")
                                                                                                        : selectedCountry == "Finland"
                                                                                                            ? context.read<LanguageChangeProvider>().changeLocale("fi")
                                                                                                            : selectedCountry == "Korean"
                                                                                                                ? context.read<LanguageChangeProvider>().changeLocale("ko")
                                                                                                                : selectedCountry == "Malay"
                                                                                                                    ? context.read<LanguageChangeProvider>().changeLocale("ms")
                                                                                                                    : selectedCountry == "Indonesian"
                                                                                                                        ? context.read<LanguageChangeProvider>().changeLocale("id")
                                                                                                                        : selectedCountry == "Ukrainian"
                                                                                                                            ? context.read<LanguageChangeProvider>().changeLocale("uk")
                                                                                                                            : selectedCountry == "Bosnian"
                                                                                                                                ? context.read<LanguageChangeProvider>().changeLocale("bs")
                                                                                                                                : selectedCountry == "Greek"
                                                                                                                                    ? context.read<LanguageChangeProvider>().changeLocale("el")
                                                                                                                                    : selectedCountry == "Dutch"
                                                                                                                                        ? context.read<LanguageChangeProvider>().changeLocale("nl")
                                                                                                                                        : selectedCountry == "Urdu"
                                                                                                                                            ? context.read<LanguageChangeProvider>().changeLocale("ur")
                                                                                                                                            : selectedCountry == "Sinhala"
                                                                                                                                                ? context
                                                                                                                                                    .read<LanguageChangeProvider>()
                                                                                                                                                    .changeLocale("si")
                                                                                                                                                : selectedCountry == "Persian"
                                                                                                                                                    ? context
                                                                                                                                                        .read<LanguageChangeProvider>()
                                                                                                                                                        .changeLocale("fa")
                                                                                                                                                    : selectedCountry == "Serbian"
                                                                                                                                                        ? context
                                                                                                                                                            .read<LanguageChangeProvider>()
                                                                                                                                                            .changeLocale("sr")
                                                                                                                                                        : selectedCountry == "Khmer"
                                                                                                                                                            ? context
                                                                                                                                                                .read<LanguageChangeProvider>()
                                                                                                                                                                .changeLocale("km")
                                                                                                                                                            : selectedCountry == "Lao"
                                                                                                                                                                ? context
                                                                                                                                                                    .read<LanguageChangeProvider>()
                                                                                                                                                                    .changeLocale("lo")
                                                                                                                                                                : selectedCountry == "Russian"
                                                                                                                                                                    ? context
                                                                                                                                                                        .read<LanguageChangeProvider>()
                                                                                                                                                                        .changeLocale("ru")
                                                                                                                                                                    : selectedCountry == "Kannada"
                                                                                                                                                                        ? context
                                                                                                                                                                            .read<
                                                                                                                                                                                LanguageChangeProvider>()
                                                                                                                                                                            .changeLocale("kn")
                                                                                                                                                                        : selectedCountry == "Marathi"
                                                                                                                                                                            ? context
                                                                                                                                                                                .read<
                                                                                                                                                                                    LanguageChangeProvider>()
                                                                                                                                                                                .changeLocale("mr")
                                                                                                                                                                            : selectedCountry == "Tamil"
                                                                                                                                                                                ? context
                                                                                                                                                                                    .read<
                                                                                                                                                                                        LanguageChangeProvider>()
                                                                                                                                                                                    .changeLocale("ta")
                                                                                                                                                                                : selectedCountry ==
                                                                                                                                                                                        "Afrikaans"
                                                                                                                                                                                    ? context
                                                                                                                                                                                        .read<
                                                                                                                                                                                            LanguageChangeProvider>()
                                                                                                                                                                                        .changeLocale(
                                                                                                                                                                                            "af")
                                                                                                                                                                                    : selectedCountry ==
                                                                                                                                                                                            "Czech"
                                                                                                                                                                                        ? context
                                                                                                                                                                                            .read<
                                                                                                                                                                                                LanguageChangeProvider>()
                                                                                                                                                                                            .changeLocale(
                                                                                                                                                                                                "cs")
                                                                                                                                                                                        : selectedCountry ==
                                                                                                                                                                                                "Swedish"
                                                                                                                                                                                            ? context.read<LanguageChangeProvider>().changeLocale("sv")
                                                                                                                                                                                            : selectedCountry == "Slovak"
                                                                                                                                                                                                ? context.read<LanguageChangeProvider>().changeLocale("sk")
                                                                                                                                                                                                : selectedCountry == "Swahili"
                                                                                                                                                                                                    ? context.read<LanguageChangeProvider>().changeLocale("sw")
                                                                                                                                                                                                    : selectedCountry == "Burmese"
                                                                                                                                                                                                        ? context.read<LanguageChangeProvider>().changeLocale("my")
                                                                                                                                                                                                        : selectedCountry == "Albanian"
                                                                                                                                                                                                            ? context.read<LanguageChangeProvider>().changeLocale("sq")
                                                                                                                                                                                                            : selectedCountry == "Danish"
                                                                                                                                                                                                                ? context.read<LanguageChangeProvider>().changeLocale("da")
                                                                                                                                                                                                                : selectedCountry == "Azerbaijani"
                                                                                                                                                                                                                    ? context.read<LanguageChangeProvider>().changeLocale("az")
                                                                                                                                                                                                                    : selectedCountry == "Kazakh"
                                                                                                                                                                                                                        ? context.read<LanguageChangeProvider>().changeLocale("kk")
                                                                                                                                                                                                                        : selectedCountry == "Croatian"
                                                                                                                                                                                                                            ? context.read<LanguageChangeProvider>().changeLocale("hr")
                                                                                                                                                                                                                            : selectedCountry == "Nepali"
                                                                                                                                                                                                                                ? context.read<LanguageChangeProvider>().changeLocale("ne")
                                                                                                                                                                                                                                : context.read<LanguageChangeProvider>().changeLocale("en");
                            saveDataOnLocal(key: 'savedLanguage', type: 'string', value: selectedCountry);
                            saveData(selectedCountry);
                          },
                        );
                      },
                      leading: Container(
                        decoration: BoxDecoration(border: Border.all(color: kBorderColorTextField, width: 0.3)),
                        child: Flag.fromString(
                          baseFlagsCode[index],
                          fit: BoxFit.cover,
                          height: 25,
                          width: 30,
                        ),
                      ),
                      title: Text(countryList[index]),
                      trailing: selectedCountry == countryList[index]
                          ? const Icon(Icons.radio_button_checked, color: kMainColor)
                          : const Icon(
                              Icons.radio_button_off,
                              color: Color(0xff9F9F9F),
                            ),
                    ),
                  ),
                );
              }),
        ),
      ),
      bottomNavigationBar: Container(
        height: 95,
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.only(top: 25, left: 20, right: 20, bottom: 15),
          child: InkWell(
            onTap: () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Home()));
            },
            child: Container(
              alignment: Alignment.center,
              width: double.infinity,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: kMainColor),
              child: Text(
                lang.S.of(context).save,
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
