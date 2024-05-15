import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_pos/GlobalComponents/button_global.dart';
import 'package:mobile_pos/Screens/Authentication/login_form.dart';
import 'package:mobile_pos/constant.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import 'package:mobile_pos/model/user_role_model.dart';
import 'package:nb_utils/nb_utils.dart';

class AddUserRole extends StatefulWidget {
  const AddUserRole({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AddUserRoleState createState() => _AddUserRoleState();
}

class _AddUserRoleState extends State<AddUserRole> {
  GlobalKey<FormState> globalKey = GlobalKey<FormState>();
  bool validateAndSave() {
    final form = globalKey.currentState;
    if (form!.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  bool allPermissions = false;
  bool salePermission = false;
  bool partiesPermission = false;
  bool purchasePermission = false;
  bool productPermission = false;
  bool profileEditPermission = false;
  bool addExpensePermission = false;
  bool lossProfitPermission = false;
  bool dueListPermission = false;
  bool stockPermission = false;
  bool reportsPermission = false;
  bool salesListPermission = false;
  bool purchaseListPermission = false;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController titleController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, __) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(
            lang.S.of(context).addUserRole,
            style: GoogleFonts.poppins(
              color: Colors.black,
            ),
          ),
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.black),
          elevation: 0.0,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(width: 0.5, color: kGreyTextColor),
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                    ),
                    child: Column(
                      children: [
                        ///_______all_&_sale____________________________________________
                        Row(
                          children: [
                            ///_______all__________________________
                            SizedBox(
                              width: context.width() / 2 - 20,
                              child: CheckboxListTile(
                                value: allPermissions,
                                onChanged: (value) {
                                  if (value == true) {
                                    setState(() {
                                      allPermissions = value!;
                                      salePermission = true;
                                      partiesPermission = true;
                                      purchasePermission = true;
                                      productPermission = true;
                                      profileEditPermission = true;
                                      addExpensePermission = true;
                                      lossProfitPermission = true;
                                      dueListPermission = true;
                                      stockPermission = true;
                                      reportsPermission = true;
                                      salesListPermission = true;
                                      purchaseListPermission = true;
                                    });
                                  } else {
                                    setState(() {
                                      allPermissions = value!;
                                      salePermission = false;
                                      partiesPermission = false;
                                      purchasePermission = false;
                                      productPermission = false;
                                      profileEditPermission = false;
                                      addExpensePermission = false;
                                      lossProfitPermission = false;
                                      dueListPermission = false;
                                      stockPermission = false;
                                      reportsPermission = false;
                                      salesListPermission = false;
                                      purchaseListPermission = false;
                                    });
                                  }
                                },
                                title:  Text(lang.S.of(context).all),
                              ),
                            ),
                          ],
                        ),

                        ///_______Edit Profile_&_sale____________________________________________
                        Row(
                          children: [
                            ///_______Edit_Profile_________________________
                            Expanded(
                              child: CheckboxListTile(
                                value: profileEditPermission,
                                onChanged: (value) {
                                  setState(() {
                                    profileEditPermission = value!;
                                  });
                                },
                                title:  Text(lang.S.of(context).profileEdit),
                              ),
                            ),

                            ///______sales____________________________
                            Expanded(
                              child: CheckboxListTile(
                                value: salePermission,
                                onChanged: (value) {
                                  setState(() {
                                    salePermission = value!;
                                  });
                                },
                                title:  Text(lang.S.of(context).sales),
                              ),
                            ),
                          ],
                        ),

                        ///_____parties_&_Purchase_________________________________________
                        Row(
                          children: [
                            Expanded(
                              child: CheckboxListTile(
                                value: partiesPermission,
                                onChanged: (value) {
                                  setState(() {
                                    partiesPermission = value!;
                                  });
                                },
                                title:  Text(lang.S.of(context).parties),
                              ),
                            ),
                            Expanded(
                              child: CheckboxListTile(
                                value: purchasePermission,
                                onChanged: (value) {
                                  setState(() {
                                    purchasePermission = value!;
                                  });
                                },
                                title:  Text(lang.S.of(context).purchase),
                              ),
                            ),
                          ],
                        ),

                        ///_____Product_&_DueList_________________________________________
                        Row(
                          children: [
                            Expanded(
                              child: CheckboxListTile(
                                value: productPermission,
                                onChanged: (value) {
                                  setState(() {
                                    productPermission = value!;
                                  });
                                },
                                title:  Text(lang.S.of(context).product),
                              ),
                            ),
                            Expanded(
                              child: CheckboxListTile(
                                value: dueListPermission,
                                onChanged: (value) {
                                  setState(() {
                                    dueListPermission = value!;
                                  });
                                },
                                title:  Text(lang.S.of(context).dueList),
                              ),
                            ),
                          ],
                        ),

                        ///_____Stock_&_Reports_________________________________________
                        Row(
                          children: [
                            Expanded(
                              child: CheckboxListTile(
                                value: stockPermission,
                                onChanged: (value) {
                                  setState(() {
                                    stockPermission = value!;
                                  });
                                },
                                title:  Text(lang.S.of(context).stocks),
                              ),
                            ),
                            Expanded(
                              child: CheckboxListTile(
                                value: reportsPermission,
                                onChanged: (value) {
                                  setState(() {
                                    reportsPermission = value!;
                                  });
                                },
                                title:  Text(lang.S.of(context).reports),
                              ),
                            ),
                          ],
                        ),

                        ///_____SalesList_&_Purchase List_________________________________________
                        Row(
                          children: [
                            Expanded(
                              child: CheckboxListTile(
                                value: salesListPermission,
                                onChanged: (value) {
                                  setState(() {
                                    salesListPermission = value!;
                                  });
                                },
                                title:  Text(lang.S.of(context).salesList),
                              ),
                            ),
                            Expanded(
                              child: CheckboxListTile(
                                value: purchaseListPermission,
                                onChanged: (value) {
                                  setState(() {
                                    purchaseListPermission = value!;
                                  });
                                },
                                title: Text(lang.S.of(context).purchaseList),
                              ),
                            ),
                          ],
                        ),

                        ///_____LossProfit_&_Expense_________________________________________
                        Row(
                          children: [
                            Expanded(
                              child: CheckboxListTile(
                                value: lossProfitPermission,
                                onChanged: (value) {
                                  setState(() {
                                    lossProfitPermission = value!;
                                  });
                                },
                                title: Text(lang.S.of(context).lossOrProfit),
                              ),
                            ),
                            Expanded(
                              child: CheckboxListTile(
                                value: addExpensePermission,
                                onChanged: (value) {
                                  setState(() {
                                    addExpensePermission = value!;
                                  });
                                },
                                title:  Text(lang.S.of(context).expense),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                ///___________Text_fields_____________________________________________
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Form(
                    key: globalKey,
                    child: Column(
                      children: [
                        ///__________email_________________________________________________________
                        AppTextField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Email can\'n be empty';
                            } else if (!value.contains('@')) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                          showCursor: true,
                          controller: emailController,
                          // cursorColor: kTitleColor,
                          decoration: kInputDecoration.copyWith(
                            labelText: lang.S.of(context).email,
                            // labelStyle: kTextStyle.copyWith(color: kTitleColor),
                            hintText: lang.S.of(context).enterYourEmailAddress,
                            // hintStyle: kTextStyle.copyWith(color: kLitGreyColor),
                            contentPadding: const EdgeInsets.all(10.0),
                            enabledBorder: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(4.0),
                              ),
                              borderSide: BorderSide(color: kBorderColorTextField, width: 1),
                            ),
                            errorBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.red)),
                            focusedBorder: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(4.0)),
                              borderSide: BorderSide(color: kBorderColorTextField, width: 2),
                            ),
                          ),
                          textFieldType: TextFieldType.EMAIL,
                        ),
                        const SizedBox(height: 20.0),

                        ///______password___________________________________________________________
                        AppTextField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Password can\'t be empty';
                            } else if (value.length < 4) {
                              return 'Please enter a bigger password';
                            }
                            return null;
                          },
                          controller: passwordController,
                          showCursor: true,
                          // cursorColor: kTitleColor,
                          decoration: kInputDecoration.copyWith(
                            labelText: lang.S.of(context).password,
                            floatingLabelAlignment: FloatingLabelAlignment.start,
                            // labelStyle: kTextStyle.copyWith(color: kTitleColor),
                            hintText: lang.S.of(context).enterYourPassword,
                            // hintStyle: kTextStyle.copyWith(color: kLitGreyColor),
                            contentPadding: const EdgeInsets.all(10.0),
                            enabledBorder: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(4.0),
                              ),
                              borderSide: BorderSide(color: kBorderColorTextField, width: 1),
                            ),
                            errorBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.red)),
                            focusedBorder: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(4.0)),
                              borderSide: BorderSide(color: kBorderColorTextField, width: 2),
                            ),
                          ),
                          textFieldType: TextFieldType.PASSWORD,
                        ),

                        ///________retype_email____________________________________________________
                        const SizedBox(height: 20.0),
                        AppTextField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Password can\'t be empty';
                            } else if (value != passwordController.text) {
                              return 'Password and confirm password does not match';
                            } else if (value.length < 4) {
                              return 'Please enter a bigger password';
                            }
                            return null;
                          },
                          controller: confirmPasswordController,
                          showCursor: true,
                          // cursorColor: kTitleColor,
                          decoration: kInputDecoration.copyWith(
                            labelText: lang.S.of(context).password,
                            floatingLabelAlignment: FloatingLabelAlignment.start,
                            // labelStyle: kTextStyle.copyWith(color: kTitleColor),
                            hintText: lang.S.of(context).enterYourPassword,
                            // hintStyle: kTextStyle.copyWith(color: kLitGreyColor),
                            contentPadding: const EdgeInsets.all(10.0),
                            errorBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.red)),
                            enabledBorder: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(4.0),
                              ),
                              borderSide: BorderSide(color: kBorderColorTextField, width: 1),
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(4.0)),
                              borderSide: BorderSide(color: kBorderColorTextField, width: 2),
                            ),
                          ),
                          textFieldType: TextFieldType.PASSWORD,
                        ),

                        ///__________Title_________________________________________________________
                        const SizedBox(height: 20.0),
                        AppTextField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'User title can\'n be empty';
                            }
                            return null;
                          },
                          showCursor: true,
                          controller: titleController,
                          decoration: kInputDecoration.copyWith(
                            labelText: lang.S.of(context).userTitle,
                            hintText: lang.S.of(context).enterUserTitle,
                            contentPadding: const EdgeInsets.all(10.0),
                            errorBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.red)),
                            enabledBorder: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(4.0),
                              ),
                              borderSide: BorderSide(color: kBorderColorTextField, width: 1),
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(4.0)),
                              borderSide: BorderSide(color: kBorderColorTextField, width: 2),
                            ),
                          ),
                          textFieldType: TextFieldType.EMAIL,
                        ),
                        const SizedBox(height: 20.0),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(10.0),
          child: ButtonGlobalWithoutIcon(
              buttontext: lang.S.of(context).create,
              buttonDecoration: kButtonDecoration.copyWith(color: kMainColor),
              onPressed: (() {
                if (salePermission ||
                    partiesPermission ||
                    purchasePermission ||
                    productPermission ||
                    profileEditPermission ||
                    addExpensePermission ||
                    lossProfitPermission ||
                    dueListPermission ||
                    stockPermission ||
                    reportsPermission ||
                    salesListPermission ||
                    purchaseListPermission) {
                  if (validateAndSave()) {
                    UserRoleModel userRoleData = UserRoleModel(
                      email: emailController.text,
                      userTitle: titleController.text,
                      databaseId: FirebaseAuth.instance.currentUser!.uid,
                      salePermission: salePermission,
                      partiesPermission: partiesPermission,
                      purchasePermission: purchasePermission,
                      productPermission: productPermission,
                      profileEditPermission: profileEditPermission,
                      addExpensePermission: addExpensePermission,
                      lossProfitPermission: lossProfitPermission,
                      dueListPermission: dueListPermission,
                      stockPermission: stockPermission,
                      reportsPermission: reportsPermission,
                      salesListPermission: salesListPermission,
                      purchaseListPermission: purchaseListPermission,
                    );
                    // print(FirebaseAuth.instance.currentUser!.uid);
                    signUp(
                      context: context,
                      email: emailController.text,
                      password: passwordController.text,
                      ref: ref,
                      userRoleModel: userRoleData,
                    );
                  }
                } else {
                  EasyLoading.showError('You Have To Give Permission');
                }
              }),
              buttonTextColor: Colors.white),
        ),
      );
    });
  }
}

