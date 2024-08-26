// ignore_for_file: unused_result, use_build_context_synchronously

import 'dart:io';

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
import 'package:mobile_pos/generated/l10n.dart' as lang;
import 'package:nb_utils/nb_utils.dart';

import '../../Provider/profile_provider.dart';
import '../../Provider/shop_category_provider.dart';
import '../../constant.dart';
import '../../currency.dart';
import '../../model/personal_information_model.dart';
import '../../model/seller_info_model.dart';
import '../../model/shop_category_model.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  String dropdownLangValue = 'English';
  String initialCountry = '';
  String dropdownValue = 'Fashion Store';
  String companyName = 'nodata', phoneNumber = 'nodata';
  String gst = '';
  double progress = 0.0;
  int invoiceNumber = 0;
  bool showProgress = false;
  String profilePicture = 'nodata';

  // ignore: prefer_typing_uninitialized_variables
  var dialogContext;
  final ImagePicker _picker = ImagePicker();
  XFile? pickedImage;
  File imageFile = File('No File');
  String imagePath = 'No Data';

  int loopCount = 0;

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

  List<String> catList = [];

  DropdownButton<String> getCategory() {
    List<DropdownMenuItem<String>> dropDownItems = [];
    for (String category in catList) {
      var item = DropdownMenuItem(
        value: category,
        child: Text(category),
      );
      dropDownItems.add(item);
    }
    return DropdownButton(
      items: dropDownItems,
      value: isSelectedCat,
      onChanged: (value) {
        setState(() {
          isSelectedCat = value!;
        });
      },
    );
  }

  String isSelectedCat = '';

  DropdownButton<String> getLanguage(String lang) {
    List<DropdownMenuItem<String>> dropDownLangItems = [];
    for (String lang in language) {
      var item = DropdownMenuItem(
        value: lang,
        child: Text(lang),
      );
      dropDownLangItems.add(item);
    }
    return DropdownButton(
      items: dropDownLangItems,
      value: lang,
      onChanged: (value) {
        setState(() {
          dropdownLangValue = value!;
        });
      },
    );
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kMainColor,
      appBar: AppBar(
        title: Text(
          lang.S.of(context).updateYourProfile,
          style: GoogleFonts.poppins(
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: kMainColor,
        elevation: 0.0,
        iconTheme: const IconThemeData(color: kWhite),
      ),
      body: Container(
        alignment: Alignment.topCenter,
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(topRight: Radius.circular(30), topLeft: Radius.circular(30))),
        child: SingleChildScrollView(
          child: Consumer(builder: (context, ref, child) {
            AsyncValue<PersonalInformationModel> userProfileDetails = ref.watch(profileDetailsProvider);
            AsyncValue<List<ShopCategoryModel>> categoryList = ref.watch(shopCategoryProvider);
            loopCount++;
            if (loopCount == 1) {
              dropdownValue = userProfileDetails.value!.businessCategory.toString();
              isSelectedCat = userProfileDetails.value!.businessCategory.toString();
              dropdownLangValue = userProfileDetails.value!.language.toString();
              profilePicture = userProfileDetails.value?.pictureUrl.toString() ?? '';
            }
            return Center(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      lang.S.of(context).updateYourProfiletoConnectTOCusomter,
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
                  ),
                  const SizedBox(height: 20.0),
                  categoryList.when(
                    data: (warehouse) {
                      catList.clear();
                      for (var element in warehouse) {
                        catList.add(element.categoryName.toString());
                      }
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
                                child: DropdownButtonHideUnderline(child: getCategory()),
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
                  userProfileDetails.when(data: (details) {
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: AppTextField(
                            initialValue: details.companyName,
                            onChanged: (value) {
                              setState(() {
                                companyName = value;
                              });
                            }, // Optional
                            textFieldType: TextFieldType.NAME,
                            decoration: const InputDecoration(labelText: 'Company & Business Name', border: OutlineInputBorder()),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: SizedBox(
                            height: 60.0,
                            child: AppTextField(
                              readOnly: true,
                              textFieldType: TextFieldType.PHONE,
                              initialValue: details.phoneNumber,
                              onChanged: (value) {
                                setState(() {
                                  phoneNumber = value;
                                });
                              },
                              decoration: InputDecoration(
                                labelText: lang.S.of(context).phoneNumber,
                                border: const OutlineInputBorder(),
                                // prefix: CountryCodePicker(
                                //   padding: EdgeInsets.zero,
                                //   onChanged: print,
                                //   initialSelection: 'BD',
                                //   showFlag: false,
                                //   showDropDownButton: true,
                                //   alignLeft: false,
                                // ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: SizedBox(
                            height: 60.0,
                            child: AppTextField(
                              textFieldType: TextFieldType.NUMBER,
                              initialValue: details.gst,
                              onChanged: (value) {
                                setState(() {
                                  gst = value;
                                });
                              },
                              decoration: const InputDecoration(
                                hintText: 'Enter Your GST Number',
                                labelText: "GST Number",

                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: AppTextField(
                            initialValue: details.countryName,
                            onChanged: (value) {
                              setState(() {
                                initialCountry = value;
                              });
                            }, // Optional
                            textFieldType: TextFieldType.NAME,
                            decoration: const InputDecoration(labelText: 'Address', border: OutlineInputBorder()),
                          ),
                        ),
                      ],
                    );
                  }, error: (e, stack) {
                    return Text(e.toString());
                  }, loading: () {
                    return const CircularProgressIndicator();
                  }),
                  const SizedBox(
                    height: 40.0,
                  ),
                  ButtonGlobal(
                    iconWidget: Icons.arrow_forward,
                    buttontext: lang.S.of(context).updateNow,
                    iconColor: Colors.white,
                    buttonDecoration: kButtonDecoration.copyWith(color: kMainColor, borderRadius: const BorderRadius.all(Radius.circular(30))),
                    onPressed: () async {
                      if (!isDemo) {
                        if (profilePicture == 'nodata') {
                          setState(() {
                            profilePicture = userProfileDetails.value!.pictureUrl.toString();
                          });
                        }
                        if (companyName == 'nodata') {
                          setState(() {
                            companyName = userProfileDetails.value!.companyName.toString();
                          });
                        }
                        if (phoneNumber == 'nodata') {
                          setState(() {
                            phoneNumber = userProfileDetails.value!.phoneNumber.toString();
                          });
                        }
                        try {
                          EasyLoading.show(status: 'Loading...', dismissOnTap: false);
                          bool result = await InternetConnectionChecker().hasConnection;
                          result
                              ? imagePath == 'No Data'
                                  ? null
                                  : await uploadFile(imagePath)
                              : null;
                          // ignore: no_leading_underscores_for_local_identifiers
                          final DatabaseReference _personalInformationRef = FirebaseDatabase.instance
                              // ignore: deprecated_member_use
                              .reference()
                              .child(constUserId)
                              .child('Personal Information');
                          _personalInformationRef.keepSynced(true);
                          _personalInformationRef.update({
                            "businessCategory": dropdownValue,
                            'companyName': companyName,
                            'phoneNumber': phoneNumber,
                            'countryName': initialCountry,
                            'language': dropdownLangValue,
                            "pictureUrl": profilePicture,
                            "gst":gst,
                          });

                          SellerInfoModel sellerInfo = SellerInfoModel(
                            businessCategory: dropdownValue,
                            companyName: companyName,
                            phoneNumber: phoneNumber,
                            countryName: initialCountry,
                            language: dropdownLangValue,
                            pictureUrl: profilePicture,
                            gst: gst,
                          );

                          String? sellerDataRef = await getSaleID(id: constUserId);
                          if (sellerDataRef != null) {
                            final DatabaseReference superAdminSalerListRepo =
                                FirebaseDatabase.instance.ref().child('Admin Panel').child('Seller List').child(sellerDataRef);

                            superAdminSalerListRepo.update({
                              'phoneNumber': phoneNumber,
                              'companyName': companyName,
                              "businessCategory": dropdownValue,
                              "pictureUrl": profilePicture,
                              'language': dropdownLangValue,
                              'countryName': initialCountry,
                            });
                          }
                          ref.refresh(profileDetailsProvider);
                          EasyLoading.dismiss();
                          Navigator.pushNamed(context, '/home');
                        } catch (e) {
                          EasyLoading.showError(e.toString());
                        }
                      } else {
                        EasyLoading.showError(demoText);
                      }

                      // Navigator.pushNamed(context, '/otp');
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}
