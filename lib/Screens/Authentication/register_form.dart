import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:mobile_pos/GlobalComponents/button_global.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import 'package:nb_utils/nb_utils.dart';

import '../../constant.dart';
import '../../repository/signup_repo.dart';
import 'login_form.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool showPass1 = true;
  bool showPass2 = true;
  GlobalKey<FormState> globalKey = GlobalKey<FormState>();
  bool passwordShow = false;
  String? givenPassword;
  String? givenPassword2;

  bool validateAndSave() {
    final form = globalKey.currentState;
    if (form!.validate() && givenPassword == givenPassword2) {
      form.save();
      return true;
    }
    return false;
  }

  @override
  void initState() {
    getConnectivity();
    checkInternet();
    super.initState();
  }

  late StreamSubscription subscription;
  bool isDeviceConnected = false;
  bool isAlertSet = false;

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
    return SafeArea(
      child: Scaffold(
        body: Consumer(builder: (context, ref, child) {
          final auth = ref.watch(signUpProvider);
          return Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    loginScreenLogo,
                    height: 150,
                    width: 150,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Form(
                      key: globalKey,
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          TextFormField(
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              labelText: lang.S.of(context).email,
                              hintText: lang.S.of(context).enterYourEmailAddress,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Email can\'n be empty';
                              } else if (!value.contains('@')) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              auth.email = value!;
                            },
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            keyboardType: TextInputType.text,
                            obscureText: showPass1,
                            decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              labelText: lang.S.of(context).password,
                              hintText: lang.S.of(context).pleaseEnterAPassword,
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    showPass1 = !showPass1;
                                  });
                                },
                                icon: Icon(showPass1 ? Icons.visibility_off : Icons.visibility),
                              ),
                            ),
                            onChanged: (value) {
                              givenPassword = value;
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Password can\'t be empty';
                              } else if (value.length < 4) {
                                return 'Please enter a bigger password';
                              } else if (value.length < 4) {
                                return 'Please enter a bigger password';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              auth.password = value!;
                            },
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            keyboardType: TextInputType.emailAddress,
                            obscureText: showPass2,
                            decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              labelText: lang.S.of(context).confirmPassword,
                              hintText: lang.S.of(context).pleaseEnterAPassword,
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    showPass2 = !showPass2;
                                  });
                                },
                                icon: Icon(showPass2 ? Icons.visibility_off : Icons.visibility),
                              ),
                            ),
                            onChanged: (value) {
                              givenPassword2 = value;
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Password can\'t be empty';
                              } else if (value.length < 4) {
                                return 'Please enter a bigger password';
                              } else if (givenPassword != givenPassword2) {
                                return 'Password Not mach';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  ButtonGlobal(
                    buttontext: lang.S.of(context).register,
                    buttonDecoration: kButtonDecoration.copyWith(color: kMainColor),
                    onPressed: () {
                      if (validateAndSave()) {
                        auth.signUp(context);
                      }
                    },
                    iconWidget: null,
                    iconColor: Colors.white,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        lang.S.of(context).alreadyHaveAnAccounts,
                        style: GoogleFonts.poppins(color: kGreyTextColor, fontSize: 15.0),
                      ),
                      TextButton(
                        onPressed: () {
                          const LoginForm().launch(context);
                          // Navigator.pushNamed(context, '/loginForm');
                        },
                        child: Text(
                          lang.S.of(context).logIn,
                          style: GoogleFonts.poppins(
                            color: kMainColor,
                            fontSize: 15.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
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