void signUp({required BuildContext context, required String email, required String password, required WidgetRef ref, required UserRoleModel userRoleModel}) async {
  if(!isDemo){
    EasyLoading.show(status: 'Registering....');
    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
      // ignore: unnecessary_null_comparison
      if (userCredential != null) {
        await FirebaseDatabase.instance.ref().child(userRoleModel.databaseId).child('User Role').push().set(userRoleModel.toJson());
        await FirebaseDatabase.instance.ref().child('Admin Panel').child('User Role').push().set(userRoleModel.toJson());

        EasyLoading.dismiss();
        await FirebaseAuth.instance.signOut();
        // ignore: use_build_context_synchronously
        await showSussesScreenAndLogOut(context: context);
      }
    } on FirebaseAuthException catch (e) {
      EasyLoading.showError('Failed with Error');
      if (e.code == 'weak-password') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('The password provided is too weak.'),
            duration: Duration(seconds: 3),
          ),
        );
      } else if (e.code == 'email-already-in-use') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('The account already exists for that email.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      EasyLoading.showError('Failed with Error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          duration: const Duration(seconds: 3),
        ),
      );
    }

  }else{
    EasyLoading.showError(demoText);
  }

}

Future showSussesScreenAndLogOut({required BuildContext context}) {
  return showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Center(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(30)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 20),
                     Text(
                      lang.S.of(context).addSuccessful,
                      style: const TextStyle(fontSize: 22),
                    ),
                    const SizedBox(height: 10),
                     Text(
                      lang.S.of(context).youHaveToReLogin,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ButtonGlobalWithoutIcon(
                        buttontext: lang.S.of(context).ok,
                        buttonDecoration: kButtonDecoration.copyWith(color: Colors.green),
                        onPressed: (() {
                          const LoginForm().launch(context, isNewTask: true);
                          // const SplashScreen().launch(context, isNewTask: true);
                        }),
                        buttonTextColor: Colors.white),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}
