// ignore_for_file: use_build_context_synchronously, unused_result

import 'dart:async';
import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:intl/intl.dart';
import 'package:mobile_pos/Provider/add_to_cart.dart';
import 'package:mobile_pos/Provider/customer_provider.dart';
import 'package:mobile_pos/Provider/profile_provider.dart';
import 'package:mobile_pos/Provider/transactions_provider.dart';
import 'package:mobile_pos/Screens/Sales/sale%20setting/sale_setting.dart';
import 'package:mobile_pos/Screens/Sales/sale%20setting/sale_setting_provider.dart';
import 'package:mobile_pos/Screens/Sales/sales_screen.dart';
import 'package:mobile_pos/Screens/invoice_details/sales_invoice_details_screen.dart';
import 'package:mobile_pos/const_commas.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import 'package:mobile_pos/model/add_to_cart_model.dart';
import 'package:mobile_pos/model/personal_information_model.dart';
import 'package:mobile_pos/model/transition_model.dart';
import 'package:mobile_pos/subscription.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../Provider/printer_provider.dart';
import '../../Provider/product_provider.dart';
import '../../Provider/seles_report_provider.dart';
import '../../Widget/primary_button_widget.dart';
import '../../constant.dart';
import '../../currency.dart';
import '../../model/DailyTransactionModel.dart';
import '../../model/print_transaction_model.dart';
import '../Customers/Model/customer_model.dart';
import '../Home/home.dart';

// ignore: must_be_immutable
class AddSalesScreen extends StatefulWidget {
  AddSalesScreen({super.key, required this.customerModel});

  CustomerModel customerModel;

  @override
  State<AddSalesScreen> createState() => _AddSalesScreenState();
}

class _AddSalesScreenState extends State<AddSalesScreen> {
  double calculateAmountFromPercentage(double percentage, double price) {
    return (percentage * price) / 100;
  }

  bool saleButtonClicked = false;
  // TextEditingController paidText = TextEditingController();
  int invoice = 0;
  double paidAmount = 0;
  double discountAmount = 0;
  // double vatAmount = 0;
  double returnAmount = 0;
  double dueAmount = 0;
  double subTotal = 0;
  bool sendSms = true;
  bool firstTime = true;

  String? dropdownValue = 'Cash';
  String? selectedPaymentType;
  TextEditingController dateTextEditingController =
      TextEditingController(text: DateFormat.yMMMd().format(DateTime.now()));

  double calculateSubtotal({required double total}) {
    subTotal = total - discountAmount;
    return total - discountAmount;
  }

  double calculateReturnAmount({required double total}) {
    if (widget.customerModel.type == 'Guest') {
      return 0;
    }
    returnAmount = total - paidAmount;
    return paidAmount <= 0 || paidAmount <= subTotal ? 0 : total - paidAmount;
  }

  double calculateDueAmount({required double total}) {
    if (widget.customerModel.type == 'Guest') {
      return 0;
    }
    if (total < 0) {
      dueAmount = 0;
    } else {
      dueAmount = subTotal - paidAmount;
    }
    return returnAmount <= 0 ? 0 : subTotal - paidAmount;
  }

  double percentage = 0;
  TextEditingController discountAmountEditingController =
      TextEditingController();
  TextEditingController discountPercentageEditingController =
      TextEditingController();

  String phoneNumber = '';
  late StreamSubscription subscription;
  bool isDeviceConnected = false;
  bool isAlertSet = false;

  late SalesTransitionModel transitionModel = SalesTransitionModel(
    customerName: widget.customerModel.customerName,
    customerAddress: widget.customerModel.customerAddress,
    customerPhone: widget.customerModel.phoneNumber,
    customerType: widget.customerModel.type,
    customerImage: widget.customerModel.profilePicture,
    customerGst: widget.customerModel.gst,
    invoiceNumber: invoice.toString(),
    purchaseDate: DateTime.now().toString(),
    vat: 0,
    serviceCharge: 0,
  );
  GlobalKey key = GlobalKey();

  @override
  void initState() {
    super.initState();
    getConnectivity();
  }

  void connectivityCallback(List<ConnectivityResult> results) async {
    ConnectivityResult result = results.first;

    isDeviceConnected = await InternetConnectionChecker().hasConnection;
    if (!isDeviceConnected && !isAlertSet) {
      showDialogBox();
      setState(() => isAlertSet = true);
    }
  }

