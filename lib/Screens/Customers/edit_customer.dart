import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart' as firebase_core;
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_pos/GlobalComponents/button_global.dart';
import 'package:mobile_pos/Screens/Customers/Model/customer_model.dart';
import 'package:mobile_pos/constant.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import 'package:nb_utils/nb_utils.dart';

import '../../Provider/customer_provider.dart';
import '../../currency.dart';
import 'customer_list.dart';

class EditCustomer extends StatefulWidget {
  const EditCustomer({super.key, required this.customerModel});
  final CustomerModel customerModel;

  @override
  State<EditCustomer> createState() => _EditCustomerState();
}

class _EditCustomerState extends State<EditCustomer> {
  late CustomerModel updatedCustomerModel;
  String groupValue = '';
  bool expanded = false;
  final ImagePicker _picker = ImagePicker();
  bool showProgress = false;
  double progress = 0.0;
  XFile? pickedImage;
  File imageFile = File('No File');
  String imagePath = 'No Data';
  late String customerKey;
  void getCustomerKey(String phoneNumber) async {
    final ref = FirebaseDatabase.instance.ref(constUserId).child('Customers');
    ref.keepSynced(true);
    ref.orderByKey().get().then((value) {
      for (var element in value.children) {
        var data = jsonDecode(jsonEncode(element.value));
        if (data['phoneNumber'].toString() == phoneNumber) {
          customerKey = element.key.toString();
        }
      }
    });
  }

