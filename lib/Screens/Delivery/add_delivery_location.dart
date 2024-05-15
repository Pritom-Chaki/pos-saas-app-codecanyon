
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_pos/GlobalComponents/button_global.dart';
import 'package:mobile_pos/GlobalComponents/tab_buttons.dart';
import 'package:mobile_pos/Screens/Delivery/Model/delivery_model.dart';
import 'package:mobile_pos/Screens/Delivery/delivery_address_list.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import 'package:nb_utils/nb_utils.dart';

import '../../Provider/delivery_address_provider.dart';
import '../../constant.dart';
import '../../currency.dart';

class AddDelivery extends StatefulWidget {
  const AddDelivery({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AddDeliveryState createState() => _AddDeliveryState();
}

class _AddDeliveryState extends State<AddDelivery> {
  String initialCountry = 'Bangladesh';
  late String firstName, lastname, emailAddress, phoneNumber, addressLocation, addressType = 'Home';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          lang.S.of(context).addNewAddress,
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontSize: 20.0,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.0,
      ),
      body: Consumer(builder: (context, ref, __) {
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: AppTextField(
                        onChanged: (value) {
                          setState(() {
                            firstName = value;
                          });
                        }, // Optional
                        textFieldType: TextFieldType.NAME,
                        decoration: InputDecoration(
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          labelText: lang.S.of(context).firstName,
                          labelStyle: GoogleFonts.poppins(
                            color: Colors.black,
                          ),
                          hintText: lang.S.of(context).enterYourName,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: AppTextField(
                        onChanged: (value) {
                          setState(() {
                            lastname = value;
                          });
                        }, // Optional
                        textFieldType: TextFieldType.NAME,
                        decoration: InputDecoration(
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          labelText: lang.S.of(context).lastName,
                          labelStyle: GoogleFonts.poppins(
                            color: Colors.black,
                          ),
                          hintText: 'Rieyad',
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: AppTextField(
                  onChanged: (value) {
                    setState(() {
                      emailAddress = value;
                    });
                  },
                  textFieldType: TextFieldType.NAME,
                  decoration: InputDecoration(
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    labelText: lang.S.of(context).emailAddress,
                    labelStyle: GoogleFonts.poppins(
                      color: Colors.black,
                    ),
                    hintText: 'ibneriead@gmail.com',
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: AppTextField(
                  onChanged: (value) {
                    setState(() {
                      phoneNumber = value;
                    });
                  },
                  textFieldType: TextFieldType.NAME,
                  decoration: InputDecoration(
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    labelText: lang.S.of(context).phoneNumber,
                    labelStyle: GoogleFonts.poppins(
                      color: Colors.black,
                    ),
                    hintText: '+1253 5456 1145',
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: SizedBox(
                  height: 60.0,
                  child: AppTextField(
                    textFieldType: TextFieldType.NAME,
                    readOnly: true,
                    controller: TextEditingController(text: initialCountry),
                    decoration: InputDecoration(
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: kGreyTextColor),
                      ),
                      labelText: lang.S.of(context).country,
                      labelStyle: GoogleFonts.poppins(
                        color: Colors.black,
                      ),
                      hintText: lang.S.of(context).bangladesh,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: AppTextField(
                  textFieldType: TextFieldType.NAME,
                  onChanged: (value) {
                    setState(() {
                      addressLocation = value;
                    });
                  },
                  maxLines: 2,
                  decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      labelText: lang.S.of(context).address,
                      labelStyle: GoogleFonts.poppins(
                        color: Colors.black,
                      ),
                      hintText: 'Placentia, California(CA), 92870'),
                ),
              ),
              const SizedBox(height: 15.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TabButton(
                    background: addressType == 'Home' ? kMainColor : kDarkWhite,
                    text: addressType == 'Home' ? kDarkWhite : kMainColor,
                    title: 'Home',
                    press: () {
                      setState(() {
                        addressType = 'Home';
                      });
                    },
                  ),
                  const SizedBox(
                    width: 20.0,
                  ),
                  TabButton(
                    background: addressType == 'Office' ? kMainColor : kDarkWhite,
                    text: addressType == 'Office' ? kDarkWhite : kMainColor,
                    title: 'Office',
                    press: () {
                      setState(() {
                        addressType = 'Office';
                      });
                    },
                  ),
                  const SizedBox(
                    width: 20.0,
                  ),
                  TabButton(
                    background: addressType == 'Other' ? kMainColor : kDarkWhite,
                    text: addressType == 'Other' ? kDarkWhite : kMainColor,
                    title: 'Other',
                    press: () {
                      setState(() {
                        addressType = 'Other';
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 15.0),
              ButtonGlobalWithoutIcon(
                buttontext: lang.S.of(context).apply,
                buttonDecoration: kButtonDecoration.copyWith(color: kMainColor),
                onPressed: () async {
                  try {
                    EasyLoading.show(status: 'Loading...', dismissOnTap: false);
                    // ignore: no_leading_underscores_for_local_identifiers
                    final DatabaseReference _deliveryInformationRef = FirebaseDatabase.instance
                        // ignore: deprecated_member_use
                        .reference()
                        .child(constUserId)
                        .child('Delivery Addresses');
                    DeliveryModel deliveryModel = DeliveryModel(firstName, lastname, emailAddress, phoneNumber, initialCountry, addressLocation, addressType);
                    await _deliveryInformationRef.push().set(deliveryModel.toJson());
                    EasyLoading.showSuccess('Added Successfully', duration: const Duration(milliseconds: 1000));
                    ref.refresh(deliveryAddressProvider);
                    Future.delayed(const Duration(milliseconds: 100), () {
                      const DeliveryAddress().launch(context);
                    });
                  } catch (e) {
                    EasyLoading.dismiss();
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                  }
                  // Navigator.pushNamed(context, '/otp');
                },
                buttonTextColor: Colors.white,
              ),
            ],
          ),
        );
      }),
    );
  }
}
