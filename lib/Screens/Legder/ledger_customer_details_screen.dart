import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mobile_pos/Screens/Customers/Model/customer_model.dart';
import 'package:mobile_pos/Widget/primary_button_widget.dart';
import 'package:mobile_pos/const_commas.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import 'package:mobile_pos/model/personal_information_model.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../Provider/print_purchase_provider.dart';
import '../../Provider/printer_provider.dart';
import '../../Provider/profile_provider.dart';
import '../../Provider/transactions_provider.dart';
import '../../constant.dart';
import '../../currency.dart';
import '../../model/print_transaction_model.dart';
import '../../model/transition_model.dart';
import '../invoice_details/purchase_invoice_details.dart';
import '../invoice_details/sales_invoice_details_screen.dart';

class LedgerCustomerDetailsScreen extends StatefulWidget {
  const LedgerCustomerDetailsScreen({super.key, required this.customerModel});

  final CustomerModel customerModel;

  @override
  State<LedgerCustomerDetailsScreen> createState() => _LedgerCustomerDetailsScreenState();
}

class _LedgerCustomerDetailsScreenState extends State<LedgerCustomerDetailsScreen> {
  double totalSale = 0;
  TextEditingController fromDateTextEditingController = TextEditingController(text: DateFormat.yMMMd().format(DateTime(2021)));
  TextEditingController toDateTextEditingController = TextEditingController(text: DateFormat.yMMMd().format(DateTime.now()));

  DateTime fromDate = DateTime(2021);
  DateTime toDate = DateTime.now();

  Future<void> getTotalSale() async {
    List<SalesTransitionModel> transitionList = [];
    await FirebaseDatabase.instance.ref(constUserId).child('Sales Transition').orderByKey().get().then((value) {
      for (var element in value.children) {
        transitionList.add(SalesTransitionModel.fromJson(jsonDecode(jsonEncode(element.value))));
      }
    });
    for (var element in transitionList) {
      if (element.customerPhone == widget.customerModel.phoneNumber) {
        totalSale = totalSale + element.totalAmount!.toInt();
      }
    }
  }

