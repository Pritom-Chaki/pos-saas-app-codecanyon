import 'dart:convert';
import 'dart:math';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_pos/Screens/tax%20report/tax_model.dart';
import 'package:mobile_pos/constant.dart';
import 'package:nb_utils/nb_utils.dart';

//____________________________________________________AddSingleTax_______________________
class CreateSingleTax extends StatefulWidget {
  const CreateSingleTax({super.key, required this.listOfTax});

  final List<TaxModel> listOfTax;

  @override
  State<CreateSingleTax> createState() => _CreateSingleTaxState();
}

class _CreateSingleTaxState extends State<CreateSingleTax> {
  String name = '';
  num rate = 0;
  String id = DateTime.now().millisecondsSinceEpoch.toString() + Random().nextInt(1000).toString();

  void deleteExpenseCategory({required String name, required WidgetRef updateRef, required BuildContext context}) async {
    EasyLoading.show(status: 'Deleting..');
    String expenseKey = '';
    final userId = await getUserID();
    await FirebaseDatabase.instance.ref(userId).child('Tax List').orderByKey().get().then((value) {
      for (var element in value.children) {
        var data = jsonDecode(jsonEncode(element.value));
        if (data['name'].toString() == name) {
          expenseKey = element.key.toString();
        }
      }
    });
    DatabaseReference ref = FirebaseDatabase.instance.ref("${await getUserID()}/Tax List/$expenseKey");
    await ref.remove();
    updateRef.refresh(taxProvider);
    EasyLoading.showSuccess('Done').then(
      (value) => Navigator.pop(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<String> names = [];
    for (var element in widget.listOfTax) {
      names.add(element.name.removeAllWhiteSpace().toLowerCase());
    }
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        return Scaffold(
          backgroundColor: kMainColor,
          appBar: AppBar(
            title: Text(
              'Tax',
              style: GoogleFonts.poppins(
                color: Colors.white,
              ),
            ),
            iconTheme: const IconThemeData(color: Colors.white),
            centerTitle: true,
            backgroundColor: kMainColor,
            elevation: 0.0,
          ),
          body: Container(
            padding: const EdgeInsets.all(15),
            width: MediaQuery.of(context).size.width,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(30),
                topLeft: Radius.circular(30),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //___________________________________Tax Rates______________________________
                Text(
                  'Add New Tax',
                  style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20.0),
                Text('Name*', style: kTextStyle.copyWith(color: kTitleColor)),
                const SizedBox(height: 8.0),
                TextFormField(
                  onChanged: (value) {
                    name = value;
                  },
                  keyboardType: TextInputType.text,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.only(left: 8, right: 8.0),
                    border: OutlineInputBorder(),
                    hintText: 'Enter Name',
                  ),
                  onSaved: (value) {},
                ),
                const SizedBox(height: 20.0),
                Text(
                  'Tax rate',
                  style: kTextStyle.copyWith(color: kTitleColor),
                ),
                const SizedBox(height: 8.0),
                TextFormField(
                  onChanged: (value) {
                    rate = double.parse(value);
                  },
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.only(left: 8, right: 8.0),
                    border: OutlineInputBorder(),
                    hintText: 'Enter Tax rate',
                  ),
                  onSaved: (value) {},
                ),
                Spacer(),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: SizedBox(
                    height: 45.0,
                    width: MediaQuery.of(context).size.width,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.only(left: 2, right: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        backgroundColor: kMainColor,
                        elevation: 1.0,
                        foregroundColor: kGreyTextColor.withOpacity(0.1),
                        shadowColor: kMainColor,
                        animationDuration: const Duration(milliseconds: 300),
                        textStyle: const TextStyle(color: Colors.white, fontFamily: 'Display', fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      onPressed: () async {
                        if (name != '' && !names.contains(name.toLowerCase().removeAllWhiteSpace())) {
                          TaxModel tax = TaxModel(name: name, taxRate: rate, id: id.toString());
                          try {
                            EasyLoading.show(status: 'Loading...', dismissOnTap: false);
                            final DatabaseReference productInformationRef = FirebaseDatabase.instance.ref().child(await getUserID()).child('Tax List');
                            await productInformationRef.push().set(tax.toJson());
                            EasyLoading.showSuccess('Added Successfully', duration: const Duration(milliseconds: 500));

                            ///____provider_refresh____________________________________________
                            ref.refresh(taxProvider);

                            Future.delayed(const Duration(milliseconds: 100), () {
                              Navigator.pop(context);
                            });
                          } catch (e) {
                            EasyLoading.dismiss();
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                          }
                        } else if (names.contains(name.toLowerCase().removeAllWhiteSpace())) {
                          EasyLoading.showError('Already Exists');
                        } else {
                          EasyLoading.showError('Enter Name');
                        }
                      },
                      child: Text(
                        'Save',
                        style: kTextStyle.copyWith(color: kWhite, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

//____________________________________________________EditSingleTax_______________________

class EditSingleTax extends StatefulWidget {
  const EditSingleTax({
    super.key,
    required this.taxList,
    required this.taxModel,
  });

  final List<TaxModel> taxList;
  final TaxModel taxModel;

  @override
  State<EditSingleTax> createState() => _EditSingleTaxTaxState();
}

class _EditSingleTaxTaxState extends State<EditSingleTax> {
  String name = '';
  num rate = 0;
  String taxKey = '';

  void getTaxKey() async {
    final userId = await getUserID();
    await FirebaseDatabase.instance.ref(userId).child('Tax List').orderByKey().get().then((value) {
      for (var element in value.children) {
        var data = jsonDecode(jsonEncode(element.value));
        if (data['name'].toString() == widget.taxModel.name) {
          taxKey = element.key.toString();
        }
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    name = widget.taxModel.name;
    rate = widget.taxModel.taxRate;
    getTaxKey();
  }

  @override
  Widget build(BuildContext context) {
    List<String> names = [];
    for (var element in widget.taxList) {
      names.add(element.name.removeAllWhiteSpace().toLowerCase());
    }
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        return Scaffold(
          backgroundColor: kMainColor,
          appBar: AppBar(
            title: Text(
              'Edit Tax',
              style: GoogleFonts.poppins(
                color: Colors.white,
              ),
            ),
            iconTheme: const IconThemeData(color: Colors.white),
            centerTitle: true,
            backgroundColor: kMainColor,
            elevation: 0.0,
          ),
          body: Container(
            padding: const EdgeInsets.all(15),
            width: MediaQuery.of(context).size.width,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(30),
                topLeft: Radius.circular(30),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //___________________________________Tax Rates______________________________
                Text(
                  'Edit Tax',
                  style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20.0),
                Text('Name*', style: kTextStyle.copyWith(color: kTitleColor)),
                const SizedBox(height: 8.0),
                TextFormField(
                  initialValue: name,
                  onChanged: (value) {
                    name = value;
                  },
                  keyboardType: TextInputType.text,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.only(left: 8, right: 8.0),
                    border: OutlineInputBorder(),
                    hintText: 'Enter Name',
                  ),
                  onSaved: (value) {},
                ),
                const SizedBox(height: 20.0),
                Text(
                  'Tax rate',
                  style: kTextStyle.copyWith(color: kTitleColor),
                ),
                const SizedBox(height: 8.0),
                TextFormField(
                  initialValue: rate.toString(),
                  onChanged: (value) {
                    rate = double.parse(value);
                  },
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.only(left: 8, right: 8.0),
                    border: OutlineInputBorder(),
                    hintText: 'Enter Tax rate',
                  ),
                  onSaved: (value) {},
                ),
                Spacer(),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: SizedBox(
                    height: 45.0,
                    width: MediaQuery.of(context).size.width,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.only(left: 2, right: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        backgroundColor: kMainColor,
                        elevation: 1.0,
                        foregroundColor: kGreyTextColor.withOpacity(0.1),
                        shadowColor: kMainColor,
                        animationDuration: const Duration(milliseconds: 300),
                        textStyle: const TextStyle(color: Colors.white, fontFamily: 'Display', fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      onPressed: () {
                        TaxModel tax = TaxModel(taxRate: rate, id: widget.taxModel.id, name: name);
                        if (name != '' && name == widget.taxModel.name ? true : !names.contains(name.toLowerCase().removeAllWhiteSpace())) {
                          setState(() async {
                            try {
                              EasyLoading.show(status: 'Loading...', dismissOnTap: false);
                              final DatabaseReference taxInfoRef = FirebaseDatabase.instance.ref().child(await getUserID()).child('Tax List').child(taxKey);
                              await taxInfoRef.set(tax.toJson());
                              EasyLoading.showSuccess('Edit Successfully', duration: const Duration(milliseconds: 500));

                              ///____provider_refresh____________________________________________
                              ref.refresh(taxProvider);
                              Future.delayed(const Duration(milliseconds: 100), () {
                                Navigator.pop(context);
                              });
                            } catch (e) {
                              EasyLoading.dismiss();
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                            }
                          });
                        } else if (names.contains(name.toLowerCase().removeAllWhiteSpace())) {
                          EasyLoading.showError('Name  Already Exists');
                        } else {
                          EasyLoading.showError('Name can\'t be empty');
                        }
                      },
                      child: Text(
                        'Update',
                        style: kTextStyle.copyWith(color: kWhite, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

//____________________________________________________EditSingleTax_______________________
