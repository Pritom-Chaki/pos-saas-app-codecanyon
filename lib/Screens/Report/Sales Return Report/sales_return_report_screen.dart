// ignore_for_file: use_build_context_synchronously
import 'dart:async';

import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:intl/intl.dart';
import 'package:mobile_pos/Provider/printer_provider.dart';
import 'package:mobile_pos/Provider/transactions_provider.dart';
import 'package:mobile_pos/const_commas.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import 'package:mobile_pos/model/personal_information_model.dart';
import 'package:mobile_pos/model/print_transaction_model.dart';
import 'package:mobile_pos/model/transition_model.dart';
import 'package:mobile_pos/widget/primary_button_widget.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:pdf/widgets.dart' as pw;


import '../../../Provider/profile_provider.dart';
import '../../../constant.dart';
import '../../../currency.dart';
import '../../../empty_screen_widget.dart';
import '../../../generate_pdf.dart';
import '../../../pdf/sales_pdf.dart';
import '../../Home/home.dart';
import '../../invoice_details/sales_invoice_details_screen.dart';

class SalesReportScreen extends StatefulWidget {
  const SalesReportScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SalesReportScreenState createState() => _SalesReportScreenState();
}

class _SalesReportScreenState extends State<SalesReportScreen> {
  String? invoiceNumber;
  TextEditingController fromDateTextEditingController = TextEditingController(text: DateFormat.yMMMd().format(DateTime(2021)));
  TextEditingController toDateTextEditingController = TextEditingController(text: DateFormat.yMMMd().format(DateTime.now()));
  DateTime fromDate = DateTime(2021);
  DateTime toDate = DateTime.now();
  double totalSell = 0;
  bool isPicked = false;
  int count = 0;

  final pw.Document doc = pw.Document();

  final pdf = pw.Document();

  late StreamSubscription subscription;
  bool isDeviceConnected = false;
  bool isAlertSet = false;

  getConnectivity() => subscription = Connectivity().onConnectivityChanged.listen(
        (ConnectivityResult result) async {
          isDeviceConnected = await InternetConnectionChecker().hasConnection;
          if (!isDeviceConnected && isAlertSet == false) {
            showDialogBox();
            setState(() => isAlertSet = true);
          }
        },
      );

  checkInternet() async {
    isDeviceConnected = await InternetConnectionChecker().hasConnection;
    if (!isDeviceConnected) {
      showDialogBox();
      setState(() => isAlertSet = true);
    }
  }