  Future<void> uploadFile(String filePath) async {
    File file = File(filePath);
    try {
      EasyLoading.show(
        status: 'Uploading... ',
        dismissOnTap: false,
      );
      var snapshot = await FirebaseStorage.instance.ref('Customer Picture/${DateTime.now().millisecondsSinceEpoch}').putFile(file);
      var url = await snapshot.ref.getDownloadURL();
      setState(() {
        updatedCustomerModel.profilePicture = url.toString();
      });
    } on firebase_core.FirebaseException catch (e) {
      EasyLoading.dismiss();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.code.toString())));
    }
  }

  @override
  void initState() {
    getCustomerKey(widget.customerModel.phoneNumber);
    updatedCustomerModel = widget.customerModel;
    groupValue = widget.customerModel.type;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, cRef, __) {
      return Scaffold(
        backgroundColor: kMainColor,
        appBar: AppBar(
          backgroundColor: kMainColor,
          title: Text(
            lang.S.of(context).updateContact,
            style: GoogleFonts.poppins(
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white),
          elevation: 0.0,
        ),
        body: Consumer(builder: (context, ref, __) {
          // ignore: unused_local_variable
          final customerData = ref.watch(customerProvider);

          return Container(
            alignment: Alignment.topCenter,
            decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(topRight: Radius.circular(30), topLeft: Radius.circular(30))),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: AppTextField(
                        initialValue: widget.customerModel.phoneNumber,
                        readOnly: true,
                        textFieldType: TextFieldType.PHONE,
                        decoration:  InputDecoration(
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          labelText: lang.S.of(context).phoneNumber,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: AppTextField(
                        initialValue: widget.customerModel.customerName,
                        textFieldType: TextFieldType.NAME,
                        onChanged: (value) {
                          setState(() {
                            updatedCustomerModel.customerName = value;
                          });
                        },
                        decoration:  InputDecoration(
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          labelText: lang.S.of(context).name,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile(
                            contentPadding: EdgeInsets.zero,
                            groupValue: groupValue,
                            title: Text(
                              lang.S.of(context).retailer,
                              maxLines: 1,
                              style: GoogleFonts.poppins(
                                fontSize: 12.0,
                              ),
                            ),
                            value: 'Retailer',
                            onChanged: (value) {
                              setState(() {
                                groupValue = value.toString();
                                updatedCustomerModel.type = value.toString();
                              });
                            },
                          ),
                        ),
                        Expanded(
                          child: RadioListTile(
                            contentPadding: EdgeInsets.zero,
                            groupValue: groupValue,
                            title: Text(
                              lang.S.of(context).dealer,
                              maxLines: 1,
                              style: GoogleFonts.poppins(
                                fontSize: 12.0,
                              ),
                            ),
                            value: 'Dealer',
                            onChanged: (value) {
                              setState(() {
                                groupValue = value.toString();
                                updatedCustomerModel.type = value.toString();
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile(
                            contentPadding: EdgeInsets.zero,
                            activeColor: kMainColor,
                            groupValue: groupValue,
                            title: Text(
                              lang.S.of(context).wholSeller,
                              maxLines: 1,
                              style: GoogleFonts.poppins(
                                fontSize: 12.0,
                              ),
                            ),
                            value: 'Wholesaler',
                            onChanged: (value) {
                              setState(() {
                                groupValue = value.toString();
                                updatedCustomerModel.type = value.toString();
                              });
                            },
                          ),
                        ),
                        Expanded(
                          child: RadioListTile(
                            contentPadding: EdgeInsets.zero,
                            activeColor: kMainColor,
                            groupValue: groupValue,
                            title: Text(
                              lang.S.of(context).supplier,
                              maxLines: 1,
                              style: GoogleFonts.poppins(
                                fontSize: 12.0,
                              ),
                            ),
                            value: 'Supplier',
                            onChanged: (value) {
                              setState(() {
                                groupValue = value.toString();
                                updatedCustomerModel.type = value.toString();
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    Visibility(
                      visible: showProgress,
                      child: const CircularProgressIndicator(
                        color: kMainColor,
                        strokeWidth: 5.0,
                      ),
                    ),
                    ExpansionPanelList(
                      expansionCallback: (int index, bool isExpanded) {
                        setState(() {
                          expanded == false ? expanded = true : expanded = false;
                        });
                      },
                      animationDuration: const Duration(seconds: 1),
                      elevation: 0,
                      dividerColor: Colors.white,
                      children: [
                        ExpansionPanel(
                          canTapOnHeader: true,
                          headerBuilder: (BuildContext context, bool isExpanded) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextButton(
                                  child: Text(
                                    'More Info',
                                    style: GoogleFonts.poppins(
                                      fontSize: 20.0,
                                      color: kMainColor,
                                    ),
                                  ),
                                  onPressed: () {

                                  },
                                ),
                              ],
                            );
                          },
                          body: Column(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return Dialog(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12.0),
                                          ),
                                          // ignore: sized_box_for_whitespace
                                          child: Container(
                                            height: 200.0,
                                            width: MediaQuery.of(context).size.width - 80,
                                            child: Center(
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  GestureDetector(
                                                    onTap: () async {
                                                      pickedImage = await _picker.pickImage(source: ImageSource.gallery);
                                                      setState(() {
                                                        imageFile = File(pickedImage!.path);
                                                        imagePath = pickedImage!.path;
                                                      });
                                                      Future.delayed(const Duration(milliseconds: 100), () {
                                                        Navigator.pop(context);
                                                      });
                                                    },
                                                    child: Column(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        const Icon(
                                                          Icons.photo_library_rounded,
                                                          size: 60.0,
                                                          color: kMainColor,
                                                        ),
                                                        Text(
                                                          lang.S.of(context).gallary,
                                                          style: GoogleFonts.poppins(
                                                            fontSize: 20.0,
                                                            color: kMainColor,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    width: 40.0,
                                                  ),
                                                  GestureDetector(
                                                    onTap: () async {
                                                      pickedImage = await _picker.pickImage(source: ImageSource.camera);
                                                      setState(() {
                                                        imageFile = File(pickedImage!.path);
                                                        imagePath = pickedImage!.path;
                                                      });
                                                      Future.delayed(const Duration(milliseconds: 100), () {
                                                        Navigator.pop(context);
                                                      });
                                                    },
                                                    child: Column(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        const Icon(
                                                          Icons.camera,
                                                          size: 60.0,
                                                          color: kGreyTextColor,
                                                        ),
                                                        Text(
                                                          lang.S.of(context).camera,
                                                          style: GoogleFonts.poppins(
                                                            fontSize: 20.0,
                                                            color: kGreyTextColor,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      });
                                },
                                child: Stack(
                                  children: [
                                    Container(
                                      height: 120,
                                      width: 120,
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.black54, width: 1),
                                        borderRadius: const BorderRadius.all(Radius.circular(120)),
                                        image: imagePath == 'No Data'
                                            ? DecorationImage(
                                                image: NetworkImage(updatedCustomerModel.profilePicture),
                                                fit: BoxFit.cover,
                                              )
                                            : DecorationImage(
                                                image: FileImage(imageFile),
                                                fit: BoxFit.cover,
                                              ),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: Container(
                                        height: 35,
                                        width: 35,
                                        decoration: BoxDecoration(
                                          border: Border.all(color: Colors.white, width: 2),
                                          borderRadius: const BorderRadius.all(Radius.circular(120)),
                                          color: kMainColor,
                                        ),
                                        child: const Icon(
                                          Icons.camera_alt_outlined,
                                          size: 20,
                                          color: Colors.white,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: AppTextField(
                                  initialValue: widget.customerModel.emailAddress,
                                  textFieldType: TextFieldType.EMAIL,
                                  onChanged: (value) {
                                    setState(() {
                                      updatedCustomerModel.emailAddress = value;
                                    });
                                  },
                                  decoration:  InputDecoration(
                                    border: const OutlineInputBorder(),
                                    floatingLabelBehavior: FloatingLabelBehavior.always,
                                    labelText: lang.S.of(context).emailAddress,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: AppTextField(
                                  initialValue: widget.customerModel.customerAddress,
                                  textFieldType: TextFieldType.NAME,
                                  maxLines: 2,
                                  onChanged: (value) {
                                    setState(() {
                                      updatedCustomerModel.customerAddress = value;
                                    });
                                  },
                                  decoration:  InputDecoration(
                                      border: const OutlineInputBorder(),
                                      floatingLabelBehavior: FloatingLabelBehavior.always,
                                      labelText: lang.S.of(context).address,),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: AppTextField(
                                  readOnly: true,
                                  initialValue: widget.customerModel.dueAmount,
                                  textFieldType: TextFieldType.NAME,
                                  maxLines: 2,
                                  decoration: const InputDecoration(
                                      border: OutlineInputBorder(), floatingLabelBehavior: FloatingLabelBehavior.always, labelText: 'Previous Due'),
                                ),
                              ),
                            ],
                          ),
                          isExpanded: expanded,
                        ),
                      ],
                    ),
                    ButtonGlobalWithoutIcon(
                      buttontext: 'Update',
                      buttonDecoration: kButtonDecoration.copyWith(color: kMainColor, borderRadius: const BorderRadius.all(Radius.circular(30))),
                      onPressed: () async {
                        try {
                          EasyLoading.show(status: 'Loading...', dismissOnTap: false);
                          imagePath == 'No Data' ? null : await uploadFile(imagePath);
                          DatabaseReference ref = FirebaseDatabase.instance.ref("$constUserId/Customers/$customerKey");
                          ref.keepSynced(true);
                          ref.update({
                            'customerName': updatedCustomerModel.customerName,
                            'type': updatedCustomerModel.type,
                            'profilePicture': updatedCustomerModel.profilePicture,
                            'emailAddress': updatedCustomerModel.emailAddress,
                            'customerAddress': updatedCustomerModel.customerAddress,
                          });
                          EasyLoading.dismiss();
                          //ref.refresh(productProvider);
                          Future.delayed(const Duration(milliseconds: 100), () {
                            cRef.refresh(customerProvider);
                            const CustomerList().launch(context);
                          });
                        } catch (e) {
                          EasyLoading.dismiss();
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                        }
                      },
                      buttonTextColor: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      );
    });
  }
}
