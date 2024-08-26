// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart' as firebase_core;
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:mobile_pos/GlobalComponents/button_global.dart';
import 'package:mobile_pos/Screens/Authentication/phone.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import 'package:nb_utils/nb_utils.dart';

import '../../Provider/shop_category_provider.dart';
import '../../constant.dart';
import '../../currency.dart';
import '../../model/personal_information_model.dart';
import '../../model/seller_info_model.dart';
import '../../model/shop_category_model.dart';
import '../../model/subscription_plan_model.dart';
import '../../subscription.dart';
import '../Home/home.dart';
import '../Warehouse/warehouse_model.dart';

class ProfileSetup extends StatefulWidget {
  const ProfileSetup({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ProfileSetupState createState() => _ProfileSetupState();
}

class _ProfileSetupState extends State<ProfileSetup> {
  final CurrentUserData currentUserData = CurrentUserData();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    currentUserData.putUserData(userId: FirebaseAuth.instance.currentUser!.uid, subUser: false, title: '', email: '');

    freeSubscription();
  }

  String dropdownLangValue = 'English';
  String initialCountry = 'Bangladesh';
  String gst = '';
  String dropdownValue = 'Bag & Luggage';
  late String companyName;
  String phoneNumber = FirebaseAuth.instance.currentUser?.phoneNumber ?? '';
  double progress = 0.0;
  bool showProgress = false;
  int openingBalance = 0;
  String profilePicture =
      'https://firebasestorage.googleapis.com/v0/b/maanpos.appspot.com/o/Profile%20Picture%2Fblank-profile-picture-973460_1280.webp?alt=media&token=3578c1e0-7278-4c03-8b56-dd007a9befd3';

  // String profilePicture = 'https://i.imgur.com/jlyGd1j.jpg';
  // ignore: prefer_typing_uninitialized_variables
  var dialogContext;
  final ImagePicker _picker = ImagePicker();
  XFile? pickedImage;
  File imageFile = File('No File');
  String imagePath = 'No Data';
  TextEditingController controller = TextEditingController();

  Future<void> uploadFile(String filePath) async {
    File file = File(filePath);
    try {
      EasyLoading.show(
        status: 'Uploading... ',
        dismissOnTap: false,
      );
      var snapshot = await FirebaseStorage.instance.ref('Profile Picture/${DateTime.now().millisecondsSinceEpoch}').putFile(file);
      var url = await snapshot.ref.getDownloadURL();
      setState(() {
        profilePicture = url.toString();
      });
    } on firebase_core.FirebaseException catch (e) {
      EasyLoading.dismiss();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.code.toString())));
    }
  }

  DropdownButton<String> getLanguage() {
    List<DropdownMenuItem<String>> dropDownLangItems = [];
    for (String lang in language) {
      var item = DropdownMenuItem(
        value: lang,
        child: Text(lang),
      );
      dropDownLangItems.add(item);
    }
    return DropdownButton(
      menuMaxHeight: 500,
      items: dropDownLangItems,
      value: dropdownLangValue,
      onChanged: (value) {
        setState(() {
          dropdownLangValue = value!;
        });
      },
    );
  }

  //
  // void freeSubscription() async {
  //   final DatabaseReference subscriptionRef = FirebaseDatabase.instance.ref().child(FirebaseAuth.instance.currentUser!.uid).child('Subscription');
  //   SubscriptionModel subscriptionModel = SubscriptionModel(
  //     subscriptionName: 'Year',
  //     subscriptionDate: DateTime.now().toString(),
  //     saleNumber: Subscription.subscriptionPlansService['Year']!['Sales'].toInt(),
  //     purchaseNumber: Subscription.subscriptionPlansService['Year']!['Purchase'].toInt(),
  //     partiesNumber: Subscription.subscriptionPlansService['Year']!['Parties'].toInt(),
  //     dueNumber: Subscription.subscriptionPlansService['Year']!['Due Collection'].toInt(),
  //     duration: 365,
  //     products: Subscription.subscriptionPlansService['Year']!['Products'].toInt(),
  //   );
  //   await subscriptionRef.set(subscriptionModel.toJson());
  // }

  void freeSubscription() async {
    await FirebaseDatabase.instance.ref().child('Admin Panel').child('Subscription Plan').orderByKey().get().then((value) {
      for (var element in value.children) {
        Subscription.subscriptionPlan.add(SubscriptionPlanModel.fromJson(jsonDecode(jsonEncode(element.value))));
      }
    });
    for (var element in Subscription.subscriptionPlan) {
      if (element.subscriptionName == 'Free') {
        Subscription.freeSubscriptionModel.products = element.products;
        Subscription.freeSubscriptionModel.duration = element.duration;
        Subscription.freeSubscriptionModel.dueNumber = element.dueNumber;
        Subscription.freeSubscriptionModel.partiesNumber = element.partiesNumber;
        Subscription.freeSubscriptionModel.purchaseNumber = element.purchaseNumber;
        Subscription.freeSubscriptionModel.saleNumber = element.purchaseNumber;
        Subscription.freeSubscriptionModel.subscriptionDate = DateTime.now().toString();
      }
    }
    final DatabaseReference subscriptionRef = FirebaseDatabase.instance.ref().child(FirebaseAuth.instance.currentUser!.uid).child('Subscription');

    await subscriptionRef.set(Subscription.freeSubscriptionModel.toJson());
  }

  // DropdownButton<String> getCategory() {
  //   List<DropdownMenuItem<String>> dropDownItems = [];
  //   for (String category in businessCategory) {
  //     var item = DropdownMenuItem(
  //       value: category,
  //       child: Text(
  //         category,
  //         style: const TextStyle(fontWeight: FontWeight.bold),
  //       ),
  //     );
  //     dropDownItems.add(item);
  //   }
  //   return DropdownButton(
  //     items: dropDownItems,
  //     value: dropdownValue,
  //     onChanged: (value) {
  //       setState(() {
  //         dropdownValue = value!;
  //       });
  //     },
  //   );
  // }
  //__________________________________________________shop_category_______________________________
  ShopCategoryModel? selectedShopCategory;

  DropdownButton<ShopCategoryModel> getShopCategory({required List<ShopCategoryModel> list}) {
    List<DropdownMenuItem<ShopCategoryModel>> dropDownItems = [];
    for (var element in list) {
      dropDownItems.add(DropdownMenuItem(
        value: element,
        child: Text(
          element.categoryName.toString(),
          style: kTextStyle.copyWith(color: kGreyTextColor, fontWeight: FontWeight.bold),
          overflow: TextOverflow.ellipsis,
        ),
      ));
    }

    return DropdownButton(
      icon: const Icon(
        Icons.keyboard_arrow_down_outlined,
        color: kGreyTextColor,
      ),
      items: dropDownItems,
      hint: const Text('Select Shop Category'),
      value: selectedShopCategory,
      onChanged: (ShopCategoryModel? value) {
        setState(() {
          selectedShopCategory = value;
        });
      },
    );
  }

  DateTime id = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: kMainColor,
        appBar: AppBar(
          title: Text(
            lang.S.of(context).setUpYourProfile,
            style: GoogleFonts.poppins(
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          backgroundColor: kMainColor,
          elevation: 0.0,
        ),
        body: Consumer(
          builder: (context, ref, _) {
            AsyncValue<List<ShopCategoryModel>> categoryList = ref.watch(shopCategoryProvider);
            return Container(
              alignment: Alignment.topCenter,
              decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(topRight: Radius.circular(30), topLeft: Radius.circular(30))),
              child: SingleChildScrollView(
                child: Center(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(
                          lang.S.of(context).updateYourProfileToConnect,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            color: kGreyTextColor,
                            fontSize: 15.0,
                          ),
                        ),
                      ),
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
                                        image: NetworkImage(profilePicture),
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
                      ).visible(false),
                      const SizedBox(height: 20.0),

                      ///_______Business_category______________________________________________
                      categoryList.when(
                        data: (warehouse) {
                          return Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: SizedBox(
                              height: 60.0,
                              child: FormField(
                                builder: (FormFieldState<dynamic> field) {
                                  return InputDecorator(
                                    decoration: InputDecoration(
                                        floatingLabelBehavior: FloatingLabelBehavior.always,
                                        labelText: lang.S.of(context).businessCategory,
                                        labelStyle: GoogleFonts.poppins(
                                          color: Colors.black,
                                          fontSize: 20.0,
                                        ),
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0))),
                                    child: DropdownButtonHideUnderline(child: getShopCategory(list: warehouse ?? [])),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                        error: (e, stack) {
                          return Center(
                            child: Text(
                              e.toString(),
                            ),
                          );
                        },
                        loading: () {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: AppTextField(
                          onChanged: (value) {
                            setState(() {
                              companyName = value;
                            });
                          }, // Optional
                          textFieldType: TextFieldType.NAME,
                          decoration: InputDecoration(labelText: lang.S.of(context).companyAndShopName, border: const OutlineInputBorder()),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: SizedBox(
                          height: 60.0,
                          child: AppTextField(
                            textFieldType: TextFieldType.PHONE,
                            initialValue: PhoneAuth.phoneNumber,
                            onChanged: (value) {
                              setState(() {
                                phoneNumber = value;
                              });
                            },
                            decoration: InputDecoration(
                              labelText: lang.S.of(context).phoneNumber,
                              hintText: lang.S.of(context).enterPhoneNumber,
                              border: const OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: AppTextField(
                          // ignore: deprecated_member_use
                          textFieldType: TextFieldType.ADDRESS,
                          controller: controller,
                          decoration: InputDecoration(
                            focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: kGreyTextColor),
                            ),
                            labelText: lang.S.of(context).companyAddress,
                            hintText: lang.S.of(context).enterFullAddress,
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: SizedBox(
                          height: 60.0,
                          child: FormField(
                            builder: (FormFieldState<dynamic> field) {
                              return InputDecorator(
                                decoration: InputDecoration(
                                    floatingLabelBehavior: FloatingLabelBehavior.always,
                                    labelText: lang.S.of(context).language,
                                    labelStyle: GoogleFonts.poppins(
                                      color: Colors.black,
                                      fontSize: 20.0,
                                    ),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0))),
                                child: DropdownButtonHideUnderline(child: getLanguage()),
                              );
                            },
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: AppTextField(
                          onChanged: (value) {
                            setState(() {
                              openingBalance = value.toInt();
                            });
                          }, // Optional
                          textFieldType: TextFieldType.PHONE,
                          decoration: InputDecoration(
                            prefixIcon: Container(
                              alignment: Alignment.center,
                              height: 60,
                              width: 30,
                              child: Text(currency),
                            ),
                            labelText: lang.S.of(context).openingBalance,
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: AppTextField(
                          onChanged: (value) {
                            gst = value;
                          }, // Optional
                          textFieldType: TextFieldType.PHONE,
                          decoration: InputDecoration(
                            prefixIcon: Container(
                              alignment: Alignment.center,
                              height: 60,
                              width: 30,
                              child: Text(currency),
                            ),
                            labelText: "GST Number",
                            hintText: 'Enter your GST Number',
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      ButtonGlobalWithoutIcon(
                        buttontext: lang.S.of(context).continu,
                        buttonDecoration: kButtonDecoration.copyWith(color: kMainColor, borderRadius: const BorderRadius.all(Radius.circular(30))),
                        onPressed: () async {
                          if (selectedShopCategory?.categoryName?.isNotEmpty ?? false) {
                            try {
                              EasyLoading.show(status: 'Loading...', dismissOnTap: false);

                              bool result = await InternetConnectionChecker().hasConnection;
                              result
                                  ? imagePath == 'No Data'
                                      ? null
                                      : await uploadFile(imagePath)
                                  : null;

                              // ignore: no_leading_underscores_for_local_identifiers
                              final DatabaseReference _personalInformationRef =
                                  // ignore: deprecated_member_use
                                  FirebaseDatabase.instance.ref().child(FirebaseAuth.instance.currentUser!.uid).child('Personal Information');
                              PersonalInformationModel personalInformation = PersonalInformationModel(
                                businessCategory: selectedShopCategory?.categoryName ?? '',
                                gst: gst,
                                companyName: companyName,
                                phoneNumber: phoneNumber,
                                countryName: controller.text,
                                language: dropdownLangValue,
                                pictureUrl: profilePicture,
                                dueInvoiceCounter: 1,
                                purchaseInvoiceCounter: 1,
                                saleInvoiceCounter: 1,
                                shopOpeningBalance: openingBalance,
                                remainingShopBalance: openingBalance,
                              );
                              await _personalInformationRef.set(personalInformation.toJson());
                              SellerInfoModel sellerInfoModel = SellerInfoModel(
                                businessCategory: selectedShopCategory?.categoryName ?? '',
                                companyName: companyName,
                                phoneNumber: phoneNumber,
                                countryName: controller.text,
                                language: dropdownLangValue,
                                pictureUrl: profilePicture,
                                userID: FirebaseAuth.instance.currentUser!.uid,
                                email: FirebaseAuth.instance.currentUser!.email ?? '',
                                subscriptionDate: DateTime.now().toString(),
                                subscriptionName: 'Free',
                                subscriptionMethod: 'Not Provided',
                                gst: gst,
                                userRegistrationDate: DateTime.now().toString(),
                              );

                              //_______________warehouse_setup______________
                              final DatabaseReference productInformationRef = FirebaseDatabase.instance.ref().child(await getUserID()).child('Warehouse List');
                              WareHouseModel warehouse = WareHouseModel(warehouseName: 'InHouse', warehouseAddress: companyName, id: id.toString());
                              await productInformationRef.push().set(warehouse.toJson());
                              final adminRef = FirebaseDatabase.instance.ref().child('Admin Panel');
                              await adminRef.child('Seller List').push().set(sellerInfoModel.toJson());

                              EasyLoading.showSuccess('Added Successfully', duration: const Duration(milliseconds: 1000));
                              await Future.delayed(const Duration(seconds: 1)).then((value) => const Home().launch(context));
                            } catch (e) {
                              EasyLoading.showError(e.toString());
                            }
                          } else {
                            EasyLoading.showInfo('Please Select Business Category');
                          }

                          // Navigator.pushNamed(context, '/otp');
                        },
                        buttonTextColor: Colors.white,
                      ),
                      const SizedBox(height: 20.0),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
