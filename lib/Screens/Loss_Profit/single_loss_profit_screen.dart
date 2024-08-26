import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mobile_pos/const_commas.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import 'package:nb_utils/nb_utils.dart';

import '../../constant.dart';
import '../../currency.dart';
import '../../model/transition_model.dart';

class SingleLossProfitScreen extends StatefulWidget {
  const SingleLossProfitScreen({
    super.key,
    required this.transactionModel,
  });

  final SalesTransitionModel transactionModel;

  @override
  State<SingleLossProfitScreen> createState() => _SingleLossProfitScreenState();
}

class _SingleLossProfitScreenState extends State<SingleLossProfitScreen> {
  double getTotalProfit() {
    double totalProfit = 0;
    for (var element in widget.transactionModel.productList!) {
      double purchasePrice;
      if (element.taxType == 'Exclusive') {
        double tax = calculateAmountFromPercentage((element.groupTaxRate.toString() ?? '').toDouble(), double.tryParse(element.productPurchasePrice.toString()) ?? 0);
        purchasePrice = (double.parse(element.productPurchasePrice.toString()) + tax) * double.parse(element.quantity.toString());
      } else {
        purchasePrice = double.parse(element.productPurchasePrice.toString()) * double.parse(element.quantity.toString());
      }
      double salePrice = double.parse(element.subTotal.toString()) * double.parse(element.quantity.toString());

      double profit = salePrice - purchasePrice;

      if (!profit.isNegative) {
        totalProfit = totalProfit + profit;
      }
    }

    return totalProfit;
  }

  double getTotalLoss() {
    double totalLoss = 0;
    for (var element in widget.transactionModel.productList!) {
      double purchasePrice;
      if (element.taxType == 'Exclusive') {
        double tax = calculateAmountFromPercentage((element.groupTaxRate.toString() ?? '').toDouble(), double.tryParse(element.productPurchasePrice.toString()) ?? 0);
        purchasePrice = (double.parse(element.productPurchasePrice.toString()) + tax) * double.parse(element.quantity.toString());
      } else {
        purchasePrice = (double.parse(element.productPurchasePrice.toString())) * double.parse(element.quantity.toString());
      }
      double salePrice = double.parse(element.subTotal.toString()) * double.parse(element.quantity.toString());

      double profit = salePrice - purchasePrice;

      if (profit.isNegative) {
        totalLoss = totalLoss + profit.abs();
      }
    }

    return totalLoss;
  }

