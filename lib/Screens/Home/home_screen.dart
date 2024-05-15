// ignore_for_file: unused_result
import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mobile_pos/Provider/customer_provider.dart';
import 'package:mobile_pos/Provider/homepage_image_provider.dart';
import 'package:mobile_pos/Screens/Home/components/grid_items.dart';
import 'package:mobile_pos/Screens/Profile%20Screen/profile_details.dart';
import 'package:mobile_pos/constant.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import 'package:nb_utils/nb_utils.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../Provider/due_transaction_provider.dart';
import '../../Provider/profile_provider.dart';
import '../../Provider/transactions_provider.dart';
import '../../const_commas.dart';
import '../../currency.dart';
import '../../model/subscription_model.dart';
import '../../subscription.dart';
import '../About App/about_app.dart';
import '../Shimmers/home_screen_appbar_shimmer.dart';
import '../subscription/package_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool checkPermission({required String item}) {
    if (item == 'Sales' && finalUserRoleModel.salePermission) {
      return true;
    } else if (item == 'Parties' && finalUserRoleModel.partiesPermission) {
      return true;
    } else if (item == 'Purchase' && finalUserRoleModel.purchasePermission) {
      return true;
    } else if (item == 'Products' && finalUserRoleModel.productPermission) {
      return true;
    } else if (item == 'Due List' && finalUserRoleModel.dueListPermission) {
      return true;
    } else if (item == 'Stock' && finalUserRoleModel.stockPermission) {
      return true;
    } else if (item == 'Reports' && finalUserRoleModel.reportsPermission) {
      return true;
    } else if (item == 'Sales List' && finalUserRoleModel.salesListPermission) {
      return true;
    } else if (item == 'Purchase List' && finalUserRoleModel.purchaseListPermission) {
      return true;
    } else if (item == 'Loss/Profit' && finalUserRoleModel.lossProfitPermission) {
      return true;
    } else if (item == 'Expense' && finalUserRoleModel.addExpensePermission) {
      return true;
    }
    return false;
  }

  // List<Color> color = [
  //   const Color(0xffEDFAFF),
  //   const Color(0xffFFF6ED),
  //   const Color(0xffEAFFEA),
  //   const Color(0xffEAFFEA),
  //   const Color(0xffEDFAFF),
  //   const Color(0xffFFF6ED),
  //   const Color(0xffFFF3FB),
  //   const Color(0xffFFF4F4),
  //   const Color(0xffEDFAFF),
  //   const Color(0xffEDFAFF),
  //   const Color(0xffEAFFEA),
  //   const Color(0xffFFF6ED),
  //   // const Color(0xffFFF6ED),
  // ];

  List<Color> color = [
    const Color(0xffEBD7FF),
    const Color(0xffFFD6E2),
    const Color(0xffBBFFC1),
    const Color(0xffD9EEFF),
    const Color(0xffFFE4C1),
    const Color(0xffBFFFEF),
    const Color(0xffFFD6E2),
    const Color(0xffEDDBFF),
    const Color(0xffF7CCFE),
    const Color(0xffBBFFC1),
    const Color(0xffD4ECFF),
    const Color(0xffFFE4C1),
    const Color(0xffD9EEFF),
  ];
  TextEditingController fromDateTextEditingController = TextEditingController(text: DateFormat.yMMMd().format(DateTime(2021)));
  TextEditingController toDateTextEditingController = TextEditingController(text: DateFormat.yMMMd().format(DateTime.now()));
  DateTime fromDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  DateTime toDate = DateTime.now();
  DateTime selectedDate = DateTime.now();
  double totalProfit = 0;
  double totalLoss = 0;
  bool isPicked = false;
  List<Map<String, dynamic>> sliderList = [
    {
      "icon": 'images/banner1.png',
    },
    {
      "icon": 'images/banner2.png',
    }
  ];
  PageController pageController = PageController(
    initialPage: 0,
  );

  List<String> dayList = ['Today', 'Weekly', 'Monthly', 'Yearly'];
  String selectedDay = 'Today';

  @override
  void initState() {
    super.initState();
    getCurrency();
  }

  double totalSell = 0;
  double totalDue = 0;
  double totalPurchase = 0;
  int count = 0;

  setCurrency(String currency) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currency', currency);
    getCurrency();
  }

  void getCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    String? data = prefs.getString('currency');
    if (!data.isEmptyOrNull) {
      currency = data!;
    }
  }

  @override
  Widget build(BuildContext context) {
    freeIcons = getFreeIcons(context: context);
    return SafeArea(
      child: Consumer(builder: (_, ref, __) {
        final purchaseProviderData = ref.watch(purchaseTransitionProvider);
        final dueProviderData = ref.watch(dueTransactionProvider);
        final userProfileDetails = ref.watch(profileDetailsProvider);
        final homePageImageProvider = ref.watch(homepageImageProvider);
        final providerData = ref.watch(transitionProvider);
        return WillPopScope(
          onWillPop: () async => false,
          child: Scaffold(
            backgroundColor: Colors.white,
            resizeToAvoidBottomInset: true,
            body: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    color: kMainColor,
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: userProfileDetails.when(data: (details) {
                        setCurrency(details.currency.toString());
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  isSubUser ? null : const ProfileDetails().launch(context);
                                },
                                child: Container(
                                  height: 50,
                                  width: 50,
                                  decoration: BoxDecoration(
                                      image: DecorationImage(image: NetworkImage(details.pictureUrl ?? ''), fit: BoxFit.cover),
                                      borderRadius: BorderRadius.circular(50),
                                      border: Border.all(color: kBorderColorTextField)),
                                ),
                              ),
                              const SizedBox(width: 15.0),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isSubUser ? '${details.companyName ?? ''} [$subUserTitle]' : details.companyName ?? '',
                                    style: GoogleFonts.poppins(fontSize: 20.0, fontWeight: FontWeight.w600, color: Colors.white),
                                  ),
                                  Text(
                                    '${Subscription.selectedItem} Plan',
                                    style: GoogleFonts.poppins(color: Colors.white),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              // Container(
                              //   height: 40.0,
                              //   width: 86.0,
                              //   decoration: BoxDecoration(
                              //     borderRadius: BorderRadius.circular(10.0),
                              //     color: Color(0xFFD9DDE3).withOpacity(0.5),
                              //   ),
                              //   child: Center(
                              //     child: Text(
                              //       '$currency 450',
                              //       style: GoogleFonts.p(
                              //         fontSize: 20.0,
                              //         color: Colors.black,
                              //       ),
                              //     ),
                              //   ),
                              // ),
                              // SizedBox(
                              //   width: 10.0,
                              // ),
                              Container(
                                height: 44.0,
                                width: 44.0,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withOpacity(0.1),
                                ),
                                child: Center(
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => const AboutApp()));
                                    },
                                    child: const Badge(
                                      padding: EdgeInsets.only(top: -2),
                                      alignment: Alignment.topRight,
                                      backgroundColor: Colors.red,
                                      child: Icon(
                                        Icons.notifications_none_rounded,
                                        color: Colors.white,
                                        size: 25,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }, error: (e, stack) {
                        return Text(e.toString());
                      }, loading: () {
                        return const HomeScreenAppBarShimmer();
                      }),
                    ),
                  ),
                  Container(
                    color: kMainColor,
                    child: Container(
                      decoration:
                          const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(topRight: Radius.circular(25), topLeft: Radius.circular(25))),
                      child: Column(
                        children: [
                          Container(
                            decoration: const BoxDecoration(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(25),
                                  topRight: Radius.circular(25),
                                ),
                                color: kDarkWhite),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 15, top: 10, bottom: 10),
                              child: Row(
                                children: [
                                  Text(
                                    lang.S.of(context).dashBoardOverView,
                                    style: kTextStyle.copyWith(fontWeight: FontWeight.bold, color: kTitleColor),
                                  ),
                                  const Spacer(),
                                  Transform.scale(
                                    scale: 0.6,
                                    child: CupertinoSwitch(
                                        activeColor: kMainColor,
                                        value: isReportShow,
                                        onChanged: (newValue) {
                                          setState(() {
                                            isReportShow = newValue;
                                          });
                                        }),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          isReportShow
                              ? Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  lang.S.of(context).salesAndPurchaseReports,
                                                  style: kTextStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 16, color: kTitleColor),
                                                ),
                                                const Spacer(),
                                                DropdownButtonHideUnderline(
                                                    child: DropdownButton(
                                                        icon: const Icon(
                                                          Icons.keyboard_arrow_down_sharp,
                                                          color: kGreyTextColor,
                                                          size: 18,
                                                        ),
                                                        value: selectedDay,
                                                        items: dayList
                                                            .map(
                                                              (e) => DropdownMenuItem(
                                                                value: e,
                                                                child: Text(
                                                                  e,
                                                                  style: kTextStyle.copyWith(color: kTitleColor, fontSize: 14),
                                                                ),
                                                              ),
                                                            )
                                                            .toList(),
                                                        onChanged: (String? newValue) {
                                                          setState(() {
                                                            selectedDay = newValue!;
                                                            if (newValue == 'Today') {
                                                              fromDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
                                                            } else if (newValue == 'Weekly') {
                                                              fromDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day)
                                                                  .subtract(const Duration(days: 7));
                                                            } else if (newValue == 'Monthly') {
                                                              fromDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
                                                            } else if (newValue == 'Yearly') {
                                                              fromDate = DateTime(DateTime.now().year, 1, 1);
                                                            }
                                                          });
                                                        }))
                                              ],
                                            ),
                                            const SizedBox(height: 10),
                                            Container(
                                              alignment: Alignment.center,
                                              height: 64,
                                              decoration: BoxDecoration(color: const Color(0xffCEFFE2), borderRadius: BorderRadius.circular(8)),
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  providerData.when(data: (transaction) {
                                                    totalSell = 0;
                                                    totalDue = 0;
                                                    final reTransaction = transaction.reversed.toList();
                                                    for (var element in reTransaction) {
                                                      if ((fromDate.isBefore(DateTime.parse(element.purchaseDate)) ||
                                                              DateTime.parse(element.purchaseDate).isAtSameMomentAs(fromDate)) &&
                                                          (toDate.isAfter(DateTime.parse(element.purchaseDate)) ||
                                                              DateTime.parse(element.purchaseDate).isAtSameMomentAs(toDate))) {
                                                        totalSell = totalSell + element.totalAmount!.toDouble();
                                                        totalDue = totalDue + element.dueAmount!.toDouble();
                                                      }
                                                    }
                                                    return reTransaction.isNotEmpty
                                                        ? Text(
                                                            '$currency${myFormat.format(totalSell)}',
                                                            style: kTextStyle.copyWith(fontWeight: FontWeight.bold, color: kTitleColor),
                                                          )
                                                        : Text('$currency 0');
                                                  }, error: (e, stack) {
                                                    return Text(e.toString());
                                                  }, loading: () {
                                                    return const Center(
                                                      child: CircularProgressIndicator(),
                                                    );
                                                  }),
                                                  const SizedBox(
                                                    height: 5,
                                                  ),
                                                  Text(lang.S.of(context).sales),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Container(
                                                    alignment: Alignment.center,
                                                    height: 64,
                                                    decoration: BoxDecoration(color: const Color(0xffDFD3FF), borderRadius: BorderRadius.circular(8)),
                                                    child: Column(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                      children: [
                                                        purchaseProviderData.when(data: (transaction) {
                                                          final reTransaction = transaction.reversed.toList();
                                                          totalPurchase = 0;
                                                          for (var element in reTransaction) {
                                                            if ((fromDate.isBefore(DateTime.parse(element.purchaseDate)) ||
                                                                    DateTime.parse(element.purchaseDate).isAtSameMomentAs(fromDate)) &&
                                                                (toDate.isAfter(DateTime.parse(element.purchaseDate)) ||
                                                                    DateTime.parse(element.purchaseDate).isAtSameMomentAs(toDate))) {
                                                              totalPurchase = totalPurchase + element.totalAmount!.toDouble();
                                                            }
                                                          }
                                                          return reTransaction.isNotEmpty
                                                              ? Text(
                                                                  '$currency${myFormat.format(totalPurchase)}',
                                                                  style: kTextStyle.copyWith(fontWeight: FontWeight.bold, color: kTitleColor),
                                                                )
                                                              : Text('$currency 0');
                                                        }, error: (e, stack) {
                                                          return Text(e.toString());
                                                        }, loading: () {
                                                          return const Center(
                                                            child: CircularProgressIndicator(),
                                                          );
                                                        }),
                                                        const SizedBox(
                                                          height: 5,
                                                        ),
                                                        Text(lang.S.of(context).purchase),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 15),
                                                Expanded(
                                                  child: Container(
                                                    alignment: Alignment.center,
                                                    height: 64,
                                                    decoration: BoxDecoration(color: const Color(0xffFFDBDB), borderRadius: BorderRadius.circular(8)),
                                                    child: Column(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                      children: [
                                                        dueProviderData.when(data: (transaction) {
                                                          final reTransaction = transaction.reversed.toList();
                                                          // totalDue = 0;
                                                          // for (var element in reTransaction) {
                                                          //   if ((fromDate.isBefore(DateTime.parse(element.purchaseDate)) ||
                                                          //           DateTime.parse(element.purchaseDate).isAtSameMomentAs(fromDate)) &&
                                                          //       (toDate.isAfter(DateTime.parse(element.purchaseDate)) ||
                                                          //           DateTime.parse(element.purchaseDate).isAtSameMomentAs(toDate))) {
                                                          //     totalDue = totalDue + element.totalDue!.toDouble();
                                                          //   }
                                                          // }
                                                          return transaction.isNotEmpty
                                                              ? Text('$currency${myFormat.format(totalDue)}',
                                                                  style: kTextStyle.copyWith(fontWeight: FontWeight.bold, color: kTitleColor))
                                                              : Text('$currency 0');
                                                        }, error: (e, stack) {
                                                          return Text(e.toString());
                                                        }, loading: () {
                                                          return const Center(
                                                            child: CircularProgressIndicator(),
                                                          );
                                                        }),
                                                        const SizedBox(height: 5),
                                                        Text(
                                                          lang.S.of(context).due,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                )
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10.0),
                                      child: GridView.count(
                                        physics: const NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        childAspectRatio: 1.0,
                                        crossAxisSpacing: 0,
                                        mainAxisSpacing: 0,
                                        crossAxisCount: 3,
                                        children: List.generate(
                                          freeIcons.length,
                                          (index) => HomeGridCards(
                                            gridItems: freeIcons[index],
                                            color: color[index],
                                            svg: freeIcons[index].icon.contains('svg'),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    Container(
                                      height: 1,
                                      width: double.infinity,
                                      color: Colors.grey.shade300,
                                    ),
                                    const SizedBox(height: 10),

                                    homePageImageProvider.when(data: (images) {
                                      if (images.isNotEmpty) {
                                        return SizedBox(
                                          width: double.infinity,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Text(
                                                lang.S.of(context).whatsNew,
                                                style: GoogleFonts.poppins(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20.0,
                                                ),
                                              ),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                children: [
                                                  GestureDetector(
                                                    child: const Icon(Icons.keyboard_arrow_left),
                                                    onTap: () {
                                                      pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.linear);
                                                    },
                                                  ),
                                                  Container(
                                                    height: 180,
                                                    width: 310,
                                                    padding: const EdgeInsets.all(10),
                                                    child: PageView.builder(
                                                      pageSnapping: true,
                                                      itemCount: images.length,
                                                      controller: pageController,
                                                      itemBuilder: (_, index) {
                                                        if (images[index].imageUrl.contains('https://firebasestorage.googleapis.com')) {
                                                          return GestureDetector(
                                                            onTap: () {
                                                              const PackageScreen().launch(context);
                                                            },
                                                            child: Container(
                                                              decoration: BoxDecoration(
                                                                  borderRadius: BorderRadius.circular(8),
                                                                  image: DecorationImage(fit: BoxFit.fill, image: NetworkImage(images[index].imageUrl))),
                                                            ),
                                                          );
                                                        } else {
                                                          YoutubePlayerController videoController = YoutubePlayerController(
                                                            flags: const YoutubePlayerFlags(
                                                              autoPlay: false,
                                                              mute: false,
                                                            ),
                                                            initialVideoId: images[index].imageUrl,
                                                          );
                                                          return YoutubePlayer(
                                                            controller: videoController,
                                                            showVideoProgressIndicator: true,
                                                            onReady: () {},
                                                          );
                                                        }
                                                      },
                                                    ),
                                                  ),
                                                  GestureDetector(
                                                    child: const Icon(Icons.keyboard_arrow_right),
                                                    onTap: () {
                                                      pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.linear);
                                                    },
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 30),
                                            ],
                                          ),
                                        );
                                      } else {
                                        return Container(
                                          padding: const EdgeInsets.all(10),
                                          height: 180,
                                          width: 320,
                                          decoration: const BoxDecoration(image: DecorationImage(image: AssetImage('image/banner1.png'))),
                                        );
                                      }
                                    }, error: (e, stack) {
                                      return Container(
                                        padding: const EdgeInsets.all(10),
                                        height: 180,
                                        width: 320,
                                        decoration: const BoxDecoration(image: DecorationImage(image: AssetImage('image/banner1.png'))),
                                      );
                                    }, loading: () {
                                      return const CircularProgressIndicator();
                                    }),

                                  ],
                                ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

class HomeGridCards extends StatefulWidget {
  const HomeGridCards({super.key, required this.gridItems, required this.color,this.svg = true});

  final GridItems gridItems;
  final Color color;
  final bool svg;

  @override
  State<HomeGridCards> createState() => _HomeGridCardsState();
}

class _HomeGridCardsState extends State<HomeGridCards> {
  Future<bool> subscriptionChecker({
    required String item,
  }) async {
    final DatabaseReference subscriptionRef = FirebaseDatabase.instance.ref().child(constUserId).child('Subscription');
    DatabaseReference ref = FirebaseDatabase.instance.ref('$constUserId/Subscription');
    ref.keepSynced(true);
    subscriptionRef.keepSynced(true);

    bool boolValue = true;

    ref.get().then((value) async {
      final dataModel = SubscriptionModel.fromJson(jsonDecode(jsonEncode(value.value)));
      final remainTime = DateTime.parse(dataModel.subscriptionDate).difference(DateTime.now());
      for (var element in Subscription.subscriptionPlan) {
        if (dataModel.subscriptionName == element.subscriptionName) {
          if (remainTime.inHours.abs() > element.duration * 24) {
            Subscription.freeSubscriptionModel.subscriptionDate = DateTime.now().toString();
            subscriptionRef.set(Subscription.freeSubscriptionModel.toJson());
            final prefs = await SharedPreferences.getInstance();
            await prefs.setBool('isFiveDayRemainderShown', true);
          } else if (item == 'Sales' && dataModel.saleNumber <= 0 && dataModel.saleNumber != -202) {
            boolValue = false;
          } else if (item == 'Parties' && dataModel.partiesNumber <= 0 && dataModel.partiesNumber != -202) {
            boolValue = false;
          } else if (item == 'Purchase' && dataModel.purchaseNumber <= 0 && dataModel.purchaseNumber != -202) {
            boolValue = false;
          } else if (item == 'Products' && dataModel.products <= 0 && dataModel.products != -202) {
            boolValue = false;
          } else if (item == 'Due List' && dataModel.dueNumber <= 0 && dataModel.dueNumber != -202) {
            boolValue = false;
          }
        }
      }
    });
    return boolValue;
  }

  Future<bool> checkUserRolePermission({required String type}) async {
    bool permission = true;

    if (isSubUser) {
      switch (type) {
        case 'Sales':
          permission = finalUserRoleModel.salePermission;
          break;
        case 'Sale List':
          permission = finalUserRoleModel.salesListPermission;
          break;
        case "Expense":
          permission = finalUserRoleModel.addExpensePermission;
          break;
        case "Due List":
          permission = finalUserRoleModel.dueListPermission;
          break;
        case "Loss/Profit":
          permission = finalUserRoleModel.lossProfitPermission;
          break;
        case 'Parties':
          permission = finalUserRoleModel.partiesPermission;
          break;
        case 'Product':
          permission = finalUserRoleModel.productPermission;
          break;
        case 'Purchase List':
          permission = finalUserRoleModel.purchaseListPermission;
          break;
        case 'Purchase':
          permission = finalUserRoleModel.purchasePermission;
          break;
        case "Reports":
          permission = finalUserRoleModel.reportsPermission;
          break;
        case 'Stock List':
          permission = finalUserRoleModel.stockPermission;
          break;
        case 'profileEdit':
          permission = finalUserRoleModel.profileEditPermission;
          break;
        default:
          permission = true;
          break;
      }
      if (permission) {
        return permission;
      } else {
        return permission;
      }
    } else {
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    // ignore: avoid_unnecessary_containers
    return Consumer(builder: (context, ref, __) {
      return Column(
        children: [
          Container(
            height: 80,
            width: 80,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.color,
                border: Border.all(
                  color: widget.color,
                )),
            child: TextButton(
              onPressed: () async {
                if (kDebugMode) {
                  print(widget.gridItems.title);
                }
                ref.refresh(customerProvider);
                ref.refresh(dueTransactionProvider);
                ref.refresh(purchaseTransitionProvider);
                ref.refresh(transitionProvider);
                isSubUser
                    ? await checkUserRolePermission(type: widget.gridItems.route)
                        ? await subscriptionChecker(item: widget.gridItems.route)
                            ? Navigator.of(context).pushNamed('/${widget.gridItems.route}')
                            : EasyLoading.showError('Update your plan first,\nyour limit is over.')
                        : EasyLoading.showError('Sorry, you have no permission to access this service')
                    : await subscriptionChecker(item: widget.gridItems.route)
                        ? Navigator.of(context).pushNamed('/${widget.gridItems.route}')
                        : EasyLoading.showError('Update your plan first,\nyour limit is over.');
              },
              child: widget.svg ? SvgPicture.asset(
                widget.gridItems.icon,
                height: 40.0,
                width: 40.0,
                allowDrawingOutsideViewBox: false,
                fit: BoxFit.cover,
              ) : Image.asset(widget.gridItems.icon, width: 40,height: 40,fit: BoxFit.cover,),
            ),
          ),
          Text(
            widget.gridItems.title.toString(),
            style: const TextStyle(fontSize: 13, color: Colors.black),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      );
    });
  }
}
