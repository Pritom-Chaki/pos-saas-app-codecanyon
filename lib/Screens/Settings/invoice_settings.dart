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
import 'package:mobile_pos/generated/l10n.dart' as lang;
import 'package:mobile_pos/model/invoice_model.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../constant.dart';
import '../../currency.dart';
import '../../invoice_constant.dart' as con;

class InvoiceSettings extends StatefulWidget {
  const InvoiceSettings({super.key});

  @override
  State<InvoiceSettings> createState() => _InvoiceSettingsState();
}

class _InvoiceSettingsState extends State<InvoiceSettings> {
  String productPicture =
      'https://firebasestorage.googleapis.com/v0/b/maanpos.appspot.com/o/Customer%20Picture%2FNo_Image_Available.jpeg?alt=media&token=3de0d45e-0e4a-4a7b-b115-9d6722d5031f';
  final ImagePicker _picker = ImagePicker();
  XFile? pickedImage;
  File imageFile = File('No File');
  String imagePath = 'No Data';

  Future<void> uploadFile(String filePath) async {
    File file = File(filePath);
    try {
      EasyLoading.show(
        status: 'Uploading... ',
        dismissOnTap: false,
      );
      var snapshot = await FirebaseStorage.instance.ref('Product Picture/${DateTime.now().millisecondsSinceEpoch}').putFile(file);
      var url = await snapshot.ref.getDownloadURL();

      setState(() {
        productPicture = url.toString();
      });
      EasyLoading.dismiss();
    } on firebase_core.FirebaseException catch (e) {
      EasyLoading.dismiss();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.code.toString())));
    }
  }

  Future<void> getSettingsData() async {
    DatabaseReference ref = FirebaseDatabase.instance.ref('$constUserId/Invoice Settings');
    ref.keepSynced(true);
    final model = await ref.get();
    var data = jsonDecode(jsonEncode(model.value));
    InvoiceModel data1 = InvoiceModel.fromJson(data);
      setState(() {
        phoneController.text = data1.phoneNumber;
        emailController.text = data1.emailAddress.toString();
        addressController.text = data1.address.toString();
        productPicture = data1.pictureUrl.toString();
      });
  }

  TextEditingController phoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getSettingsData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kMainColor,
      appBar: AppBar(
        title:  Text(
          lang.S.of(context).invoiceSetting,
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0.0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Consumer(builder: (_, ref, watch) {
          return Column(
            children: [
              Container(
                alignment: Alignment.center,
                height: context.height(),
                decoration:
                    const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(topRight: Radius.circular(30), topLeft: Radius.circular(30))),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    ListTile(
                      title: Text(
                        lang.S.of(context).printingOption,
                        style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontSize: 18.0,
                        ),
                      ),
                      leading: const Icon(
                        Icons.print,
                        color: kMainColor,
                      ),
                      trailing: Switch.adaptive(
                        value: isPrintEnable,
                        onChanged: (bool value) async {
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setBool('isPrintEnable', value);
                          setState(
                            () {
                              isPrintEnable = value;
                            },
                          );
                        },
                      ),
                    ),
                    ListTile(
                        onTap: () async {
                          pickedImage = await _picker.pickImage(source: ImageSource.gallery);
                          setState(() {
                            imageFile = File(pickedImage!.path);
                            imagePath = pickedImage!.path;
                          });
                        },
                        title: Text(
                          lang.S.of(context).logo,
                          style: GoogleFonts.poppins(
                            color: Colors.black,
                            fontSize: 18.0,
                          ),
                        ),
                        leading: const Icon(
                          Icons.image,
                          color: kMainColor,
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            imagePath != 'No Data' ? Image(
                              image: FileImage(imageFile),
                              fit: BoxFit.cover,
                              height: 40.0,
                              width: 150.0,
                            ) : Image(
                              image: NetworkImage(productPicture),
                              fit: BoxFit.cover,
                              height: 40.0,
                              width: 150.0,
                            ),
                            const SizedBox(
                              width: 6.0,
                            ),
                            Text(
                              lang.S.of(context).change,
                              style: const TextStyle(color: con.kTitleColor, fontWeight: FontWeight.bold),
                            )
                          ],
                        )),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: AppTextField(
                        textFieldType: TextFieldType.PHONE,
                        controller: phoneController,
                        decoration:  InputDecoration(
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          labelText: lang.S.of(context).phoneNumber,
                          hintText: lang.S.of(context).enterYourPhoneNumber,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: AppTextField(
                        textFieldType: TextFieldType.EMAIL,
                        controller: emailController,
                        decoration:  InputDecoration(
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          labelText: lang.S.of(context).emailAddress,
                          hintText: lang.S.of(context).enterYourEmailAddress,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: AppTextField(
                        textFieldType: TextFieldType.MULTILINE,
                        controller: addressController,
                        decoration:  InputDecoration(
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          labelText: lang.S.of(context).address,
                          hintText: lang.S.of(context).enterFullAddress,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                    ButtonGlobalWithoutIcon(
                      buttontext: lang.S.of(context).saveChanges,
                      buttonDecoration: kButtonDecoration.copyWith(color: kMainColor),
                      onPressed: () async {
                        imagePath.contains('com.possaas.app/cache/') ? await uploadFile(imagePath) : null;
                        InvoiceModel invoice = InvoiceModel(
                          address: addressController.text,
                          emailAddress: emailController.text,
                          phoneNumber: phoneController.text,
                          pictureUrl: productPicture,
                        );

                        DatabaseReference ref = FirebaseDatabase.instance.ref('$constUserId/Invoice Settings');

                        ref.set(invoice.toJson());
                        EasyLoading.showSuccess('Updated');
                        // ignore: use_build_context_synchronously
                        Navigator.pop(context);
                      },
                      buttonTextColor: Colors.white,
                    )
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
