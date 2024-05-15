import 'package:flutter/material.dart';
import 'package:mobile_pos/Screens/Settings/settings_screen.dart';
import 'package:mobile_pos/constant.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import 'package:nb_utils/nb_utils.dart';
class BottomNav extends StatefulWidget {
  const BottomNav({
    super.key,
  });

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      switch (_selectedIndex) {
        case 0:
          Navigator.pushNamed(context, '/home');
          break;
        case 1:
          Navigator.pushNamed(context, '/order');
          break;
        case 2:
          Navigator.pushNamed(context, '/featuredProduct');
          break;
        case 3:
          const SettingScreen().launch(context);
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      elevation: 6.0,
      selectedItemColor: kMainColor,
      // ignore: prefer_const_literals_to_create_immutables
      items: [
         BottomNavigationBarItem(
          icon: const Icon(Icons.home),
          label: lang.S.of(context).home,
        ),
         BottomNavigationBarItem(
          icon: const Icon(Icons.flare_sharp),
          label: lang.S.of(context).maan,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.backpack),
          label: lang.S.of(context).pacakge,
        ),
        BottomNavigationBarItem(icon: const Icon(Icons.settings), label: lang.S.of(context).setting),
      ],
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
    );
  }
}
