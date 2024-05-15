// ignore_for_file: use_build_context_synchronously

import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mobile_pos/const_commas.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import 'package:mobile_pos/widget/primary_button_widget.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../Provider/printer_due_provider.dart';
// ignore: library_prefixes
import '../../constant.dart' as mainConstant;
import '../../currency.dart';
import '../../invoice_constant.dart';
import '../../model/due_transaction_model.dart';
import '../../model/personal_information_model.dart';
import '../../model/print_transaction_model.dart';
import '../../pdf/due_pdf.dart';
import '../Home/home.dart';

class DueInvoiceDetails extends StatefulWidget {
  const DueInvoiceDetails({super.key, required this.transitionModel, required this.personalInformationModel});

  final DueTransactionModel transitionModel;
  final PersonalInformationModel personalInformationModel;

  @override
  State<DueInvoiceDetails> createState() => _DueInvoiceDetailsState();
}

class _DueInvoiceDetailsState extends State<DueInvoiceDetails> {
  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, __) {
      final printerData = ref.watch(printerDueProviderNotifier);
      return SafeArea(
        child: Scaffold(
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      height: 50.0,
                      width: 50.0,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('images/logo1.png'),
                        ),
                      ),
                    ),
                    title: Text(
                      widget.personalInformationModel.companyName.toString(),
                      style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold, fontSize: 18.0),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.personalInformationModel.countryName.toString(),
                          style: kTextStyle.copyWith(
                            color: kGreyTextColor,
                          ),
                        ),
                        Text(
                          widget.personalInformationModel.phoneNumber.toString(),
                          style: kTextStyle.copyWith(
                            color: kGreyTextColor,
                          ),
                        ),
                      ],
                    ),
                    isThreeLine: true,
                  ),
                  Divider(
                    thickness: 1.0,
                    color: kGreyTextColor.withOpacity(0.1),
                  ),
                  const SizedBox(height: 10.0),
                  Row(
                    children: [
                      Text(
                        lang.S.of(context).billTo,
                        style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      Text(
                        'Invoice# ${widget.transitionModel.invoiceNumber}',
                        style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Divider(
                    thickness: 1.0,
                    color: kGreyTextColor.withOpacity(0.1),
                  ),
                  const SizedBox(height: 5.0),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          widget.transitionModel.customerName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: kTextStyle.copyWith(color: kGreyTextColor),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        DateFormat.yMMMd().format(DateTime.parse(widget.transitionModel.purchaseDate)),
                        style: kTextStyle.copyWith(color: kGreyTextColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5.0),
                  Row(
                    children: [
                      Text(
                        widget.transitionModel.customerPhone,
                        style: kTextStyle.copyWith(color: kGreyTextColor),
                      ),
                      const Spacer(),
                      Text(
                        widget.transitionModel.purchaseDate.substring(10, 16),
                        style: kTextStyle.copyWith(color: kGreyTextColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10.0),
                  Divider(
                    thickness: 1.0,
                    color: kGreyTextColor.withOpacity(0.1),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        lang.S.of(context).totalDue,
                        maxLines: 1,
                        style: kTextStyle.copyWith(color: kGreyTextColor),
                      ),
                      const SizedBox(width: 20.0),
                      SizedBox(
                        width: 120,
                        child: Text(
                          '$currency ${myFormat.format(widget.transitionModel.totalDue)}',
                          maxLines: 2,
                          style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        lang.S.of(context).paymentAmount,
                        maxLines: 1,
                        style: kTextStyle.copyWith(color: kGreyTextColor),
                      ),
                      const SizedBox(width: 20.0),
                      SizedBox(
                        width: 120,
                        child: Text(
                          '$currency ${myFormat.format(widget.transitionModel.payDueAmount)}',
                          maxLines: 2,
                          style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        lang.S.of(context).remainingDue,
                        maxLines: 1,
                        style: kTextStyle.copyWith(color: kGreyTextColor),
                      ),
                      const SizedBox(width: 20.0),
                      SizedBox(
                        width: 120,
                        child: Text(
                          '$currency ${myFormat.format(widget.transitionModel.dueAmountAfterPay)}',
                          maxLines: 2,
                          style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ],
                  ),
                  Divider(
                    thickness: 1.0,
                    color: kGreyTextColor.withOpacity(0.1),
                  ),
                  const SizedBox(height: 10.0),
                  Center(
                    child: Text(
                      lang.S.of(context).thankYOuForYourDuePayment,
                      maxLines: 1,
                      style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
          floatingActionButton: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: Container(
                    height: 60,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.all(
                        Radius.circular(30),
                      ),
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.close,
                            color: Colors.white,
                          ),
                          Text(
                            lang.S.of(context).cacel,
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).onTap(() => const Home().launch(context)),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () async {

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
                                        onPressed: () =>  duePrinter(printerData, true,widget.transitionModel,widget.personalInformationModel),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: PrimaryButton(
                                        label: "80 mm",
                                        isDisabled: false,
                                        onPressed: () =>  duePrinter(printerData, false,widget.transitionModel,widget.personalInformationModel),
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
                    child: Container(
                      height: 60,
                      width: context.width() / 3,
                      decoration: const BoxDecoration(
                        color: mainConstant.kMainColor,
                        borderRadius: BorderRadius.all(
                          Radius.circular(30),
                        ),
                      ),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.print,
                              color: Colors.white,
                            ),
                            Text(
                              lang.S.of(context).print,
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      shareDuePDF(context: context, personalInformation: widget.personalInformationModel, transactions: widget.transitionModel);
                    },
                    // onTap: () async => await GeneratePdf1().generateDueDocument(widget.transitionModel, widget.personalInformationModel, context),
                    child: Container(
                      height: 60,
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.all(
                          Radius.circular(30),
                        ),
                      ),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              CommunityMaterialIcons.share,
                              color: Colors.white,
                            ),
                            Text(
                              lang.S.of(context).share,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        ),
      );
    });
  }

  void duePrinter(PrinterDue printerData, bool printer58, DueTransactionModel transitionModel, PersonalInformationModel personalInformationModel) async {
    await printerData.getBluetooth();
    PrintDueTransactionModel model =
    PrintDueTransactionModel(dueTransactionModel: widget.transitionModel, personalInformationModel: widget.personalInformationModel);
    mainConstant.connected
        ? printerData.printTicket(
      printDueTransactionModel: model,
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
                      itemCount: printerData.availableBluetoothDevices.isNotEmpty ? printerData.availableBluetoothDevices.length : 0,
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
                          style: const TextStyle(color: mainConstant.kMainColor),
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
