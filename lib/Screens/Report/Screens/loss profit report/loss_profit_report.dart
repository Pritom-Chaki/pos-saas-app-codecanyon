// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mobile_pos/Provider/printer_provider.dart';
import 'package:mobile_pos/Provider/transactions_provider.dart';
import 'package:mobile_pos/Screens/Loss_Profit/single_loss_profit_screen.dart';
import 'package:mobile_pos/const_commas.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import 'package:mobile_pos/model/personal_information_model.dart';
import 'package:mobile_pos/model/print_transaction_model.dart';
import 'package:mobile_pos/widget/primary_button_widget.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../../Provider/profile_provider.dart';
import '../../../../constant.dart';
import '../../../../currency.dart';
import '../../../../empty_screen_widget.dart';
import '../../../../generate_pdf.dart';
import '../../../../model/transition_model.dart';
import 'loss_profit_pdf.dart';

class LossProfitReport extends StatefulWidget {
  const LossProfitReport({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LossProfitReportState createState() => _LossProfitReportState();
}

class _LossProfitReportState extends State<LossProfitReport> {
  TextEditingController fromDateTextEditingController = TextEditingController(text: DateFormat.yMMMd().format(DateTime(2021)));
  TextEditingController toDateTextEditingController = TextEditingController(text: DateFormat.yMMMd().format(DateTime.now()));
  DateTime fromDate = DateTime(2021);
  DateTime toDate = DateTime.now();
  double totalProfit = 0;
  double totalLoss = 0;
  double totalSale = 0;

  bool isPicked = false;

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, __) {
      final providerData = ref.watch(transitionProvider);
      final printerData = ref.watch(printerProviderNotifier);
      final personalData = ref.watch(profileDetailsProvider);
      return providerData.when(
        data: (transaction) {
          totalProfit = 0;
          totalLoss = 0;
          totalSale = 0;
          List<SalesTransitionModel> showAbleSaleTransactions = [];
          final reTransaction = transaction.reversed.toList();
          for (var element in reTransaction) {
            if (!isPicked) {
              if (DateTime.parse(element.purchaseDate).month == DateTime.now().month && DateTime.parse(element.purchaseDate).year == DateTime.now().year) {
                element.lossProfit!.isNegative ? totalLoss = totalLoss + element.lossProfit!.abs() : totalProfit = totalProfit + element.lossProfit!;
                totalSale += element.totalAmount!;
                showAbleSaleTransactions.add(element);
              }
            } else {
              if ((fromDate.isBefore(DateTime.parse(element.purchaseDate)) || DateTime.parse(element.purchaseDate).isAtSameMomentAs(fromDate)) &&
                  (toDate.isAfter(DateTime.parse(element.purchaseDate)) || DateTime.parse(element.purchaseDate).isAtSameMomentAs(toDate))) {
                element.lossProfit!.isNegative ? totalLoss = totalLoss + element.lossProfit!.abs() : totalProfit = totalProfit + element.lossProfit!;
                totalSale += element.totalAmount!;
                showAbleSaleTransactions.add(element);
              }
            }
          }
          return personalData.when(
            data: (data) {
              return Scaffold(
                backgroundColor: kMainColor,
                appBar: AppBar(
                  iconTheme: const IconThemeData(color: kWhite),
                  title: Text(
                    lang.S.of(context).lossOrProfit,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 20.0,
                    ),
                  ),
                  centerTitle: true,
                  backgroundColor: kMainColor,
                  elevation: 0.0,
                  actions: [
                    Padding(
                      padding: const EdgeInsets.only(right: 10.0),
                      child: Row(
                        children: [
                          Container(
                            height: 35,
                            width: 35,
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(6.0), border: Border.all(color: kMainColor), color: Colors.white),
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                              onPressed: () async {
                                shareLossProfitPDF(
                                  personalInformationModel: data,
                                  transactions: showAbleSaleTransactions ?? [],
                                  fromDate: fromDate.toString(),
                                  toDate: toDate.toString(),
                                  saleAmount: totalSale.toStringAsFixed(2),
                                  profit: totalProfit.toStringAsFixed(2),
                                  loss: totalLoss.toStringAsFixed(2),
                                  context: context,
                                );
                              },
                              icon: const Icon(
                                Icons.share_outlined,
                                color: kMainColor,
                              ),
                              hoverColor: kMainColor.withOpacity(0.1),
                              style: ButtonStyle(
                                  shape: MaterialStatePropertyAll(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6.0),
                                ),
                              )),
                              color: kMainColor,
                            ),
                          ),
                          const SizedBox(width: 10.0),
                          Container(
                            height: 35,
                            width: 35,
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(6.0), border: Border.all(color: kMainColor), color: Colors.white),
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                              onPressed: () async {
                                await GeneratePdf1().viewLossProfitPDf(data, showAbleSaleTransactions ?? [], fromDate.toString(), toDate.toString(),
                                    totalSale.toStringAsFixed(2), totalProfit.toStringAsFixed(2), totalLoss.toStringAsFixed(2), context);
                              },
                              icon: const Icon(
                                Icons.download_outlined,
                                color: kMainColor,
                              ),
                              hoverColor: kMainColor.withOpacity(0.1),
                              style: ButtonStyle(
                                  shape: MaterialStatePropertyAll(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6.0),
                                ),
                              )),
                              color: kMainColor,
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                body: Container(
                  alignment: Alignment.topCenter,
                  decoration:
                      const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(topRight: Radius.circular(30), topLeft: Radius.circular(30))),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 20.0, left: 20.0, top: 20, bottom: 10),
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
                                          totalLoss = 0;
                                          totalProfit = 0;
                                          isPicked = true;
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
                                          totalLoss = 0;
                                          totalProfit = 0;
                                          isPicked = true;
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
                        showAbleSaleTransactions.isNotEmpty
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
                                                myFormat.format(totalProfit),
                                                style: const TextStyle(
                                                  color: Colors.green,
                                                  fontSize: 20,
                                                ),
                                              ),
                                              const SizedBox(height: 10),
                                              Text(
                                                lang.S.of(context).profit,
                                                style: const TextStyle(
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
                                                myFormat.format(totalLoss),
                                                style: const TextStyle(
                                                  color: Colors.orange,
                                                  fontSize: 20,
                                                ),
                                              ),
                                              const SizedBox(height: 10),
                                              Text(
                                                lang.S.of(context).loss,
                                                style: const TextStyle(
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
                                    itemCount: showAbleSaleTransactions.length,
                                    itemBuilder: (context, index) {
                                      return (fromDate.isBefore(DateTime.parse(showAbleSaleTransactions[index].purchaseDate)) ||
                                                  DateTime.parse(showAbleSaleTransactions[index].purchaseDate).isAtSameMomentAs(fromDate)) &&
                                              (toDate.isAfter(DateTime.parse(showAbleSaleTransactions[index].purchaseDate)) ||
                                                  DateTime.parse(showAbleSaleTransactions[index].purchaseDate).isAtSameMomentAs(toDate))
                                          ? GestureDetector(
                                              onTap: () {
                                                SingleLossProfitScreen(
                                                  transactionModel: showAbleSaleTransactions[index],
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
                                                                showAbleSaleTransactions[index].customerName.isNotEmpty
                                                                    ? showAbleSaleTransactions[index].customerName
                                                                    : showAbleSaleTransactions[index].customerPhone,
                                                                style: const TextStyle(fontSize: 16),
                                                                maxLines: 2,
                                                                overflow: TextOverflow.ellipsis,
                                                              ),
                                                            ),
                                                            Text(
                                                              '#${showAbleSaleTransactions[index].invoiceNumber}',
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
                                                                  color: showAbleSaleTransactions[index].dueAmount! <= 0
                                                                      ? const Color(0xff0dbf7d).withOpacity(0.1)
                                                                      : const Color(0xFFED1A3B).withOpacity(0.1),
                                                                  borderRadius: const BorderRadius.all(Radius.circular(10))),
                                                              child: Text(
                                                                showAbleSaleTransactions[index].dueAmount! <= 0 ? 'Paid' : 'Unpaid',
                                                                style: TextStyle(
                                                                    color: showAbleSaleTransactions[index].dueAmount! <= 0
                                                                        ? const Color(0xff0dbf7d)
                                                                        : const Color(0xFFED1A3B)),
                                                              ),
                                                            ),
                                                            Column(
                                                              crossAxisAlignment: CrossAxisAlignment.end,
                                                              children: [
                                                                Text(
                                                                  DateFormat.yMMMd().format(DateTime.parse(showAbleSaleTransactions[index].purchaseDate)),
                                                                  style: const TextStyle(color: Colors.grey),
                                                                ),
                                                                const SizedBox(height: 5),
                                                                Text(
                                                                  DateFormat.jm().format(DateTime.parse(showAbleSaleTransactions[index].purchaseDate)),
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
                                                                'Total : $currency ${myFormat.format(showAbleSaleTransactions[index].totalAmount)}',
                                                                style: const TextStyle(color: Colors.grey),
                                                              ),
                                                              const SizedBox(height: 5),
                                                              Text(
                                                                'Profit : $currency ${myFormat.format(showAbleSaleTransactions[index].lossProfit)}',
                                                                style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                                                              ).visible(!showAbleSaleTransactions[index].lossProfit!.isNegative),
                                                              Text(
                                                                'Loss: $currency ${myFormat.format(showAbleSaleTransactions[index].lossProfit!.abs())}',
                                                                style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                                                              ).visible(showAbleSaleTransactions[index].lossProfit!.isNegative),
                                                            ]),
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
                                                                                      padding: const EdgeInsets.all( 8.0),
                                                                                      child: PrimaryButton(
                                                                                        label: "58 mm",
                                                                                        isDisabled: false,
                                                                                        onPressed: () => rePrinter(printerData, true,providerData,data, showAbleSaleTransactions[index]),
                                                                                      ),
                                                                                    ),
                                                                                    Padding(
                                                                                      padding: const EdgeInsets.all(8.0),
                                                                                      child: PrimaryButton(
                                                                                        label: "80 mm",
                                                                                        isDisabled: false,
                                                                                        onPressed: () =>   rePrinter(printerData, false,providerData,data, showAbleSaleTransactions[index]),
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
                                                                    onPressed: () => toast('Coming Soon'),
                                                                    icon: const Icon(
                                                                      FeatherIcons.share,
                                                                      color: Colors.grey,
                                                                    )).visible(false),
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

  void rePrinter(Printer printerData, bool printer58, AsyncValue<List<SalesTransitionModel>> providerData, PersonalInformationModel data, SalesTransitionModel showAbleSaleTransactions)async {
    totalProfit = 0;
    totalLoss = 0;
    await printerData.getBluetooth();
    PrintTransactionModel model = PrintTransactionModel(
        transitionModel: showAbleSaleTransactions, personalInformationModel: data);
    connected
        ? printerData.printTicket(
      printTransactionModel: model,
      productList: model.transitionModel!.productList,
      printer58: printer58
    )
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
                      itemCount: printerData.availableBluetoothDevices.isNotEmpty
                          ? printerData.availableBluetoothDevices.length
                          : 0,
                      itemBuilder: (context, index) {
                        return ListTile(
                          onTap: () async {
                            String select = printerData.availableBluetoothDevices[index];
                            List list = select.split("#");
                            // String name = list[0];
                            String mac = list[1];
                            bool isConnect = await printerData.setConnect(mac);
                            isConnect ? finish(context) : toast('Try Again');
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
                        style: const TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
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
