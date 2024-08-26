import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_pos/Screens/subscription/payment_page.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import 'package:mobile_pos/repository/paypal_info_repo.dart';
import 'package:mobile_pos/subscript.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../Provider/subscription_provider.dart';
import '../../constant.dart';
import '../../currency.dart';
import '../../model/payment_model.dart';
import '../../model/subscription_model.dart';
import '../../model/subscription_plan_model.dart';
import '../Home/home.dart';

class PurchasePremiumPlanScreen extends StatefulWidget {
  const PurchasePremiumPlanScreen({super.key, required this.initialSelectedPackage, required this.initPackageValue, required this.isCameBack});

  final String initialSelectedPackage;
  final int initPackageValue;
  final bool isCameBack;

  @override
  State<PurchasePremiumPlanScreen> createState() => _PurchasePremiumPlanScreenState();
}

class _PurchasePremiumPlanScreenState extends State<PurchasePremiumPlanScreen> {
  String selectedPayButton = 'Paypal';
  int selectedPackageValue = 0;

  CurrentSubscriptionPlanRepo currentSubscriptionPlanRepo = CurrentSubscriptionPlanRepo();

  SubscriptionModel currentSubscriptionPlan = SubscriptionModel(
    subscriptionName: 'Free',
    subscriptionDate: DateTime.now().toString(),
    saleNumber: 0,
    purchaseNumber: 0,
    partiesNumber: 0,
    dueNumber: 0,
    duration: 0,
    products: 0,
  );

  void getCurrentSubscriptionPlan() async {
    currentSubscriptionPlan = await currentSubscriptionPlanRepo.getCurrentSubscriptionPlans();
    setState(() {
      currentSubscriptionPlan;
    });
  }

  @override
  initState() {
    super.initState();
    getCurrentSubscriptionPlan();
    widget.initPackageValue == 0 ? selectedPackageValue = 2 : 0;
  }

  List<Color> colors = [
    const Color(0xFF06DE90),
    const Color(0xFFF5B400),
    const Color(0xFFFF7468),
  ];
  SubscriptionPlanModel selectedPlan =
  SubscriptionPlanModel(subscriptionName: '', saleNumber: 0, purchaseNumber: 0, partiesNumber: 0, dueNumber: 0, duration: 0, products: 0, subscriptionPrice: 0, offerPrice: 0);
  ScrollController mainScroll = ScrollController();

  List<String> imageList = [
    'images/sp1.png',
    'images/sp2.png',
    'images/sp3.png',
    'images/sp4.png',
    'images/sp5.png',
    'images/sp6.png',
  ];

  List<String> getTitleList({required BuildContext context}){
    List<String> titleListData = [
      lang.S.of(context).freeLifeTimeUpdate,
      lang.S.of(context).androidIOSAppSupport,
      lang.S.of(context).premiumCustomerSupport,
      lang.S.of(context).customInvoiceBranding,
      lang.S.of(context).unlimitedUsage,
      lang.S.of(context).freeDataBackup,
    ];
    return titleListData;
  }

  List<String> titleListData = [];


  List<String> planDetailsImages = [
    'images/plan_details_1.png',
    'images/plan_details_2.png',
    'images/plan_details_3.png',
    'images/plan_details_4.png',
    'images/plan_details_5.png',
    'images/plan_details_6.png',
  ];
  List<String> getPlanDetailsText({required BuildContext context}){
    List<String> planDetailsText = [
      lang.S.of(context).freeLifeTimeUpdate,
      lang.S.of(context).androidIOSAppSupport,
      lang.S.of(context).premiumCustomerSupport,
      lang.S.of(context).customInvoiceBranding,
      lang.S.of(context).unlimitedUsage,
      lang.S.of(context).freeDataBackup,
    ];
    return planDetailsText;
  }
  List<String> planDetailsText = [];

  List<String> getDescription({required BuildContext context}){
    List<String> desciption = [
      lang.S.of(context).stayAtTheForFront,
      lang.S.of(context).weUnderStand,
      lang.S.of(context).unlockTheFull,
      lang.S.of(context).makeALastingImpression,
      lang.S.of(context).theNameSysIt,
      lang.S.of(context).safeGuardYourBusinessDate,
    ];
    return desciption;
  }
  List<String> desciption = [];

