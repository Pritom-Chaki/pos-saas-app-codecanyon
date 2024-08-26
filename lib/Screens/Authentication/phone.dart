import 'dart:async';

import 'package:country_picker/country_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:mobile_pos/Screens/Authentication/phone_OTP_screen.dart';
import 'package:mobile_pos/constant.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import 'package:nb_utils/nb_utils.dart';

import '../../GlobalComponents/button_global.dart';
import 'login_form.dart';

class PhoneAuth extends StatefulWidget {
  const PhoneAuth({super.key});
  static String verify = '';
  static String phoneNumber = '';

  @override
  State<PhoneAuth> createState() => _PhoneAuthState();
}

class _PhoneAuthState extends State<PhoneAuth> {
  TextEditingController countryController = TextEditingController();

  String phoneNumber = '';
  late StreamSubscription subscription;
  String countryFlag = '🇹🇿';
  String countryName = 'Tanzania';
  String countryCode = '255';
  bool isDeviceConnected = false;
  bool isAlertSet = false;

  @override
  void initState() {
    super.initState();
    getConnectivity();
    checkInternet();
  }

  // getConnectivity() => subscription = Connectivity().onConnectivityChanged.listen(
  //       (ConnectivityResult result) async {
  //         isDeviceConnected = await InternetConnectionChecker().hasConnection;
  //         if (!isDeviceConnected && isAlertSet == false) {
  //           showDialogBox();
  //           setState(() => isAlertSet = true);
  //         }
  //       },
  //     );

  void connectivityCallback(List<ConnectivityResult> results) async {
    // Since it's likely that only one result will be received,
    // you can handle just the first one.
    ConnectivityResult result = results.first;

    isDeviceConnected = await InternetConnectionChecker().hasConnection;
    if (!isDeviceConnected && !isAlertSet) {
      showDialogBox();
      setState(() => isAlertSet = true);
    }
  }

  getConnectivity() {
    subscription = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      connectivityCallback(results);
    });
  }

  checkInternet() async {
    isDeviceConnected = await InternetConnectionChecker().hasConnection;
    if (!isDeviceConnected) {
      showDialogBox();
      setState(() => isAlertSet = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kMainColor,
      appBar: AppBar(
        backgroundColor: kMainColor,
        elevation: 0,
        title: const Text('Sign In'),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(topRight: Radius.circular(30), topLeft: Radius.circular(30))),
        child: Container(
          padding: const EdgeInsets.only(left: 25, right: 25),
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(lang.S.of(context).manageYourBussinessWith),
                    const Text(
                      'POS SAAS',
                      style: TextStyle(color: kMainColor, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    // const Image(width: 100, image: AssetImage('images/sb.png')),
                  ],
                ),
                const SizedBox(height: 30),
                GestureDetector(
                  onTap: () {
                    showCountryPicker(
                      context: context,
                      favorite: <String>['TZ'],
                      showPhoneCode: true,
                      onSelect: (Country country) {
                        setState(() {
                          countryCode = country.phoneCode;
                          countryName = country.name;
                          countryFlag = country.flagEmoji;
                        });
                      },
                      // Optional. Sets the theme for the country list picker.
                      countryListTheme: CountryListThemeData(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(30.0),
                          topRight: Radius.circular(30.0),
                        ),
                        // Optional. Styles the search field.
                        inputDecoration: InputDecoration(
                          labelText: lang.S.of(context).search,
                          hintText: lang.S.of(context).startTypingToSearch,
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: const Color(0xFF8C98A8).withOpacity(0.2),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      Text(
                        '$countryFlag  $countryName',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const Icon(
                        Icons.arrow_drop_down_outlined,
                        color: kMainColor,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  height: 55,
                  decoration: BoxDecoration(border: Border.all(width: 1, color: Colors.grey), borderRadius: BorderRadius.circular(10)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(width: 10),
                      SizedBox(
                        width: 40,
                        child: Text('+$countryCode'),
                      ),
                      const Text(
                        "|",
                        style: TextStyle(fontSize: 33, color: Colors.grey),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                          child: TextField(
                        onChanged: (value) {
                          phoneNumber = value;
                          PhoneAuth.phoneNumber = '+$countryCode${value.toInt().toString()}';
                        },
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: lang.S.of(context).enterYourPhoneNumber,
                        ),
                      ))
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginForm(),
                      ),
                    );
                  },
                  child: const Text(
                    'Sign in with email',
                    style: TextStyle(
                      color: kMainColor,
                    ),
                  ),
                ),
                ButtonGlobalWithoutIcon(
                    buttontext: lang.S.of(context).getOtp,
                    buttonDecoration: kButtonDecoration.copyWith(color: kMainColor, borderRadius: const BorderRadius.all(Radius.circular(30))),
                    onPressed: () async {
                      if (phoneNumber.length >= 8 && phoneNumber.isDigit()) {
                        EasyLoading.show(status: 'Loading', dismissOnTap: false);
                        try {
                          await FirebaseAuth.instance.verifyPhoneNumber(
                            phoneNumber: '+$countryCode$phoneNumber',
                            verificationCompleted: (PhoneAuthCredential credential) {},
                            verificationFailed: (FirebaseAuthException e) {
                              print(e.toString());
                              EasyLoading.showError('Phone number is not valid');
                            },
                            codeSent: (String verificationId, int? resendToken) {
                              EasyLoading.dismiss();
                              PhoneAuth.verify = verificationId;
                              const OTPVerify().launch(context, isNewTask: true);
                            },
                            codeAutoRetrievalTimeout: (String verificationId) {},
                          );
                        } catch (e) {
                          EasyLoading.showError('Error');
                        }
                      } else {
                        EasyLoading.showError('Enter a valid phone number.');
                      }
                    },
                    buttonTextColor: Colors.white),
                const SizedBox(height: 30),
                Center(child: Image(height: context.width() / 1.4, width: context.width() / 1.4, image: const AssetImage('images/otp_screen_image.png')))
              ],
            ),
          ),
        ),
      ),
    );
  }

  showDialogBox() => showCupertinoDialog<String>(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
          title: Text(lang.S.of(context).noConnection),
          content: Text(lang.S.of(context).pleaseCheckYourInternetConnectivity),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                Navigator.pop(context, 'Cancel');
                setState(() => isAlertSet = false);
                isDeviceConnected = await InternetConnectionChecker().hasConnection;
                if (!isDeviceConnected && isAlertSet == false) {
                  showDialogBox();
                  setState(() => isAlertSet = true);
                }
              },
              child: Text(lang.S.of(context).tryAgain),
            ),
          ],
        ),
      );
}
