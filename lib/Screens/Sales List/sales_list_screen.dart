import 'package:community_material_icon/community_material_icon.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mobile_pos/Provider/add_to_cart.dart';
import 'package:mobile_pos/Provider/customer_provider.dart';
import 'package:mobile_pos/Provider/printer_provider.dart';
import 'package:mobile_pos/Provider/product_provider.dart';
import 'package:mobile_pos/Provider/transactions_provider.dart';
import 'package:mobile_pos/Screens/Sales%20List/sales_report_edit_screen.dart';
import 'package:mobile_pos/Screens/sale%20return/sales_return_screen.dart';
import 'package:mobile_pos/Widget/primary_button_widget.dart';
import 'package:mobile_pos/const_commas.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import 'package:mobile_pos/model/personal_information_model.dart';
import 'package:mobile_pos/model/print_transaction_model.dart';
import 'package:mobile_pos/model/transition_model.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../../Provider/profile_provider.dart';
import '../../../constant.dart';
import '../../currency.dart';
import '../../empty_screen_widget.dart';
import '../../generate_pdf.dart';
import '../../pdf/sales_pdf.dart';
import '../Home/home.dart';
import '../Sales/sale_returns/sale_return_functions.dart';
import '../invoice_details/sales_invoice_details_screen.dart';

class SalesListScreen extends StatefulWidget {
  const SalesListScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SalesListScreenState createState() => _SalesListScreenState();
}

class _SalesListScreenState extends State<SalesListScreen> {
  String? invoiceNumber;
  final String _selectedItem = '';

