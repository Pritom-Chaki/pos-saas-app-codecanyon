import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_pos/GlobalComponents/button_global.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import 'package:nb_utils/nb_utils.dart';

import '../../Provider/user_role_provider.dart';
import '../../constant.dart';
import '../../currency.dart';
import '../Home/home.dart';

class SuccessScreen extends StatelessWidget {
  SuccessScreen({super.key, this.email});
  final String? email;
  final CurrentUserData currentUserData = CurrentUserData();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Consumer(builder: (context, ref, _) {
        final userRoleData = ref.watch(allUserRoleProvider);
        return userRoleData.when(data: (data) {
          if (email == 'phone') {
            currentUserData.putUserData(userId: FirebaseAuth.instance.currentUser!.uid, subUser: false, title: '', email: '');
          } else {
            bool isNotFound = true;
            for (var element in data) {
              if (element.email == email) {
                isNotFound = false;
                currentUserData.putUserData(userId: element.databaseId, subUser: true, title: element.userTitle, email: element.email);
                subUserTitle = element.userTitle;
              }
            }
            if (isNotFound) {
              currentUserData.putUserData(userId: FirebaseAuth.instance.currentUser!.uid, subUser: false, title: '', email: '');
            }
          }
          return Scaffold(
            resizeToAvoidBottomInset: true,
            body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Image(image: AssetImage('images/success.png')),
                const SizedBox(height: 40.0),
                Text(
                  lang.S.of(context).congratulations,
                  style: GoogleFonts.poppins(
                    fontSize: 25.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    lang.S.of(context).youHaveSuccefulyLogin,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: kGreyTextColor,
                      fontSize: 20.0,
                    ),
                  ),
                ),
              ],
            ),
            bottomNavigationBar: ButtonGlobal(
                buttontext: lang.S.of(context).continu,
                buttonDecoration: kButtonDecoration.copyWith(color: kMainColor, borderRadius: const BorderRadius.all(Radius.circular(30))),
                onPressed: () async {
                  await Future.delayed(const Duration(seconds: 1)).then((value) => const Home().launch(context));
                  // Navigator.pushNamed(context, '/home');
                },
                 iconWidget: null, iconColor: Colors.white),
          );
        }, error: (e, stack) {
          return Text(e.toString());
        }, loading: () {
          return const Center(child: CircularProgressIndicator());
        });
      }),
    );
  }
}
