import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_pos/Screens/subscription/purchase_premium_plan_screen.dart';
import 'package:mobile_pos/constant.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import 'package:nb_utils/nb_utils.dart';

import '../../currency.dart';
import '../../model/subscription_model.dart';
import '../../subscription.dart';

class PackageScreen extends StatefulWidget {
  const PackageScreen({super.key});

  @override
  State<PackageScreen> createState() => _PackageScreenState();
}

class _PackageScreenState extends State<PackageScreen> {
  String? initialSelectedPackage = 'Free';
  SubscriptionModel subscriptionModel = SubscriptionModel(
    subscriptionName: '',
    subscriptionDate: DateTime.now().toString(),
    saleNumber: 0,
    purchaseNumber: 0,
    partiesNumber: 0,
    dueNumber: 0,
    duration: 0,
    products: 0,
  );
  int? initPackageValue;
  Duration? remainTime;
  List<String>? initialPackageService;
  List<String> nameList = ['Sales', 'Purchase', 'Due collection', 'Parties', 'Products'];
  List<String> imageList = [
    'images/sales_2.png',
    'images/purchase_2.png',
    'images/due_collection_2.png',
    'images/parties_2.png',
    'images/product1.png',
  ];
  void checkSubscriptionData() async {
    EasyLoading.show(status: 'Loading');
    DatabaseReference ref = FirebaseDatabase.instance.ref('$constUserId/Subscription');
    final model = await ref.get();
    var data = jsonDecode(jsonEncode(model.value));
    Subscription.selectedItem = SubscriptionModel.fromJson(data).subscriptionName;
    final finalModel = SubscriptionModel.fromJson(data);
    if (finalModel.subscriptionName == 'Free') {
      Subscription.selectedItem = 'Year';
    } else if (finalModel.subscriptionName == 'Month') {
      initPackageValue = 1;
      Subscription.selectedItem = 'Month';
    } else if (finalModel.subscriptionName == 'Year') {
      initPackageValue = 2;
      Subscription.selectedItem = 'Year';
    } else if (finalModel.subscriptionName == 'Lifetime') {
      initPackageValue = 3;
      Subscription.selectedItem = 'Lifetime';
    }

    setState(() {
      initialSelectedPackage = finalModel.subscriptionName;
      subscriptionModel = finalModel;
      initialPackageService = [
        subscriptionModel.saleNumber.toString(),
        subscriptionModel.purchaseNumber.toString(),
        subscriptionModel.dueNumber.toString(),
        subscriptionModel.partiesNumber.toString(),
        subscriptionModel.products.toString(),
      ];
    });
    EasyLoading.dismiss();
  }

  @override
  void initState() {
    checkSubscriptionData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kMainColor,
      appBar: AppBar(
        backgroundColor: kMainColor,
        title: Text(
          lang.S.of(context).yourPackage,
          style: GoogleFonts.poppins(
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0.0,
      ),
      body: Container(
        alignment: Alignment.topCenter,
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(topRight: Radius.circular(30), topLeft: Radius.circular(30))),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(25.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 80,
                  width: double.infinity,
                  decoration: BoxDecoration(color: kPremiumPlanColor.withOpacity(0.2), borderRadius: const BorderRadius.all(Radius.circular(10))),
                  child: Row(
                    children: [
                      const SizedBox(width: 10),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            lang.S.of(context).freePlan,
                            style: const TextStyle(fontSize: 18),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Text(
                                lang.S.of(context).youAreUsing,
                                style: const TextStyle(fontSize: 14),
                              ),
                              const SizedBox(width: 5.0),
                              Text(
                                lang.S.of(context).freePacakge,
                                style: const TextStyle(fontSize: 14, color: kMainColor, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const Spacer(),
                      Container(
                        height: 63,
                        width: 63,
                        decoration: const BoxDecoration(
                          color: kMainColor,
                          borderRadius: BorderRadius.all(
                            Radius.circular(50),
                          ),
                        ),
                        child: Center(
                            child: Text(
                          '${(DateTime.parse(subscriptionModel.subscriptionDate).difference(DateTime.now()).inDays.abs() - subscriptionModel.duration).abs()} \nDays Left',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 12, color: Colors.white),
                        )),
                      ),
                      const SizedBox(width: 20),
                    ],
                  ),
                ).visible(initialSelectedPackage == 'Free'),
                Container(
                  height: 80,
                  width: double.infinity,
                  decoration: BoxDecoration(color: kPremiumPlanColor.withOpacity(0.2), borderRadius: const BorderRadius.all(Radius.circular(10))),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(width: 20),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            lang.S.of(context).premiumPlan,
                            style: const TextStyle(fontSize: 18),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Text(
                                lang.S.of(context).youAreUsing,
                                style: const TextStyle(fontSize: 14),
                              ),
                              Text(
                                ' $initialSelectedPackage',
                                style: const TextStyle(fontSize: 14, color: kMainColor, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const Spacer(),
                      Container(
                        height: 63,
                        width: 63,
                        decoration: const BoxDecoration(
                          color: kMainColor,
                          borderRadius: BorderRadius.all(
                            Radius.circular(50),
                          ),
                        ),
                        child: Center(
                            child: Text(
                          '${(DateTime.parse(subscriptionModel.subscriptionDate).difference(DateTime.now()).inDays.abs() - subscriptionModel.duration).abs()} \nDays Left',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 12, color: Colors.white),
                        )),
                      ).visible(subscriptionModel.subscriptionName != 'Lifetime'),
                      const SizedBox(width: 20),
                    ],
                  ),
                ).visible(initialSelectedPackage != 'Free'),
                const SizedBox(height: 20),
                Text(
                  lang.S.of(context).packageFeatures,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                ListView.builder(
                    itemCount: nameList.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (_, i) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: GestureDetector(
                          onTap: () {},
                          child: Card(
                            elevation: 1,
                            child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: ListTile(
                                leading: SizedBox(
                                  height: 40,
                                  width: 40,
                                  child: Image(
                                    image: AssetImage(imageList[i]),
                                  ),
                                ),
                                title: Text(
                                  nameList[i],
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                trailing: initialSelectedPackage == 'Free'
                                    ? Text(
                                        initialPackageService?[i] == '-202' ? 'Unlimited' : '(${initialPackageService?[i] ?? ''}/50)',
                                        style: const TextStyle(color: Colors.grey),
                                      )
                                    :  Text(
                                  initialPackageService?[i] == '-202' ? 'Unlimited' : '(${initialPackageService?[i] ?? ''})',
                                        style: TextStyle(color: Colors.grey),
                                      ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                const SizedBox(height: 20),
                Text(
                  lang.S.of(context).forUnlimitedUses,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ).visible(initialSelectedPackage != 'Lifetime'),
                const SizedBox(height: 20).visible(initialSelectedPackage != 'Lifetime'),
                GestureDetector(
                  onTap: () {
                    const PurchasePremiumPlanScreen(
                      isCameBack: true,
                      initialSelectedPackage: 'Yearly',
                      initPackageValue: 0,
                    ).launch(context);
                  },
                  child: Container(
                    height: 50,
                    decoration: const BoxDecoration(
                      color: kMainColor,
                      borderRadius: BorderRadius.all(Radius.circular(30)),
                    ),
                    child: Center(
                      child: Text(
                        lang.S.of(context).updateNow,
                        style: const TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),
                ).visible(initialSelectedPackage != 'Lifetime' && !isSubUser),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
