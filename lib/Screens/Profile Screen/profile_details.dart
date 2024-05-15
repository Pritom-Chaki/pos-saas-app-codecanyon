import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_pos/GlobalComponents/button_global.dart';
import 'package:mobile_pos/Screens/Authentication/login_form.dart';
import 'package:mobile_pos/Screens/Profile%20Screen/edit_profile.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import 'package:nb_utils/nb_utils.dart';

import '../../Provider/profile_provider.dart';
import '../../constant.dart';
import '../../model/personal_information_model.dart';

class ProfileDetails extends StatefulWidget {
  const ProfileDetails({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ProfileDetailsState createState() => _ProfileDetailsState();
}

class _ProfileDetailsState extends State<ProfileDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kMainColor,
      appBar: AppBar(
        title: Text(
          lang.S.of(context).profile,
          style: GoogleFonts.poppins(
            color: Colors.white,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15.0),
            child: GestureDetector(
              onTap: () {
                const EditProfile().launch(context);
              },
              child: Row(
                children: [
                  const Icon(
                    Icons.edit,
                    color: Colors.white,
                  ),
                  const SizedBox(
                    width: 5.0,
                  ),
                  Text(
                    lang.S.of(context).edit,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        backgroundColor: kMainColor,
        elevation: 0.0,
      ),
      body: Consumer(builder: (context, ref, child) {
        AsyncValue<PersonalInformationModel> userProfileDetails = ref.watch(profileDetailsProvider);
        return Container(
          alignment: Alignment.topCenter,
          decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(topRight: Radius.circular(30), topLeft: Radius.circular(30))),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: SingleChildScrollView(
              child: userProfileDetails.when(data: (details) {
                return Column(
                  children: [
                    Center(
                      child: Container(
                        height: 100.0,
                        width: 100.0,
                        decoration: BoxDecoration(
                          image: DecorationImage(image: NetworkImage(details.pictureUrl ?? ''), fit: BoxFit.cover),
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: AppTextField(
                        readOnly: true,
                        cursorColor: kGreyTextColor,
                        controller: TextEditingController(
                          text: details.companyName,
                        ),
                        decoration: InputDecoration(
                            labelText: lang.S.of(context).name,
                            border: const OutlineInputBorder().copyWith(borderSide: const BorderSide(color: kGreyTextColor)),
                            hoverColor: kGreyTextColor,
                            fillColor: kGreyTextColor),
                        textFieldType: TextFieldType.NAME,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: AppTextField(
                        readOnly: true,
                        cursorColor: kGreyTextColor,
                        controller: TextEditingController(
                          text: details.phoneNumber,
                        ),
                        decoration: InputDecoration(
                            labelText: lang.S.of(context).phoneNumber,
                            border: const OutlineInputBorder().copyWith(borderSide: const BorderSide(color: kGreyTextColor)),
                            hoverColor: kGreyTextColor,
                            fillColor: kGreyTextColor),
                        textFieldType: TextFieldType.NAME,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: AppTextField(
                        readOnly: true,
                        cursorColor: kGreyTextColor,
                        controller: TextEditingController(
                          text: details.businessCategory,
                        ),
                        decoration: InputDecoration(
                          labelText: lang.S.of(context).businessCategory,
                          border: const OutlineInputBorder().copyWith(borderSide: const BorderSide(color: kGreyTextColor)),
                          hoverColor: kGreyTextColor,
                          fillColor: kGreyTextColor,
                        ),
                        textFieldType: TextFieldType.NAME,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: AppTextField(
                        readOnly: true,
                        cursorColor: kGreyTextColor,
                        controller: TextEditingController(
                          text: details.countryName,
                        ),
                        decoration: InputDecoration(
                            labelText: lang.S.of(context).address,
                            border: const OutlineInputBorder().copyWith(borderSide: const BorderSide(color: kGreyTextColor)),
                            hoverColor: kGreyTextColor,
                            fillColor: kGreyTextColor),
                        textFieldType: TextFieldType.NAME,
                      ),
                    ),
                    ButtonGlobal(
                      iconWidget: Icons.arrow_forward,
                      buttontext: lang.S.of(context).changePassword,
                      iconColor: Colors.white,
                      buttonDecoration: kButtonDecoration.copyWith(color: kMainColor),
                      onPressed: () async {
                        try {
                          EasyLoading.show(status: 'Sending Email', dismissOnTap: false);
                          await FirebaseAuth.instance.sendPasswordResetEmail(
                            email: FirebaseAuth.instance.currentUser!.email.toString(),
                          );
                          EasyLoading.showSuccess('Email Sent! Check your Inbox');
                          // ignore: use_build_context_synchronously
                          const LoginForm().launch(context);
                          FirebaseAuth.instance.signOut();
                        } catch (e) {
                          EasyLoading.showError(e.toString());
                        }
                      },
                    ).visible(false),
                  ],
                );
              }, error: (e, stack) {
                return Text(e.toString());
              }, loading: () {
                return const CircularProgressIndicator();
              }),
            ),
          ),
        );
      }),
    );
  }
}
