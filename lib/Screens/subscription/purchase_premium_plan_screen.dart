import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bkash/flutter_bkash.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_pos/Provider/profile_provider.dart';
import 'package:mobile_pos/Screens/subscription/buy_now.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import 'package:mobile_pos/subscript.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../Provider/subscription_provider.dart';
import '../../constant.dart';
import '../../currency.dart';
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
  SubscriptionPlanModel selectedPlan = SubscriptionPlanModel(subscriptionName: '', saleNumber: 0, purchaseNumber: 0, partiesNumber: 0, dueNumber: 0, duration: 0, products: 0, subscriptionPrice: 0, offerPrice: 0);
  ScrollController mainScroll = ScrollController();

  SubscriptionRequestModel subscriptionRequestModelData = SubscriptionRequestModel(
    subscriptionPlanModel: SubscriptionPlanModel(
        dueNumber: 0, duration: 0, offerPrice: 0, partiesNumber: 0, products: 0, purchaseNumber: 0, saleNumber: 0, subscriptionName: '', subscriptionPrice: 00, subscriptionDate: DateTime.now().toString()),
    transactionNumber: '',
    note: '',
    attachment: '',
    userId: constUserId,
    businessCategory: '',
    companyName: '',
    countryName: '',
    language: '',
    phoneNumber: '',
    pictureUrl: '',
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kMainColor,
      body: Consumer(
        builder: (context, ref, __) {
          final subscriptionData = ref.watch(subscriptionPlanProvider);
          final userProfileDetails = ref.watch(profileDetailsProvider);

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
                          Text(
                            lang.S.of(context).buyPremiumPlan,
                            textAlign: TextAlign.start,
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 20),
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
                                              border: Border.all(width: 1, color: data[index].subscriptionName == selectedPlan.subscriptionName ? kPremiumPlanColor2 : kPremiumPlanColor),
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
                          const SizedBox(height: 20),
                          GestureDetector(
                            onTap: () async {
                              if (selectedPlan.subscriptionName == '') {
                                EasyLoading.showError('Please Select a Plan');
                              } else {
                                await userProfileDetails.when(data: (details) {
                                  EasyLoading.dismiss();
                                  subscriptionRequestModelData.countryName = details.countryName ?? '';
                                  subscriptionRequestModelData.language = details.language ?? '';
                                  subscriptionRequestModelData.pictureUrl = details.pictureUrl ?? '';
                                  subscriptionRequestModelData.companyName = details.companyName ?? '';
                                  subscriptionRequestModelData.businessCategory = details.businessCategory ?? '';
                                  subscriptionRequestModelData.phoneNumber = details.phoneNumber ?? '';
                                }, error: (Object error, StackTrace stackTrace) {
                                  EasyLoading.dismiss();
                                }, loading: () {
                                  EasyLoading.show(status: 'Loading....');
                                });

                                subscriptionRequestModelData.subscriptionPlanModel = selectedPlan;

                                final flutterBkash = FlutterBkash(
                                    bkashCredentials: BkashCredentials(
                                        username: '01752156079', password: '!<+8Cb!k^@C', appKey: 'TyvaRsl9jCZ37daetzZ1lQeKtc', appSecret: 'nQYx0fC5jDdN9DitOKPkDuYLOUqEVHVqMVA8RmGgqSxewtKsgsqX', isSandbox: false));
                                try {
                                  double price = ((selectedPlan.offerPrice < 1) ? selectedPlan.subscriptionPrice : selectedPlan.offerPrice).toDouble();

                                  /// call pay method to pay without agreement as parameter pass the context, amount, merchantInvoiceNumber
                                  final result = await flutterBkash.pay(
                                    context: context,
                                    amount: price,
                                    merchantInvoiceNumber: subscriptionRequestModelData.userId,
                                  );

                                  if (result != null) {
                                    // EasyLoading.dismiss();
                                    String? sellerUserRef = await getSaleID(id: await getUserID());
                                    if (sellerUserRef != null) {
                                      final DatabaseReference subscriptionRef = FirebaseDatabase.instance.ref().child(subscriptionRequestModelData.userId).child('Subscription');
                                      selectedPlan.subscriptionDate = DateTime.now().toString();
                                      await subscriptionRef.set(selectedPlan.toJson());

                                      ///_____Seller_info_update________________________________________
                                      final DatabaseReference superAdminSellerListRepo = FirebaseDatabase.instance.ref().child('Admin Panel').child('Seller List').child(sellerUserRef);
                                      superAdminSellerListRepo.update({
                                        "subscriptionDate": DateTime.now().toString(),
                                        "subscriptionName": selectedPlan.subscriptionName,
                                      });

                                      ///______________________________________
                                      subscriptionRequestModelData.transactionNumber = result.trxId;
                                      // data.attachment == '' ? null : await uploadFile(data.attachment);
                                      final DatabaseReference ref = FirebaseDatabase.instance.ref().child('Admin Panel').child('Subscription Update Request');
                                      ref.keepSynced(true);
                                      ref.push().set(subscriptionRequestModelData.toJson());
                                      EasyLoading.showSuccess('Payment Successfully');
                                      Navigator.pop(context);
                                      Navigator.pop(context);
                                    } else {
                                      EasyLoading.showError('You Are Not A Valid User');
                                    }
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("(Success) tranId: ${result.trxId}"),
                                        duration: Duration(seconds: 3),
                                      ),
                                    );
                                  }
                                } on BkashFailure catch (e, st) {
                                  // paymentStatus = "Bkash Response Error";
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("${e.message}"),
                                      duration: Duration(seconds: 3),
                                    ),
                                  );
                                } catch (e, st) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("Something went wrong"),
                                      duration: Duration(seconds: 3),
                                    ),
                                  );
                                }

                                /*                Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => BuyNow(
                                            subscriptionPlanModel: selectedPlan,
                                          )));
*/
                                /*
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

                                  */
                              }
                            },
                            child: Container(
                              height: 50,
                              decoration: const BoxDecoration(
                                color: kMainColor,
                                borderRadius: BorderRadius.all(Radius.circular(10)),
                              ),
                              child: Center(
                                child: Text(
                                  "Pay Now",
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
