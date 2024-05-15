import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_pos/GlobalComponents/button_global.dart';
import 'package:mobile_pos/Provider/expense_category_proivder.dart';
import 'package:mobile_pos/constant.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import 'package:mobile_pos/model/expense_category_model.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../currency.dart';

class AddExpenseCategory extends StatefulWidget {
  const AddExpenseCategory({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AddExpenseCategoryState createState() => _AddExpenseCategoryState();
}

class _AddExpenseCategoryState extends State<AddExpenseCategory> {
  bool showProgress = false;
  late String categoryName;

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, __) {
      final allCategory = ref.watch(expenseCategoryProvider);
      return Scaffold(
        backgroundColor: kMainColor,
        appBar: AppBar(
          backgroundColor: kMainColor,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.close),
          ),
          title: Text(
            lang.S.of(context).addExpenseCategory,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 20.0,
            ),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          centerTitle: true,
          elevation: 0.0,
        ),
        body: Container(
          alignment: Alignment.topCenter,
          decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(topRight: Radius.circular(30), topLeft: Radius.circular(30))),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Visibility(
                    visible: showProgress,
                    child: const CircularProgressIndicator(
                      color: kMainColor,
                      strokeWidth: 5.0,
                    ),
                  ),
                  AppTextField(
                    textFieldType: TextFieldType.NAME,
                    onChanged: (value) {
                      setState(() {
                        categoryName = value;
                      });
                    },
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      hintText: lang.S.of(context).fashion,
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      labelText: lang.S.of(context).cateogryName,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ButtonGlobalWithoutIcon(
                    buttontext: lang.S.of(context).save,
                    buttonDecoration: kButtonDecoration.copyWith(color: kMainColor),
                    onPressed: () async {
                      bool isAlreadyAdded = false;
                      allCategory.value?.forEach((element) {
                        if (element.categoryName.toLowerCase().removeAllWhiteSpace().contains(
                              categoryName.toLowerCase().removeAllWhiteSpace(),
                            )) {
                          isAlreadyAdded = true;
                        }
                      });
                      setState(() {
                        showProgress = true;
                      });
                      final DatabaseReference categoryInformationRef = FirebaseDatabase.instance.ref().child(constUserId).child('Expense Category');
                      categoryInformationRef.keepSynced(true);
                      ExpenseCategoryModel categoryModel = ExpenseCategoryModel(
                        categoryName: categoryName,
                        categoryDescription: '',
                      );
                      isAlreadyAdded ? EasyLoading.showError('Already Added') : categoryInformationRef.push().set(categoryModel.toJson());
                      setState(() {
                        showProgress = false;
                        isAlreadyAdded ? null : ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Data Saved Successfully")));
                      });

                      ref.refresh(expenseCategoryProvider);
                      // ignore: use_build_context_synchronously
                      isAlreadyAdded ? null : Navigator.pop(context);
                    },
                    buttonTextColor: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
