import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mobile_pos/Provider/due_transaction_provider.dart';
import 'package:mobile_pos/Provider/profile_provider.dart';
import 'package:mobile_pos/Screens/sale%20return/sale%20return%20provider%20&%20repo/sale_return_provider_&repo.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import 'package:mobile_pos/model/transition_model.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:restart_app/restart_app.dart';

import '../../Provider/customer_provider.dart';
import '../../Provider/product_provider.dart';
import '../../Provider/seles_report_provider.dart';
import '../../Provider/transactions_provider.dart';
import '../../const_commas.dart';
import '../../constant.dart';
import '../../currency.dart';
import '../../model/DailyTransactionModel.dart';
import '../../model/add_to_cart_model.dart';

// ignore: must_be_immutable
class SalesReturn extends StatefulWidget {
  SalesReturn({super.key, required this.saleTransactionModel});

  final SalesTransitionModel saleTransactionModel;

  @override
  State<SalesReturn> createState() => _SalesReturnState();
}

class _SalesReturnState extends State<SalesReturn> {
  double calculateAmountFromPercentage(double percentage, double price) {
    return (percentage * price) / 100;
  }

  num getTotalReturnAmount() {
    num returnAmount = 0;
    for (var element in returnList) {
      if (int.parse(element.quantity.toString()) > 0) {
        returnAmount += int.parse(element.quantity.toString()) *
            (num.tryParse(element.subTotal.toString()) ?? 0);
      }
    }
    return returnAmount;
  }

  Future<void> saleReturn(
      {required SalesTransitionModel salesModel,
      required SalesTransitionModel orginal,
      required WidgetRef consumerRef,
      required BuildContext context}) async {
    try {
      EasyLoading.show(status: 'Loading...', dismissOnTap: false);

      ///_________Push_on_Sale_return_dataBase____________________________________________________________________________
      DatabaseReference ref =
          FirebaseDatabase.instance.ref("${await getUserID()}/Sales Return");
      await ref.push().set(salesModel.toJson());

      ///__________StockMange_________________________________________________________________________________
      final stockRef =
          FirebaseDatabase.instance.ref('${await getUserID()}/Products/');

      for (var element in salesModel.productList!) {
        var data = await stockRef
            .orderByChild('productCode')
            .equalTo(element.productId)
            .once();
        final data2 = jsonDecode(jsonEncode(data.snapshot.value));
        String productPath = data.snapshot.value.toString().substring(1, 21);

        var data1 = await stockRef.child('$productPath/productStock').once();
        num stock = num.parse(data1.snapshot.value.toString());
        num remainStock = stock + int.parse(element.quantity.toString());

        stockRef.child(productPath).update({'productStock': '$remainStock'});

        ///________Update_Serial_Number____________________________________________________

        if (element.serialNumber != null && element.serialNumber!.isNotEmpty) {
          var productOldSerialList =
              data2[productPath]['serialNumber'] + element.serialNumber;

          // List<dynamic> result = productOldSerialList.where((item) => !element.serialNumber!.contains(item)).toList();
          stockRef.child(productPath).update({
            'serialNumber': productOldSerialList.map((e) => e).toList(),
          });
        }
      }

      ///________daily_transactionModel_________________________________________________________________________

      DailyTransactionModel dailyTransaction = DailyTransactionModel(
        name: salesModel.customerName,
        date: salesModel.purchaseDate,
        type: 'Sale Return',
        total: salesModel.totalAmount!.toDouble(),
        paymentIn: 0,
        paymentOut: ((orginal.totalAmount ?? 0) - (orginal.dueAmount ?? 0)) >
                (salesModel.totalAmount ?? 0)
            ? (salesModel.totalAmount ?? 0)
            : ((orginal.totalAmount ?? 0) - (orginal.dueAmount ?? 0)),
        remainingBalance:
            ((orginal.totalAmount ?? 0) - (orginal.dueAmount ?? 0)) >
                    (salesModel.totalAmount ?? 0)
                ? (salesModel.totalAmount ?? 0)
                : ((orginal.totalAmount ?? 0) - (orginal.dueAmount ?? 0)),
        id: salesModel.invoiceNumber,
        saleTransactionModel: salesModel,
      );
      print('Done');
      postDailyTransaction(dailyTransactionModel: dailyTransaction);

      ///_________DueUpdate___________________________________________________________________________________
      if (salesModel.customerName != 'Guest' && (orginal.dueAmount ?? 0) > 0) {
        final dueUpdateRef =
            FirebaseDatabase.instance.ref('${await getUserID()}/Customers/');
        String? key;

        await FirebaseDatabase.instance
            .ref(await getUserID())
            .child('Customers')
            .orderByKey()
            .get()
            .then((value) {
          for (var element in value.children) {
            var data = jsonDecode(jsonEncode(element.value));
            if (data['phoneNumber'] == salesModel.customerPhone) {
              key = element.key;
            }
          }
        });
        var data1 = await dueUpdateRef.child('$key/due').once();
        int previousDue = data1.snapshot.value.toString().toInt();

        int dueNow = int.parse(orginal.dueAmount != null
                ? orginal.dueAmount.toString()
                : '0') -
            int.parse(salesModel.totalAmount != null
                ? salesModel.totalAmount.toString()
                : '0');

        int totalDue = int.parse(dueNow.toString()) < 0
            ? 0
            : int.parse(previousDue.toString()) -
                int.parse(salesModel.totalAmount == null
                    ? '0'
                    : salesModel.totalAmount.toString());

        dueUpdateRef.child(key!).update({'due': '$totalDue'});
      }
      consumerRef.refresh(customerProvider);
      consumerRef.refresh(saleReturnProvider);
      consumerRef.refresh(productProvider);
      consumerRef.refresh(salesReportProvider);
      consumerRef.refresh(transitionProvider);
      consumerRef.refresh(profileDetailsProvider);
      consumerRef.refresh(purchaseTransitionProvider);
      consumerRef.refresh(dueTransactionProvider);
      EasyLoading.showSuccess('Successfully Done');

      // ignore: use_build_context_synchronously
      Navigator.pop(context);
    } catch (e) {
      EasyLoading.dismiss();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  ScrollController mainScroll = ScrollController();
  String searchItem = '';

  DateTime selectedDueDate = DateTime.now();

  Future<void> _selectedDueDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDueDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedDueDate) {
      setState(() {
        selectedDueDate = picked;
      });
    }
  }