  void rePrinter(
      Printer printerData,
      bool printer58,
      AsyncValue<List<SalesTransitionModel>> providerData,
      PersonalInformationModel data,
      SalesTransitionModel reTransaction) async {
    await printerData.getBluetooth();
    PrintTransactionModel model = PrintTransactionModel(
        transitionModel: reTransaction, personalInformationModel: data);
    connected
        ? printerData.printTicket(
            printTransactionModel: model,
            productList: model.transitionModel!.productList,
            printer58: printer58)
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
                          itemCount:
                              printerData.availableBluetoothDevices.isNotEmpty
                                  ? printerData.availableBluetoothDevices.length
                                  : 0,
                          itemBuilder: (context, index) {
                            return ListTile(
                              onTap: () async {
                                String select = printerData
                                    .availableBluetoothDevices[index];
                                List list = select.split("#");
                                // String name = list[0];
                                String mac = list[1];
                                bool isConnect =
                                    await printerData.setConnect(mac);
                                // ignore: use_build_context_synchronously
                                isConnect
                                    // ignore: use_build_context_synchronously
                                    ? finish(context)
                                    : toast('Try Again');
                              },
                              title: Text(
                                  '${printerData.availableBluetoothDevices[index]}'),
                              subtitle: Text(lang.S.of(context).clickToConnect),
                            );
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 20, bottom: 10),
                          child: Text(
                            lang.S.of(context).pleaseConnectYourBluttothPrinter,
                            style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                            height: 1,
                            width: double.infinity,
                            color: Colors.grey),
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
            lang.S.of(context).salesList,
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
        body: Consumer(builder: (context, consumerRef, __) {
          final providerData = consumerRef.watch(transitionProvider);
          final profile = consumerRef.watch(profileDetailsProvider);
          final printerData = consumerRef.watch(printerProviderNotifier);
          final personalData = consumerRef.watch(profileDetailsProvider);
          final cart = consumerRef.watch(cartNotifier);
          return Container(
            alignment: Alignment.topCenter,
            decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(30),
                    topLeft: Radius.circular(30))),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20.0),
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
                  providerData.when(data: (transaction) {
                    final reTransaction = transaction.reversed.toList();
                    return reTransaction.isNotEmpty
                        ? ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: reTransaction.length,
                            itemBuilder: (context, index) {
                              return GestureDetector(
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Flexible(
                                                child: Text(
                                                  reTransaction[index]
                                                          .customerName
                                                          .isNotEmpty
                                                      ? reTransaction[index]
                                                          .customerName
                                                      : reTransaction[index]
                                                          .customerPhone,
                                                  style: const TextStyle(
                                                      fontSize: 16),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                              const SizedBox(width: 10.0),
                                              Text(
                                                '#${reTransaction[index].invoiceNumber}',
                                                style: const TextStyle(
                                                    color: Colors.black,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                    color: reTransaction[index]
                                                                .dueAmount! <=
                                                            0
                                                        ? const Color(
                                                                0xff0dbf7d)
                                                            .withOpacity(0.1)
                                                        : const Color(
                                                                0xFFED1A3B)
                                                            .withOpacity(0.1),
                                                    borderRadius:
                                                        const BorderRadius.all(
                                                            Radius.circular(
                                                                10))),
                                                child: Text(
                                                  reTransaction[index]
                                                              .dueAmount! <=
                                                          0
                                                      ? 'Paid'
                                                      : 'Unpaid',
                                                  style: TextStyle(
                                                      color: reTransaction[
                                                                      index]
                                                                  .dueAmount! <=
                                                              0
                                                          ? const Color(
                                                              0xff0dbf7d)
                                                          : const Color(
                                                              0xFFED1A3B)),
                                                ),
                                              ),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: [
                                                  Text(
                                                    DateFormat.yMMMd().format(
                                                        DateTime.parse(
                                                            reTransaction[index]
                                                                .purchaseDate)),
                                                    style: const TextStyle(
                                                        color: Colors.grey),
                                                  ),
                                                  const SizedBox(height: 5),
                                                  Text(
                                                    DateFormat.jm().format(
                                                        DateTime.parse(
                                                            reTransaction[index]
                                                                .purchaseDate)),
                                                    style: const TextStyle(
                                                        color: Colors.grey),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Total : $currency ${myFormat.format(reTransaction[index].totalAmount)}',
                                                    style: const TextStyle(
                                                        color: Colors.grey),
                                                  ),
                                                  const SizedBox(height: 3),
                                                  Text(
                                                    'Paid : $currency ${myFormat.format(reTransaction[index].totalAmount!.toDouble() - reTransaction[index].dueAmount!.toDouble())}',
                                                    style: const TextStyle(
                                                        color: Colors.grey),
                                                  ),
                                                  const SizedBox(height: 3),
                                                  Text(
                                                    'Due: $currency ${myFormat.format(reTransaction[index].dueAmount)}',
                                                    style: const TextStyle(
                                                        fontSize: 16),
                                                  ).visible(reTransaction[index]
                                                          .dueAmount!
                                                          .toInt() !=
                                                      0),
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
                                                                  child:
                                                                      SizedBox(
                                                                    child:
                                                                        Column(
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .min,
                                                                      children: [
                                                                        const Padding(
                                                                          padding: EdgeInsets.only(
                                                                              top: 20,
                                                                              bottom: 10),
                                                                          child:
                                                                              Text(
                                                                            "POS Printer",
                                                                            style:
                                                                                TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                                                                          ),
                                                                        ),
                                                                        const SizedBox(
                                                                            height:
                                                                                10),
                                                                        Container(
                                                                            height:
                                                                                1,
                                                                            width:
                                                                                double.infinity,
                                                                            color: Colors.grey),
                                                                        const SizedBox(
                                                                            height:
                                                                                15),
                                                                        Padding(
                                                                          padding: const EdgeInsets
                                                                              .all(
                                                                              8.0),
                                                                          child:
                                                                              PrimaryButton(
                                                                            label:
                                                                                "58 mm",
                                                                            isDisabled:
                                                                                false,
                                                                            onPressed: () => rePrinter(
                                                                                printerData,
                                                                                true,
                                                                                providerData,
                                                                                data,
                                                                                reTransaction[index]),
                                                                          ),
                                                                        ),
                                                                        Padding(
                                                                          padding: const EdgeInsets
                                                                              .all(
                                                                              8.0),
                                                                          child:
                                                                              PrimaryButton(
                                                                            label:
                                                                                "80 mm",
                                                                            isDisabled:
                                                                                false,
                                                                            onPressed: () => rePrinter(
                                                                                printerData,
                                                                                false,
                                                                                providerData,
                                                                                data,
                                                                                reTransaction[index]),
                                                                          ),
                                                                        ),
                                                                        GestureDetector(
                                                                          onTap:
                                                                              () {
                                                                            Navigator.pop(context);
                                                                          },
                                                                          child:
                                                                              Center(
                                                                            child:
                                                                                Padding(
                                                                              padding: const EdgeInsets.all(8.0),
                                                                              child: Text(
                                                                                lang.S.of(context).cacel,
                                                                                style: const TextStyle(color: kMainColor),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        const SizedBox(
                                                                            height:
                                                                                15),
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
                                                        onPressed: () {
                                                          cart.clearCart();
                                                          SalesReportEditScreen(
                                                            transitionModel:
                                                                reTransaction[
                                                                    index],
                                                          ).launch(context);
                                                        },
                                                        icon: const Icon(
                                                          FeatherIcons.edit,
                                                          color: Colors.grey,
                                                        )),
                                                    PopupMenuButton(
                                                      offset:
                                                          const Offset(0, 30),
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(4.0),
                                                      ),
                                                      padding: EdgeInsets.zero,
                                                      itemBuilder:
                                                          (BuildContext bc) => [
                                                        PopupMenuItem(
                                                          child:
                                                              GestureDetector(
                                                            onTap: () async =>
                                                                await GeneratePdf1()
                                                                    .generateSaleDocument(
                                                              reTransaction[
                                                                  index],
                                                              data,
                                                              context,
                                                              // share: false,
                                                            ),
                                                            child: Row(
                                                              children: [
                                                                const Icon(
                                                                  Icons
                                                                      .picture_as_pdf,
                                                                  color: Colors
                                                                      .grey,
                                                                ),
                                                                const SizedBox(
                                                                    width:
                                                                        10.0),
                                                                Text(
                                                                  'Pdf View',
                                                                  style: kTextStyle
                                                                      .copyWith(
                                                                          color:
                                                                              kGreyTextColor),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        PopupMenuItem(
                                                          child:
                                                              GestureDetector(
                                                            onTap: () {
                                                              shareSalePDF(
                                                                transactions:
                                                                    reTransaction[
                                                                        index],
                                                                personalInformation:
                                                                    data,
                                                                context:
                                                                    context,
                                                              );
                                                              // GeneratePdf().generateSaleDocument(transaction[index], data, context, share: true);
                                                              finish(context);
                                                            },
                                                            child: Row(
                                                              children: [
                                                                const Icon(
                                                                  CommunityMaterialIcons
                                                                      .share,
                                                                  color: Colors
                                                                      .grey,
                                                                ),
                                                                const SizedBox(
                                                                  width: 10.0,
                                                                ),
                                                                Text(
                                                                  lang.S
                                                                      .of(context)
                                                                      .share,
                                                                  style: kTextStyle
                                                                      .copyWith(
                                                                          color:
                                                                              kGreyTextColor),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        PopupMenuItem(
                                                          child:
                                                              GestureDetector(
                                                            onTap: () =>
                                                                showDialog(
                                                                    context:
                                                                        context,
                                                                    builder:
                                                                        (context2) =>
                                                                            AlertDialog(
                                                                              title: const Text('Are you sure to delete this sale?'),
                                                                              content: const Text(
                                                                                'The sale will be deleted and all the data will be deleted about this sale.Are you sure to delete this?',
                                                                                maxLines: 5,
                                                                              ),
                                                                              actions: [
                                                                                const Text('Cancel').onTap(() => Navigator.pop(context2)),
                                                                                Padding(
                                                                                  padding: const EdgeInsets.all(20.0),
                                                                                  child: const Text('Yes, Delete Forever').onTap(() async {
                                                                                    EasyLoading.show();

                                                                                    DeleteInvoice delete = DeleteInvoice();

                                                                                    await delete.editStockAndSerial(saleTransactionModel: reTransaction[index]);

                                                                                    await delete.customerDueUpdate(
                                                                                      due: reTransaction[index].dueAmount ?? 0,
                                                                                      phone: reTransaction[index].customerPhone,
                                                                                    );
                                                                                    await delete.updateFromShopRemainBalance(
                                                                                      paidAmount: (reTransaction[index].totalAmount ?? 0) - (reTransaction[index].dueAmount ?? 0),
                                                                                      isFromPurchase: false,
                                                                                    );
                                                                                    await delete.deleteDailyTransaction(invoice: reTransaction[index].invoiceNumber, status: 'Sale', field: "saleTransactionModel");
                                                                                    DatabaseReference ref = FirebaseDatabase.instance.ref("${await getUserID()}/Sales Transition/${reTransaction[index].key}");

                                                                                    await ref.remove();
                                                                                    consumerRef.refresh(transitionProvider);
                                                                                    consumerRef.refresh(productProvider);
                                                                                    consumerRef.refresh(customerProvider);
                                                                                    consumerRef.refresh(profileDetailsProvider);
                                                                                    // consumerRef.refresh(dailyTransactionProvider);
                                                                                    EasyLoading.showSuccess('Done');
                                                                                    // ignore: use_build_context_synchronously
                                                                                    Navigator.pop(context2);
                                                                                    Navigator.pop(bc);
                                                                                  }),
                                                                                ),
                                                                              ],
                                                                            )),
                                                            child: Row(
                                                              children: [
                                                                const Icon(
                                                                  Icons.delete,
                                                                  color:
                                                                      kGreyTextColor,
                                                                ),
                                                                const SizedBox(
                                                                  width: 10.0,
                                                                ),
                                                                Text(
                                                                  'Delete',
                                                                  style: kTextStyle
                                                                      .copyWith(
                                                                          color:
                                                                              kGreyTextColor),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),

                                                        ///________Sale Return___________________________________
                                                        PopupMenuItem(
                                                          child:
                                                              GestureDetector(
                                                            onTap: () =>
                                                                Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder: (context) =>
                                                                    SalesReturn(
                                                                        saleTransactionModel:
                                                                            reTransaction[index]),
                                                              ),
                                                            ),
                                                            child: Row(
                                                              children: [
                                                                const Icon(
                                                                  Icons
                                                                      .keyboard_return_outlined,
                                                                  color:
                                                                      kGreyTextColor,
                                                                ),
                                                                const SizedBox(
                                                                  width: 10.0,
                                                                ),
                                                                Text(
                                                                  'Sale return',
                                                                  style: kTextStyle
                                                                      .copyWith(
                                                                          color:
                                                                              kGreyTextColor),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                      onSelected: (value) {
                                                        Navigator.pushNamed(
                                                            context, '$value');
                                                      },
                                                      child: const Icon(
                                                        FeatherIcons
                                                            .moreVertical,
                                                        color: kGreyTextColor,
                                                      ),
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
                              ).visible(invoiceNumber.isEmptyOrNull
                                  ? true
                                  : reTransaction[index]
                                      .invoiceNumber
                                      .toString()
                                      .contains(invoiceNumber!));
                            },
                          )
                        : const Padding(
                            padding: EdgeInsets.only(top: 60),
                            child: EmptyScreenWidget(),
                          );
                  }, error: (e, stack) {
                    return Text(stack.toString());
                  }, loading: () {
                    return const Center(child: CircularProgressIndicator());
                  }),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