  @override
  void initState() {
    getConnectivity();
    // checkInternet();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return await const Home().launch(context, isNewTask: true);
      },
      child: Scaffold(
        backgroundColor: kMainColor,
        appBar: AppBar(
          title: Text(
            lang.S.of(context).saleReports,
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
        body: Consumer(builder: (context, ref, __) {
          final providerData = ref.watch(transitionProvider);
          final profile = ref.watch(profileDetailsProvider);
          final printerData = ref.watch(printerProviderNotifier);
          final personalData = ref.watch(profileDetailsProvider);
          return Container(
            alignment: Alignment.topCenter,
            decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(topRight: Radius.circular(30), topLeft: Radius.circular(30))),
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
                                    totalSell = 0;
                                    count = 0;
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
                                    totalSell = 0;
                                    count = 0;
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
                  providerData.when(data: (transaction) {
                    final reTransaction = transaction.reversed.toList();
                    if (count == 0) {
                      count++;
                      for (var element in reTransaction) {
                        if (!isPicked) {
                          if (DateTime.parse(element.purchaseDate).month == DateTime.now().month && DateTime.parse(element.purchaseDate).year == DateTime.now().year) {
                            totalSell = totalSell + element.totalAmount!.toDouble();
                          }
                        } else {
                          if ((fromDate.isBefore(DateTime.parse(element.purchaseDate)) || DateTime.parse(element.purchaseDate).isAtSameMomentAs(fromDate)) &&
                              (toDate.isAfter(DateTime.parse(element.purchaseDate)) || DateTime.parse(element.purchaseDate).isAtSameMomentAs(toDate))) {
                            totalSell = totalSell + element.totalAmount!.toDouble();
                          }
                        }
                      }
                    }
                    return reTransaction.isNotEmpty
                        ? Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 20, right: 20.0),
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
                                        "$currency${myFormat.format(totalSell)}",
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
                                          decoration: BoxDecoration(borderRadius: const BorderRadius.all(Radius.circular(80)), color: Colors.orange.withOpacity(0.2)),
                                          child: const Icon(
                                            Icons.notifications_none,
                                            color: Colors.orange,
                                          ),
                                        ),
                                      ]).visible(false),
                                      subtitle: Text(
                                          'Total Sale ${isPicked ? '(From ${fromDate.toString().substring(0, 10)} to ${toDate.toString().substring(0, 10)})' : '(This Month)'}'),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 10.0),
                                child: AppTextField(
                                  textFieldType: TextFieldType.NUMBER,
                                  onChanged: (value) {
                                    setState(() {
                                      invoiceNumber = value;
                                    });
                                  },
                                  decoration: InputDecoration(
                                      floatingLabelBehavior: FloatingLabelBehavior.never,
                                      labelText: lang.S.of(context).invoiceNumber,
                                      hintText: lang.S.of(context).enterInvoiceNumber,
                                      border: const OutlineInputBorder(),
                                      prefixIcon: const Icon(Icons.search)),
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
                                            SalesInvoiceDetails(
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
                                                            reTransaction[index].customerName.isNotEmpty ? reTransaction[index].customerName : reTransaction[index].customerPhone,
                                                            style: const TextStyle(fontSize: 16),
                                                            maxLines: 2,
                                                            overflow: TextOverflow.ellipsis,
                                                          ),
                                                        ),
                                                        Text(
                                                          '#${reTransaction[index].invoiceNumber}',
                                                          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
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
                                                            style: TextStyle(color: reTransaction[index].dueAmount! <= 0 ? const Color(0xff0dbf7d) : const Color(0xFFED1A3B)),
                                                          ),
                                                        ),
                                                        Column(
                                                          crossAxisAlignment: CrossAxisAlignment.end,
                                                          children: [
                                                            Text(
                                                              DateFormat.yMMMd().format(DateTime.parse(reTransaction[index].purchaseDate)),
                                                              style: const TextStyle(color: Colors.grey),
                                                            ),
                                                            const SizedBox(height: 2),
                                                            Text(
                                                              DateFormat.jm().format(DateTime.parse(reTransaction[index].purchaseDate)),
                                                              style: const TextStyle(color: Colors.grey),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
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
                                                        personalData.when(data: (data) {
                                                          return Row(
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
                                                                                      onPressed: () => duePrinter(printerData, true, reTransaction[index], data),
                                                                                    ),
                                                                                  ),
                                                                                  Padding(
                                                                                    padding: const EdgeInsets.all(8.0),
                                                                                    child: PrimaryButton(
                                                                                      label: "80 mm",
                                                                                      isDisabled: false,
                                                                                      onPressed: () => duePrinter(printerData, false, reTransaction[index], data),
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
                                                                  onPressed: () async => await GeneratePdf1().generateSaleDocument(
                                                                        reTransaction[index],
                                                                        data,
                                                                        context,
                                                                        // share: false,
                                                                      ),
                                                                  icon: const Icon(
                                                                    Icons.picture_as_pdf,
                                                                    color: Colors.grey,
                                                                  )),
                                                              IconButton(
                                                                  onPressed: () async {
                                                                    shareSalePDF(
                                                                      transactions: reTransaction[index],
                                                                      personalInformation: data,
                                                                      context: context,
                                                                    );
                                                                    // GeneratePdf1().generateSaleDocument(
                                                                    //   reTransaction[index],
                                                                    //   data,
                                                                    //   context,
                                                                    //   // share: true,
                                                                    // );
                                                                  },
                                                                  icon: const Icon(
                                                                    CommunityMaterialIcons.share,
                                                                    color: Colors.grey,
                                                                  )),
                                                            ],
                                                          );
                                                        }, error: (e, stack) {
                                                          return Text(e.toString());
                                                        }, loading: () {
                                                          return const Text('Loading');
                                                        }),
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
                                        ).visible(invoiceNumber.isEmptyOrNull ? true : reTransaction[index].invoiceNumber.toString().contains(invoiceNumber!))
                                      : Container();
                                },
                              ),
                            ],
                          )
                        : const Center(
                            child: Padding(
                            padding: EdgeInsets.only(top: 60),
                            child: EmptyScreenWidget(),
                          ));
                  }, error: (e, stack) {
                    return Text(e.toString());
                  }, loading: () {
                    return const Padding(
                      padding: EdgeInsets.all(20),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }),
                ],
              ),
            ),
          );
        }),
      ),
    );
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
                isDeviceConnected = await InternetConnectionChecker().hasConnection;
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

  void duePrinter(Printer printerData, bool printer58, SalesTransitionModel reTransaction, PersonalInformationModel data) async {
    await printerData.getBluetooth();
    PrintTransactionModel model =
    PrintTransactionModel(transitionModel: reTransaction, personalInformationModel: data);
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