  List<AddToCartModel> returnList = [];

  void checkCurrentUserAndRestartApp() {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user?.uid == null) {
      Restart.restartApp();
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkCurrentUserAndRestartApp();

    for (var element in widget.saleTransactionModel.productList!) {
      AddToCartModel p = AddToCartModel(
        warehouseName: element.warehouseName,
        warehouseId: element.warehouseId,
        productPurchasePrice: element.productPurchasePrice,
        productImage: element.productImage,
        itemCartIndex: element.itemCartIndex,
        productBrandName: element.productBrandName,
        productDetails: element.productDetails,
        productId: element.productId,
        productName: element.productName,
        quantity: 0,
        serialNumber: element.serialNumber,
        stock: element.quantity,
        subTotal: element.subTotal,
        uniqueCheck: element.uniqueCheck,
        unitPrice: element.unitPrice,
        uuid: element.uuid,
        subTaxes: element.subTaxes,
        excTax: element.excTax,
        groupTaxName: element.groupTaxName,
        groupTaxRate: element.groupTaxRate,
        incTax: element.incTax,
        margin: element.margin,
        taxType: element.taxType,
      );

      returnList.add(p);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, consumerRef, __) {
      return Scaffold(
        backgroundColor: kMainColor,
        appBar: AppBar(
          backgroundColor: kMainColor,
          title: Text(
            'Sales Return',
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
          decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  topRight: Radius.circular(30), topLeft: Radius.circular(30))),
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
                          initialValue:
                              widget.saleTransactionModel.invoiceNumber,
                          decoration: InputDecoration(
                            floatingLabelBehavior: FloatingLabelBehavior.always,
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
                          initialValue:
                              DateFormat.yMMMd().format(DateTime.parse(
                            widget.saleTransactionModel.purchaseDate,
                          )),
                          decoration: InputDecoration(
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            labelText: lang.S.of(context).date,
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  AppTextField(
                    textFieldType: TextFieldType.NAME,
                    readOnly: true,
                    initialValue:
                        widget.saleTransactionModel.customerName.isNotEmpty
                            ? widget.saleTransactionModel.customerName
                            : widget.saleTransactionModel.customerPhone,
                    decoration: InputDecoration(
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      labelText: lang.S.of(context).customerName,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),

                  ///_______Added_ItemS__________________________________________________
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                      ),
                      border:
                          Border.all(width: 1, color: const Color(0xffEAEFFA)),
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
                              topRight: Radius.circular(10),
                            ),
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
                          ),
                        ),
                        ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: returnList.length,
                            itemBuilder: (context, index) {
                              int i = 0;
                              TextEditingController quantityController =
                                  TextEditingController(
                                      text: returnList[index]
                                          .quantity
                                          .toString());
                              return Padding(
                                padding:
                                    const EdgeInsets.only(left: 10, right: 10),
                                child: ListTile(
                                  visualDensity: const VisualDensity(
                                      horizontal: -4, vertical: -4),
                                  contentPadding: const EdgeInsets.all(0),
                                  title: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      SizedBox(
                                        width: 280,
                                        child: Text(
                                          returnList[index]
                                              .productName
                                              .toString(),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      // const SizedBox(width: 5.0),
                                      // const Text('Return QTY'),
                                    ],
                                  ),
                                  subtitle: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '${returnList[index].stock.toString()} X ${returnList[index].subTotal} = ${myFormat.format(double.tryParse((double.parse(returnList[index].subTotal.toString()) * ((returnList[index].stock ?? 0) - returnList[index].quantity)).toStringAsFixed(2)) ?? 0)}',
                                      ),
                                      Row(
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
                                                      int.parse(returnList[
                                                                      index]
                                                                  .quantity) >
                                                              0
                                                          ? returnList[index]
                                                              .quantity--
                                                          : returnList[index]
                                                              .quantity = 0;
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
                                                SizedBox(
                                                  width: 50,
                                                  child: TextFormField(
                                                    // initialValue: quantityController.text,
                                                    controller:
                                                        quantityController,
                                                    textAlign: TextAlign.center,
                                                    keyboardType:
                                                        TextInputType.phone,
                                                    onChanged: (value) {
                                                      if ((returnList[index]
                                                                  .stock ??
                                                              0) <
                                                          (num.tryParse(
                                                                  value) ??
                                                              0)) {
                                                        EasyLoading.showError(
                                                            'Out of Stock');
                                                        quantityController
                                                            .clear();
                                                      } else if (value == '') {
                                                        returnList[index]
                                                            .quantity = 1;
                                                      } else if (value == '0') {
                                                        returnList[index]
                                                            .quantity = 1;
                                                      } else {
                                                        returnList[index]
                                                                .quantity =
                                                            (num.tryParse(
                                                                    value) ??
                                                                0);
                                                      }
                                                    },
                                                    onFieldSubmitted: (value) {
                                                      if (value == '') {
                                                        setState(() {
                                                          returnList[index]
                                                              .quantity = 1;
                                                        });
                                                      } else {
                                                        setState(() {
                                                          returnList[index]
                                                                  .quantity =
                                                              (num.tryParse(
                                                                      value) ??
                                                                  0);
                                                        });
                                                      }
                                                    },
                                                    decoration:
                                                        const InputDecoration(
                                                            border: InputBorder
                                                                .none),
                                                  ),
                                                ),
                                                const SizedBox(width: 5),
                                                GestureDetector(
                                                  onTap: () {
                                                    if (returnList[index]
                                                            .quantity <
                                                        (returnList[index]
                                                                .stock ??
                                                            0)) {
                                                      setState(() {
                                                        returnList[index]
                                                            .quantity += 1;
                                                        toast(returnList[index]
                                                            .quantity
                                                            .toString());
                                                      });
                                                    } else {
                                                      EasyLoading.showError(
                                                          'Out of Stock');
                                                    }
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
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                      ],
                    ).visible(returnList.isNotEmpty),
                  ),
                  const SizedBox(height: 20),

                  ///______________________Total_Return____________________________________
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                      border: Border.all(color: Colors.grey.shade300, width: 1),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                            color: Color(0xffEAEFFA),
                            borderRadius: BorderRadius.all(
                              Radius.circular(10.0),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total return amount:',
                                style: TextStyle(fontSize: 16),
                              ),
                              Text(
                                '$currency ${myFormat.format(getTotalReturnAmount())}',
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: const BoxDecoration(color: Colors.white),
          child: Row(
            children: [
              Expanded(
                  child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: const BorderRadius.all(Radius.circular(30)),
                  ),
                  child: Center(
                    child: Text(
                      lang.S.of(context).cacel,
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              )),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    returnList
                        .removeWhere((element) => (element.quantity) <= 0);
                    SalesTransitionModel editedTransitionModel =
                        widget.saleTransactionModel;
                    (num.tryParse(getTotalReturnAmount().toString()) ?? 0) >
                            (widget.saleTransactionModel.dueAmount ?? 0)
                        ? editedTransitionModel.isPaid = true
                        : editedTransitionModel.isPaid = false;
                    if ((widget.saleTransactionModel.dueAmount ?? 0) > 0) {
                      (num.tryParse(getTotalReturnAmount().toString()) ?? 0) >=
                              (widget.saleTransactionModel.dueAmount ?? 0)
                          ? editedTransitionModel.dueAmount = 0
                          : editedTransitionModel.dueAmount =
                              (widget.saleTransactionModel.dueAmount ?? 0) -
                                  (num.tryParse(
                                          getTotalReturnAmount().toString()) ??
                                      0);
                    }
                    List<AddToCartModel> newProductList = [];
                    List<AddToCartModel> oldProduct =
                        widget.saleTransactionModel.productList!;

                    for (var p in widget.saleTransactionModel.productList!) {
                      if (returnList
                          .any((element) => element.productId == p.productId)) {
                        int index = returnList.indexWhere(
                            (element) => element.productId == p.productId);
                        p.quantity = p.quantity - returnList[index].quantity;
                      }

                      if (p.quantity > 0) newProductList.add(p);
                    }

                    editedTransitionModel.productList = newProductList;
                    editedTransitionModel.totalAmount = (editedTransitionModel
                                .totalAmount ??
                            0) -
                        (double.tryParse(getTotalReturnAmount().toString()) ??
                            0);

                    // myTransitionModel.totalAmount = widget.newTransitionModel.totalAmount!.toDouble();
                    ///________________updateInvoice___________________________________________________________OK
                    String? key;
                    final userId = await getUserID();
                    await FirebaseDatabase.instance
                        .ref(userId)
                        .child('Sales Transition')
                        .orderByKey()
                        .get()
                        .then((value) {
                      for (var element in value.children) {
                        final t = SalesTransitionModel.fromJson(
                            jsonDecode(jsonEncode(element.value)));
                        if (editedTransitionModel.invoiceNumber ==
                            t.invoiceNumber) {
                          key = element.key;
                        }
                      }
                    });

                    if (newProductList.isEmpty) {
                      await FirebaseDatabase.instance
                          .ref(userId)
                          .child('Sales Transition')
                          .child(key!)
                          .remove();
                    } else {
                      num totalQuantity = 0;
                      double lossProfit = 0;
                      double totalPurchasePrice = 0;
                      double totalSalePrice = 0;
                      for (var element in newProductList) {
                        if (element.taxType == 'Exclusive') {
                          double tax = calculateAmountFromPercentage(
                              element.groupTaxRate.toDouble(),
                              double.tryParse(element.productPurchasePrice
                                      .toString()) ??
                                  0);
                          totalPurchasePrice = totalPurchasePrice +
                              ((double.parse(element.productPurchasePrice
                                          .toString()) +
                                      tax) *
                                  double.parse(element.quantity.toString()));
                        } else {
                          totalPurchasePrice = totalPurchasePrice +
                              (double.parse(
                                      element.productPurchasePrice.toString()) *
                                  int.parse(element.quantity.toString()));
                        }

                        totalSalePrice = totalSalePrice +
                            (double.parse(element.subTotal.toString()) *
                                int.parse(element.quantity.toString()));

                        totalQuantity = totalQuantity +
                            int.parse(element.quantity.toString());
                      }
                      lossProfit = ((totalSalePrice -
                              totalPurchasePrice.toDouble()) -
                          double.parse(
                              editedTransitionModel.discountAmount.toString()));
                      editedTransitionModel.totalQuantity = totalQuantity;
                      editedTransitionModel.lossProfit = lossProfit;

                      ///__________total LossProfit & quantity________________________________________________________________
                      // final postEditedTransitionModel = ShowEditPaymentPopUp.checkLossProfit(transitionModel: editedTransitionModel);
                      await FirebaseDatabase.instance
                          .ref(userId)
                          .child('Sales Transition')
                          .child(key!)
                          .update(editedTransitionModel.toJson());
                    }
                    SalesTransitionModel invoice = SalesTransitionModel(
                      customerName: widget.saleTransactionModel.customerName,
                      customerType: widget.saleTransactionModel.customerType,
                      customerPhone: widget.saleTransactionModel.customerPhone,
                      invoiceNumber: widget.saleTransactionModel.invoiceNumber,
                      purchaseDate: widget.saleTransactionModel.purchaseDate,
                      customerGst: widget.saleTransactionModel.customerGst,
                      customerAddress:
                          widget.saleTransactionModel.customerAddress,
                      customerImage: widget.saleTransactionModel.customerImage,
                      productList: returnList,
                      totalAmount:
                          double.tryParse(getTotalReturnAmount().toString()),
                      discountAmount: 0,
                      dueAmount: 0,
                      isPaid: false,
                      lossProfit: 0,
                      paymentType: 'Cash',
                      returnAmount: 0,
                      serviceCharge: 0,
                      vat: 0,
                      totalQuantity: 0,
                    );

                    await saleReturn(
                        salesModel: invoice,
                        orginal: widget.saleTransactionModel,
                        consumerRef: consumerRef,
                        context: context);
                  },
                  child: Container(
                    height: 60,
                    decoration: const BoxDecoration(
                      color: kMainColor,
                      borderRadius: BorderRadius.all(Radius.circular(30)),
                    ),
                    child: const Center(
                      child: Text(
                        'Confirm return',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