  Future<void> getTotalPurchase() async {
    List<dynamic> transitionList = [];
    await FirebaseDatabase.instance.ref(constUserId).child('Purchase Transition').orderByKey().get().then((value) {
      for (var element in value.children) {
        transitionList.add(PurchaseTransactionModel.fromJson(jsonDecode(jsonEncode(element.value))));
      }
    });

    for (var element in transitionList) {
      if (element.customerPhone == widget.customerModel.phoneNumber) {
        totalSale = totalSale + element.totalAmount!.toInt();
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getTotalSale();
    getTotalPurchase();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, __) {
      final providerData = ref.watch(transitionProvider);
      final purchaseProviderData = ref.watch(purchaseTransitionProvider);
      final personalData = ref.watch(profileDetailsProvider);
      final printerData = ref.watch(printerProviderNotifier);
      final purchasePrinterData = ref.watch(printerPurchaseProviderNotifier);
      return Scaffold(
          backgroundColor: kMainColor,
          appBar: AppBar(
            title: Text(
              widget.customerModel.customerName,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 20.0,
              ),
            ),
            iconTheme: const IconThemeData(color: Colors.white),
            centerTitle: true,
            backgroundColor: kMainColor,
            elevation: 0.0,
          ),
          body: widget.customerModel.type != 'Supplier'
              ? Container(
                  alignment: Alignment.topCenter,
                  decoration:
                      const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(topRight: Radius.circular(30), topLeft: Radius.circular(30))),
                  child: providerData.when(data: (transaction) {
                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: AppTextField(
                                    textFieldType: TextFieldType.NAME,
                                    readOnly: true,
                                    controller: fromDateTextEditingController,
                                    decoration: InputDecoration(
                                      floatingLabelBehavior: FloatingLabelBehavior.always,
                                      labelText: lang.S.of(context).formDate,
                                      border: const OutlineInputBorder(),
                                      suffixIcon: IconButton(
                                        onPressed: () async {
                                          final DateTime? picked = await showDatePicker(
                                            initialDate: DateTime.now(),
                                            firstDate: DateTime(2015, 8),
                                            lastDate: DateTime(2101),
                                            context: context,
                                          );
                                          setState(() {
                                            fromDateTextEditingController.text = DateFormat.yMMMd().format(picked ?? DateTime.now());
                                            fromDate = picked!;
                                          });
                                        },
                                        icon: const Icon(FeatherIcons.calendar),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: AppTextField(
                                    textFieldType: TextFieldType.NAME,
                                    readOnly: true,
                                    controller: toDateTextEditingController,
                                    decoration: InputDecoration(
                                      floatingLabelBehavior: FloatingLabelBehavior.always,
                                      labelText: lang.S.of(context).toDate,
                                      border: const OutlineInputBorder(),
                                      suffixIcon: IconButton(
                                        onPressed: () async {
                                          final DateTime? picked = await showDatePicker(
                                            initialDate: toDate,
                                            firstDate: DateTime(2015, 8),
                                            lastDate: DateTime(2101),
                                            context: context,
                                          );
                                          setState(() {
                                            toDateTextEditingController.text = DateFormat.yMMMd().format(picked ?? DateTime.now());
                                            picked!.isToday ? toDate = DateTime.now() : toDate = picked;
                                          });
                                        },
                                        icon: const Icon(FeatherIcons.calendar),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 20,right: 20.0),
                            child: Container(
                              height: 120,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.all(Radius.circular(15)),
                                color: kMainColor.withOpacity(0.08),
                              ),
                              child: Center(
                                child: ListTile(
                                  leading: Container(
                                    height: 40,
                                    width: 40,
                                    decoration: const BoxDecoration(
                                      borderRadius: BorderRadius.all(Radius.circular(80)),
                                      image: DecorationImage(
                                        image: AssetImage(
                                          'images/ledger_total_sale.png',
                                        ),
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    "$currency${myFormat.format(totalSale)}",
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                                    Container(
                                      height: 40,
                                      width: 40,
                                      decoration: BoxDecoration(borderRadius: const BorderRadius.all(Radius.circular(80)), color: kMainColor.withOpacity(0.2)),
                                      child: const Icon(
                                        Icons.picture_as_pdf_outlined,
                                        color: kMainColor,
                                      ),
                                    ),
                                    const SizedBox(width: 7),
                                    Container(
                                      height: 40,
                                      width: 40,
                                      decoration: BoxDecoration(
                                        borderRadius: const BorderRadius.all(Radius.circular(80)),
                                        color: Colors.green.withOpacity(0.2),
                                      ),
                                      child: const Icon(
                                        Icons.print,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(width: 7),
                                    Container(
                                      height: 40,
                                      width: 40,
                                      decoration:
                                          BoxDecoration(borderRadius: const BorderRadius.all(Radius.circular(80)), color: Colors.orange.withOpacity(0.2)),
                                      child: const Icon(
                                        Icons.notifications_none,
                                        color: Colors.orange,
                                      ),
                                    ),
                                  ]).visible(false),
                                  subtitle:  Text(lang.S.of(context).totalSale),
                                ),
                              ),
                            ),
                          ),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: transaction.length,
                            itemBuilder: (context, index) {
                              final reTransaction = transaction.reversed.toList();

                              return reTransaction[index].customerPhone == widget.customerModel.phoneNumber &&
                                      (fromDate.isBefore(DateTime.parse(reTransaction[index].purchaseDate)) ||
                                          DateTime.parse(reTransaction[index].purchaseDate).isAtSameMomentAs(fromDate)) &&
                                      (toDate.isAfter(DateTime.parse(reTransaction[index].purchaseDate)) ||
                                          DateTime.parse(reTransaction[index].purchaseDate).isAtSameMomentAs(toDate))
                                  ? GestureDetector(
                                      onTap: () {
                                        SalesInvoiceDetails(
                                          personalInformationModel: personalData.value!,
                                          transitionModel: reTransaction[index],
                                        ).launch(context);
                                      },
                                      child: Column(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(20),
                                            width: context.width(),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text(
                                                      "Total Products : ${reTransaction[index].productList!.length.toString()}",
                                                      style: const TextStyle(fontSize: 16),
                                                    ),
                                                    Text(
                                                      '#${reTransaction[index].invoiceNumber}',
                                                      style: const TextStyle(color: Colors.black),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 10),
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Container(
                                                      padding: const EdgeInsets.all(8),
                                                      decoration: BoxDecoration(
                                                          color: reTransaction[index].dueAmount! <= 0
                                                              ? const Color(0xff0dbf7d).withOpacity(0.1)
                                                              : const Color(0xFFED1A3B).withOpacity(0.1),
                                                          borderRadius: const BorderRadius.all(Radius.circular(10))),
                                                      child: Text(
                                                        reTransaction[index].dueAmount! <= 0 ? 'Paid' : 'Unpaid',
                                                        style: TextStyle(
                                                            color: reTransaction[index].dueAmount! <= 0 ? const Color(0xff0dbf7d) : const Color(0xFFED1A3B)),
                                                      ),
                                                    ),
                                                    Column(
                                                      crossAxisAlignment: CrossAxisAlignment.end,
                                                      children: [
                                                        Text(
                                                          DateFormat.yMMMd().format(DateTime.parse(reTransaction[index].purchaseDate)),
                                                          style: const TextStyle(color: Colors.grey),
                                                        ),
                                                        const SizedBox(height: 5),
                                                        Text(
                                                          DateFormat.jm().format(DateTime.parse(reTransaction[index].purchaseDate)),
                                                          style: const TextStyle(color: Colors.grey),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                personalData.when(data: (data) {
                                                  return Column(
                                                    children: [
                                                      const SizedBox(height: 10),
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              Text(
                                                                'Total : $currency ${myFormat.format(reTransaction[index].totalAmount)}',
                                                                style: const TextStyle(color: Colors.grey),
                                                              ),
                                                              const SizedBox(height: 3),
                                                              Text(
                                                                'Paid : $currency ${myFormat.format(reTransaction[index].totalAmount!.toDouble() - reTransaction[index].dueAmount!.toDouble())}',
                                                                style: const TextStyle(color: Colors.grey),
                                                              ),
                                                              const SizedBox(height: 3),
                                                              Text(
                                                                'Due: $currency ${myFormat.format(reTransaction[index].dueAmount)}',
                                                                style: const TextStyle(fontSize: 16),
                                                              ).visible(reTransaction[index].dueAmount!.toInt() != 0),
                                                            ],
                                                          ),
                                                          Row(
                                                            children: [
                                                              IconButton(
                                                                  onPressed: () async {

                                                                    showDialog(
                                                                        context: context,
                                                                        builder: (_) {
                                                                          return Dialog(
                                                                            child: SizedBox(
                                                                              child: Column(
                                                                                mainAxisSize: MainAxisSize.min,
                                                                                children: [
                                                                                  const Padding(
                                                                                    padding: EdgeInsets.only(top: 20, bottom: 10),
                                                                                    child: Text(
                                                                                      "POS Printer",
                                                                                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                                                                                    ),
                                                                                  ),
                                                                                  const SizedBox(height: 10),
                                                                                  Container(height: 1, width: double.infinity, color: Colors.grey),
                                                                                  const SizedBox(height: 15),
                                                                                  Padding(
                                                                                    padding: const EdgeInsets.all(8.0),
                                                                                    child: PrimaryButton(
                                                                                      label: "58 mm",
                                                                                      isDisabled: false,
                                                                                      onPressed: () {
                                                                                        rePrinter(printerData, data, reTransaction[index], true);
                                                                                      },
                                                                                    ),
                                                                                  ),
                                                                                  Padding(
                                                                                    padding: const EdgeInsets.all(8.0),
                                                                                    child: PrimaryButton(
                                                                                      label: "80 mm",
                                                                                      isDisabled: false,
                                                                                      onPressed: () {
                                                                                        rePrinter(printerData, data, reTransaction[index], false);
                                                                                      },
                                                                                    ),
                                                                                  ),
                                                                                  GestureDetector(
                                                                                    onTap: () {
                                                                                      Navigator.pop(context);
                                                                                    },
                                                                                    child: Center(
                                                                                      child: Padding(
                                                                                        padding: const EdgeInsets.all(8.0),
                                                                                        child: Text(
                                                                                          lang.S.of(context).cacel,
                                                                                          style: const TextStyle(color: kMainColor),
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                  const SizedBox(height: 15),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                          );
                                                                        });

                                                                  },
                                                                  icon: const Icon(
                                                                    FeatherIcons.printer,
                                                                    color: Colors.grey,
                                                                  )),
                                                              IconButton(
                                                                  onPressed: () {},
                                                                  icon: const Icon(
                                                                    FeatherIcons.share,
                                                                    color: Colors.grey,
                                                                  )).visible(false),
                                                            ],
                                                          )
                                                        ],
                                                      ),
                                                    ],
                                                  );
                                                }, error: (e, stack) {
                                                  return Text(e.toString());
                                                }, loading: () {
                                                  return const Text('Loading');
                                                }),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            height: 0.5,
                                            width: context.width(),
                                            color: Colors.grey,
                                          )
                                        ],
                                      ),
                                    )
                                  : Container();
                            },
                          ),
                          Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(20),
                                width: context.width(),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children:  [
                                        Text(
                                          lang.S.of(context).openingBalance,
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                              color: widget.customerModel.remainedBalance.toInt() <= 0
                                                  ? const Color(0xff0dbf7d).withOpacity(0.1)
                                                  : const Color(0xFFED1A3B).withOpacity(0.1),
                                              borderRadius: const BorderRadius.all(Radius.circular(10))),
                                          child: Text(
                                            widget.customerModel.remainedBalance.toInt() <= 0 ? 'Paid' : 'Unpaid',
                                            style: TextStyle(
                                                color: widget.customerModel.remainedBalance.toInt() <= 0 ? const Color(0xff0dbf7d) : const Color(0xFFED1A3B)),
                                          ),
                                        ),

                                      ],
                                    ),
                                    Column(
                                      children: [
                                        const SizedBox(height: 10),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Total : $currency ${myFormat.format(int.tryParse(widget.customerModel.openingBalance.toString())??0)}',
                                                  style: const TextStyle(color: Colors.grey),
                                                ),
                                                const SizedBox(height: 3),
                                                Text(
                                                  'Paid : $currency ${myFormat.format(int.tryParse('${widget.customerModel.openingBalance.toInt() - widget.customerModel.remainedBalance.toInt()}')??0)}',
                                                  style: const TextStyle(color: Colors.grey),
                                                ),
                                                const SizedBox(height: 3),
                                                Text(
                                                  'Due: $currency ${myFormat.format(int.tryParse(widget.customerModel.remainedBalance.toString())??0)}',
                                                  style: const TextStyle(fontSize: 16),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                height: 0.5,
                                width: context.width(),
                                color: Colors.grey,
                              )
                            ],
                          ),
                        ],
                      ),
                    );
                  }, error: (e, stack) {
                    return Text(e.toString());
                  }, loading: () {
                    return const Center(child: CircularProgressIndicator());
                  }),
                )
              : Container(
                  alignment: Alignment.topCenter,
                  decoration:
                      const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(topRight: Radius.circular(30), topLeft: Radius.circular(30))),
                  child: purchaseProviderData.when(data: (transaction) {
                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Container(
                              height: 120,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.all(Radius.circular(15)),
                                color: kMainColor.withOpacity(0.08),
                              ),
                              child: Center(
                                child: ListTile(
                                  leading: Container(
                                    height: 40,
                                    width: 40,
                                    decoration: const BoxDecoration(
                                      borderRadius: BorderRadius.all(Radius.circular(80)),
                                      image: DecorationImage(
                                        image: AssetImage(
                                          'images/ledger_total_sale.png',
                                        ),
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    "$currency${myFormat.format(totalSale)}",
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                                    Container(
                                      height: 40,
                                      width: 40,
                                      decoration: BoxDecoration(borderRadius: const BorderRadius.all(Radius.circular(80)), color: kMainColor.withOpacity(0.2)),
                                      child: const Icon(
                                        Icons.picture_as_pdf_outlined,
                                        color: kMainColor,
                                      ),
                                    ),
                                    const SizedBox(width: 7),
                                    Container(
                                      height: 40,
                                      width: 40,
                                      decoration: BoxDecoration(
                                        borderRadius: const BorderRadius.all(Radius.circular(80)),
                                        color: Colors.green.withOpacity(0.2),
                                      ),
                                      child: const Icon(
                                        Icons.print,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(width: 7),
                                    Container(
                                      height: 40,
                                      width: 40,
                                      decoration:
                                          BoxDecoration(borderRadius: const BorderRadius.all(Radius.circular(80)), color: Colors.orange.withOpacity(0.2)),
                                      child: const Icon(
                                        Icons.notifications_none,
                                        color: Colors.orange,
                                      ),
                                    ),
                                  ]).visible(false),
                                  subtitle:  Text(lang.S.of(context).totalSale),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 20.0, left: 20.0, top: 10, bottom: 10),
                            child: Row(
                              children: [
                                Expanded(
                                  child: AppTextField(
                                    textFieldType: TextFieldType.NAME,
                                    readOnly: true,
                                    controller: fromDateTextEditingController,
                                    decoration: InputDecoration(
                                      floatingLabelBehavior: FloatingLabelBehavior.always,
                                      labelText: lang.S.of(context).formDate,
                                      border: const OutlineInputBorder(),
                                      suffixIcon: IconButton(
                                        onPressed: () async {
                                          final DateTime? picked = await showDatePicker(
                                            initialDate: DateTime.now(),
                                            firstDate: DateTime(2015, 8),
                                            lastDate: DateTime(2101),
                                            context: context,
                                          );
                                          setState(() {
                                            fromDateTextEditingController.text = DateFormat.yMMMd().format(picked ?? DateTime.now());
                                            fromDate = picked!;
                                          });
                                        },
                                        icon: const Icon(FeatherIcons.calendar),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: AppTextField(
                                    textFieldType: TextFieldType.NAME,
                                    readOnly: true,
                                    controller: toDateTextEditingController,
                                    decoration: InputDecoration(
                                      floatingLabelBehavior: FloatingLabelBehavior.always,
                                      labelText: lang.S.of(context).toDate,
                                      border: const OutlineInputBorder(),
                                      suffixIcon: IconButton(
                                        onPressed: () async {
                                          final DateTime? picked = await showDatePicker(
                                            initialDate: DateTime.now(),
                                            firstDate: DateTime(2015, 8),
                                            lastDate: DateTime(2101),
                                            context: context,
                                          );
                                          setState(() {
                                            toDateTextEditingController.text = DateFormat.yMMMd().format(picked ?? DateTime.now());
                                            picked!.isToday ? toDate = DateTime.now() : toDate = picked;
                                          });
                                        },
                                        icon: const Icon(FeatherIcons.calendar),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: transaction.length,
                            itemBuilder: (context, index) {
                              final reTransaction = transaction.reversed.toList();

                              return reTransaction[index].customerPhone == widget.customerModel.phoneNumber &&
                                      (fromDate.isBefore(DateTime.parse(reTransaction[index].purchaseDate)) ||
                                          DateTime.parse(reTransaction[index].purchaseDate).isAtSameMomentAs(fromDate)) &&
                                      (toDate.isAfter(DateTime.parse(reTransaction[index].purchaseDate)) ||
                                          DateTime.parse(reTransaction[index].purchaseDate).isAtSameMomentAs(toDate))
                                  ? GestureDetector(
                                      onTap: () {
                                        PurchaseInvoiceDetails(
                                          personalInformationModel: personalData.value!,
                                          transitionModel: reTransaction[index],
                                        ).launch(context);
                                      },
                                      child: Column(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(20),
                                            width: context.width(),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text(
                                                      "Total Products : ${reTransaction[index].productList!.length.toString()}",
                                                      style: const TextStyle(fontSize: 16),
                                                    ),
                                                    Text('#${reTransaction[index].invoiceNumber}'),
                                                  ],
                                                ),
                                                const SizedBox(height: 10),
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Container(
                                                      padding: const EdgeInsets.all(8),
                                                      decoration: BoxDecoration(
                                                          color: reTransaction[index].dueAmount! <= 0
                                                              ? const Color(0xff0dbf7d).withOpacity(0.1)
                                                              : const Color(0xFFED1A3B).withOpacity(0.1),
                                                          borderRadius: const BorderRadius.all(Radius.circular(10))),
                                                      child: Text(
                                                        reTransaction[index].dueAmount! <= 0 ? 'Paid' : 'Unpaid',
                                                        style: TextStyle(
                                                            color: reTransaction[index].dueAmount! <= 0 ? const Color(0xff0dbf7d) : const Color(0xFFED1A3B)),
                                                      ),
                                                    ),
                                                    Column(
                                                      crossAxisAlignment: CrossAxisAlignment.end,
                                                      children: [
                                                        Text(
                                                          DateFormat.yMMMd().format(DateTime.parse(reTransaction[index].purchaseDate)),
                                                          style: const TextStyle(color: Colors.grey),
                                                        ),
                                                        const SizedBox(height: 3),
                                                        Text(
                                                          DateFormat.jm().format(DateTime.parse(reTransaction[index].purchaseDate)),
                                                          style: const TextStyle(color: Colors.grey),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 10),
                                                personalData.when(data: (data) {
                                                  return Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            'Total : $currency ${myFormat.format(reTransaction[index].totalAmount)}',
                                                            style: const TextStyle(color: Colors.grey),
                                                          ),
                                                          const SizedBox(height: 3),
                                                          Text(
                                                            'Paid : $currency ${myFormat.format(reTransaction[index].totalAmount!.toDouble() - reTransaction[index].dueAmount!.toDouble())}',
                                                            style: const TextStyle(color: Colors.grey),
                                                          ),
                                                          const SizedBox(height: 3),
                                                          Text(
                                                            'Due: $currency ${myFormat.format(reTransaction[index].dueAmount)}',
                                                            style: const TextStyle(fontSize: 16),
                                                          ).visible(reTransaction[index].dueAmount!.toInt() != 0),
                                                        ],
                                                      ),
                                                      Row(
                                                        children: [
                                                          IconButton(
                                                              onPressed: () async {


                                                                showDialog(
                                                                    context: context,
                                                                    builder: (_) {
                                                                      return Dialog(
                                                                        child: SizedBox(
                                                                          child: Column(
                                                                            mainAxisSize: MainAxisSize.min,
                                                                            children: [
                                                                              const Padding(
                                                                                padding: EdgeInsets.only(top: 20, bottom: 10),
                                                                                child: Text(
                                                                                  "POS Printer",
                                                                                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                                                                                ),
                                                                              ),
                                                                              const SizedBox(height: 10),
                                                                              Container(height: 1, width: double.infinity, color: Colors.grey),
                                                                              const SizedBox(height: 15),
                                                                              Padding(
                                                                                padding: const EdgeInsets.all(8.0),
                                                                                child: PrimaryButton(
                                                                                  label: "58 mm",
                                                                                  isDisabled: false,
                                                                                  onPressed: () => printType(data, true, providerData, purchasePrinterData, reTransaction[index]),

                                                                                ),
                                                                              ),
                                                                              Padding(
                                                                                padding: const EdgeInsets.all(8.0),
                                                                                child: PrimaryButton(
                                                                                  label: "80 mm",
                                                                                  isDisabled: false,
                                                                                  onPressed: () {
                                                                                    printType(data, false, providerData, purchasePrinterData, reTransaction[index]);
                                                                                  },
                                                                                ),
                                                                              ),

                                                                              GestureDetector(
                                                                                onTap: () {
                                                                                  Navigator.pop(context);
                                                                                },
                                                                                child: Center(
                                                                                  child: Padding(
                                                                                    padding: const EdgeInsets.all(8.0),
                                                                                    child: Text(
                                                                                      lang.S.of(context).cacel,
                                                                                      style: const TextStyle(color: kMainColor),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              const SizedBox(height: 15),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      );
                                                                    });


                                                              },
                                                              icon: const Icon(
                                                                FeatherIcons.printer,
                                                                color: Colors.grey,
                                                              )),
                                                          IconButton(
                                                              onPressed: () {},
                                                              icon: const Icon(
                                                                FeatherIcons.share,
                                                                color: Colors.grey,
                                                              )).visible(false),
                                                        ],
                                                      )
                                                    ],
                                                  );
                                                }, error: (e, stack) {
                                                  return Text(e.toString());
                                                }, loading: () {
                                                  return const Text('Loading');
                                                }),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            height: 0.5,
                                            width: context.width(),
                                            color: Colors.grey,
                                          )
                                        ],
                                      ),
                                    )
                                  : Container();
                            },
                          ),
                          Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(20),
                                width: context.width(),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children:  [
                                        Text(
                                          lang.S.of(context).openingBalance,
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                              color: widget.customerModel.remainedBalance.toInt() <= 0
                                                  ? const Color(0xff0dbf7d).withOpacity(0.1)
                                                  : const Color(0xFFED1A3B).withOpacity(0.1),
                                              borderRadius: const BorderRadius.all(Radius.circular(10))),
                                          child: Text(
                                            widget.customerModel.remainedBalance.toInt() <= 0 ? 'Paid' : 'Unpaid',
                                            style: TextStyle(
                                                color: widget.customerModel.remainedBalance.toInt() <= 0 ? const Color(0xff0dbf7d) : const Color(0xFFED1A3B)),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        const SizedBox(height: 10),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Total : $currency ${widget.customerModel.openingBalance.toString()}',
                                                  style: const TextStyle(color: Colors.grey),
                                                ),
                                                const SizedBox(height: 3),
                                                Text(
                                                  'Paid : $currency ${widget.customerModel.openingBalance.toInt() - widget.customerModel.remainedBalance.toInt()}',
                                                  style: const TextStyle(color: Colors.grey),
                                                ),
                                                const SizedBox(height: 3),
                                                Text(
                                                  'Due: $currency ${widget.customerModel.remainedBalance}',
                                                  style: const TextStyle(fontSize: 16),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                height: 0.5,
                                width: context.width(),
                                color: Colors.grey,
                              )
                            ],
                          ),
                        ],
                      ),
                    );
                  }, error: (e, stack) {
                    return Text(e.toString());
                  }, loading: () {
                    return const Center(child: CircularProgressIndicator());
                  }),
                ));
    });
  }

  void rePrinter(Printer printerData, PersonalInformationModel data, SalesTransitionModel reTransaction, bool peinter58) async {
    await printerData.getBluetooth();
    PrintTransactionModel model = PrintTransactionModel(transitionModel: reTransaction, personalInformationModel: data);
    connected
        ? printerData.printTicket(printTransactionModel: model, productList: model.transitionModel!.productList, printer58: peinter58)
        : showDialog(
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
                      itemCount: printerData.availableBluetoothDevices.isNotEmpty ? printerData.availableBluetoothDevices.length : 0,
                      itemBuilder: (context, index) {
                        return ListTile(
                          onTap: () async {
                            String select = printerData.availableBluetoothDevices[index];
                            List list = select.split("#");
                            // String name = list[0];
                            String mac = list[1];
                            bool isConnect = await printerData.setConnect(mac);
                            // ignore: use_build_context_synchronously
                            isConnect
                            // ignore: use_build_context_synchronously
                                ? finish(context)
                                : toast('Try Again');
                          },
                          title: Text('${printerData.availableBluetoothDevices[index]}'),
                          subtitle: Text(lang.S.of(context).clickToConnect),
                        );
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20, bottom: 10),
                      child: Text(
                        lang.S.of(context).pleaseConnectYourBluttothPrinter,
                        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(height: 1, width: double.infinity, color: Colors.grey),
                    const SizedBox(height: 15),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
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

  void printType(PersonalInformationModel data, bool printer58, AsyncValue<List<SalesTransitionModel>> providerData, PrinterPurchase purchasePrinterData, PurchaseTransactionModel reTransaction) async {
    ///________Print_______________________________________________________
    await purchasePrinterData.getBluetooth();
    PrintPurchaseTransactionModel model = PrintPurchaseTransactionModel(purchaseTransitionModel: reTransaction, personalInformationModel: data);
    if (connected) {
      await purchasePrinterData.printTicket(printTransactionModel: model, productList: model.purchaseTransitionModel!.productList, printer58: false);
    } else {
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
                        itemCount: purchasePrinterData.availableBluetoothDevices.isNotEmpty ? purchasePrinterData.availableBluetoothDevices.length : 0,
                        itemBuilder: (context, index) {
                          return ListTile(
                            onTap: () async {
                              String select = purchasePrinterData.availableBluetoothDevices[index];
                              List list = select.split("#");
                              // String name = list[0];
                              String mac = list[1];
                              bool isConnect = await purchasePrinterData.setConnect(mac);
                              isConnect
                              // ignore: use_build_context_synchronously
                                  ? finish(context)
                                  : toast('Try Again');
                            },
                            title: Text('${purchasePrinterData.availableBluetoothDevices[index]}'),
                            subtitle: Text(lang.S.of(context).clickToConnect),
                          );
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 20, bottom: 10),
                        child: Text(
                          lang.S.of(context).pleaseConnectYourBluttothPrinter,
                          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(height: 1, width: double.infinity, color: Colors.grey),
                      const SizedBox(height: 15),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
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