  getConnectivity() {
    subscription = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      connectivityCallback(results);
    });
  }

  checkInternet() async {
    isDeviceConnected = await InternetConnectionChecker().hasConnection;
    if (!isDeviceConnected) {
      showDialogBox();
      setState(() => isAlertSet = true);
    }
  }

  bool show = true;

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, consumerRef, __) {
      final providerData = consumerRef.watch(cartNotifier);
      final printerData = consumerRef.watch(printerProviderNotifier);
      final personalData = consumerRef.watch(profileDetailsProvider);
      final saleSetting = consumerRef.watch(saleSettingProvider);
      return personalData.when(data: (data) {
        invoice = data.saleInvoiceCounter!.toInt();
        return Scaffold(
            backgroundColor: kMainColor,
            appBar: AppBar(
              backgroundColor: kMainColor,
              title: Text(
                lang.S.of(context).addSales,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                ),
              ),
              centerTitle: true,
              iconTheme: const IconThemeData(color: Colors.white),
              elevation: 0.0,
              actions: [
                IconButton(
                  onPressed: () async {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SaleAndLoanSetting(),
                      ),
                    );
                    // bool? set = await Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (context) => const SaleAndLoanSetting(),
                    //   ),
                    // );
                    // if (set ?? false) {
                    //   // firstTime = true;
                    //   await getDataBack();
                    // }
                  },
                  icon: const Icon(Icons.settings, color: kWhite),
                )
              ],
            ),
            body: Container(
              alignment: Alignment.topCenter,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(30),
                  topLeft: Radius.circular(30),
                ),
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: AppTextField(
                              textFieldType: TextFieldType.NAME,
                              readOnly: true,
                              initialValue: data.saleInvoiceCounter.toString(),
                              decoration: InputDecoration(
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always,
                                labelText: lang.S.of(context).invNo,
                                border: const OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: AppTextField(
                              textFieldType: TextFieldType.NAME,
                              readOnly: true,
                              controller: dateTextEditingController,
                              decoration: InputDecoration(
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always,
                                labelText: lang.S.of(context).date,
                                border: const OutlineInputBorder(),
                                suffixIcon: IconButton(
                                  onPressed: () async {
                                    final DateTime? picked =
                                        await showDatePicker(
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime(2015, 8),
                                      lastDate: DateTime(2101),
                                      context: context,
                                    );
                                    setState(() {
                                      dateTextEditingController.text =
                                          DateFormat.yMMMd()
                                              .format(picked ?? DateTime.now());
                                      transitionModel.purchaseDate =
                                          picked.toString();
                                    });
                                  },
                                  icon: const Icon(FeatherIcons.calendar),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(lang.S.of(context).dueAmount),
                              Text(
                                myFormat.format(int.tryParse(widget
                                                .customerModel.dueAmount) ??
                                            0) ==
                                        ''
                                    ? '$currency 0'
                                    : '$currency${myFormat.format(int.tryParse(widget.customerModel.dueAmount) ?? 0)}',
                                style:
                                    const TextStyle(color: Color(0xFFFF8C34)),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          AppTextField(
                            textFieldType: TextFieldType.NAME,
                            readOnly: true,
                            initialValue:
                                widget.customerModel.customerName.isNotEmpty
                                    ? widget.customerModel.customerName
                                    : widget.customerModel.phoneNumber,
                            decoration: InputDecoration(
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.always,
                              labelText: lang.S.of(context).customerName,
                              border: const OutlineInputBorder(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      ///_______Added_ItemS__________________________________________________
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10)),
                          border: Border.all(
                              width: 1, color: const Color(0xffEAEFFA)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                                width: double.infinity,
                                decoration: const BoxDecoration(
                                  color: Color(0xffEAEFFA),
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      topRight: Radius.circular(10)),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: SizedBox(
                                    width: context.width() / 1.35,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          lang.S.of(context).itemAdded,
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                        Text(
                                          lang.S.of(context).quantity,
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                      ],
                                    ),
                                  ),
                                )),
                            ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: providerData.cartItemList.length,
                                itemBuilder: (context, index) {
                                  // providerData.controllers[index].text = providerData.cartItemList[index].quantity.toString();
                                  // TextEditingController quantityController = TextEditingController();
                                  return Padding(
                                    padding: const EdgeInsets.only(
                                        left: 10, right: 10),
                                    child: ListTile(
                                      // key: providerData.keyForEdit[index],
                                      contentPadding: const EdgeInsets.all(0),
                                      title: Text(providerData
                                          .cartItemList[index].productName
                                          .toString()),
                                      subtitle: GestureDetector(
                                        onTap: () {
                                          showDialog(
                                              context: context,
                                              builder: (_) {
                                                providerData.controllers[index]
                                                    .clear();
                                                AddToCartModel
                                                    tempProductModel =
                                                    providerData
                                                        .cartItemList[index];
                                                GlobalKey<FormState> globalKey =
                                                    GlobalKey<FormState>();
                                                bool validateAndSave() {
                                                  final form =
                                                      globalKey.currentState;
                                                  if (form!.validate()) {
                                                    form.save();
                                                    return true;
                                                  }
                                                  return false;
                                                }

                                                return AlertDialog(
                                                    content: SizedBox(
                                                  child: SingleChildScrollView(
                                                    child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  bottom: 10),
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              Text(
                                                                lang.S
                                                                    .of(context)
                                                                    .addItems,
                                                                style: const TextStyle(
                                                                    fontSize:
                                                                        16,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              ),
                                                              GestureDetector(
                                                                  onTap: () {
                                                                    Navigator
                                                                        .pop(_);
                                                                  },
                                                                  child:
                                                                      const Icon(
                                                                    Icons
                                                                        .cancel,
                                                                    color:
                                                                        kMainColor,
                                                                  )),
                                                            ],
                                                          ),
                                                        ),
                                                        Container(
                                                          height: 1,
                                                          width:
                                                              double.infinity,
                                                          color: Colors.grey,
                                                        ),
                                                        const SizedBox(
                                                            height: 10),
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Column(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text(
                                                                  tempProductModel
                                                                          .productName ??
                                                                      '',
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                          16),
                                                                ),
                                                                Text(
                                                                  tempProductModel
                                                                      .productBrandName,
                                                                  style:
                                                                      const TextStyle(
                                                                    fontSize:
                                                                        16,
                                                                    color: Colors
                                                                        .grey,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            Column(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .end,
                                                              children: [
                                                                Text(
                                                                  lang.S
                                                                      .of(context)
                                                                      .stocks,
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                          16),
                                                                ),
                                                                Text(
                                                                  tempProductModel
                                                                          .stock
                                                                          .toString() ??
                                                                      '',
                                                                  style:
                                                                      const TextStyle(
                                                                    fontSize:
                                                                        16,
                                                                    color: Colors
                                                                        .grey,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(
                                                            height: 20),
                                                        Form(
                                                          key: globalKey,
                                                          child: Column(
                                                            children: [
                                                              AppTextField(
                                                                textFieldType:
                                                                    TextFieldType
                                                                        .PHONE,
                                                                initialValue:
                                                                    tempProductModel
                                                                        .quantity
                                                                        .toString(),
                                                                validator:
                                                                    (value) {
                                                                  if ((num.tryParse(value ??
                                                                              '0') ??
                                                                          0) >
                                                                      (tempProductModel
                                                                              .stock ??
                                                                          0)) {
                                                                    return 'Out Of stock';
                                                                  }
                                                                  return null;
                                                                },
                                                                onChanged:
                                                                    (value) {
                                                                  tempProductModel
                                                                          .quantity =
                                                                      num.parse(
                                                                          value);
                                                                },
                                                                keyboardType:
                                                                    TextInputType
                                                                        .number,
                                                                inputFormatters: [
                                                                  FilteringTextInputFormatter
                                                                      .allow(RegExp(
                                                                          r'^\d*\.?\d{0,2}'))
                                                                ],
                                                                // inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                                                                decoration:
                                                                    InputDecoration(
                                                                  floatingLabelBehavior:
                                                                      FloatingLabelBehavior
                                                                          .always,
                                                                  labelText: lang
                                                                      .S
                                                                      .of(context)
                                                                      .quantity,
                                                                  border:
                                                                      const OutlineInputBorder(),
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                  height: 20),
                                                              AppTextField(
                                                                initialValue:
                                                                    tempProductModel
                                                                        .subTotal
                                                                        .toString(),
                                                                keyboardType:
                                                                    TextInputType
                                                                        .number,
                                                                textFieldType:
                                                                    TextFieldType
                                                                        .NAME,
                                                                onChanged:
                                                                    (value) {
                                                                  tempProductModel
                                                                          .subTotal =
                                                                      value;
                                                                },
                                                                validator:
                                                                    (value) {
                                                                  if ((double.tryParse(value ??
                                                                              '0') ??
                                                                          0) <
                                                                      0.01) {
                                                                    return 'Enter a valid price';
                                                                  }
                                                                  return null;
                                                                },
                                                                inputFormatters: [
                                                                  FilteringTextInputFormatter
                                                                      .allow(RegExp(
                                                                          r'^\d*\.?\d{0,2}'))
                                                                ],
                                                                decoration:
                                                                    InputDecoration(
                                                                  floatingLabelBehavior:
                                                                      FloatingLabelBehavior
                                                                          .always,
                                                                  labelText: lang
                                                                      .S
                                                                      .of(context)
                                                                      .salePrice,
                                                                  border:
                                                                      const OutlineInputBorder(),
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                  height: 20),
                                                            ],
                                                          ),
                                                        ),
                                                        GestureDetector(
                                                          onTap: () {
                                                            if (validateAndSave()) {
                                                              Navigator.pop(
                                                                  context);
                                                            }
                                                          },
                                                          child: Container(
                                                            height: 60,
                                                            width:
                                                                context.width(),
                                                            decoration: const BoxDecoration(
                                                                color:
                                                                    kMainColor,
                                                                borderRadius: BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            30))),
                                                            child: Center(
                                                              child: Text(
                                                                lang.S
                                                                    .of(context)
                                                                    .save,
                                                                style: const TextStyle(
                                                                    fontSize:
                                                                        18,
                                                                    color: Colors
                                                                        .white),
                                                              ),
                                                            ),
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ));
                                              });
                                          // if (products[i].productStock.toInt() <= 0) {
                                          //   EasyLoading.showError('Out of stock');
                                          // } else {
                                          //   if (widget.customerModel!.type.contains('Retailer')) {
                                          //     sentProductPrice = products[i].productSalePrice;
                                          //   } else if (widget.customerModel!.type.contains('Dealer')) {
                                          //     sentProductPrice = products[i].productDealerPrice;
                                          //   } else if (widget.customerModel!.type.contains('Wholesaler')) {
                                          //     sentProductPrice = products[i].productWholeSalePrice;
                                          //   } else if (widget.customerModel!.type.contains('Supplier')) {
                                          //     sentProductPrice = products[i].productPurchasePrice;
                                          //   }
                                          //
                                          //   AddToCartModel cartItem = AddToCartModel(
                                          //     productName: products[i].productName,
                                          //     subTotal: sentProductPrice,
                                          //     productId: products[i].productCode,
                                          //     productBrandName: products[i].brandName,
                                          //     stock: int.parse(products[i].productStock),
                                          //   );
                                          //   providerData.addToCartRiverPod(cartItem);
                                          //
                                          //   EasyLoading.showSuccess('Added To Cart');
                                          //   Navigator.pop(context);
                                          // }
                                        },
                                        child: Text(
                                            '${providerData.cartItemList[index].quantity} X ${myFormat.format(double.tryParse(providerData.cartItemList[index].subTotal.toString()) ?? 0)} = ${myFormat.format(double.parse(providerData.cartItemList[index].subTotal.toString()) * providerData.cartItemList[index].quantity)}'),
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          SizedBox(
                                            width: 100,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      providerData
                                                          .quantityDecrease(
                                                              index);
                                                      providerData
                                                          .controllers[index]
                                                          .clear();
                                                    });
                                                  },
                                                  child: Container(
                                                    height: 20,
                                                    width: 20,
                                                    decoration:
                                                        const BoxDecoration(
                                                      color: kMainColor,
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  10)),
                                                    ),
                                                    child: const Center(
                                                      child: Text(
                                                        '-',
                                                        style: TextStyle(
                                                            fontSize: 14,
                                                            color:
                                                                Colors.white),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 5),
                                                GestureDetector(
                                                  // onTap: () {
                                                  //   setState(() {
                                                  //     show = !show;
                                                  //     textFocus.requestFocus();
                                                  //   });
                                                  // },
                                                  child: Container(
                                                    width: 50,
                                                    child: TextFormField(
                                                      onTapOutside: (event) {
                                                        providerData
                                                            .controllers[index]
                                                            .clear();
                                                      },
                                                      onTap: () {
                                                        providerData
                                                            .controllers[index]
                                                            .clear();
                                                      },
                                                      // key: providerData.keyForEdit[index],
                                                      // key: key,

                                                      focusNode: providerData
                                                          .focus[index],

                                                      // initialValue: providerData.cartItemList[index].quantity.toString(),
                                                      controller: providerData
                                                          .controllers[index],

                                                      textAlign:
                                                          TextAlign.center,
                                                      keyboardType:
                                                          TextInputType.number,
                                                      inputFormatters: [
                                                        FilteringTextInputFormatter
                                                            .allow(RegExp(
                                                                r'^\d*\.?\d{0,2}'))
                                                      ],
                                                      onChanged: (value) {
                                                        num stock = providerData
                                                                .cartItemList[
                                                                    index]
                                                                .stock ??
                                                            1;
                                                        if (value.isEmpty ||
                                                            value == '0' ||
                                                            num.tryParse(
                                                                    value) ==
                                                                null) {
                                                          value = '1';
                                                          providerData
                                                              .controllers[
                                                                  index]
                                                              .clear();
                                                          providerData
                                                              .focus[index]
                                                              .unfocus();
                                                        } else if (stock <
                                                            num.parse(value)) {
                                                          EasyLoading.showError(
                                                              'Out of Stock');
                                                          value = '1';
                                                          providerData
                                                              .controllers[
                                                                  index]
                                                              .clear();
                                                          providerData
                                                              .focus[index]
                                                              .unfocus();
                                                        }

                                                        setState(() {
                                                          providerData
                                                                  .cartItemList[
                                                                      index]
                                                                  .quantity =
                                                              num.parse(value);
                                                        });
                                                        // providerData.controllers[index].clear();
                                                        // providerData.controllers[index].value = TextEditingValue(
                                                        //   text: value,
                                                        //   selection: TextSelection.fromPosition(
                                                        //     TextPosition(offset: value.length),
                                                        //   ),
                                                        // );
                                                        // setState(() {
                                                        //   show = !show;
                                                        // });
                                                      },
                                                      decoration: InputDecoration(
                                                          border:
                                                              InputBorder.none,
                                                          hintText: providerData
                                                                  .focus[index]
                                                                  .hasFocus
                                                              ? null
                                                              : providerData
                                                                  .cartItemList[
                                                                      index]
                                                                  .quantity
                                                                  .toString()),
                                                    ),
                                                  ),
                                                ),
                                                // Text(
                                                //   '${providerData.cartItemList[index].quantity}',
                                                //   style: GoogleFonts.poppins(
                                                //     color: kGreyTextColor,
                                                //     fontSize: 15.0,
                                                //   ),
                                                // ),
                                                const SizedBox(width: 5),
                                                GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      providerData
                                                          .quantityIncrease(
                                                              index);
                                                      providerData
                                                          .controllers[index]
                                                          .clear();
                                                    });
                                                  },
                                                  child: Container(
                                                    height: 20,
                                                    width: 20,
                                                    decoration:
                                                        const BoxDecoration(
                                                      color: kMainColor,
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  10)),
                                                    ),
                                                    child: const Center(
                                                        child: Text(
                                                      '+',
                                                      style: TextStyle(
                                                          fontSize: 14,
                                                          color: Colors.white),
                                                    )),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          GestureDetector(
                                            onTap: () {
                                              providerData.deleteToCart(index);
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.all(4),
                                              color:
                                                  Colors.red.withOpacity(0.1),
                                              child: const Icon(
                                                Icons.delete,
                                                size: 20,
                                                color: Colors.red,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                          ],
                        ).visible(providerData.cartItemList.isNotEmpty),
                      ),
                      const SizedBox(height: 20),

                      ///_______Add_Button__________________________________________________
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SaleProducts(
                                        catName: null,
                                        customerModel: widget.customerModel,
                                      )));
                        },
                        child: Container(
                          height: 50,
                          width: double.infinity,
                          decoration: BoxDecoration(
                              color: kMainColor.withOpacity(0.1),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(10))),
                          child: Center(
                              child: Text(
                            lang.S.of(context).addItems,
                            style: const TextStyle(
                                color: kMainColor, fontSize: 20),
                          )),
                        ),
                      ),
                      const SizedBox(height: 20),

                      ///_____Total______________________________
                      Container(
                        decoration: BoxDecoration(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10)),
                            border: Border.all(
                                color: Colors.grey.shade300, width: 1)),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: const BoxDecoration(
                                  color: Color(0xffEAEFFA),
                                  borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(10),
                                      topLeft: Radius.circular(10))),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    lang.S.of(context).subTotal,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  Text(
                                    myFormat
                                        .format(providerData.getTotalAmount()),
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    lang.S.of(context).discount,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  Row(
                                    children: [
                                      SizedBox(
                                        width: context.width() / 4,
                                        height: 40.0,
                                        child: Center(
                                          child: AppTextField(
                                            inputFormatters: [
                                              FilteringTextInputFormatter.allow(
                                                  RegExp(r'^\d*\.?\d{0,2}'))
                                            ],
                                            controller:
                                                discountPercentageEditingController,
                                            onChanged: (value) {
                                              if (value == '') {
                                                setState(() {
                                                  percentage = 0.0;
                                                });
                                              } else {
                                                if (value.toInt() <= 100) {
                                                  setState(() {
                                                    discountAmount = (value
                                                                .toDouble() /
                                                            100) *
                                                        providerData
                                                            .getTotalAmount()
                                                            .toDouble();
                                                    discountAmountEditingController
                                                            .text =
                                                        discountAmount
                                                            .toStringAsFixed(2);
                                                  });
                                                } else {
                                                  setState(() {
                                                    discountAmount = 0;
                                                    discountAmountEditingController
                                                            .text =
                                                        discountAmount
                                                            .toStringAsFixed(2);
                                                  });
                                                  EasyLoading.showError(
                                                      'Enter a valid Discount');
                                                }
                                              }
                                            },
                                            textAlign: TextAlign.right,
                                            decoration: InputDecoration(
                                              contentPadding:
                                                  const EdgeInsets.only(
                                                      right: 6.0),
                                              hintText: '0',
                                              border: const OutlineInputBorder(
                                                  gapPadding: 0.0,
                                                  borderSide: BorderSide(
                                                      color:
                                                          Color(0xFFff5f00))),
                                              enabledBorder:
                                                  const OutlineInputBorder(
                                                      gapPadding: 0.0,
                                                      borderSide: BorderSide(
                                                          color: Color(
                                                              0xFFff5f00))),
                                              disabledBorder:
                                                  const OutlineInputBorder(
                                                      gapPadding: 0.0,
                                                      borderSide: BorderSide(
                                                          color: Color(
                                                              0xFFff5f00))),
                                              focusedBorder:
                                                  const OutlineInputBorder(
                                                      gapPadding: 0.0,
                                                      borderSide: BorderSide(
                                                          color: Color(
                                                              0xFFff5f00))),
                                              prefixIconConstraints:
                                                  const BoxConstraints(
                                                      maxWidth: 30.0,
                                                      minWidth: 30.0),
                                              prefixIcon: Container(
                                                padding: const EdgeInsets.only(
                                                    top: 8.0, left: 8.0),
                                                height: 40,
                                                decoration: const BoxDecoration(
                                                    color: Color(0xFFff5f00),
                                                    borderRadius: BorderRadius
                                                        .only(
                                                            topLeft:
                                                                Radius.circular(
                                                                    4.0),
                                                            bottomLeft:
                                                                Radius.circular(
                                                                    4.0))),
                                                child: const Text(
                                                  '%',
                                                  style: TextStyle(
                                                      fontSize: 18.0,
                                                      color: Colors.white),
                                                ),
                                              ),
                                            ),
                                            textFieldType: TextFieldType.PHONE,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 4.0,
                                      ),
                                      SizedBox(
                                        width: context.width() / 4,
                                        height: 40.0,
                                        child: Center(
                                          child: AppTextField(
                                            inputFormatters: [
                                              FilteringTextInputFormatter.allow(
                                                  RegExp(r'^\d*\.?\d{0,2}'))
                                            ],
                                            controller:
                                                discountAmountEditingController,
                                            onChanged: (value) {
                                              if (value == '') {
                                                setState(() {
                                                  discountAmount = 0;
                                                });
                                              } else {
                                                if (value.toInt() <=
                                                    providerData
                                                        .getTotalAmount()) {
                                                  setState(() {
                                                    discountAmount =
                                                        double.parse(value);
                                                    discountPercentageEditingController
                                                        .text = ((discountAmount *
                                                                100) /
                                                            providerData
                                                                .getTotalAmount())
                                                        .toStringAsFixed(2);
                                                  });
                                                } else {
                                                  setState(() {
                                                    discountAmount = 0;
                                                    discountPercentageEditingController
                                                        .text = '0';
                                                  });
                                                  EasyLoading.showError(
                                                      'Enter a valid Discount');
                                                }
                                              }
                                            },
                                            textAlign: TextAlign.right,
                                            decoration: InputDecoration(
                                              contentPadding:
                                                  const EdgeInsets.only(
                                                      right: 6.0),
                                              hintText: '0',
                                              border: const OutlineInputBorder(
                                                  gapPadding: 0.0,
                                                  borderSide: BorderSide(
                                                      color: kMainColor)),
                                              enabledBorder:
                                                  const OutlineInputBorder(
                                                      gapPadding: 0.0,
                                                      borderSide: BorderSide(
                                                          color: kMainColor)),
                                              disabledBorder:
                                                  const OutlineInputBorder(
                                                      gapPadding: 0.0,
                                                      borderSide: BorderSide(
                                                          color: kMainColor)),
                                              focusedBorder:
                                                  const OutlineInputBorder(
                                                      gapPadding: 0.0,
                                                      borderSide: BorderSide(
                                                          color: kMainColor)),
                                              prefixIconConstraints:
                                                  const BoxConstraints(
                                                      maxWidth: 30.0,
                                                      minWidth: 30.0),
                                              prefixIcon: Container(
                                                alignment: Alignment.center,
                                                height: 40,
                                                decoration: const BoxDecoration(
                                                    color: kMainColor,
                                                    borderRadius: BorderRadius
                                                        .only(
                                                            topLeft:
                                                                Radius.circular(
                                                                    4.0),
                                                            bottomLeft:
                                                                Radius.circular(
                                                                    4.0))),
                                                child: Text(
                                                  currency,
                                                  style: const TextStyle(
                                                      fontSize: 14.0,
                                                      color: Colors.white),
                                                ),
                                              ),
                                            ),
                                            textFieldType: TextFieldType.PHONE,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: getAllTaxFromCartList(
                                        cart: providerData.cartItemList)
                                    .length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          getAllTaxFromCartList(
                                                  cart: providerData
                                                      .cartItemList)[index]
                                              .name,
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                        Row(
                                          children: [
                                            SizedBox(
                                              width: context.width() / 4,
                                              height: 40.0,
                                              child: Center(
                                                child: AppTextField(
                                                  inputFormatters: [
                                                    FilteringTextInputFormatter
                                                        .allow(RegExp(
                                                            r'^\d*\.?\d{0,2}'))
                                                  ],
                                                  initialValue:
                                                      getAllTaxFromCartList(
                                                              cart: providerData
                                                                  .cartItemList)[index]
                                                          .taxRate
                                                          .toString(),
                                                  readOnly: true,
                                                  textAlign: TextAlign.right,
                                                  decoration: InputDecoration(
                                                    contentPadding:
                                                        const EdgeInsets.only(
                                                            right: 6.0),
                                                    hintText: '0',
                                                    border: const OutlineInputBorder(
                                                        gapPadding: 0.0,
                                                        borderSide: BorderSide(
                                                            color: Color(
                                                                0xFFff5f00))),
                                                    enabledBorder:
                                                        const OutlineInputBorder(
                                                            gapPadding: 0.0,
                                                            borderSide: BorderSide(
                                                                color: Color(
                                                                    0xFFff5f00))),
                                                    disabledBorder:
                                                        const OutlineInputBorder(
                                                            gapPadding: 0.0,
                                                            borderSide: BorderSide(
                                                                color: Color(
                                                                    0xFFff5f00))),
                                                    focusedBorder:
                                                        const OutlineInputBorder(
                                                            gapPadding: 0.0,
                                                            borderSide: BorderSide(
                                                                color: Color(
                                                                    0xFFff5f00))),
                                                    prefixIconConstraints:
                                                        const BoxConstraints(
                                                            maxWidth: 30.0,
                                                            minWidth: 30.0),
                                                    prefixIcon: Container(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 8.0,
                                                              left: 8.0),
                                                      height: 40,
                                                      decoration: const BoxDecoration(
                                                          color:
                                                              Color(0xFFff5f00),
                                                          borderRadius:
                                                              BorderRadius.only(
                                                                  topLeft: Radius
                                                                      .circular(
                                                                          4.0),
                                                                  bottomLeft: Radius
                                                                      .circular(
                                                                          4.0))),
                                                      child: const Text(
                                                        '%',
                                                        style: TextStyle(
                                                            fontSize: 18.0,
                                                            color:
                                                                Colors.white),
                                                      ),
                                                    ),
                                                  ),
                                                  textFieldType:
                                                      TextFieldType.PHONE,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    lang.S.of(context).total,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  Text(
                                    myFormat.format(calculateSubtotal(
                                        total: providerData.getTotalAmount())),
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                            Visibility(
                              visible: widget.customerModel.customerName !=
                                      'Guest' &&
                                  widget.customerModel.phoneNumber != 'Guest' &&
                                  widget.customerModel.type != 'Guest',
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      lang.S.of(context).paidAmount,
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    SizedBox(
                                      width: context.width() / 4,
                                      child: TextField(
                                        keyboardType: TextInputType.number,
                                        onChanged: (value) {
                                          if (value == '') {
                                            setState(() {
                                              paidAmount = 0;
                                            });
                                          } else {
                                            setState(() {
                                              paidAmount = double.parse(value);
                                            });
                                          }
                                        },
                                        textAlign: TextAlign.right,
                                        decoration: const InputDecoration(
                                            hintText: '0'),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    lang.S.of(context).returnAMount,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  Text(
                                    myFormat.format(
                                        calculateReturnAmount(total: subTotal)
                                            .abs()),
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    lang.S.of(context).dueAmount,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  Text(
                                    myFormat.format(
                                        calculateDueAmount(total: subTotal)),
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    lang.S.of(context).sendSmsw,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  Switch(
                                    value: sendSms,
                                    onChanged: (val) {
                                      setState(() {
                                        sendSms = val;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ).visible(false),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        height: 1,
                        width: double.infinity,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                lang.S.of(context).paymentType,
                                style: const TextStyle(
                                    fontSize: 16, color: Colors.black54),
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              const Icon(
                                Icons.wallet,
                                color: Colors.green,
                              )
                            ],
                          ),
                          DropdownButton(
                            value: dropdownValue,
                            icon: const Icon(Icons.keyboard_arrow_down),
                            items: paymentsTypeList.map((String items) {
                              return DropdownMenuItem(
                                value: items,
                                child: Text(items),
                              );
                            }).toList(),
                            onChanged: (newValue) {
                              setState(() {
                                dropdownValue = newValue.toString();
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Container(
                        height: 1,
                        width: double.infinity,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 30),
                      Row(
                        children: [
                          Expanded(
                            child: AppTextField(
                              textFieldType: TextFieldType.NAME,
                              onChanged: (value) {
                                setState(() {});
                              },
                              decoration: InputDecoration(
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always,
                                labelText: lang.S.of(context).describtion,
                                hintText: lang.S.of(context).addNote,
                                border: const OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Container(
                            height: 60,
                            width: 100,
                            decoration: BoxDecoration(
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(10)),
                                color: Colors.grey.shade200),
                            child: Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    FeatherIcons.camera,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    lang.S.of(context).image,
                                    style: const TextStyle(
                                        color: Colors.grey, fontSize: 16),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ).visible(false),
                      Row(
                        children: [
                          Expanded(
                              child: GestureDetector(
                            onTap: () async {
                              const Home().launch(context);
                            },
                            child: Container(
                              height: 60,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(30)),
                              ),
                              child: Center(
                                child: Text(
                                  lang.S.of(context).cacel,
                                  style: const TextStyle(
                                      fontSize: 18, color: Colors.white),
                                ),
                              ),
                            ),
                          )),
                          const SizedBox(width: 10),
                          Expanded(
                            child: GestureDetector(
                              onTap: saleButtonClicked
                                  ? () {}
                                  : () async {
                                      if (providerData
                                          .cartItemList.isNotEmpty) {
                                        if (widget.customerModel.type ==
                                                'Guest' &&
                                            dueAmount > 0) {
                                          EasyLoading.showError(
                                              'Due is not available For Guest');
                                        } else {
                                          final availableSubscription =
                                              await Subscription
                                                  .availableSubscription(
                                                      context: context);
                                          final availableLimit =
                                              await Subscription
                                                  .subscriptionChecker(
                                                      item: 'Sales');
                                          if (!availableSubscription) {
                                            return EasyLoading.showError(
                                                "Please update your subscription. Subscription date is expired.");
                                          } else if (!availableLimit) {
                                            return EasyLoading.showError(
                                                "Please Update Your Subscription. Your Sale limit is expired.");
                                          }
                                          try {
                                            setState(() {
                                              saleButtonClicked = true;
                                            });

                                            dueAmount <= 0
                                                ? transitionModel.isPaid = true
                                                : transitionModel.isPaid =
                                                    false;
                                            dueAmount <= 0
                                                ? transitionModel.dueAmount = 0
                                                : transitionModel.dueAmount =
                                                    dueAmount;
                                            returnAmount < 0
                                                ? transitionModel.returnAmount =
                                                    returnAmount.abs()
                                                : transitionModel.returnAmount =
                                                    0;
                                            transitionModel.discountAmount =
                                                discountAmount;
                                            transitionModel.totalAmount =
                                                subTotal;
                                            transitionModel.vat = 0;
                                            transitionModel.productList =
                                                providerData.cartItemList;
                                            transitionModel.paymentType =
                                                dropdownValue;
                                            isSubUser
                                                ? transitionModel.sellerName =
                                                    subUserTitle
                                                : null;
                                            transitionModel.invoiceNumber =
                                                invoice.toString();

                                            num totalQuantity = 0;
                                            double lossProfit = 0;
                                            double totalPurchasePrice = 0;
                                            double totalSalePrice = 0;
                                            for (var element in transitionModel
                                                .productList!) {
                                              if (element.taxType ==
                                                  'Exclusive') {
                                                double tax =
                                                    calculateAmountFromPercentage(
                                                        element.groupTaxRate
                                                            .toDouble(),
                                                        double.tryParse(element
                                                                .productPurchasePrice
                                                                .toString()) ??
                                                            0);
                                                totalPurchasePrice =
                                                    totalPurchasePrice +
                                                        ((double.parse(element
                                                                    .productPurchasePrice
                                                                    .toString()) +
                                                                tax) *
                                                            element.quantity);
                                              } else {
                                                totalPurchasePrice =
                                                    totalPurchasePrice +
                                                        (double.parse(element
                                                                .productPurchasePrice
                                                                .toString()) *
                                                            element.quantity);
                                              }

                                              totalSalePrice = totalSalePrice +
                                                  (double.parse(element.subTotal
                                                          .toString()) *
                                                      element.quantity);

                                              totalQuantity = totalQuantity +
                                                  element.quantity;
                                            }
                                            lossProfit = ((totalSalePrice -
                                                    totalPurchasePrice
                                                        .toDouble()) -
                                                double.parse(transitionModel
                                                    .discountAmount
                                                    .toString()));

                                            transitionModel.totalQuantity =
                                                totalQuantity;
                                            transitionModel.lossProfit =
                                                lossProfit;
                                            DatabaseReference ref =
                                                FirebaseDatabase.instance.ref(
                                                    "$constUserId/Sales Transition");
                                            ref.keepSynced(true);
                                            ref
                                                .push()
                                                .set(transitionModel.toJson());

                                            ///__________StockMange_________________________________________________-

                                            for (var element
                                                in providerData.cartItemList) {
                                              decreaseStock(element.productId,
                                                  element.quantity);
                                            }

                                            ///_______invoice_Update_____________________________________________
                                            final DatabaseReference
                                                personalInformationRef =
                                                // ignore: deprecated_member_use
                                                FirebaseDatabase.instance
                                                    .ref()
                                                    .child(constUserId)
                                                    .child(
                                                        'Personal Information');
                                            personalInformationRef
                                                .keepSynced(true);
                                            personalInformationRef.update({
                                              'saleInvoiceCounter': invoice + 1
                                            });

                                            ///________Subscription_____________________________________________________

                                            Subscription
                                                .decreaseSubscriptionLimits(
                                                    itemType: 'saleNumber',
                                                    context: context);

                                            ///_________DueUpdate______________________________________________________
                                            getSpecificCustomers(
                                                phoneNumber: widget
                                                    .customerModel.phoneNumber,
                                                due: transitionModel.dueAmount!
                                                    .toInt());

                                            ///________daily_transactionModel_________________________________________________________________________

                                            DailyTransactionModel
                                                dailyTransaction =
                                                DailyTransactionModel(
                                              name:
                                                  transitionModel.customerName,
                                              date:
                                                  transitionModel.purchaseDate,
                                              type: 'Sale',
                                              total: transitionModel
                                                  .totalAmount!
                                                  .toDouble(),
                                              paymentIn: transitionModel
                                                      .totalAmount!
                                                      .toDouble() -
                                                  transitionModel.dueAmount!
                                                      .toDouble(),
                                              paymentOut: 0,
                                              remainingBalance: transitionModel
                                                      .totalAmount!
                                                      .toDouble() -
                                                  transitionModel.dueAmount!
                                                      .toDouble(),
                                              id: transitionModel.invoiceNumber,
                                              saleTransactionModel:
                                                  transitionModel,
                                            );
                                            postDailyTransaction(
                                                dailyTransactionModel:
                                                    dailyTransaction);

                                            ///________Print_______________________________________________________

                                            PrintTransactionModel model =
                                                PrintTransactionModel(
                                                    transitionModel:
                                                        transitionModel,
                                                    personalInformationModel:
                                                        data);
                                            if (isPrintEnable) {
                                              showDialog(
                                                  context: context,
                                                  builder: (_) {
                                                    return Dialog(
                                                      child: SizedBox(
                                                        child: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            const Padding(
                                                              padding: EdgeInsets
                                                                  .only(
                                                                      top: 20,
                                                                      bottom:
                                                                          10),
                                                              child: Text(
                                                                "POS Printer",
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .black,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                                height: 10),
                                                            Container(
                                                                height: 1,
                                                                width: double
                                                                    .infinity,
                                                                color: Colors
                                                                    .grey),
                                                            const SizedBox(
                                                                height: 15),
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(8.0),
                                                              child:
                                                                  PrimaryButton(
                                                                label: "58 mm",
                                                                isDisabled:
                                                                    false,
                                                                onPressed: () => rePrinter(
                                                                    printerData,
                                                                    true,
                                                                    model,
                                                                    providerData,
                                                                    consumerRef,
                                                                    data),
                                                              ),
                                                            ),
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(8.0),
                                                              child:
                                                                  PrimaryButton(
                                                                label: "80 mm",
                                                                isDisabled:
                                                                    false,
                                                                onPressed: () => rePrinter(
                                                                    printerData,
                                                                    false,
                                                                    model,
                                                                    providerData,
                                                                    consumerRef,
                                                                    data),
                                                              ),
                                                            ),
                                                            GestureDetector(
                                                              onTap: () {
                                                                Navigator.pop(
                                                                    context);
                                                              },
                                                              child: Center(
                                                                child: Text(
                                                                  lang.S
                                                                      .of(context)
                                                                      .cacel,
                                                                  style: const TextStyle(
                                                                      color:
                                                                          kMainColor),
                                                                ),
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                                height: 15),
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                                  });
                                            } else {
                                              consumerRef
                                                  .refresh(customerProvider);
                                              consumerRef
                                                  .refresh(productProvider);
                                              consumerRef
                                                  .refresh(salesReportProvider);
                                              consumerRef
                                                  .refresh(transitionProvider);
                                              consumerRef.refresh(
                                                  profileDetailsProvider);
                                              EasyLoading.dismiss();
                                              await Future.delayed(
                                                      const Duration(
                                                          milliseconds: 500))
                                                  .then((value) =>
                                                      SalesInvoiceDetails(
                                                              transitionModel:
                                                                  transitionModel,
                                                              personalInformationModel:
                                                                  data)
                                                          .launch(context));
                                            }
                                          } catch (e) {
                                            setState(() {
                                              saleButtonClicked = false;
                                            });
                                            EasyLoading.showError(e.toString());
                                          }
                                        }
                                      } else {
                                        EasyLoading.showError(
                                            'Add product first');
                                      }
                                    },
                              child: Container(
                                height: 60,
                                decoration: const BoxDecoration(
                                  color: kMainColor,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(30)),
                                ),
                                child: Center(
                                  child: Text(
                                    lang.S.of(context).save,
                                    style: const TextStyle(
                                        fontSize: 18, color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ));
      }, error: (e, stack) {
        return Center(
          child: Text(e.toString()),
        );
      }, loading: () {
        return const Center(child: CircularProgressIndicator());
      });
    });
  }

  showDialogBox() => showCupertinoDialog<String>(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
          title: Text(lang.S.of(context).noConnection),
          content: Text(lang.S.of(context).pleaseCheckYourInternetConnectivity),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                Navigator.pop(context, 'Cancel');
                setState(() => isAlertSet = false);
                isDeviceConnected =
                    await InternetConnectionChecker().hasConnection;
                if (!isDeviceConnected && isAlertSet == false) {
                  showDialogBox();
                  setState(() => isAlertSet = true);
                }
              },
              child: Text(lang.S.of(context).tryAgain),
            ),
          ],
        ),
      );

  void decreaseStock(String productCode, num quantity) async {
    final ref = FirebaseDatabase.instance.ref(constUserId).child('Products');
    ref.keepSynced(true);

    ref.orderByKey().get().then((value) {
      for (var element in value.children) {
        var data = jsonDecode(jsonEncode(element.value));
        if (data['productCode'] == productCode) {
          String? key = element.key;
          num previousStock =
              num.tryParse(element.child('productStock').value.toString()) ?? 0;
          num remainStock = previousStock - quantity;
          ref.child(key!).update({'productStock': '$remainStock'});
        }
      }
    });
  }

  void getSpecificCustomers(
      {required String phoneNumber, required int due}) async {
    final ref = FirebaseDatabase.instance.ref(constUserId).child('Customers');
    ref.keepSynced(true);
    String? key;

    ref.orderByKey().get().then((value) {
      for (var element in value.children) {
        var data = jsonDecode(jsonEncode(element.value));
        if (data['phoneNumber'] == phoneNumber) {
          key = element.key;
          int previousDue = element.child('due').value.toString().toInt();
          int totalDue = previousDue + due;
          ref.child(key!).update({'due': '$totalDue'});
        }
      }
    });
  }

  void rePrinter(
      Printer printerData,
      bool printer58,
      PrintTransactionModel model,
      CartNotifier providerData,
      WidgetRef consumerRef,
      PersonalInformationModel data) async {
    await printerData.getBluetooth();
    if (connected) {
      await printerData.printTicket(
          printTransactionModel: model,
          productList: providerData.cartItemList,
          printer58: printer58);

      consumerRef.refresh(customerProvider);
      consumerRef.refresh(productProvider);
      consumerRef.refresh(salesReportProvider);
      consumerRef.refresh(transitionProvider);
      consumerRef.refresh(profileDetailsProvider);

      EasyLoading.dismiss();
      await Future.delayed(const Duration(milliseconds: 500)).then((value) =>
          SalesInvoiceDetails(
                  transitionModel: transitionModel,
                  personalInformationModel: data)
              .launch(context));
    } else {
      EasyLoading.dismiss();
      EasyLoading.showError('Please Connect The Printer First');

      showDialog(
          context: context,
          builder: (_) {
            return WillPopScope(
              onWillPop: () async => false,
              child: Dialog(
                child: SizedBox(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount:
                            printerData.availableBluetoothDevices.isNotEmpty
                                ? printerData.availableBluetoothDevices.length
                                : 0,
                        itemBuilder: (context, index) {
                          return ListTile(
                            onTap: () async {
                              String select =
                                  printerData.availableBluetoothDevices[index];
                              List list = select.split("#");
                              // String name = list[0];
                              String mac = list[1];
                              bool isConnect =
                                  await printerData.setConnect(mac);
                              if (isConnect) {
                                await printerData.printTicket(
                                    printTransactionModel: model,
                                    productList: transitionModel.productList,
                                    printer58: printer58);

                                consumerRef.refresh(customerProvider);
                                consumerRef.refresh(productProvider);
                                consumerRef.refresh(salesReportProvider);
                                consumerRef.refresh(transitionProvider);
                                consumerRef.refresh(profileDetailsProvider);
                                EasyLoading.dismiss();
                                await Future.delayed(
                                        const Duration(milliseconds: 500))
                                    .then((value) => SalesInvoiceDetails(
                                            transitionModel: transitionModel,
                                            personalInformationModel: data)
                                        .launch(context));
                              }
                            },
                            title: Text(
                                '${printerData.availableBluetoothDevices[index]}'),
                            subtitle: Text(lang.S.of(context).clickToConnect),
                          );
                        },
                      ).visible(
                          printerData.availableBluetoothDevices.isNotEmpty),
                      Padding(
                        padding: const EdgeInsets.only(top: 20, bottom: 10),
                        child: Text(
                          lang.S.of(context).pleaseConnectYourBluttothPrinter,
                          style: const TextStyle(
                              color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        height: 1,
                        width: double.infinity,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 15),
                      GestureDetector(
                        onTap: () async {
                          await Future.delayed(
                                  const Duration(milliseconds: 500))
                              .then((value) {
                            consumerRef.refresh(customerProvider);
                            consumerRef.refresh(productProvider);
                            consumerRef.refresh(salesReportProvider);
                            consumerRef.refresh(transitionProvider);
                            consumerRef.refresh(profileDetailsProvider);
                            SalesInvoiceDetails(
                                    transitionModel: transitionModel,
                                    personalInformationModel: data)
                                .launch(context);
                          });
                        },
                        child: Center(
                          child: Text(
                            lang.S.of(context).cacel,
                            style: const TextStyle(color: kMainColor),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                    ],
                  ),
                ),
              ),
            );
          });
    }
  }
}
