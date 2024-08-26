import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconly/iconly.dart';
import 'package:mobile_pos/GlobalComponents/button_global.dart';
import 'package:mobile_pos/Screens/Authentication/login_form.dart';
import 'package:mobile_pos/Screens/Profile%20Screen/edit_profile.dart';
import 'package:mobile_pos/Widget/key_value_widget.dart';
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
                    IconlyBold.edit,
                    color: Colors.white,
                    size: 22,
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
          decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(topRight: Radius.circular(30), topLeft: Radius.circular(30))),
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: SingleChildScrollView(
              child: userProfileDetails.when(data: (details) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10,),
                    Center(
                      child: Column(
                        children: [
                          Container(
                            height: 100.0,
                            width: 100.0,
                            decoration: BoxDecoration(
                              image: DecorationImage(image: NetworkImage(details.pictureUrl ?? ''), fit: BoxFit.cover),
                              shape: BoxShape.circle
                            ),
                          ),
                          Text(details.companyName.toString(),style: kTextStyle.copyWith(color: kTitleColor,fontWeight: FontWeight.bold,fontSize: 20),),
                        ],
                      ),
                    ),

                    const SizedBox(
                      height: 25.0,
                    ),
                    Text('Personal Information:',style: kTextStyle.copyWith(fontWeight: FontWeight.bold,fontSize: 18,color: kTitleColor),),
                    const SizedBox(height: 15,),
                    KeyValueWidget(
                        keys: 'Shop Name',
                        value: details.companyName.toString()),
                    Divider(thickness: 1.0,color: kBorderColor.withOpacity(0.30),),
                    KeyValueWidget(keys: 'Phone Number', value: details.phoneNumber),
                    Divider(thickness: 1.0,color: kBorderColor.withOpacity(0.30),),
                    KeyValueWidget(keys: 'Business Category', value: details.businessCategory.toString()),
                    Divider(thickness: 1.0,color: kBorderColor.withOpacity(0.30),),
                    KeyValueWidget(keys: 'Language', value: details.language.toString()),
                    Divider(thickness: 1.0,color: kBorderColor.withOpacity(0.30),),
                    KeyValueWidget(keys: 'Shop GST', value: details.gst.toString()),
                    Divider(thickness: 1.0,color: kBorderColor.withOpacity(0.30),),
                    KeyValueWidget(keys: 'Address', value: details.countryName.toString()),
                    // Divider(thickness: 1.0,color: kBorderColor.withOpacity(0.30),),
                    // KeyValueWidget(keys: 'Opening Balance', value: details.shopOpeningBalance.toString()),
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
