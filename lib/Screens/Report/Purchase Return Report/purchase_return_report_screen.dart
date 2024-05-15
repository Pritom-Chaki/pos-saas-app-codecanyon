// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mobile_pos/const_commas.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../../Provider/profile_provider.dart';
import '../../../../constant.dart';
import '../../../../currency.dart';
import '../../../../empty_screen_widget.dart';
import '../../../../model/transition_model.dart';
import '../../purchase return/purchase_return_details.dart';
import '../../purchase return/purchase_return_pdf.dart';
import 'Provider/purchase_returns_provider.dart';

class PurchaseReturnReport extends StatefulWidget {
  const PurchaseReturnReport({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _PurchaseReturnReportState createState() => _PurchaseReturnReportState();
}

class _PurchaseReturnReportState extends State<PurchaseReturnReport> {
  double getTotalReturnAmount(List<PurchaseTransactionModel> transitionModel) {
    double total = 0.0;
    for (var element in transitionModel) {
      total += element.totalAmount ?? 0;
    }
    return total;
  }

  double calculateTotalDue(List<dynamic> purchaseTransitionModel) {
    double total = 0.0;
    for (var element in purchaseTransitionModel) {
      total += element.dueAmount!;
    }
    return total;
  }

  String searchItem = '';
  DateTime fromDate = DateTime(2021);
  DateTime toDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, __) {
      final transactionReport = ref.watch(purchaseReturnProvider);
      return transactionReport.when(
        data: (transaction) {
          List<PurchaseTransactionModel> reTransaction = [];
          for (var element in transaction.reversed.toList()) {
            if ((element.invoiceNumber.toLowerCase().contains(searchItem.toLowerCase()) ||
                element.customerName.toLowerCase().contains(searchItem.toLowerCase()))) {
              reTransaction.add(element);
            }
          }
          final profile = ref.watch(profileDetailsProvider);
          return Scaffold(
            backgroundColor: kMainColor,
            appBar: AppBar(
              iconTheme: const IconThemeData(color: kWhite),
              title: Text(
                'Purchase Return Report',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 20.0,
                ),
              ),
              centerTitle: true,
              backgroundColor: kMainColor,
              elevation: 0.0,
            ),
            body: Container(
              alignment: Alignment.topCenter,
              decoration:
                  const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(topRight: Radius.circular(30), topLeft: Radius.circular(30))),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    reTransaction.isNotEmpty
                        ? Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Container(
                                  height: 100,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                      color: kMainColor.withOpacity(0.1),
                                      border: Border.all(width: 1, color: kMainColor),
                                      borderRadius: const BorderRadius.all(Radius.circular(15))),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            myFormat.format(double.tryParse(transaction.length.toString()) ?? 0),
                                            style: const TextStyle(
                                              color: Colors.green,
                                              fontSize: 20,
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          const Text(
                                            'Total returns',
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Container(
                                        width: 1,
                                        height: 60,
                                        color: kMainColor,
                                      ),
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            '$currency${myFormat.format(double.tryParse(getTotalReturnAmount(transaction).toString()) ?? 0)}',
                                            style: const TextStyle(
                                              color: Colors.orange,
                                              fontSize: 20,
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          const Text(
                                            'Total Return amount',
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: reTransaction.length,
                                itemBuilder: (context, index) {
                                  return (fromDate.isBefore(DateTime.parse(reTransaction[index].purchaseDate)) ||
                                              DateTime.parse(reTransaction[index].purchaseDate).isAtSameMomentAs(fromDate)) &&
                                          (toDate.isAfter(DateTime.parse(reTransaction[index].purchaseDate)) ||
                                              DateTime.parse(reTransaction[index].purchaseDate).isAtSameMomentAs(toDate))
                                      ? GestureDetector(
                                          onTap: () {
                                            PurchaseReturnDetails(
                                              transitionModel: reTransaction[index],
                                              personalInformationModel: profile.value!,
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
                                                        Flexible(
                                                          child: Text(
                                                            reTransaction[index].customerName.isNotEmpty
                                                                ? reTransaction[index].customerName
                                                                : reTransaction[index].customerPhone,
                                                            style: const TextStyle(fontSize: 16),
                                                            maxLines: 2,
                                                            overflow: TextOverflow.ellipsis,
                                                          ),
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
                                                                color:
                                                                    reTransaction[index].dueAmount! <= 0 ? const Color(0xff0dbf7d) : const Color(0xFFED1A3B)),
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
                                                    const SizedBox(height: 5),
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                                          Text(
                                                            'Total : $currency ${myFormat.format(reTransaction[index].totalAmount)}',
                                                            style: const TextStyle(color: Colors.grey),
                                                          ),
                                                          const SizedBox(height: 5),
                                                          Text(
                                                            'Paid : $currency ${myFormat.format(reTransaction[index].totalAmount!.toDouble() - reTransaction[index].dueAmount!.toDouble())}',
                                                            style: const TextStyle(color: Colors.grey),
                                                          ),
                                                          const SizedBox(height: 3),
                                                          Text(
                                                            'Due: $currency ${myFormat.format(reTransaction[index].dueAmount)}',
                                                            style: const TextStyle(fontSize: 16),
                                                          ).visible(reTransaction[index].dueAmount!.toInt() != 0),
                                                        ]),
                                                        Row(
                                                          children: [
                                                            IconButton(
                                                                onPressed: () async {
                                                                  await PurchaseReturn()
                                                                      .generatePurchaseReturnDocument(profile.value!, reTransaction[index], context);
                                                                },
                                                                icon: const Icon(
                                                                  FeatherIcons.printer,
                                                                  color: Colors.grey,
                                                                )),
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
                                        )
                                      : Container();
                                },
                              ),
                            ],
                          )
                        : const Padding(
                            padding: EdgeInsets.only(top: 60),
                            child: EmptyScreenWidget(),
                          ),
                  ],
                ),
              ),
            ),
          );
        },
        error: (e, stack) {
          return Text(e.toString());
        },
        loading: () {
          return const Center(child: CircularProgressIndicator());
        },
      );
    });
  }
}
