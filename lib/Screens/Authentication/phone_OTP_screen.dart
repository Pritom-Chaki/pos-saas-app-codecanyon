
// ignore_for_file: file_names

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:mobile_pos/Screens/Authentication/phone.dart';
import 'package:mobile_pos/Screens/Authentication/profile_setup.dart';
import 'package:mobile_pos/Screens/Authentication/success_screen.dart';
import 'package:mobile_pos/constant.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import 'package:nb_utils/nb_utils.dart';
import 'package:pinput/pinput.dart';

import '../../GlobalComponents/button_global.dart';

class OTPVerify extends StatefulWidget {
  const OTPVerify({super.key});

  @override
  State<OTPVerify> createState() => _OTPVerifyState();
}

class _OTPVerifyState extends State<OTPVerify> {
  FirebaseAuth auth = FirebaseAuth.instance;

  String code = '';
  int endTime = DateTime.now().millisecondsSinceEpoch + 1000 * 120;
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: kMainColor,
        appBar: AppBar(
          backgroundColor: kMainColor,
          elevation: 0,
          centerTitle: true,
          title:  Text(lang.S.of(context).verifyOtp),
        ),
        body: Container(
          padding: const EdgeInsets.only(left: 25, right: 25),
          alignment: Alignment.topCenter,
          decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(topRight: Radius.circular(30), topLeft: Radius.circular(30))),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Row(
                  children: [
                    Text(
                      'OTP sent to ${PhoneAuth.phoneNumber}',
                      style: const TextStyle( color: Colors.grey),
                    ),
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          const PhoneAuth().launch(context, isNewTask: true);
                        },
                        child:  Text(
                          lang.S.of(context).change,
                          style: const TextStyle(color: Colors.redAccent),
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 30),
                Pinput(
                    defaultPinTheme: PinTheme(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.all(Radius.circular(10)),
                        border: Border.all(width: 1, color: kMainColor),
                        color: kMainColor.withOpacity(0.1),
                      ),
                    ),
                    length: 6,
                    showCursor: true,
                    onCompleted: (pin) {
                      code = pin;
                    }),
                const SizedBox(height: 20),
                Row(
                  children: [
                     Text(
                      lang.S.of(context).resendOtp,
                      style: const TextStyle(fontSize: 17, color: Colors.grey),
                    ),
                    CountdownTimer(
                      textStyle: const TextStyle(fontSize: 17, color: Colors.black),
                      endTime: endTime,
                      endWidget: TextButton(
                        onPressed: () async {
                          EasyLoading.show(status: 'Loading', dismissOnTap: false);
                          try {
                            await FirebaseAuth.instance.verifyPhoneNumber(
                              phoneNumber: PhoneAuth.phoneNumber,
                              verificationCompleted: (PhoneAuthCredential credential) {},
                              verificationFailed: (FirebaseAuthException e) {},
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
                        },
                        child:  Text(
                          lang.S.of(context).resendCode,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                ButtonGlobalWithoutIcon(
                    buttontext: lang.S.of(context).verifyPhoneNumber,
                    buttonDecoration: kButtonDecoration.copyWith(color: kMainColor, borderRadius: const BorderRadius.all(Radius.circular(30))),
                    onPressed: () async {
                      EasyLoading.show(status: 'Loading');
                      try {
                        PhoneAuthCredential credential = PhoneAuthProvider.credential(verificationId: PhoneAuth.verify, smsCode: code);
                        await auth.signInWithCredential(credential).then((value) async{
                          if (value.additionalUserInfo!.isNewUser) {
                            EasyLoading.dismiss();
                            const ProfileSetup().launch(context);
                          } else {
                            EasyLoading.dismiss();
                            Future.delayed(const Duration(milliseconds: 500), () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) =>  SuccessScreen(email: 'phone',)),
                              );
                            });
                            // await Future.delayed(const Duration(seconds: 1)).then((value) => const Home().launch(context));
                          }
                        });
                      } catch (e) {
                        EasyLoading.showError('Wrong OTP');
                      }
                    },
                    buttonTextColor: Colors.white),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
