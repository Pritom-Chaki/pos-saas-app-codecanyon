import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_pos/Language/language_screen.dart';
import 'package:mobile_pos/Screens/Profile%20Screen/profile_details.dart';
import 'package:mobile_pos/Screens/Settings/currency_screen.dart';
import 'package:mobile_pos/Screens/Settings/feedback_screen.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import 'package:nb_utils/nb_utils.dart';
import 'package:restart_app/restart_app.dart';
import '../../Provider/profile_provider.dart';
import '../../constant.dart';
import '../../currency.dart';
import '../../model/personal_information_model.dart';
import '../Shimmers/home_screen_appbar_shimmer.dart';
import '../Terms & Privacy/terms_and_privacy_screen.dart';
import '../User Roles/user_role_screen.dart';
import '../Warehouse/warehouse_list.dart';
import '../subscription/package_screen.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SettingScreenState createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  String? dropdownValue = '\$ (US Dollar)';
  bool expanded = false;
  bool expandedHelp = false;
  bool expandedAbout = false;
  bool selected = false;

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    EasyLoading.showSuccess('Successfully Logged Out');
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    printerIsEnable();
    getCurrency();
  }

  getCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    String? data = prefs.getString('currency');
    if (!data.isEmptyOrNull) {
      for (var element in items) {
        if (element.substring(0, 2).contains(data!) || element.substring(0, 5).contains(data!)) {
          setState(() {
            dropdownValue = element;
          });
          break;
        }
      }
    } else {
      setState(() {
        dropdownValue = items[0];
      });
    }
  }

  void printerIsEnable() async {
    final prefs = await SharedPreferences.getInstance();

    isPrintEnable = prefs.getBool('isPrintEnable') ?? true;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Consumer(builder: (context, ref, _) {
        AsyncValue<PersonalInformationModel> userProfileDetails = ref.watch(profileDetailsProvider);
        return Scaffold(
          backgroundColor: kMainColor,
          body: Column(
            children: [
              Card(
                elevation: 0.0,
                color: kMainColor,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: userProfileDetails.when(data: (details) {
                    return Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            const ProfileDetails().launch(context);
                          },
                          child: Container(
                            height: 42,
                            width: 42,
                            decoration: BoxDecoration(
                              image: DecorationImage(image: NetworkImage(details.pictureUrl ?? ''), fit: BoxFit.cover),
                              borderRadius: BorderRadius.circular(50),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10.0),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              details.companyName ?? '',
                              style: GoogleFonts.poppins(
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              details.businessCategory ?? '',
                              style: GoogleFonts.poppins(
                                fontSize: 15.0,
                                fontWeight: FontWeight.normal,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  }, error: (e, stack) {
                    return Text(e.toString());
                  }, loading: () {
                    return const HomeScreenAppBarShimmer();
                  }),
                ),
              ),
              Expanded(
                child: Container(
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(topRight: Radius.circular(30), topLeft: Radius.circular(30))),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 15,left: 15,right: 15),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                  color: kWhite,
                                  borderRadius: BorderRadius.circular(6),
                                  boxShadow: [
                                    BoxShadow(
                                        color: const Color(0xff0C1A4B).withOpacity(0.24),
                                        offset: const Offset(0, 0),
                                        blurRadius: 1,
                                        spreadRadius: 0
                                    ),
                                    BoxShadow(
                                        color: const Color(0xff473232).withOpacity(0.05),
                                        offset: const Offset(0, 3),
                                        blurRadius: 8,
                                        spreadRadius: -1
                                    ),
                                  ]
                              ),
                              child: ListTile(
                                horizontalTitleGap: 10,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                                title: Text(
                                  lang.S.of(context).profile,
                                  style: GoogleFonts.poppins(
                                    color: Colors.black,
                                    fontSize: 18.0,
                                  ),
                                ),
                                onTap: () {
                                  const ProfileDetails().launch(context);
                                },
                                leading: const Icon(
                                  Icons.person_outline_rounded,
                                  color: kMainColor,
                                ),
                                trailing: const Icon(
                                  Icons.arrow_forward_ios,
                                  color: kGreyTextColor,
                                  size: 18,
                                ),
                              ),
                            ),
                            const SizedBox(height: 15,),
                            Container(
                              decoration: BoxDecoration(
                                  color: kWhite,
                                  borderRadius: BorderRadius.circular(6),
                                  boxShadow: [
                                    BoxShadow(
                                        color: const Color(0xff0C1A4B).withOpacity(0.24),
                                        offset: const Offset(0, 0),
                                        blurRadius: 1,
                                        spreadRadius: 0
                                    ),
                                    BoxShadow(
                                        color: const Color(0xff473232).withOpacity(0.05),
                                        offset: const Offset(0, 3),
                                        blurRadius: 8,
                                        spreadRadius: -1
                                    ),
                                  ]
                              ),
                              child: ListTile(
                                title: Text(
                                  lang.S.of(context).printingOption,
                                  style: GoogleFonts.poppins(
                                    color: Colors.black,
                                    fontSize: 18.0,
                                  ),
                                ),
                                horizontalTitleGap: 10,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                                leading: const Icon(
                                  Icons.print,
                                  color: kMainColor,
                                ),
                                trailing: Transform.scale(
                                  scale: 0.8,
                                  child: Switch.adaptive(
                                    value: isPrintEnable,
                                    onChanged: (bool value) async {
                                      final prefs = await SharedPreferences.getInstance();
                                      await prefs.setBool('isPrintEnable', value);
                                      setState(() {
                                        isPrintEnable = value;
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ),
                            // ListTile(
                            //   onTap: () => EasyLoading.showError('Coming Soon'),
                            //   title: Text(
                            //     'Create Online Store',
                            //     style: GoogleFonts.poppins(
                            //       color: Colors.black,
                            //       fontSize: 18.0,
                            //     ),
                            //   ),
                            //   leading: const Icon(
                            //     Icons.shopping_bag_outlined,
                            //     color: kMainColor,
                            //   ),
                            //   trailing: const Icon(
                            //     Icons.arrow_forward_ios,
                            //     color: kGreyTextColor,
                            //   ),
                            // ),
                            // ExpansionPanelList(
                            //   expandedHeaderPadding: EdgeInsets.zero,
                            //   expansionCallback: (int index, bool isExpanded) {},
                            //   animationDuration: const Duration(seconds: 1),
                            //   elevation: 0,
                            //   dividerColor: Colors.white,
                            //   children: [
                            //     ExpansionPanel(
                            //       headerBuilder: (BuildContext context, bool isExpanded) {
                            //         return Row(
                            //           children: [
                            //             const Padding(
                            //               padding: EdgeInsets.only(left: 16.0),
                            //               child: Icon(
                            //                 Icons.handyman_outlined,
                            //                 color: kMainColor,
                            //               ),
                            //             ),
                            //             TextButton(
                            //               child: Padding(
                            //                 padding: const EdgeInsets.only(left: 24.0),
                            //                 child: Text(
                            //                   'Settings',
                            //                   style: GoogleFonts.poppins(
                            //                     fontSize: 18.0,
                            //                     color: expanded == false ? Colors.black : kMainColor,
                            //                   ),
                            //                 ),
                            //               ),
                            //               onPressed: () {
                            //                 EasyLoading.showError('Coming Soon');
                            //                 // setState(() {
                            //                 //   expanded == false ? expanded = true : expanded = false;
                            //                 // });
                            //               },
                            //             ),
                            //           ],
                            //         );
                            //       },
                            //       body: Column(
                            //         children: [
                            //           Padding(
                            //             padding: const EdgeInsets.only(left: 55.0),
                            //             child: ListTile(
                            //               title: Text(
                            //                 'Notification Setting',
                            //                 style: GoogleFonts.poppins(
                            //                   color: Colors.black,
                            //                   fontSize: 16.0,
                            //                 ),
                            //               ),
                            //               trailing: const Icon(
                            //                 Icons.arrow_forward_ios,
                            //                 color: kGreyTextColor,
                            //                 size: 16.0,
                            //               ),
                            //               onTap: () => showDialog(
                            //                 context: context,
                            //                 builder: (BuildContext context) => Dialog(
                            //                   shape: RoundedRectangleBorder(
                            //                     borderRadius: BorderRadius.circular(12.0),
                            //                   ),
                            //                   child: const NoticationSettings(),
                            //                 ),
                            //               ),
                            //             ),
                            //           ),
                            //           Padding(
                            //             padding: const EdgeInsets.only(left: 55.0),
                            //             child: ListTile(
                            //               title: Text(
                            //                 'Language Setting',
                            //                 style: GoogleFonts.poppins(
                            //                   color: Colors.black,
                            //                   fontSize: 16.0,
                            //                 ),
                            //               ),
                            //               onTap: () => showDialog(
                            //                 context: context,
                            //                 builder: (BuildContext context) => Dialog(
                            //                   shape: RoundedRectangleBorder(
                            //                     borderRadius: BorderRadius.circular(12.0),
                            //                   ),
                            //                   // ignore: sized_box_for_whitespace
                            //                   child: Container(
                            //                     height: 400.0,
                            //                     width: MediaQuery.of(context).size.width - 80,
                            //                     child: Column(
                            //                       children: [
                            //                         const SizedBox(
                            //                           height: 20.0,
                            //                         ),
                            //                         Text(
                            //                           'Select Language',
                            //                           style: GoogleFonts.poppins(
                            //                             color: Colors.black,
                            //                             fontSize: 20.0,
                            //                             fontWeight: FontWeight.bold,
                            //                           ),
                            //                         ),
                            //                         ...List.generate(
                            //                           language.length,
                            //                           (index) => ListTile(
                            //                             title: Text(language[index]),
                            //                             trailing: const Icon(
                            //                               Icons.check_circle_outline,
                            //                               color: kGreyTextColor,
                            //                             ),
                            //                             onTap: () {
                            //                               setState(() {
                            //                                 selected == false ? selected = true : selected = false;
                            //                               });
                            //                               Navigator.pop(context);
                            //                             },
                            //                           ),
                            //                         ),
                            //                       ],
                            //                     ),
                            //                   ),
                            //                 ),
                            //               ),
                            //               trailing: const Icon(
                            //                 Icons.arrow_forward_ios,
                            //                 color: kGreyTextColor,
                            //                 size: 16.0,
                            //               ),
                            //             ),
                            //           ),
                            //           Padding(
                            //             padding: const EdgeInsets.only(left: 55.0),
                            //             child: ListTile(
                            //               title: Text(
                            //                 'Online Store Setting',
                            //                 style: GoogleFonts.poppins(
                            //                   color: Colors.black,
                            //                   fontSize: 16.0,
                            //                 ),
                            //               ),
                            //               trailing: const Icon(
                            //                 Icons.arrow_forward_ios,
                            //                 color: kGreyTextColor,
                            //                 size: 16.0,
                            //               ),
                            //             ),
                            //           ),
                            //           Padding(
                            //             padding: const EdgeInsets.only(left: 55.0),
                            //             child: ListTile(
                            //               title: Text(
                            //                 'App Update',
                            //                 style: GoogleFonts.poppins(
                            //                   color: Colors.black,
                            //                   fontSize: 16.0,
                            //                 ),
                            //               ),
                            //               trailing: const Icon(
                            //                 Icons.arrow_forward_ios,
                            //                 color: kGreyTextColor,
                            //                 size: 16.0,
                            //               ),
                            //             ),
                            //           ),
                            //         ],
                            //       ),
                            //       isExpanded: expanded,
                            //     ),
                            //   ],
                            // ),
                            // ExpansionPanelList(
                            //   expandedHeaderPadding: EdgeInsets.zero,
                            //   expansionCallback: (int index, bool isExpanded) {},
                            //   animationDuration: const Duration(seconds: 1),
                            //   elevation: 0,
                            //   dividerColor: Colors.white,
                            //   children: [
                            //     ExpansionPanel(
                            //       headerBuilder: (BuildContext context, bool isExpanded) {
                            //         return Row(
                            //           children: [
                            //             const Padding(
                            //               padding: EdgeInsets.only(left: 16.0),
                            //               child: Icon(
                            //                 Icons.help_outline_rounded,
                            //                 color: kMainColor,
                            //               ),
                            //             ),
                            //             TextButton(
                            //               child: Padding(
                            //                 padding: const EdgeInsets.only(left: 24.0),
                            //                 child: Text(
                            //                   'Help & Support',
                            //                   style: GoogleFonts.poppins(
                            //                     fontSize: 18.0,
                            //                     color: expandedHelp == false ? Colors.black : kMainColor,
                            //                   ),
                            //                 ),
                            //               ),
                            //               onPressed: () {
                            //                 EasyLoading.showError('Coming Soon');
                            //                 // setState(() {
                            //                 //   expandedHelp == false ? expandedHelp = true : expandedHelp = false;
                            //                 // });
                            //               },
                            //             ),
                            //           ],
                            //         );
                            //       },
                            //       body: Column(
                            //         children: [
                            //           Padding(
                            //             padding: const EdgeInsets.only(left: 55.0),
                            //             child: ListTile(
                            //               title: Text(
                            //                 'FAQs',
                            //                 style: GoogleFonts.poppins(
                            //                   color: Colors.black,
                            //                   fontSize: 16.0,
                            //                 ),
                            //               ),
                            //               trailing: const Icon(
                            //                 Icons.arrow_forward_ios,
                            //                 color: kGreyTextColor,
                            //                 size: 16.0,
                            //               ),
                            //             ),
                            //           ),
                            //           Padding(
                            //             padding: const EdgeInsets.only(left: 55.0),
                            //             child: ListTile(
                            //               onTap: () {
                            //                 const ContactUs().launch(context);
                            //               },
                            //               title: Text(
                            //                 'Contact Us',
                            //                 style: GoogleFonts.poppins(
                            //                   color: Colors.black,
                            //                   fontSize: 16.0,
                            //                 ),
                            //               ),
                            //               trailing: const Icon(
                            //                 Icons.arrow_forward_ios,
                            //                 color: kGreyTextColor,
                            //                 size: 16.0,
                            //               ),
                            //             ),
                            //           ),
                            //         ],
                            //       ),
                            //       isExpanded: expandedHelp,
                            //     ),
                            //   ],
                            // ),
                            // ExpansionPanelList(
                            //   expandedHeaderPadding: EdgeInsets.zero,
                            //   expansionCallback: (int index, bool isExpanded) {},
                            //   animationDuration: const Duration(seconds: 1),
                            //   elevation: 0,
                            //   dividerColor: Colors.white,
                            //   children: [
                            //     ExpansionPanel(
                            //       headerBuilder: (BuildContext context, bool isExpanded) {
                            //         return Row(
                            //           children: [
                            //             const Padding(
                            //               padding: EdgeInsets.only(left: 16.0),
                            //               child: Icon(
                            //                 Icons.text_snippet_outlined,
                            //                 color: kMainColor,
                            //               ),
                            //             ),
                            //             TextButton(
                            //               child: Padding(
                            //                 padding: const EdgeInsets.only(left: 24.0),
                            //                 child: Text(
                            //                   'About Us',
                            //                   style: GoogleFonts.poppins(
                            //                     fontSize: 18.0,
                            //                     color: expandedAbout == false ? Colors.black : kMainColor,
                            //                   ),
                            //                 ),
                            //               ),
                            //               onPressed: () {
                            //                 EasyLoading.showError('Coming Soon');
                            //                 // setState(() {
                            //                 //   expandedAbout == false ? expandedAbout = true : expandedAbout = false;
                            //                 // });
                            //               },
                            //             ),
                            //           ],
                            //         );
                            //       },
                            //       body: Column(
                            //         children: [
                            //           Padding(
                            //             padding: const EdgeInsets.only(left: 55.0),
                            //             child: ListTile(
                            //               title: Text(
                            //                 'About Sales Pro',
                            //                 style: GoogleFonts.poppins(
                            //                   color: Colors.black,
                            //                   fontSize: 16.0,
                            //                 ),
                            //               ),
                            //               trailing: const Icon(
                            //                 Icons.arrow_forward_ios,
                            //                 color: kGreyTextColor,
                            //                 size: 16.0,
                            //               ),
                            //             ),
                            //           ),
                            //           Padding(
                            //             padding: const EdgeInsets.only(left: 55.0),
                            //             child: ListTile(
                            //               title: Text(
                            //                 'Privacy Policy',
                            //                 style: GoogleFonts.poppins(
                            //                   color: Colors.black,
                            //                   fontSize: 16.0,
                            //                 ),
                            //               ),
                            //               trailing: const Icon(
                            //                 Icons.arrow_forward_ios,
                            //                 color: kGreyTextColor,
                            //                 size: 16.0,
                            //               ),
                            //             ),
                            //           ),
                            //           Padding(
                            //             padding: const EdgeInsets.only(left: 55.0),
                            //             child: ListTile(
                            //               title: Text(
                            //                 'Terms & Conditions',
                            //                 style: GoogleFonts.poppins(
                            //                   color: Colors.black,
                            //                   fontSize: 16.0,
                            //                 ),
                            //               ),
                            //               trailing: const Icon(
                            //                 Icons.arrow_forward_ios,
                            //                 color: kGreyTextColor,
                            //                 size: 16.0,
                            //               ),
                            //             ),
                            //           ),
                            //         ],
                            //       ),
                            //       isExpanded: expandedAbout,
                            //     ),
                            //   ],
                            // ),

                            // ListTile(
                            //   title: Text(
                            //     'Invoice Settings',
                            //     style: GoogleFonts.poppins(
                            //       color: Colors.black,
                            //       fontSize: 18.0,
                            //     ),
                            //   ),
                            //   onTap: () {
                            //     // const SubscriptionScreen().launch(context);
                            //     const InvoiceSettings().launch(context);
                            //   },
                            //   leading: const Icon(
                            //     Icons.print,
                            //     color: kMainColor,
                            //   ),
                            //   trailing: const Icon(
                            //     Icons.arrow_forward_ios,
                            //     color: kGreyTextColor,
                            //   ),
                            // ),

                            //____________________________wareHouse__________
                            const SizedBox(height: 15,),
                            Container(
                              decoration: BoxDecoration(
                                  color: kWhite,
                                  borderRadius: BorderRadius.circular(6),
                                  boxShadow: [
                                    BoxShadow(
                                        color: const Color(0xff0C1A4B).withOpacity(0.24),
                                        offset: const Offset(0, 0),
                                        blurRadius: 1,
                                        spreadRadius: 0
                                    ),
                                    BoxShadow(
                                        color: const Color(0xff473232).withOpacity(0.05),
                                        offset: const Offset(0, 3),
                                        blurRadius: 8,
                                        spreadRadius: -1
                                    ),
                                  ]
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                                horizontalTitleGap: 10,
                                title: Text(
                                  'Warehouse',
                                  style: GoogleFonts.poppins(
                                    color: Colors.black,
                                    fontSize: 18.0,
                                  ),
                                ),
                                onTap: () {
                                  const WarehouseList().launch(context);
                                },
                                leading: const Icon(
                                  Icons.warehouse_outlined,
                                  color: kMainColor,
                                ),
                                trailing: const Icon(
                                  Icons.arrow_forward_ios,
                                  color: kGreyTextColor,
                                  size: 18,
                                ),
                              ),
                            ),
                            const SizedBox(height: 15,),
                            Container(
                              decoration: BoxDecoration(
                                  color: kWhite,
                                  borderRadius: BorderRadius.circular(6),
                                  boxShadow: [
                                    BoxShadow(
                                        color: const Color(0xff0C1A4B).withOpacity(0.24),
                                        offset: const Offset(0, 0),
                                        blurRadius: 1,
                                        spreadRadius: 0
                                    ),
                                    BoxShadow(
                                        color: const Color(0xff473232).withOpacity(0.05),
                                        offset: const Offset(0, 3),
                                        blurRadius: 8,
                                        spreadRadius: -1
                                    ),
                                  ]
                              ),
                              child: ListTile(
                                title: Text(
                                  lang.S.of(context).feedBack,
                                  style: GoogleFonts.poppins(
                                    color: Colors.black,
                                    fontSize: 18.0,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                                horizontalTitleGap: 10,
                                onTap: () {
                                  // const SubscriptionScreen().launch(context);
                                  const FeedbackScreen().launch(context);
                                },
                                leading: const Icon(
                                  Icons.rate_review,
                                  color: kMainColor,
                                ),
                                trailing: const Icon(
                                  Icons.arrow_forward_ios,
                                  color: kGreyTextColor,
                                  size: 18,
                                ),
                              ),
                            ),
                            // ListTile(
                            //   title: Text(
                            //     'Live Chat/Support',
                            //     style: GoogleFonts.poppins(
                            //       color: Colors.black,
                            //       fontSize: 18.0,
                            //     ),
                            //   ),
                            //   onTap: () {
                            //     // const SubscriptionScreen().launch(context);
                            //     const LiveChatSupport().launch(context);
                            //   },
                            //   leading: const Icon(
                            //     Icons.chat,
                            //     color: kMainColor,
                            //   ),
                            //   trailing: const Icon(
                            //     Icons.arrow_forward_ios,
                            //     color: kGreyTextColor,
                            //   ),
                            // ),
                            // ListTile(
                            //   title: Text(
                            //     'Invite/Share With Friends',
                            //     style: GoogleFonts.poppins(
                            //       color: Colors.black,
                            //       fontSize: 18.0,
                            //     ),
                            //   ),
                            //   onTap: () {
                            //     // Share.share('Using Maan POS to make business easier. Download Maan POS and grow your business - https://play.google.com/store/apps/details?id=com.maantechnology.mobipos', subject: 'Download Maan POS and Grow Your Business');
                            //   },
                            //   leading: const Icon(
                            //     Icons.share,
                            //     color: kMainColor,
                            //   ),
                            //   trailing: const Icon(
                            //     Icons.arrow_forward_ios,
                            //     color: kGreyTextColor,
                            //   ),
                            // ),
                            const SizedBox(height: 15,),
                            Container(
                              decoration: BoxDecoration(
                                  color: kWhite,
                                  borderRadius: BorderRadius.circular(6),
                                  boxShadow: [
                                    BoxShadow(
                                        color: const Color(0xff0C1A4B).withOpacity(0.24),
                                        offset: const Offset(0, 0),
                                        blurRadius: 1,
                                        spreadRadius: 0
                                    ),
                                    BoxShadow(
                                        color: const Color(0xff473232).withOpacity(0.05),
                                        offset: const Offset(0, 3),
                                        blurRadius: 8,
                                        spreadRadius: -1
                                    ),
                                  ]
                              ),
                              child: ListTile(
                                horizontalTitleGap: 10,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                                title: Text(
                                  lang.S.of(context).subscription,
                                  style: GoogleFonts.poppins(
                                    color: Colors.black,
                                    fontSize: 18.0,
                                  ),
                                ),
                                onTap: () {
                                  // const SubscriptionScreen().launch(context);
                                  const PackageScreen().launch(context);
                                },
                                leading: const Icon(
                                  Icons.account_balance_wallet_outlined,
                                  color: kMainColor,
                                ),
                                trailing: const Icon(
                                  Icons.arrow_forward_ios,
                                  color: kGreyTextColor,
                                  size: 18,
                                ),
                              ),
                            ),
                            const SizedBox(height: 15,),
                            ///___________user_role___________________________________________________________
                            Container(
                              decoration: BoxDecoration(
                                  color: kWhite,
                                  borderRadius: BorderRadius.circular(6),
                                  boxShadow: [
                                    BoxShadow(
                                        color: const Color(0xff0C1A4B).withOpacity(0.24),
                                        offset: const Offset(0, 0),
                                        blurRadius: 1,
                                        spreadRadius: 0
                                    ),
                                    BoxShadow(
                                        color: const Color(0xff473232).withOpacity(0.05),
                                        offset: const Offset(0, 3),
                                        blurRadius: 8,
                                        spreadRadius: -1
                                    ),
                                  ]
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                                horizontalTitleGap: 10,
                                title: Text(
                                  lang.S.of(context).userRole,
                                  style: GoogleFonts.poppins(
                                    color: Colors.black,
                                    fontSize: 18.0,
                                  ),
                                ),
                                onTap: () {
                                  const UserRoleScreen().launch(context);
                                },
                                leading: const Icon(
                                  Icons.supervised_user_circle_sharp,
                                  color: kMainColor,
                                ),
                                trailing: const Icon(
                                  Icons.arrow_forward_ios,
                                  color: kGreyTextColor,
                                  size: 18,
                                ),
                              ).visible(!isSubUser),
                            ),
                            const SizedBox(height: 15,),
                            Container(
                              decoration: BoxDecoration(
                                  color: kWhite,
                                  borderRadius: BorderRadius.circular(6),
                                  boxShadow: [
                                    BoxShadow(
                                        color: const Color(0xff0C1A4B).withOpacity(0.24),
                                        offset: const Offset(0, 0),
                                        blurRadius: 1,
                                        spreadRadius: 0
                                    ),
                                    BoxShadow(
                                        color: const Color(0xff473232).withOpacity(0.05),
                                        offset: const Offset(0, 3),
                                        blurRadius: 8,
                                        spreadRadius: -1
                                    ),
                                  ]
                              ),
                              child: ListTile(
                                horizontalTitleGap: 10,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                                onTap: (){
                                  Navigator.push(context, MaterialPageRoute(builder: (context)=>const CurrencyScreen()));
                                },
                                title: Text(
                                  lang.S.of(context).currency,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.poppins(
                                    color: Colors.black,
                                    fontSize: 18.0,
                                  ),
                                ),
                                leading: const Icon(
                                  Icons.currency_exchange,
                                  color: kMainColor,
                                ),
                                trailing: const Icon(
                                  Icons.arrow_forward_ios,
                                  color: kGreyTextColor,
                                  size: 18,
                                ),
                                // trailing: DropdownButton(
                                //   underline: const SizedBox(),
                                //   value: dropdownValue,
                                //   icon: const Icon(Icons.keyboard_arrow_down),
                                //   items: items.map((String items) {
                                //     return DropdownMenuItem(
                                //       value: items,
                                //       child: SizedBox(
                                //           width: 130,
                                //           child: Text(
                                //             items,
                                //             overflow: TextOverflow.ellipsis,
                                //           )),
                                //     );
                                //   }).toList(),
                                //   onChanged: (newValue) async {
                                //     final prefs = await SharedPreferences.getInstance();
                                //
                                //     // Use a map for currency symbols
                                //     final currencySymbols = {
                                //       '\$ (US Dollar)': '\$',
                                //       '₹ (Rupee)': '₹',
                                //       '€ (Euro)': '€',
                                //       '₽ (Ruble)': '₽',
                                //       '£ (UK Pound)': '£',
                                //       '৳ (Taka)': '৳',
                                //       'R (Rial)': 'R',
                                //       '؋ (Afghani)': '؋',
                                //       'Lek (Lek)': 'Lek',
                                //       'د.ج (Algerian Dinar)': 'د.ج',
                                //       'Kz (Kwanza)': 'Kz',
                                //       'EC\$ (East Caribbean Dollar)': 'EC\$',
                                //       '\$ (Argentine Peso)': '\$',
                                //       '֏ (Armenian Dram)': '֏',
                                //       'A\$ (Australian Dollar)': 'A\$',
                                //       '₼ (Azerbaijani Manat)': '₼',
                                //       'B\$ (Bahamian Dollar)': 'B\$',
                                //       '.د.ب (Bahraini Dinar)': '.د.ب',
                                //       'Bds\$ (Barbadian Dollar)': 'Bds\$',
                                //       'Br (Belarusian Ruble)': 'Br',
                                //       'BZ\$ (Belize Dollar)': 'BZ\$',
                                //       'CFA (West African CFA franc)': 'CFA',
                                //       'FCFA (West African CFA franc)': 'FCFA',
                                //       'Nu. (Bhutanese Ngultrum)': 'Nu.',
                                //       'Bs. (Bolivian Boliviano)': 'Bs.',
                                //       'KM (Bosnia and Herzegovina Convertible Mark)': 'KM',
                                //       'P (Botswana Pula)': 'P',
                                //       'R\$ (Brazilian Real)': 'R\$',
                                //       'B\$ (Brunei Dollar)': 'B\$',
                                //       'лв (Bulgarian Lev)': 'лв',
                                //       'FBu (Burundian Franc)': 'FBu',
                                //       'Esc (Cape Verdean Escudo)': 'Esc',
                                //       '៛ (Cambodian Riel)': '៛',
                                //       'CFA (Central African CFA franc)': 'CFA',
                                //       'CA\$ (Canadian Dollar)': 'CA\$',
                                //       '\$ (Chilean Peso)': '\$',
                                //       '¥ (Chinese Yuan)': '¥',
                                //       '\$ (Colombian Peso)': '\$',
                                //       'CF (Comorian Franc)': 'CF',
                                //       'FC (Congolese Franc)': 'FC',
                                //       '₡ (Costa Rican Colón)': '₡',
                                //       'kn (Croatian Kuna)': 'kn',
                                //       'CUP (Cuban Peso)': 'CUP',
                                //       'Kč (Czech Koruna)': 'Kč',
                                //       'kr (Danish Krone)': 'kr',
                                //       'Fdj (Djiboutian Franc)': 'Fdj',
                                //       'RD\$ (Dominican Peso)': 'RD\$',
                                //       'US\$ (United States Dollar)': 'US\$',
                                //       '\$ (United States Dollar)': '\$',
                                //       'E£ (Egyptian Pound)': 'E£',
                                //       'Nfk (Eritrean Nakfa)': 'Nfk',
                                //       'E (Swazi Lilangeni)': 'E',
                                //       'Br (Ethiopian Birr)': 'Br',
                                //       'FJ\$ (Fijian Dollar)': 'FJ\$',
                                //       'D (Gambian Dalasi)': 'D',
                                //       '₾ (Georgian Lari)': '₾',
                                //       'GH₵ (Ghanaian Cedi)': 'GH₵',
                                //       'Q (Guatemalan Quetzal)': 'Q',
                                //       'GNF (Guinean Franc)': 'GNF',
                                //       'GY\$ (Guyanese Dollar)': 'GY\$',
                                //       'G (Haitian Gourde)': 'G',
                                //       'L (Honduran Lempira)': 'L',
                                //       'Ft (Hungarian Forint)': 'Ft',
                                //       'kr (Icelandic Króna)': 'kr',
                                //       'Rp (Indonesian Rupiah)': 'Rp',
                                //       '﷼ (Iranian Rial)': '﷼',
                                //       'ع.د (Iraqi Dinar)': 'ع.د',
                                //       '₪ (Israeli New Shekel)': '₪',
                                //       'J\$ (Jamaican Dollar)': 'J\$',
                                //       '¥ (Japanese Yen)': '¥',
                                //       'د.ا (Jordanian Dinar)': 'د.ا',
                                //       '₸ (Kazakhstani Tenge)': '₸',
                                //       'KSh (Kenyan Shilling)': 'KSh',
                                //       'AU\$ (Australian Dollar)': 'AU\$',
                                //       'د.ك (Kuwaiti Dinar)': 'د.ك',
                                //       'som (Kyrgyzstani Som)': 'som',
                                //       '₭ (Laotian Kip)': '₭',
                                //       'ل.ل (Lebanese Pound)': 'ل.ل',
                                //       'L (Lesotho Loti)': 'L',
                                //       'L\$ (Liberian Dollar)': 'L\$',
                                //       'ل.د (Libyan Dinar)': 'ل.د',
                                //       'CHF (Swiss Franc)': 'CHF',
                                //       'Ar (Malagasy Ariary)': 'Ar',
                                //       'MK (Malawian Kwacha)': 'MK',
                                //       'RM (Malaysian Ringgit)': 'RM',
                                //       'Rf (Maldivian Rufiyaa)': 'Rf',
                                //       'Ouguiya (Mauritanian Ouguiya)': 'Ouguiya',
                                //       'Rs (Mauritian Rupee)': 'Rs',
                                //       'Mex\$ (Mexican Peso)': 'Mex\$',
                                //       'lei (Moldovan Leu)': 'lei',
                                //       '₮ (Mongolian Tugrik)': '₮',
                                //       'د.م. (Moroccan Dirham)': 'د.م.',
                                //       'MT (Mozambican Metical)': 'MT',
                                //       'K (Myanmar Kyat)': 'K',
                                //       'N\$ (Namibian Dollar)': 'N\$',
                                //       'रू (Nepalese Rupee)': 'रू',
                                //       'NZ\$ (New Zealand Dollar)': 'NZ\$',
                                //       'C\$ (Nicaraguan Córdoba)': 'C\$',
                                //       '₦ (Nigerian Naira)': '₦',
                                //       'kr (Norwegian Krone)': 'kr',
                                //       '﷼ (Omani Rial)': '﷼',
                                //       'PKR (Pakistani Rupee)': 'PKR',
                                //       '₱ (Philippine Peso)': '₱',
                                //       'zł (Polish Złoty)': 'zł',
                                //       '﷼ (Qatari Riyal)': '﷼',
                                //       'lei (Romanian Leu)': 'lei',
                                //       'руб (Russian Ruble)': 'руб',
                                //       'RF (Rwandan Franc)': 'RF',
                                //       '₣ (Swiss Franc)': '₣',
                                //       '₲ (Paraguayan Guarani)': '₲',
                                //       'SR (Saudi Riyal)': 'SR',
                                //       'د.س (Sudanese Pound)': 'د.س',
                                //       '\$ (Singapore Dollar)': '\$',
                                //       'S (Solomon Islands Dollar)': 'S',
                                //       'Sh (Somali Shilling)': 'Sh',
                                //       'R (South African Rand)': 'R',
                                //       '₩ (South Korean Won)': '₩',
                                //       '£ (British Pound)': '£',
                                //       '\$ (Sri Lankan Rupee)': '\$',
                                //       'L (Saint Helenian Pound)': 'L',
                                //       '\$ (East Caribbean Dollar)': '\$',
                                //       'kr (Swedish Krona)': 'kr',
                                //       'TJS (Tajikistani Somoni)': 'TJS',
                                //       'TSh (Tanzanian Shilling)': 'TSh',
                                //       '฿ (Thai Baht)': '฿',
                                //       'T (Tongan Paʻanga)': 'T',
                                //       'TTD (Trinidad and Tobago Dollar)': 'TTD',
                                //       'XAf (XAf Central Africa)': 'XAF',
                                //       // Add more currencies as needed
                                //     };
                                //
                                //     if (currencySymbols.containsKey(newValue)) {
                                //       currency = currencySymbols[newValue]!;
                                //       await prefs.setString('currency', currency);
                                //       final DatabaseReference personalInformationRef = FirebaseDatabase.instance.ref().child(await getUserID()).child('Personal Information');
                                //       await personalInformationRef.update({'currency': currency});
                                //     } else {
                                //       currency = "\$";
                                //       await prefs.setString('currency', currency);
                                //     }
                                //
                                //     setState(() {
                                //       dropdownValue = newValue.toString();
                                //     });
                                //   },
                                // ),
                              ),
                            ),
                            const SizedBox(height: 15,),
                            Container(
                              decoration: BoxDecoration(
                                  color: kWhite,
                                  borderRadius: BorderRadius.circular(6),
                                  boxShadow: [
                                    BoxShadow(
                                        color: const Color(0xff0C1A4B).withOpacity(0.24),
                                        offset: const Offset(0, 0),
                                        blurRadius: 1,
                                        spreadRadius: 0
                                    ),
                                    BoxShadow(
                                        color: const Color(0xff473232).withOpacity(0.05),
                                        offset: const Offset(0, 3),
                                        blurRadius: 8,
                                        spreadRadius: -1
                                    ),
                                  ]
                              ),
                              child: ListTile(
                                onTap: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => const LanguageScreen()));
                                },
                                contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                                horizontalTitleGap: 10,
                                title: Text(
                                  lang.S.of(context).language,
                                  style: GoogleFonts.poppins(
                                    color: Colors.black,
                                    fontSize: 18.0,
                                  ),
                                ),
                                leading: Image.asset('images/en.png'),
                                trailing: const Icon(
                                  Icons.arrow_forward_ios,
                                  color: kGreyTextColor,
                                  size: 18.0,
                                ),
                              ),
                            ),
                            const SizedBox(height: 15,),
                            ///___________Terms & Privacy_____________________________
                            Container(
                              decoration: BoxDecoration(
                                  color: kWhite,
                                  borderRadius: BorderRadius.circular(6),
                                  boxShadow: [
                                    BoxShadow(
                                        color: const Color(0xff0C1A4B).withOpacity(0.24),
                                        offset: const Offset(0, 0),
                                        blurRadius: 1,
                                        spreadRadius: 0
                                    ),
                                    BoxShadow(
                                        color: const Color(0xff473232).withOpacity(0.05),
                                        offset: const Offset(0, 3),
                                        blurRadius: 8,
                                        spreadRadius: -1
                                    ),
                                  ]
                              ),
                              child: ListTile(
                                horizontalTitleGap: 10,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                                title: Text(
                                  'Terms & Privacy',
                                  style: GoogleFonts.poppins(
                                    color: Colors.black,
                                    fontSize: 18.0,
                                  ),
                                ),
                                onTap: () async {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => const TermsAndPrivacyScreen()));
                                },
                                leading: const Icon(
                                  Icons.policy,
                                  color: kMainColor,
                                ),
                                trailing: const Icon(
                                  Icons.arrow_forward_ios,
                                  color: kGreyTextColor,
                                  size: 18.0,
                                ),
                              ),
                            ),
                            const SizedBox(height: 15,),
                            Container(
                              decoration: BoxDecoration(
                                  color: kWhite,
                                  borderRadius: BorderRadius.circular(6),
                                  boxShadow: [
                                    BoxShadow(
                                        color: const Color(0xff0C1A4B).withOpacity(0.24),
                                        offset: const Offset(0, 0),
                                        blurRadius: 1,
                                        spreadRadius: 0
                                    ),
                                    BoxShadow(
                                        color: const Color(0xff473232).withOpacity(0.05),
                                        offset: const Offset(0, 3),
                                        blurRadius: 8,
                                        spreadRadius: -1
                                    ),
                                  ]
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                                horizontalTitleGap: 10,
                                title: Text(
                                  lang.S.of(context).logOUt,
                                  style: GoogleFonts.poppins(
                                    color: Colors.black,
                                    fontSize: 18.0,
                                  ),
                                ),
                                onTap: () async {
                                  EasyLoading.show(status: 'Log out');
                                  await _signOut();
                                  Future.delayed(const Duration(milliseconds: 1000), () {
                                    // Navigator.push(context, MaterialPageRoute(builder: (context) => const SplashScreen()));
                                    Restart.restartApp();
                                    // const SignInScreen().launch(context);
                                  });
                                  // Phoenix.rebirth(context);
                                },
                                leading: const Icon(
                                  Icons.logout,
                                  color: kMainColor,
                                ),
                                trailing: const Icon(
                                  Icons.arrow_forward_ios,
                                  color: kGreyTextColor,
                                  size: 18.0,
                                ),
                              ),
                            ),
                            const SizedBox(height: 15,),
                            Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Text(
                                    '$appName V-$appVersion',
                                    style: GoogleFonts.poppins(
                                      color: kGreyTextColor,
                                      fontSize: 16.0,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class NoticationSettings extends StatefulWidget {
  const NoticationSettings({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _NoticationSettingsState createState() => _NoticationSettingsState();
}

class _NoticationSettingsState extends State<NoticationSettings> {
  bool notify = false;
  String notificationText = 'Off';

  @override
  Widget build(BuildContext context) {
    // ignore: sized_box_for_whitespace
    return Container(
      height: 350.0,
      width: MediaQuery.of(context).size.width - 80,
      child: Column(
        children: [
          Row(
            children: [
              const Spacer(),
              IconButton(
                color: kGreyTextColor,
                icon: const Icon(Icons.cancel_outlined),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          Container(
            height: 100.0,
            width: 100.0,
            decoration: BoxDecoration(
              color: kDarkWhite,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: const Center(
              child: Icon(
                Icons.notifications_none_outlined,
                size: 50.0,
                color: kMainColor,
              ),
            ),
          ),
          const SizedBox(
            height: 20.0,
          ),
          Center(
            child: Text(
              lang.S.of(context).doNotDistrub,
              style: GoogleFonts.poppins(
                color: Colors.black,
                fontSize: 20.0,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Lorem ipsum dolor sit amet, consectetur elit. Interdum cons.',
                maxLines: 2,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: kGreyTextColor,
                  fontSize: 16.0,
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                notificationText,
                style: GoogleFonts.poppins(
                  color: Colors.black,
                  fontSize: 16.0,
                ),
              ),
              Switch(
                value: notify,
                onChanged: (val) {
                  setState(() {
                    notify = val;
                    val ? notificationText = 'On' : notificationText = 'Off';
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