  // Function to calculate the amount from a given percentage
  double calculateAmountFromPercentage(double percentage, double price) {
    return (percentage * price) / 100;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kMainColor,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: kWhite),
        title: Text(
          lang.S.of(context).lossOrProfitDetails,
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
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(topRight: Radius.circular(30), topLeft: Radius.circular(30))),
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('Invoice # ${widget.transactionModel.invoiceNumber}'),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        widget.transactionModel.customerName,
                        style: kTextStyle.copyWith(color: kTitleColor, overflow: TextOverflow.ellipsis),
                      ),
                    ),
                    const SizedBox(width: 10.0),
                    Text(
                      "Date: ${DateFormat.yMMMd().format(DateTime.parse(widget.transactionModel.purchaseDate))}",
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Mobile: ${widget.transactionModel.customerPhone}",
                      style: const TextStyle(color: Colors.grey),
                    ),
                    Text(
                      DateFormat.jm().format(DateTime.parse(widget.transactionModel.purchaseDate)),
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(10),
                  color: kMainColor.withOpacity(0.2),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          lang.S.of(context).product,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          lang.S.of(context).quantity,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          lang.S.of(context).profit,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(
                        lang.S.of(context).loss,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                ListView.builder(
                    itemCount: widget.transactionModel.productList!.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      double purchasePrice;
                      if (widget.transactionModel.productList![index].taxType == 'Exclusive') {
                        double tax = calculateAmountFromPercentage((widget.transactionModel.productList![index].groupTaxRate.toString() ?? '').toDouble(),
                            double.tryParse(widget.transactionModel.productList![index].productPurchasePrice.toString()) ?? 0);
                        purchasePrice = (double.parse(widget.transactionModel.productList![index].productPurchasePrice.toString()) + tax) *
                            double.parse(widget.transactionModel.productList![index].quantity.toString());
                      } else {
                        purchasePrice = double.parse(widget.transactionModel.productList![index].productPurchasePrice.toString()) *
                            double.parse(widget.transactionModel.productList![index].quantity.toString());
                      }

                      double salePrice = double.parse(widget.transactionModel.productList![index].subTotal.toString()) *
                          double.parse(widget.transactionModel.productList![index].quantity.toString());
                      double profit = salePrice - purchasePrice;

                      return Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(
                                widget.transactionModel.productList![index].productName.toString(),
                                textAlign: TextAlign.start,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Center(
                                child: Text(
                                  widget.transactionModel.productList![index].quantity.toString(),
                                  style: GoogleFonts.poppins(),
                                ),
                              ),
                            ),
                            Expanded(
                                flex: 2,
                                child: Center(
                                  child: Text(
                                    !profit.isNegative ? "$currency${myFormat.format(int.tryParse(profit.abs().toInt().toString()) ?? 0)}" : '0',
                                    style: GoogleFonts.poppins(),
                                  ),
                                )),
                            Expanded(
                              child: Center(
                                child: Text(
                                  profit.isNegative ? "$currency${myFormat.format(int.tryParse(profit.abs().toInt().toString()) ?? 0)}" : '0',
                                  style: GoogleFonts.poppins(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(color: kMainColor.withOpacity(0.2), border: const Border(bottom: BorderSide(width: 1, color: Colors.grey))),
              padding: const EdgeInsets.all(10),
              child: Padding(
                padding: const EdgeInsets.only(left: 15, right: 15),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text(
                            lang.S.of(context).total,
                            textAlign: TextAlign.start,
                            style: GoogleFonts.poppins(color: Colors.black, fontSize: 14.0, fontWeight: FontWeight.w500),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            widget.transactionModel.totalQuantity.toString(),
                            style: GoogleFonts.poppins(
                              color: Colors.black,
                            ),
                          ),
                        ),
                        Expanded(
                            flex: 2,
                            child: Text(
                              "$currency${myFormat.format(getTotalProfit())}",
                              style: GoogleFonts.poppins(
                                color: Colors.black,
                              ),
                            )),
                        Text(
                          "$currency${myFormat.format(getTotalLoss())}",
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: kMainColor.withOpacity(0.2), border: const Border(bottom: BorderSide(width: 1, color: Colors.grey))),
              child: Padding(
                padding: const EdgeInsets.only(left: 15, right: 15),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text(
                            lang.S.of(context).discount,
                            textAlign: TextAlign.start,
                            style: GoogleFonts.poppins(color: Colors.black, fontSize: 14.0, fontWeight: FontWeight.w500),
                          ),
                        ),
                        Text(
                          "$currency${myFormat.format(int.tryParse(widget.transactionModel.discountAmount!.toInt().toString()) ?? 0)}",
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: kMainColor.withOpacity(0.2),
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 15, right: 15),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text(
                            widget.transactionModel.lossProfit!.isNegative ? 'Total Loss' : 'Total Profit',
                            textAlign: TextAlign.start,
                            style: GoogleFonts.poppins(color: Colors.black, fontSize: 14.0, fontWeight: FontWeight.w500),
                          ),
                        ),
                        Text(
                          widget.transactionModel.lossProfit!.isNegative
                              ? "$currency${myFormat.format(int.tryParse('${widget.transactionModel.lossProfit!.toInt().abs()}') ?? 0)}"
                              : "$currency${myFormat.format(int.tryParse('${widget.transactionModel.lossProfit!.toInt()}') ?? 0)}",
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
