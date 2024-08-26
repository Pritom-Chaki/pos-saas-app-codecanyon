// ignore_for_file: use_build_context_synchronously
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_pos/constant.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;

import '../../Provider/bank_info_provider.dart';
import '../../Provider/profile_provider.dart';
import '../../currency.dart';
import '../../model/subscription_plan_model.dart';

class BuyNow extends StatefulWidget {
  const BuyNow({super.key, required this.subscriptionPlanModel});

  final SubscriptionPlanModel subscriptionPlanModel;

  @override
  State<BuyNow> createState() => _BuyNowState();
}

class _BuyNowState extends State<BuyNow> {
  Future<File?> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      setState(() {
        imageController.text = result.files.single.name;
      });
      return File(result.files.single.path!);
    } else {
      // User canceled the picker
      return null;
    }
  }

  TextEditingController imageController = TextEditingController();

  Future<void> uploadFile(String filePath) async {
    File file = File(filePath);
    try {
      EasyLoading.show(
        status: 'Uploading... ',
        dismissOnTap: false,
      );
      var snapshot = await FirebaseStorage.instance.ref('Subscription Attachment/${DateTime.now().millisecondsSinceEpoch}').putFile(file);
      var url = await snapshot.ref.getDownloadURL();

      data.attachment = url.toString();
    } catch (e) {
      EasyLoading.dismiss();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  // Future<void> uploadFile(File file) async {
  //   try {
  //     var request = http.MultipartRequest('POST', Uri.parse('YOUR_UPLOAD_URL'));
  //     request.files.add(await http.MultipartFile.fromPath('file', file.path));
  //
  //     var response = await request.send();
  //
  //     if (response.statusCode == 200) {
  //       // File upload successful
  //       print('File uploaded');
  //     } else {
  //       // Handle errors
  //       print('File upload failed with status code ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     // Handle exceptions
  //     print('Error uploading file: $e');
  //   }
  // }

  SubscriptionRequestModel data = SubscriptionRequestModel(
    subscriptionPlanModel: SubscriptionPlanModel(
        dueNumber: 0, duration: 0, offerPrice: 0, partiesNumber: 0, products: 0, purchaseNumber: 0, saleNumber: 0, subscriptionName: '', subscriptionPrice: 00),
    transactionNumber: '',
    note: '',
    attachment: '',
    userId: constUserId,
    businessCategory: '',
    companyName: '',
    countryName: '',
    language: '',
    phoneNumber: '',
    pictureUrl: '',
  );
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    data.subscriptionPlanModel = widget.subscriptionPlanModel;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, __) {
      final userProfileDetails = ref.watch(profileDetailsProvider);
      final bank = ref.watch(bankInfoProvider);

      return Scaffold(
        backgroundColor: kMainColor,
        appBar: AppBar(
          backgroundColor: kMainColor,
          title: Text(
            lang.S.of(context).buy,
          ),
          elevation: 0.0,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: userProfileDetails.when(data: (details) {
          data.countryName = details.countryName ?? '';
          data.language = details.language ?? '';
          data.pictureUrl = details.pictureUrl ?? '';
          data.companyName = details.companyName ?? '';
          data.businessCategory = details.businessCategory ?? '';
          data.phoneNumber = details.phoneNumber ?? '';
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Container(
                height: MediaQuery.of(context).size.height - 120,
                decoration: const BoxDecoration(borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)), color: Colors.white),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ///_______Bank_info_________________________
                      bank.when(
                        data: (bankData) {
                          return Column(
                            children: [
                              Text(
                                lang.S.of(context).bankInformation,
                                style: kTextStyle.copyWith(fontWeight: FontWeight.bold, color: kTitleColor, fontSize: 18),
                              ),
                              const SizedBox(height: 20),
                              Row(
                                children: [
                                  Expanded(
                                      flex: 4,
                                      child: Text(
                                        lang.S.of(context).bankName,
                                        style: kTextStyle.copyWith(color: kGreyTextColor),
                                      )),
                                  Expanded(
                                      child: Text(
                                    ':',
                                    style: kTextStyle.copyWith(color: kGreyTextColor),
                                  )),
                                  Expanded(
                                      flex: 5,
                                      child: Text(
                                        bankData.bankName,
                                        style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold),
                                      )),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                      flex: 4,
                                      child: Text(
                                        lang.S.of(context).branchName,
                                        style: kTextStyle.copyWith(color: kGreyTextColor),
                                      )),
                                  Expanded(
                                      child: Text(
                                    ':',
                                    style: kTextStyle.copyWith(color: kGreyTextColor),
                                  )),
                                  Expanded(
                                      flex: 5,
                                      child: Text(
                                        bankData.branchName,
                                        style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold),
                                      )),
                                ],
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                      flex: 4,
                                      child: Text(
                                        lang.S.of(context).accountName,
                                        style: kTextStyle.copyWith(color: kGreyTextColor),
                                      )),
                                  Expanded(
                                      child: Text(
                                    ':',
                                    style: kTextStyle.copyWith(color: kGreyTextColor),
                                  )),
                                  Expanded(
                                      flex: 5,
                                      child: Text(
                                        bankData.accountName,
                                        style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold),
                                      )),
                                ],
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Row(
                                children: [
                                  Expanded(
                                      flex: 4,
                                      child: Text(
                                        lang.S.of(context).accountNumber,
                                        style: kTextStyle.copyWith(color: kGreyTextColor),
                                      )),
                                  Expanded(
                                      child: Text(
                                    ':',
                                    style: kTextStyle.copyWith(color: kGreyTextColor),
                                  )),
                                  Expanded(
                                      flex: 5,
                                      child: Text(
                                        bankData.accountNumber,
                                        style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold),
                                      )),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                      flex: 4,
                                      child: Text(
                                        lang.S.of(context).swiftCode,
                                        style: kTextStyle.copyWith(color: kGreyTextColor),
                                      )),
                                  Expanded(
                                      child: Text(
                                    ':',
                                    style: kTextStyle.copyWith(color: kGreyTextColor),
                                  )),
                                  Expanded(
                                      flex: 5,
                                      child: Text(
                                        bankData.swiftCode,
                                        style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold),
                                      )),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                      flex: 4,
                                      child: Text(
                                        lang.S.of(context).bankAccountingCurrecny,
                                        style: kTextStyle.copyWith(color: kGreyTextColor),
                                      )),
                                  Expanded(
                                      child: Text(
                                    ':',
                                    style: kTextStyle.copyWith(color: kGreyTextColor),
                                  )),
                                  Expanded(
                                      flex: 5,
                                      child: Text(
                                        bankData.bankAccountCurrency,
                                        style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold),
                                      )),
                                ],
                              ),
                            ],
                          );
                        },
                        error: (e, stack) {
                          return Center(
                            child: Text(e.toString()),
                          );
                        },
                        loading: () {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        },
                      ),

                      const SizedBox(
                        height: 30,
                      ),
                      TextFormField(
                        onChanged: (value) {
                          data.transactionNumber = value;
                        },
                        decoration: kInputDecoration.copyWith(
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            labelText: lang.S.of(context).transactionId,
                            hintStyle: kTextStyle.copyWith(color: kGreyTextColor),
                            labelStyle: kTextStyle.copyWith(fontWeight: FontWeight.bold, color: kTitleColor),
                            hintText: lang.S.of(context).enterTransactionId),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        onChanged: (value) {
                          data.note = value;
                        },
                        decoration: kInputDecoration.copyWith(
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            hintStyle: kTextStyle.copyWith(color: kGreyTextColor),
                            labelText: lang.S.of(context).note,
                            labelStyle: kTextStyle.copyWith(fontWeight: FontWeight.bold, color: kTitleColor),
                            hintText: lang.S.of(context).enterNote),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: imageController,
                        onTap: () async {
                          File? selectedFile = await pickFile();
                          if (selectedFile != null) {
                            data.attachment = selectedFile.path;
                            // await uploadFile(selectedFile);
                          }
                        },
                        readOnly: true,
                        decoration: kInputDecoration.copyWith(
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            labelText: lang.S.of(context).uploadDocument,
                            labelStyle: kTextStyle.copyWith(fontWeight: FontWeight.bold, color: kTitleColor),
                            hintText: lang.S.of(context).uploadFile,
                            hintStyle: kTextStyle.copyWith(color: kGreyTextColor),
                            suffixIcon: const Icon(
                              FeatherIcons.upload,
                              color: kGreyTextColor,
                            )),
                      ),
                      const SizedBox(height: 100)
                    ],
                  ),
                ),
              ),
            ),
          );
        }, error: (e, stack) {
          return Text(e.toString());
        }, loading: () {
          return const CircularProgressIndicator();
        }),
        bottomNavigationBar: Container(
          height: 70,
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(
                                'images/success.png',
                                height: 85,
                                width: 85,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Thank You!',
                                style: kTextStyle.copyWith(fontWeight: FontWeight.bold, color: kTitleColor, fontSize: 20),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                'We will review the payment & approve it within 1-2 hours.',
                                style: kTextStyle.copyWith(color: kGreyTextColor),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      });
                });
              },
              child: GestureDetector(
                onTap: () async {
                  if (data.transactionNumber == '') {
                    EasyLoading.showError('Please Enter Transaction Number');
                  } else {
                    String? sellerUserRef = await getSaleID(id: await getUserID());
                    if (sellerUserRef != null) {
                      ///______________________________________
                      data.attachment == '' ? null : await uploadFile(data.attachment);
                      final DatabaseReference ref = FirebaseDatabase.instance.ref().child('Admin Panel').child('Subscription Update Request');
                      ref.keepSynced(true);
                      ref.push().set(data.toJson());
                      EasyLoading.showSuccess('Request has been send');
                      Navigator.pop(context);
                      Navigator.pop(context);
                    } else {
                      EasyLoading.showError('You Are Not A Valid User');
                    }

                  }
                },
                child: Container(
                  alignment: Alignment.center,
                  height: 50,
                  width: double.infinity,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(30), color: kMainColor),
                  child: Text(
                    'Submit',
                    style: kTextStyle.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}

class SubscriptionRequestModel {
  SubscriptionPlanModel subscriptionPlanModel;
  late String transactionNumber, note, attachment, userId;
  String phoneNumber;
  String companyName;
  String pictureUrl;
  String businessCategory;
  String language;
  String countryName;

  SubscriptionRequestModel({
    required this.subscriptionPlanModel,
    required this.transactionNumber,
    required this.note,
    required this.attachment,
    required this.userId,
    required this.phoneNumber,
    required this.businessCategory,
    required this.companyName,
    required this.pictureUrl,
    required this.countryName,
    required this.language,
  });

  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
        'id': DateTime.now().toString(),
        'userId': userId,
        'subscriptionName': subscriptionPlanModel.subscriptionName,
        'subscriptionDuration': subscriptionPlanModel.duration,
        'subscriptionPrice': subscriptionPlanModel.offerPrice > 0 ? subscriptionPlanModel.offerPrice : subscriptionPlanModel.subscriptionPrice,
        'transactionNumber': transactionNumber,
        'note': note,
        'status': 'pending',
        'approvedDate': '',
        'attachment': attachment,
        'phoneNumber': phoneNumber,
        'companyName': companyName,
        'pictureUrl': pictureUrl,
        'businessCategory': businessCategory,
        'language': language,
        'countryName': countryName,
      };
}
