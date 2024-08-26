// ignore_for_file: use_build_context_synchronously

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:mobile_pos/Screens/Sales/sale%20setting/sale_setting_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../constant.dart';
import '../../../currency.dart';

class SaleAndLoanSetting extends StatefulWidget {
  const SaleAndLoanSetting({super.key});

  @override
  State<SaleAndLoanSetting> createState() => _SaleAndLoanSettingState();
}

class _SaleAndLoanSettingState extends State<SaleAndLoanSetting> {
  Future<void> getDataBack() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      vatPercentageController.text = prefs.getString(defaultVat) ?? '0';
    });
  }

  TextEditingController vatPercentageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getDataBack();
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: kMainColor,
      appBar: AppBar(
        backgroundColor: kMainColor,
        title: Text('Sale Setting', style: kTextStyle.copyWith(color: kWhite)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0.0,
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 20.0, bottom: 10.0),
        decoration: BoxDecoration(
          color: kWhite,
          boxShadow: [
            BoxShadow(
              color: kBorderColorTextField.withOpacity(0.2),
              spreadRadius: 10,
              blurRadius: 8,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: GestureDetector(
          onTap: () async {
            EasyLoading.show(status: 'Saving..');
            final DatabaseReference saleSettingRef = FirebaseDatabase.instance.ref().child(constUserId).child('Sale Setting');
            saleSettingRef.keepSynced(true);
            double vatPercentage = double.parse(vatPercentageController.text);
            SaleSettingModel saleSettingModel = SaleSettingModel(
              vatPercentage,
            );
            await saleSettingRef.set(saleSettingModel.toJson());

            EasyLoading.showSuccess('Done');
            Navigator.pop(context, true);
          },
          child: Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Container(
              width: double.infinity,
              height: 50,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: kMainColor, borderRadius: BorderRadius.circular(30)),
              child: Text('Save', style: kTextStyle.copyWith(color: kWhite, fontWeight: FontWeight.bold)),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Container(
          height: MediaQuery.of(context).size.height,
          padding: const EdgeInsets.all(12.0),
          alignment: Alignment.topCenter,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(30),
              topLeft: Radius.circular(30),
            ),
          ),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10, top: 15),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Default VAT percentage',
                        style: kTextStyle.copyWith(color: kTitleColor),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 26,
                            height: 37,
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.only(topLeft: Radius.circular(7), bottomLeft: Radius.circular(7)),
                              color: kMainColor,
                            ),
                            child: Center(
                              child: Text(
                                '%',
                                style: kTextStyle.copyWith(fontWeight: FontWeight.bold, color: kWhite),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 37,
                            width: 74,
                            child: TextFormField(
                              controller: vatPercentageController,
                              textAlign: TextAlign.right,
                              cursorColor: isDark ? kWhite : kTitleColor,
                              keyboardType: TextInputType.number,
                              decoration: kInputDecoration.copyWith(
                                enabledBorder: const OutlineInputBorder(
                                  borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(7),
                                    bottomRight: Radius.circular(7),
                                  ),
                                  borderSide: BorderSide(color: kMainColor, width: 1),
                                ),
                                focusedBorder: const OutlineInputBorder(
                                  borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(7.0),
                                    bottomRight: Radius.circular(7.0),
                                  ),
                                  borderSide: BorderSide(color: kMainColor, width: 1),
                                ),
                                contentPadding: const EdgeInsets.only(right: 5.0, left: 5.0),
                                hintText: '0',
                                hintStyle: kTextStyle.copyWith(color: kGreyTextColor),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
