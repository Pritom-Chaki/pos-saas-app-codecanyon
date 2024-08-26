import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_paypal_easy_checkout/flutter_paypal_checkout.dart';
import 'package:flutter_sslcommerz/model/SSLCSdkType.dart';
import 'package:flutter_sslcommerz/model/SSLCTransactionInfoModel.dart';
import 'package:flutter_sslcommerz/model/SSLCommerzInitialization.dart';
import 'package:flutter_sslcommerz/model/SSLCurrencyType.dart';
import 'package:flutter_sslcommerz/sslcommerz.dart';
// import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutterwave_standard/core/flutterwave.dart';
import 'package:flutterwave_standard/models/requests/customer.dart';
import 'package:flutterwave_standard/models/requests/customizations.dart';
import 'package:flutterwave_standard/models/responses/charge_response.dart';
import 'package:http/http.dart' as http;
import 'package:kkiapay_flutter_sdk/kkiapay_flutter_sdk.dart';
import 'package:mobile_pos/Functions/webview_screen.dart';
import 'package:mobile_pos/constant.dart' as cns;
import 'package:mobile_pos/model/payment_model.dart';
import 'package:mobile_pos/repository/bank_info_repo.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:pay_with_paystack/pay_with_paystack.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../const_commas.dart';
import '../../currency.dart';
import '../../model/subscription_model.dart';
import '../../model/subscription_plan_model.dart';
import '../../tap_payment/flutter_tap_payment.dart';
import '../Home/home.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key, required this.selectedPlan, required this.onError, required this.totalAmount, required this.paymentModel});

  final String totalAmount;
  final SubscriptionPlanModel selectedPlan;
  final Function onError;
  final PaymentModel paymentModel;


  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final primaryColor = const Color(0xFF27AE60);
  final kGreyTextColor = const Color(0xFF828282);
  String? whichPaymentIsChecked;

  @override
  void initState() {
    setState(() {
      whichPaymentIsChecked = defaultPaymentMethod;
    });
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0.0,
        title:  const Text('Payment Method',style: TextStyle(color: Colors.black),),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Container(
            decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(30),
                    topLeft: Radius.circular(30)
                ),
                color: Colors.white
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15,vertical: 20),
              child: Column(
                children: [
                  Material(
                    elevation: 0.0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        side: BorderSide(color: whichPaymentIsChecked == 'Paypal' ? primaryColor : kGreyTextColor.withOpacity(0.2))),
                    color: Colors.white,
                    child: CheckboxListTile(
                      value: whichPaymentIsChecked == 'Paypal',
                      checkboxShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
                      onChanged: (val) {
                        setState(() {
                          val == true ? whichPaymentIsChecked = 'Paypal' : whichPaymentIsChecked = 'Paypal';
                        });
                      },
                      contentPadding: const EdgeInsets.all(10.0),
                      activeColor: primaryColor,
                      title:  const Text(
                        'Paypal',
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                      secondary: Image.asset(
                        'images/paypal-logo.png',
                        height: 50.0,
                        width: 80.0,
                      ),
                    ),
                  ).visible(widget.paymentModel.paypalInfoModel.isLive),
                  const SizedBox(
                    height: 10.0,
                  ).visible(widget.paymentModel.stripeInfoModel.isLive),
                  Material(
                    elevation: 0.0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        side: BorderSide(color: whichPaymentIsChecked == 'Stripe' ? primaryColor : kGreyTextColor.withOpacity(0.1))),
                    color: Colors.white,
                    child: CheckboxListTile(
                      value: whichPaymentIsChecked == 'Stripe',
                      checkboxShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
                      onChanged: (val) {
                        setState(() {
                          val == true ? whichPaymentIsChecked = 'Stripe' : whichPaymentIsChecked = 'Paypal';
                        });
                      },
                      contentPadding: const EdgeInsets.all(10.0),
                      activeColor: primaryColor,
                      title: const Text(
                        'Stripe',
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                      secondary: Image.asset(
                        'images/stripe-logo.png',
                        height: 50.0,
                        width: 80.0,
                      ),
                    ),
                  ).visible(widget.paymentModel.stripeInfoModel.isLive),
                  const SizedBox(
                    height: 20.0,
                  ).visible(widget.paymentModel.kkiPayInfoModel.isLive),
                  Material(
                    elevation: 0.0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        side: BorderSide(color: whichPaymentIsChecked == 'Kkipay' ? primaryColor : kGreyTextColor.withOpacity(0.2))),
                    color: Colors.white,
                    child: CheckboxListTile(
                      value: whichPaymentIsChecked == 'Kkipay',
                      checkboxShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
                      onChanged: (val) {
                        setState(() {
                          val == true ? whichPaymentIsChecked = 'Kkipay' : whichPaymentIsChecked = 'Paypal';
                        });
                      },
                      contentPadding:  const EdgeInsets.all(10.0),
                      activeColor: primaryColor,
                      title:  const Text(
                        'KKIPAY',
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                      secondary: Image.asset(
                        'images/paytm-logo.png',
                        height: 50.0,
                        width: 80.0,
                      ),
                    ),
                  ).visible(widget.paymentModel.kkiPayInfoModel.isLive),
                  const SizedBox(
                    height: 20.0,
                  ).visible(widget.paymentModel.razorpayInfoModel.isLive),
                  Material(
                    elevation: 0.0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        side: BorderSide(color: whichPaymentIsChecked == 'Razorpay' ? primaryColor : kGreyTextColor.withOpacity(0.2))),
                    color: Colors.white,
                    child: CheckboxListTile(
                      value: whichPaymentIsChecked == 'Razorpay',
                      checkboxShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
                      onChanged: (val) {
                        setState(() {
                          val == true ? whichPaymentIsChecked = 'Razorpay' : whichPaymentIsChecked = 'Paypal';
                        });
                      },
                      contentPadding: const EdgeInsets.all(10.0),
                      activeColor: primaryColor,
                      title:  const Text(
                        'Rezorpay',
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                      secondary: Image.asset(
                        'images/razorpay-logo.png',
                        height: 50.0,
                        width: 80.0,
                      ),
                    ),
                  ).visible(widget.paymentModel.razorpayInfoModel.isLive),
                  const SizedBox(
                    height: 20.0,
                  ).visible(widget.paymentModel.sslInfoModel.isLive),
                  Material(
                    elevation: 0.0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        side: BorderSide(color: whichPaymentIsChecked == 'SSLCommerz' ? primaryColor : kGreyTextColor.withOpacity(0.2))),
                    color: Colors.white,
                    child: CheckboxListTile(
                      value: whichPaymentIsChecked == 'SSLCommerz',
                      checkboxShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
                      onChanged: (val) {
                        setState(() {
                          val == true ? whichPaymentIsChecked = 'SSLCommerz' : whichPaymentIsChecked = 'Paypal';
                        });
                      },
                      contentPadding: const EdgeInsets.all(10.0),
                      activeColor: primaryColor,
                      title:  const Text(
                        'SSLCommerz',
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                      secondary: Container(
                        decoration: BoxDecoration(
                            color: kGreyTextColor
                        ),
                        child: Image.asset(
                          'images/sslcommerz.jpg',
                          height: 50.0,
                          width: 80.0,
                        ),
                      ),
                    ),
                  ).visible(widget.paymentModel.sslInfoModel.isLive),
                  const SizedBox(
                    height: 20.0,
                  ).visible(widget.paymentModel.tapInfoModel.isLive),
                  Material(
                    elevation: 0.0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        side: BorderSide(color: whichPaymentIsChecked == 'Tap' ? primaryColor : kGreyTextColor.withOpacity(0.2))),
                    color: Colors.white,
                    child: CheckboxListTile(
                      value: whichPaymentIsChecked == 'Tap',
                      checkboxShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
                      onChanged: (val) {
                        setState(() {
                          val == true ? whichPaymentIsChecked = 'Tap' : whichPaymentIsChecked = 'Paypal';
                        });
                      },
                      contentPadding: const EdgeInsets.all(10.0),
                      activeColor: primaryColor,
                      title:  const Text(
                        'Tap',
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                      secondary: Image.asset(
                        'images/tap.png',
                        height: 50.0,
                        width: 80.0,
                      ),
                    ),
                  ).visible(widget.paymentModel.tapInfoModel.isLive),
                  const SizedBox(
                    height: 20.0,
                  ).visible(widget.paymentModel.flutterWaveInfoModel.isLive),
                  Material(
                    elevation: 0.0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        side: BorderSide(color: whichPaymentIsChecked == 'Flutterwave' ? primaryColor : kGreyTextColor.withOpacity(0.2))),
                    color: Colors.white,
                    child: CheckboxListTile(
                      value: whichPaymentIsChecked == 'Flutterwave',
                      checkboxShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
                      onChanged: (val) {
                        setState(() {
                          val == true ? whichPaymentIsChecked = 'Flutterwave' : whichPaymentIsChecked = 'Paypal';
                        });
                      },
                      contentPadding: const EdgeInsets.all(10.0),
                      activeColor: primaryColor,
                      title:  const Text(
                        'Flutter Wave',
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                      secondary: Image.asset(
                        'images/flutterwave_logo.png',
                        height: 50.0,
                        width: 80.0,
                      ),
                    ),
                  ).visible(widget.paymentModel.flutterWaveInfoModel.isLive),
                  const SizedBox(
                    height: 20.0,
                  ).visible(widget.paymentModel.payStackInfoModel.isLive),
                  Material(
                    elevation: 0.0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        side: BorderSide(color: whichPaymentIsChecked == 'Paystack' ? primaryColor : kGreyTextColor.withOpacity(0.2))),
                    color: Colors.white,
                    child: CheckboxListTile(
                      value: whichPaymentIsChecked == 'Paystack',
                      checkboxShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
                      onChanged: (val) {
                        setState(() {
                          val == true ? whichPaymentIsChecked = 'Paystack' : whichPaymentIsChecked = 'Paypal';
                        });
                      },
                      contentPadding: const EdgeInsets.all(10.0),
                      activeColor: primaryColor,
                      title:  const Text(
                        'PayStack',
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                      secondary: Image.asset(
                        'images/flutterwave_logo.png',
                        height: 50.0,
                        width: 80.0,
                      ),
                    ),
                  ).visible(widget.paymentModel.payStackInfoModel.isLive),
                  const SizedBox(
                    height: 20.0,
                  ).visible(widget.paymentModel.billplzInfoModel.isLive),
                  Material(
                    elevation: 0.0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        side: BorderSide(color: whichPaymentIsChecked == 'BillPlz' ? primaryColor : kGreyTextColor.withOpacity(0.2))),
                    color: Colors.white,
                    child: CheckboxListTile(
                      value: whichPaymentIsChecked == 'BillPlz',
                      checkboxShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
                      onChanged: (val) {
                        setState(() {
                          val == true ? whichPaymentIsChecked = 'BillPlz' : whichPaymentIsChecked = 'Paypal';
                        });
                      },
                      contentPadding: const EdgeInsets.all(10.0),
                      activeColor: primaryColor,
                      title:  const Text(
                        'BillPlz',
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                      secondary: Image.asset(
                        'images/flutterwave_logo.png',
                        height: 50.0,
                        width: 80.0,
                      ),
                    ),
                  ).visible(widget.paymentModel.billplzInfoModel.isLive),
                  const SizedBox(
                    height: 20.0,
                  ).visible(widget.paymentModel.cashFreeInfoModel.isLive),
                  Material(
                    elevation: 0.0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        side: BorderSide(color: whichPaymentIsChecked == 'CashFree' ? primaryColor : kGreyTextColor.withOpacity(0.2))),
                    color: Colors.white,
                    child: CheckboxListTile(
                      value: whichPaymentIsChecked == 'CashFree',
                      checkboxShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
                      onChanged: (val) {
                        setState(() {
                          val == true ? whichPaymentIsChecked = 'CashFree' : whichPaymentIsChecked = 'Paypal';
                        });
                      },
                      contentPadding: const EdgeInsets.all(10.0),
                      activeColor: primaryColor,
                      title:  const Text(
                        'Cash Free',
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                      secondary: Image.asset(
                        'images/flutterwave_logo.png',
                        height: 50.0,
                        width: 80.0,
                      ),
                    ),
                  ).visible(widget.paymentModel.cashFreeInfoModel.isLive),
                  const SizedBox(
                    height: 20.0,
                  ).visible(widget.paymentModel.iyzicoInfoModel.isLive),
                  Material(
                    elevation: 0.0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        side: BorderSide(color: whichPaymentIsChecked == 'Iyzico' ? primaryColor : kGreyTextColor.withOpacity(0.2))),
                    color: Colors.white,
                    child: CheckboxListTile(
                      value: whichPaymentIsChecked == 'Iyzico',
                      checkboxShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
                      onChanged: (val) {
                        setState(() {
                          val == true ? whichPaymentIsChecked = 'Iyzico' : whichPaymentIsChecked = 'Paypal';
                        });
                      },
                      contentPadding: const EdgeInsets.all(10.0),
                      activeColor: primaryColor,
                      title:  const Text(
                        'Iyzico',
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                      secondary: Image.asset(
                        'images/flutterwave_logo.png',
                        height: 50.0,
                        width: 80.0,
                      ),
                    ),
                  ).visible(widget.paymentModel.iyzicoInfoModel.isLive),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 20),
          child: GestureDetector(
            onTap: (){
              _handlePayment(widget.totalAmount, paypalCurrency);
            },
            child: Container(
              padding: const EdgeInsets.all(14.0),
              height: 50,
              width: context.width(),
              decoration: BoxDecoration(
                  color: cns.kMainColor,
                  borderRadius: BorderRadius.circular(30.0)
              ),
              child:  const Center(child: Text('Purchase Now',style: TextStyle(color: Colors.white,fontWeight: FontWeight.w600),)),
            ),
          ),
        ),
      ),
    );
  }


  //Handle Multiple Payment system
  _handlePayment(String totalAmount, String currency) {
    switch (whichPaymentIsChecked) {
      case 'Razorpay':
        _handleRazorpayPayment(totalAmount, currency);
        break;
      case 'Paypal':
        _handlePaypalPayment(totalAmount, currency);
        break;
      case 'SSLCommerz':
        _handleSslCommerzPayment(totalAmount, currency);
        break;
      case 'Flutterwave':
        _handleFlutterwavePayment(totalAmount, currency);
        break;
    case 'Kkipay':
      _handleKkipayPayment(totalAmount, currency);
      break;
      // case 'Stripe':
      //   _handleStripePayment(totalAmount, currency);
      //   break;
      case 'Tap':
        _handleTapPayment(totalAmount, currency);
        break;
      case 'BillPlz':
        _handleBillPlzPayment(totalAmount, currency,context);
        break;
      case 'Paystack':
        PayWithPayStack().now(
            context: context,
            secretKey: widget.paymentModel.payStackInfoModel.payStackPublicKey,
            customerEmail: "popekabu@gmail.com",
            reference: DateTime.now().microsecondsSinceEpoch.toString(),
            currency: "GHS",
            paymentChannel: ["mobile_money", "card"],
            amount: "20000",
            transactionCompleted: () {
              onSuccess();
            },
            transactionNotCompleted: () {
              widget.onError();
            },
            callbackUrl: '');
        break;
      default:
        _handlePaypalPayment(totalAmount, currency);
    }
  }

  //Cash on Delivery Payment
  _handleCashOnDelivery(String totalAmount, String currency) {
    onSuccess;
  }

  //Stripe Payment
  createPaymentIntent(String amount, String currency) async {
    try {
      //Request body
      Map<String, dynamic> body = {
        'amount': amount,
        'currency': currency,
      };

      //Make post request to Stripe
      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {'Authorization': 'Bearer ${widget.paymentModel.stripeInfoModel.stripeSecretKey}', 'Content-Type': 'application/x-www-form-urlencoded'},
        body: body,
      );
      return json.decode(response.body);
    } catch (err) {print(err.toString());
      throw Exception(err.toString());
    }
  }

  // _handleStripePayment(String totalAmount, String currency) async {
  //   try {
  //     //STEP 1: Create Payment Intent
  //     var paymentIntent = await createPaymentIntent((double.parse(totalAmount) * 100).round().toString(), widget.paymentModel.stripeInfoModel.stripeCurrency);
  //     print(paymentIntent);
  //     Stripe.publishableKey = widget.paymentModel.stripeInfoModel.stripePublishableKey;
  //     //STEP 2: Initialize Payment Sheet
  //     await Stripe.instance.initPaymentSheet(
  //         paymentSheetParameters: SetupPaymentSheetParameters(
  //             paymentIntentClientSecret: paymentIntent!['client_secret'], //Gotten from payment intent
  //             style: ThemeMode.light,
  //             merchantDisplayName: 'Prince mahmud'));
  //
  //     //STEP 3: Display Payment sheet
  //     await Stripe.instance.presentPaymentSheet().then((value) {
  //       onSuccess();
  //       paymentIntent = null;
  //     });
  //   } on StripeException catch (e) {
  //     print('Error is: ${e.toString()}');
  //     widget.onError();
  //   }
  // }

  Future<void> _handleSslCommerzPayment(String totalAmount, String currency) async {

    Sslcommerz sslcommerz = Sslcommerz(
      initializer: SSLCommerzInitialization(
        //Use the ipn if you have valid one, or it will fail the transaction.
        ipn_url: "www.ipnurl.com",
        currency: SSLCurrencyType.BDT,
        product_category: "Food",
        sdkType: sslSandbox
            ? SSLCSdkType.TESTBOX
            : SSLCSdkType.LIVE,
        store_id: widget.paymentModel.sslInfoModel.sslStoreId,
        store_passwd: widget.paymentModel.sslInfoModel.sslStoreSecret,
        total_amount: totalAmount.toDouble(),
        tran_id: DateTime.now().millisecondsSinceEpoch.toString(),
      ),
    );
    try {
      SSLCTransactionInfoModel result = await sslcommerz.payNow();

      if (result.status!.toLowerCase() == "failed") {
        widget.onError();
        Fluttertoast.showToast(
          msg: "Transaction is Failed....",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      } else if (result.status!.toLowerCase() == "closed") {
        Fluttertoast.showToast(
          msg: "SDK Closed by User",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      } else {
        print("Success");
        onSuccess();
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  //Razorpay payment
  _handleRazorpayPayment(String totalAmount, String currency) {
    Razorpay razorpay = Razorpay();
    var options = {
      'key': widget.paymentModel.razorpayInfoModel.razorpayId,
      'amount': totalAmount,
      "currency": widget.paymentModel.razorpayInfoModel.razorpayCurrency,
      'name': 'Test',
      'retry': {'enabled': true, 'max_count': 1},
      'send_sms_hash': true,
    };
    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, () {
      widget.onError();
    });
    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, (PaymentSuccessResponse response) {
      onSuccess();
    });
    razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, () {});
    razorpay.open(options);
  }


  //KkiPay Payment
  _handleKkipayPayment(String totalAmount, String currency) {
    var kkiapay = KKiaPay(
        amount: widget.totalAmount.toInt(),
        sandbox: true,
        apikey: widget.paymentModel.kkiPayInfoModel.kkiPayApiKey,
        callback: successCallback, reason: 'Payment in PosSaas',);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => kkiapay),
    );
  }

  void successCallback(response, context) {
    switch ( response['status'] ) {

      case PAYMENT_CANCELLED:
        debugPrint(PAYMENT_CANCELLED);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(PAYMENT_CANCELLED),
        ));
        widget.onError();
        break;

      case PENDING_PAYMENT:
        debugPrint(PENDING_PAYMENT);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(PENDING_PAYMENT),
        ));
        widget.onError();
        break;

      case PAYMENT_INIT:
        debugPrint(PAYMENT_INIT);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(PAYMENT_INIT),
        ));
        break;

      case PAYMENT_SUCCESS:
        onSuccess();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(PAYMENT_SUCCESS),
        ));
        break;

      case PAYMENT_FAILED:
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(PAYMENT_SUCCESS),
        ));
        widget.onError();
      break;

      default:
        break;
    }
  }


  //Paypal payment
  _handlePaypalPayment(String totalAmount, String currency) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) => PaypalEasyCheckout(
            sandboxMode: widget.paymentModel.paypalInfoModel.isLive,
            clientId: widget.paymentModel.paypalInfoModel.paypalClientId,
            secretKey: widget.paymentModel.paypalInfoModel.paypalClientSecret,
            returnURL: "https://samplesite.com/return",
            cancelURL: "https://samplesite.com/cancel",
            transactions: [
              {
                "amount": {
                  "total": totalAmount,
                  "currency": "USD",
                  "details": {
                    "subtotal": totalAmount,
                    "shipping": '0',
                    "shipping_discount": 0
                  }
                },
                "description": "Salespro Payment",
                // "payment_options": {
                //   "allowed_payment_method":
                //       "INSTANT_FUNDING_SOURCE"
                // },
                "item_list": {
                  "items": [
                    {
                      "name": "Salespro Payment",
                      "quantity": 1,
                      "price": totalAmount,
                      "currency": "USD",
                    }
                  ],
                }
              }
            ],
            note: "Contact us for any questions on your order.",
            onSuccess: (Map params) async {
              onSuccess();
            },
            onError: (error) {
              widget.onError();
            },
            onCancel: (params) {
              widget.onError();
            }),
      ),
    );
  }

  //Tap payment
  _handleTapPayment(String totalAmount, String currency) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) => TapPayment(
            apiKey: tapApiId,
            redirectUrl: "http://your_website.com/redirect_url",
            postUrl: "http://your_website.com/post_url",
            paymentData: {
              "amount": totalAmount,
              "currency": "OMR",
              "threeDSecure": true,
              "save_card": false,
              "description": "Grocery Order From MaanGrocery",
              "statement_descriptor": "Sample",
              "metadata": const {"udf1": "test 1", "udf2": "test 2"},
              "reference": {
                "transaction": DateTime.now().microsecondsSinceEpoch.toString(),
                "order": DateTime.now().millisecondsSinceEpoch.toString(),
              },
              "receipt": const {"email": false, "sms": true},
              "customer": const {
                "first_name": 'Test',
                "middle_name": "test",
                "last_name": 'Test',
                "email": 'Test@test.com',
                "phone": {
                  "country_code": "965",
                  "number":  '8994849383',
                }
              },
              // "merchant": {"id": ""},
              "source": const {"id": "src_card"},
              // "destinations": {
              //   "destination": [
              //     {"id": "480593777", "amount": 2, "currency": "KWD"},
              //     {"id": "486374777", "amount": 3, "currency": "KWD"}
              //   ]
              // }
            },
            onSuccess: (Map params) async {
              onSuccess();
            },
            onError: (error) {
              widget.onError();
            }),
      ),
    );
  }

  // final plugin = PaystackPlugin();
  // //Paystack payment
  // _handlePayStackPayment(String totalAmount, String currency) async {
  //   Charge charge = Charge()
  //     ..amount = totalAmount.toInt()
  //     ..reference = DateTime.now().microsecondsSinceEpoch.toString()
  //     ..currency = payStackCurrency
  //     ..email = 'test@test.com';
  //   CheckoutResponse response = await plugin.checkout(
  //     context,
  //     fullscreen: true,
  //     method: CheckoutMethod.card,
  //     charge: charge,
  //   );
  //   if (response.status) {
  //     widget.onSuccess;
  //   } else {
  //     widget.onError;
  //   }
  // }

  //Flutterwave payment
  _handleFlutterwavePayment(String totalAmount, String currency) async {
    final Customer customer = Customer(
      name: "Test Test",
      phoneNumber: '567546457456',
      email: 'test@test.com',
    );
    final Flutterwave flutterwave = Flutterwave(
        context: context,
        publicKey: flutterwavePublicKey,
        currency: flutterwaveCurrency,
        redirectUrl: 'https://facebook.com',
        txRef: DateTime.now().millisecondsSinceEpoch.toString(),
        amount: totalAmount,
        customer: customer,
        paymentOptions: "card, payattitude, barter, bank transfer, ussd",
        customization: Customization(title: "Test Payment"),
        isTestMode: sandbox);
    final ChargeResponse response = await flutterwave.charge();
    if (response.success == true) {
      onSuccess();
    } else {
      widget.onError();
    }
  }


  void onSuccess() async{
    try {
      EasyLoading.show(status: 'Loading...', dismissOnTap: false);
      final prefs = await SharedPreferences.getInstance();

      await prefs.setBool('isFiveDayRemainderShown', true);

      final DatabaseReference subscriptionRef = FirebaseDatabase.instance.ref().child(constUserId).child('Subscription');

      SubscriptionModel subscriptionModel = SubscriptionModel(
        subscriptionName: widget.selectedPlan.subscriptionName,
        subscriptionDate: DateTime.now().toString(),
        saleNumber: widget.selectedPlan.saleNumber.toInt(),
        purchaseNumber: widget.selectedPlan.purchaseNumber.toInt(),
        partiesNumber: widget.selectedPlan.partiesNumber.toInt(),
        dueNumber: widget.selectedPlan.dueNumber.toInt(),
        duration: widget.selectedPlan.duration.toInt(),
        products: widget.selectedPlan.products.toInt(),
      );
      // print('here');

      // SubscriptionModel subscriptionModel = SubscriptionModel(
      //   subscriptionName: Subscription.selectedItem,
      //   subscriptionDate: DateTime.now().toString(),
      //   saleNumber: Subscription.subscriptionPlansService[Subscription.selectedItem]!['Sales'].toInt(),
      //   purchaseNumber: Subscription.subscriptionPlansService[Subscription.selectedItem]!['Purchase'].toInt(),
      //   partiesNumber: Subscription.subscriptionPlansService[Subscription.selectedItem]!['Parties'].toInt(),
      //   dueNumber: Subscription.subscriptionPlansService[Subscription.selectedItem]!['Due Collection'].toInt(),
      //   duration: Subscription.subscriptionPlansService[Subscription.selectedItem]!['Duration'].toInt(),
      //   products: Subscription.subscriptionPlansService[Subscription.selectedItem]!['Products'].toInt(),
      // );

      await subscriptionRef.set(subscriptionModel.toJson());
      EasyLoading.showSuccess('Added Successfully', duration: const Duration());
    } catch (e) {
      EasyLoading.dismiss();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
    if (mounted) {
      await const Home().launch(context);
    }
  }
  void _handleBillPlzPayment(String totalAmount, String currency, BuildContext context) async{
    EasyLoading.show(status: 'Loading...', dismissOnTap: false);
    var data = await BankInfoRepo().bilPlzPayment(totalAmount, "maanrealestate","c7bb01f7-9145-497c-b55f-3e423b96cc45", false);
    EasyLoading.dismiss();
    WebviewScreen(url: data.url ?? "",onSuccess: onSuccess,onError: widget.onError,).launch(context);
  }
}


