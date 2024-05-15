import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:mobile_pos/Screens/Home/home_screen.dart';
import 'package:mobile_pos/Screens/Report/reports.dart';
import 'package:mobile_pos/Screens/Settings/settings_screen.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import 'package:mobile_pos/subscription.dart';
import 'package:restart_app/restart_app.dart';

import '../../constant.dart';
import '../../currency.dart';
import '../Sales/sales_contact.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  void signOutAutoLogin() async {
    CurrentUserData currentUserData = CurrentUserData();
    if (await currentUserData.isSubUserEmailNotFound() && isSubUser) {
      await FirebaseAuth.instance.signOut();
      Future.delayed(const Duration(milliseconds: 5000), () async {
        EasyLoading.showError('User is deleted');
      });
      Future.delayed(const Duration(milliseconds: 1000), () async {
        Restart.restartApp();
      });
    }
  }

  int _selectedIndex = 0;
  bool isDeviceConnected = false;
  bool isAlertSet = false;
  bool isNoInternet = false;

  static const List<Widget> _widgetOptions = <Widget>[HomeScreen(), SalesContact(isFromHome: true), Reports(isFromHome: true), SettingScreen()];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isSubUser ? signOutAutoLogin() : null;
    Subscription.getUserLimitsData(context: context, wannaShowMsg: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kMainColor,
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        elevation: 6.0,
        selectedItemColor: kMainColor,
        // ignore: prefer_const_literals_to_create_immutables
        items: [
          BottomNavigationBarItem(
            icon: const Icon(FeatherIcons.home),
            label: lang.S.of(context).home,
          ),
          BottomNavigationBarItem(
            icon: const Icon(FeatherIcons.shoppingCart),
            label: lang.S.of(context).sales,
          ),
          BottomNavigationBarItem(
            icon: const Icon(FeatherIcons.fileText),
            label: lang.S.of(context).reports,
          ),
          BottomNavigationBarItem(icon: const Icon(FeatherIcons.settings), label: lang.S.of(context).setting),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

// showDialogBox() {
//   showCupertinoDialog<String>(
//     context: context,
//     barrierDismissible: false,
//     builder: (BuildContext context) => CupertinoAlertDialog(
//       title: const Text('No Connection'),
//       content: const Text('Please check your internet connectivity'),
//       actions: <Widget>[
//         TextButton(
//           onPressed: () async {
//             Navigator.pop(context, 'Cancel');
//             setState(() => isAlertSet = false);
//             isDeviceConnected = await InternetConnectionChecker().hasConnection;
//             if (!isDeviceConnected && isAlertSet == false) {
//               showDialogBox();
//               setState(() => isAlertSet = true);
//             }
//           },
//           child: const Text('Try Again'),
//         ),
//       ],
//     ),
//   );
// }
}