  @override
  Widget build(BuildContext context) {
    desciption=getDescription(context: context);
    planDetailsText=getPlanDetailsText(context: context);
    titleListData=getTitleList(context: context);
    return Scaffold(
      backgroundColor: kMainColor,
      body: Consumer(
        builder: (context, ref, __) {
          final subscriptionData = ref.watch(subscriptionPlanProvider);
          return SingleChildScrollView(
            child: SafeArea(
              child: subscriptionData.when(data: (data) {
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            lang.S.of(context).purchasePremiumPlan,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              widget.isCameBack ? Navigator.pop(context) : const Home().launch(context);
                            },
                            child: const Icon(
                              Icons.cancel_outlined,
                              color: Colors.white,
                            ),
                          )
                        ],
                      ),
                    ),
                    Container(
                      alignment: Alignment.topCenter,
                      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(topRight: Radius.circular(30), topLeft: Radius.circular(30))),
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),
                          ListView.builder(
                              itemCount: imageList.length,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemBuilder: (_, i) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: GestureDetector(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return Dialog(
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                const SizedBox(height: 20),
                                                Row(
                                                  mainAxisSize: MainAxisSize.max,
                                                  mainAxisAlignment: MainAxisAlignment.end,
                                                  children: [
                                                    GestureDetector(
                                                      child: const Icon(Icons.cancel),
                                                      onTap: () {
                                                        Navigator.pop(context);
                                                      },
                                                    ),
                                                    const SizedBox(width: 20),
                                                  ],
                                                ),
                                                const SizedBox(height: 20),
                                                Image(
                                                  height: 200,
                                                  width: 200,
                                                  image: AssetImage(planDetailsImages[i]),
                                                ),
                                                const SizedBox(height: 20),
                                                Text(
                                                  planDetailsText[i],
                                                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                                ),
                                                const SizedBox(height: 15),
                                                Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: Text(desciption[i], textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
                                                ),
                                                const SizedBox(height: 20),
                                              ],
                                            ),
                                          );
                                        },
                                      );
                                    },
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
                                            titleListData[i],
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                          ),
                                          trailing: const Icon(FeatherIcons.alertCircle),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                          const SizedBox(height: 10),
                          Text(
                            lang.S.of(context).buyPremiumPlan,
                            textAlign: TextAlign.start,
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 20),
                          // SizedBox(
                          //   height: 210,
                          //   child: ListView.builder(
                          //     physics: const ClampingScrollPhysics(),
                          //     shrinkWrap: true,
                          //     scrollDirection: Axis.horizontal,
                          //     itemCount: data.length,
                          //     itemBuilder: (BuildContext context, int index) {
                          //       return Padding(
                          //         padding: const EdgeInsets.only(right: 10),
                          //         child: Column(
                          //           children: [
                          //             SizedBox(
                          //               width: 150,
                          //               child: Stack(
                          //                 alignment: Alignment.bottomCenter,
                          //                 children: [
                          //                   GestureDetector(
                          //                     onTap:(){
                          //                       setState(() {
                          //                       });
                          //                     },
                          //                     child: Container(
                          //                       height: 210,
                          //                       width: 150,
                          //                       decoration: BoxDecoration(
                          //                         color: currentSubscriptionPlan.subscriptionName == data[index].subscriptionName ? kPremiumPlanColor2.withOpacity(0.1) : Colors.white,
                          //                         borderRadius: const BorderRadius.all(
                          //                           Radius.circular(10),
                          //                         ),
                          //                         border: Border.all(width: 1, color: currentSubscriptionPlan.subscriptionName == data[index].subscriptionName ? kPremiumPlanColor2 : kPremiumPlanColor),
                          //                       ),
                          //                       child: Column(
                          //                         mainAxisAlignment: MainAxisAlignment.center,
                          //                         children: [
                          //                           const SizedBox(height: 15),
                          //                           const Text(
                          //                             'Mobile App \n+\nDesktop',
                          //                             textAlign: TextAlign.center,
                          //                             style: TextStyle(
                          //                               fontSize: 16,
                          //                             ),
                          //                           ),
                          //                           const SizedBox(height: 15),
                          //                           Text(
                          //                             data[index].subscriptionName,
                          //                             style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue),
                          //                           ),
                          //                           const SizedBox(height: 5),
                          //                           Text(
                          //                             '$currency${data[index].offerPrice > 0 ? data[index].offerPrice : data[index].subscriptionPrice}',
                          //                             style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue),
                          //                           ),
                          //                           Text(
                          //                             '$currency${data[index].subscriptionPrice}',
                          //                             style: const TextStyle(decoration: TextDecoration.lineThrough, fontSize: 14, color: Colors.grey),
                          //                           ).visible(data[index].offerPrice > 0),
                          //                           const SizedBox(height: 5),
                          //                           Text(
                          //                             'Duration ${data[index].duration} Day',
                          //                             style: const TextStyle(color: kGreyTextColor),
                          //                           ),
                          //                         ],
                          //                       ),
                          //                     ),
                          //                   ),
                          //                   Positioned(
                          //                     top: 0,
                          //                     left: 0,
                          //                     child: Container(
                          //                       height: 25,
                          //                       width: 70,
                          //                       decoration: const BoxDecoration(
                          //                         color: Colors.blue,
                          //                         borderRadius: BorderRadius.only(
                          //                           topLeft: Radius.circular(10),
                          //                           bottomRight: Radius.circular(10),
                          //                         ),
                          //                       ),
                          //                       child: Center(
                          //                         child: Text(
                          //                           data[index].offerPrice == data[index].subscriptionPrice
                          //                               ? ""
                          //                               : 'Save ${(100 - ((data[index].offerPrice * 100) / data[index].subscriptionPrice)).toInt().toString()}%',
                          //                           style: const TextStyle(color: Colors.white),
                          //                         ),
                          //                       ),
                          //                     ),
                          //                   ).visible(data[index].offerPrice > 0),
                          //                 ],
                          //               ),
                          //             ),
                          //
                          //           ],
                          //         ),
                          //       );
                          //     },
                          //   ),
                          // ),
                          SizedBox(
                            height: (context.width() / 2) + 18,
                            child: ListView.builder(
                              physics: const ClampingScrollPhysics(),
                              shrinkWrap: true,
                              scrollDirection: Axis.horizontal,
                              itemCount: data.length,
                              itemBuilder: (BuildContext context, int index) {
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedPlan = data[index];
                                    });
                                  },
                                  child: data[index].offerPrice >= 1
                                      ? Padding(
                                    padding: const EdgeInsets.only(right: 10),
                                    child: SizedBox(
                                      height: (context.width() / 2.5) + 18,
                                      child: Stack(
                                        alignment: Alignment.bottomCenter,
                                        children: [
                                          Container(
                                            height: (context.width() / 2.0),
                                            width: (context.width() / 2.5) - 20,
                                            decoration: BoxDecoration(
                                              color: data[index].subscriptionName == selectedPlan.subscriptionName ? kPremiumPlanColor2.withOpacity(0.1) : Colors.white,
                                              borderRadius: const BorderRadius.all(
                                                Radius.circular(10),
                                              ),
                                              border: Border.all(
                                                width: 1,
                                                color: data[index].subscriptionName == selectedPlan.subscriptionName ? kPremiumPlanColor2 : kPremiumPlanColor,
                                              ),
                                            ),
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                const SizedBox(height: 15),
                                                const Text(
                                                  'Mobile App\n+\nDesktop',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                  ),
                                                ),
                                                const SizedBox(height: 15),
                                                Text(
                                                  data[index].subscriptionName,
                                                  style: const TextStyle(fontSize: 16),
                                                ),
                                                const SizedBox(height: 5),
                                                Text(
                                                  '$currency${data[index].offerPrice}',
                                                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: kPremiumPlanColor2),
                                                ),
                                                Text(
                                                  '$currency${data[index].subscriptionPrice}',
                                                  style: const TextStyle(decoration: TextDecoration.lineThrough, fontSize: 14, color: Colors.grey),
                                                ),
                                                const SizedBox(height: 5),
                                                Text(
                                                  'Duration ${data[index].duration} Day',
                                                  style: const TextStyle(color: kGreyTextColor),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Positioned(
                                            top: 8,
                                            left: 0,
                                            child: Container(
                                              height: 25,
                                              width: 70,
                                              decoration: const BoxDecoration(
                                                color: kPremiumPlanColor2,
                                                borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(10),
                                                  bottomRight: Radius.circular(10),
                                                ),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  'Save ${(100 - ((data[index].offerPrice * 100) / data[index].subscriptionPrice)).toInt().toString()}%',
                                                  style: const TextStyle(color: Colors.white),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                      : Padding(
                                    padding: const EdgeInsets.only(bottom: 20, top: 20, right: 10),
                                    child: Container(
                                      height: (context.width() / 2.0),
                                      width: (context.width() / 2.5) - 20,
                                      decoration: BoxDecoration(
                                        color: data[index].subscriptionName == selectedPlan.subscriptionName ? kPremiumPlanColor2.withOpacity(0.1) : Colors.white,
                                        borderRadius: const BorderRadius.all(
                                          Radius.circular(10),
                                        ),
                                        border: Border.all(
                                            width: 1, color: data[index].subscriptionName == selectedPlan.subscriptionName ? kPremiumPlanColor2 : kPremiumPlanColor),
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Text(
                                            'Mobile App\n+\nDesktop',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(height: 15),
                                          Text(
                                            data[index].subscriptionName,
                                            style: const TextStyle(fontSize: 16),
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            '$currency${data[index].subscriptionPrice.toString()}',
                                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: kPremiumPlanColor),
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            'Duration ${data[index].duration} Day',
                                            style: const TextStyle(color: kGreyTextColor),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(
                            height: 20
                          ),
                          GestureDetector(
                            onTap: () async {
                              if (selectedPlan.subscriptionName == '') {
                                EasyLoading.showError('Please Select a Plan');
                              } else {
                                EasyLoading.show(status: "Loading");
                                var paypal = await PaypalInfoRepo().getPaypalInfo();
                                var stripe = await StripeInfoRepo().getStripeInfo();
                                var razorpay = await RazorpayInfoRepo().getRazorpayInfo();
                                var ssl = await SSLInfoRepo().getSSLInfo();
                                var flutterwave = await FlutterWaveInfoRepo().getFlutterWaveInfo();
                                var tap = await TapInfoRepo().getTapInfo();
                                var kkiPay = await KkiPayInfoRepo().getKkiPayInfo();
                                var paystack = await PayStackInfoRepo().getPayStackInfo();
                                var billPlz = await BillplzInfoRepo().getBillplzInfo();
                                var cashfree = await CashFreeInfoRepo().getCashFreeInfo();
                                var iyzico = await IyzicoInfoRepo().getIyzicoInfo();
                                var price = selectedPlan.offerPrice < 1 ? selectedPlan.subscriptionPrice : selectedPlan.offerPrice;
                                if(mounted){
                                  EasyLoading.dismiss();
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => PaymentPage(
                                            selectedPlan: selectedPlan, onError: () {
                                            Navigator.pop(context);
                                          }, totalAmount: price.toString(), paymentModel: PaymentModel(
                                            paypalInfoModel: paypal,
                                            stripeInfoModel: stripe,
                                            razorpayInfoModel: razorpay,
                                            sslInfoModel: ssl,
                                            flutterWaveInfoModel: flutterwave,
                                            tapInfoModel: tap,
                                            kkiPayInfoModel: kkiPay,
                                            payStackInfoModel: paystack,
                                            billplzInfoModel: billPlz,
                                            cashFreeInfoModel: cashfree,
                                            iyzicoInfoModel: iyzico,
                                          ),
                                          )));
                                }
                              }
                            },
                            child: Container(
                              height: 50,
                              decoration: const BoxDecoration(
                                color: kMainColor,
                                borderRadius: BorderRadius.all(Radius.circular(10)),
                              ),
                              child:  Center(
                                child: Text(
                                  lang.S.of(context).payCash,
                                  style: const TextStyle(fontSize: 18, color: Colors.white),
                                ),
                              ),
                            ),
                          ).visible(Subscript.customersActivePlan.subscriptionName != selectedPlan.subscriptionName),
                        ],
                      ),
                    ),
                  ],
                );
              }, error: (Object error, StackTrace? stackTrace) {
                return Text(error.toString());
              }, loading: () {
                return const Center(child: CircularProgressIndicator());
              }),
            ),
          );
        },
      ),
    );
  }
}
