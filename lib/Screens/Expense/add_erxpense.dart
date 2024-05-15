import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mobile_pos/GlobalComponents/button_global.dart';
import 'package:mobile_pos/Screens/Expense/expense_category_list.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import 'package:nb_utils/nb_utils.dart';

import '../../Provider/all_expanse_provider.dart';
import '../../const_commas.dart';
import '../../constant.dart';
import '../../currency.dart';
import '../../model/DailyTransactionModel.dart';
import '../../model/expense_model.dart';

// ignore: must_be_immutable
class AddExpense extends StatefulWidget {
  const AddExpense({
    super.key,
  });

  @override
  // ignore: library_private_types_in_public_api
  _AddExpenseState createState() => _AddExpenseState();
}

class _AddExpenseState extends State<AddExpense> {
  String dropdownValue = 'Select Category';
  final dateController = TextEditingController();
  TextEditingController expanseForNameController = TextEditingController();
  final TextEditingController expanseAmountController = TextEditingController();
  TextEditingController expanseNoteController = TextEditingController();
  TextEditingController expanseRefController = TextEditingController();
  List<String> paymentMethods = [
    'Cash',
    'Bank',
    'Card',
    'Mobile Payment',
    'Snacks',
  ];

  DateTime selectedDate = DateTime.now();
  String amountText = '';

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(context: context, initialDate: selectedDate, firstDate: DateTime(2015, 8), lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  String selectedPaymentType = 'Cash';
  DropdownButton<String> getPaymentMethods() {
    List<DropdownMenuItem<String>> dropDownItems = [];
    for (String des in paymentMethods) {
      var item = DropdownMenuItem(
        value: des,
        child: Text(des),
      );
      dropDownItems.add(item);
    }
    return DropdownButton(
      items: dropDownItems,
      value: selectedPaymentType,
      onChanged: (value) {
        setState(() {
          selectedPaymentType = value!;
        });
      },
    );
  }

  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool validateAndSave() {
    final form = formKey.currentState;
    if (form!.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, __) {
      return Scaffold(
        backgroundColor: kMainColor,
        appBar: AppBar(
          backgroundColor: kMainColor,
          title: Text(
            lang.S.of(context).addExpense,
            style: GoogleFonts.poppins(
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white),
          elevation: 0.0,
        ),
        body: Container(
          alignment: Alignment.topCenter,
          decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(topRight: Radius.circular(30), topLeft: Radius.circular(30))),
          child: SingleChildScrollView(
            child: SizedBox(
              width: context.width(),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                    key: formKey,
                    child: Column(
                      children: [
                        ///_______date________________________________
                        FormField(
                          builder: (FormFieldState<dynamic> field) {
                            return InputDecorator(
                              decoration: InputDecoration(
                                suffixIcon: const Icon(FeatherIcons.calendar, color: kGreyTextColor),
                                enabledBorder: const OutlineInputBorder(),
                                contentPadding: const EdgeInsets.all(20),
                                labelText: lang.S.of(context).expenseDate,
                                hintText: lang.S.of(context).enterExpenseDate,
                              ),
                              child: Text(
                                '${DateFormat.d().format(selectedDate)} ${DateFormat.MMM().format(selectedDate)} ${DateFormat.y().format(selectedDate)}',
                              ),
                            );
                          },
                        ).onTap(() => _selectDate(context)),
                        const SizedBox(height: 20),

                        ///_________category_______________________________________________
                        Container(
                          height: 60.0,
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5.0),
                            border: Border.all(color: kGreyTextColor),
                          ),
                          child: GestureDetector(
                            onTap: () async {
                              dropdownValue = await const ExpenseCategoryList().launch(context);
                              setState(() {});
                            },
                            child: Row(
                              children: [
                                const SizedBox(
                                  width: 10.0,
                                ),
                                Text(dropdownValue),
                                const Spacer(),
                                const Icon(Icons.keyboard_arrow_down),
                                const SizedBox(
                                  width: 10.0,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        ///________Expense_for_______________________________________________
                        TextFormField(
                          showCursor: true,
                          controller: expanseForNameController,
                          validator: (value) {
                            if (value.isEmptyOrNull) {
                              return 'Please Enter Name';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            expanseForNameController.text = value!;
                          },
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            labelText: lang.S.of(context).expenseFor,
                            hintText: 'Enter Name',
                          ),
                        ),
                        const SizedBox(height: 20),

                        ///________PaymentType__________________________________
                        FormField(
                          builder: (FormFieldState<dynamic> field) {
                            return InputDecorator(
                              decoration: InputDecoration(
                                  enabledBorder: const OutlineInputBorder(),
                                  contentPadding: const EdgeInsets.all(8.0),
                                  floatingLabelBehavior: FloatingLabelBehavior.always,
                                  labelText: lang.S.of(context).paymentType),
                              child: DropdownButtonHideUnderline(child: getPaymentMethods()),
                            );
                          },
                        ),
                        const SizedBox(height: 20),

                        ///_________________Amount_____________________________
                        TextFormField(
                          showCursor: true,
                          controller: expanseAmountController,
                          onChanged: (value) {
                            amountText = value.replaceAll(',', '');
                            var formattedText = myFormat.format(int.parse(amountText));
                            expanseAmountController.value = expanseAmountController.value.copyWith(
                              text: formattedText,
                              selection: TextSelection.collapsed(offset: formattedText.length),
                            );
                          },
                          validator: (value) {
                            if (amountText.isEmptyOrNull) {
                              return 'please Inter Amount';
                            } else if (double.tryParse(amountText) == null) {
                              return 'Enter a valid Amount';
                            }
                            return null;
                          },
                          // onSaved: (value) {
                          //   amountText = value!;
                          // },
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            errorBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.red)),
                            labelText: lang.S.of(context).amount,
                            hintText: 'Enter Amount',
                          ),
                          keyboardType: TextInputType.number,
                        ),

                        const SizedBox(height: 20),

                        ///_______reference_________________________________
                        TextFormField(
                          showCursor: true,
                          controller: expanseRefController,
                          validator: (value) {
                            return null;
                          },
                          onSaved: (value) {
                            expanseRefController.text = value!;
                          },
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            labelText: lang.S.of(context).referenceNumber,
                            hintText: lang.S.of(context).enterReferenceNumber,
                          ),
                        ),
                        const SizedBox(height: 20),

                        ///_________note____________________________________________________
                        TextFormField(
                          showCursor: true,
                          controller: expanseNoteController,
                          validator: (value) {
                            if (value == null) {
                              return 'please Inter Amount';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            expanseNoteController.text = value!;
                          },
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            labelText: lang.S.of(context).note,
                            hintText: 'Enter Note',
                          ),
                        ),
                        const SizedBox(height: 20),

                        ///_______button_________________________________
                        ButtonGlobal(
                          buttontext: 'Continue',
                          buttonDecoration: kButtonDecoration.copyWith(color: kMainColor),
                          onPressed: () async {
                            if (dropdownValue != 'Select Category') {
                              if (validateAndSave()) {
                                ExpenseModel expense = ExpenseModel(
                                  expenseDate: selectedDate.toString(),
                                  category: dropdownValue,
                                  account: '',
                                  amount: amountText,
                                  expanseFor: expanseForNameController.text,
                                  paymentType: selectedPaymentType,
                                  referenceNo: expanseRefController.text,
                                  note: expanseNoteController.text,
                                );

                                try {
                                  EasyLoading.show(status: 'Loading...', dismissOnTap: false);
                                  final DatabaseReference expanseRef = FirebaseDatabase.instance.ref().child(constUserId).child('Expense');
                                  expanseRef.keepSynced(true);
                                  expanseRef.push().set(expense.toJson());
                                  expanseRef.onChildAdded.listen((event) {
                                    ref.refresh(expenseProvider);
                                  });

                                  ///________daily_transactionModel_________________________________________________________________________

                                  DailyTransactionModel dailyTransaction = DailyTransactionModel(
                                    name: expense.expanseFor,
                                    date: expense.expenseDate,
                                    type: 'Expense',
                                    total: expense.amount.toDouble(),
                                    paymentIn: 0,
                                    paymentOut: expense.amount.toDouble(),
                                    remainingBalance: expense.amount.toDouble(),
                                    id: expense.expenseDate,
                                    expenseModel: expense,
                                  );
                                  postDailyTransaction(dailyTransactionModel: dailyTransaction);

                                  ///____provider_refresh____________________________________________

                                  EasyLoading.showSuccess('Added Successfully', duration: const Duration(milliseconds: 500));
                                  Navigator.pop(context);
                                } catch (e) {
                                  EasyLoading.dismiss();
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                                }
                              }
                            } else {
                              EasyLoading.showError('Please select a category first');
                            }
                          },
                          iconWidget: Icons.arrow_forward,
                          iconColor: Colors.white,
                        ),
                      ],
                    )),
              ),
            ),
          ),
        ),
      );
    });
  }
}
