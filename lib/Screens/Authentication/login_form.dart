import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:mobile_pos/GlobalComponents/button_global.dart';
import 'package:mobile_pos/Screens/Authentication/register_form.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import 'package:mobile_pos/repository/login_repo.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../constant.dart';
import 'forgot_password.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  bool showPassword = true;
  late String email, password;
  GlobalKey<FormState> globalKey = GlobalKey<FormState>();

  bool validateAndSave() {
    final form = globalKey.currentState;
    if (form!.validate()) {
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
    return SafeArea(
      child: Scaffold(
        body: Consumer(builder: (context, ref, child) {
          final loginProvider = ref.watch(logInProvider);

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
                              loginProvider.email = value!;
                            },
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            keyboardType: TextInputType.text,
                            obscureText: showPassword,
                            decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              labelText: lang.S.of(context).password,
                              hintText: lang.S.of(context).pleaseEnterAPassword,
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    showPassword = !showPassword;
                                  });
                                },
                                icon: Icon(showPassword ? Icons.visibility_off : Icons.visibility),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Password can\'t be empty';
                              } else if (value.length < 4) {
                                return 'Please enter a bigger password';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              loginProvider.password = value!;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          const ForgotPassword().launch(context);
                          // Navigator.pushNamed(context, '/forgotPassword');
                        },
                        child: Text(
                          lang.S.of(context).forgotPasswords,
                          style: GoogleFonts.poppins(
                            color: kGreyTextColor,
                            fontSize: 15.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                  ButtonGlobal(
                      buttontext: lang.S.of(context).login,
                      buttonDecoration: kButtonDecoration.copyWith(color: kMainColor),
                      onPressed: () {
                        if (validateAndSave()) {
                          loginProvider.signIn(context);
                        }
                      },
                       iconWidget: null, iconColor: Colors.white,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        lang.S.of(context).havenotAnAccounts,
                        style: GoogleFonts.poppins(color: kGreyTextColor, fontSize: 15.0),
                      ),
                      TextButton(
                        onPressed: () {
                          // Navigator.pushNamed(context, '/signup');
                          const RegisterScreen().launch(context);
                        },
                        child: Text(
                          lang.S.of(context).register,
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
