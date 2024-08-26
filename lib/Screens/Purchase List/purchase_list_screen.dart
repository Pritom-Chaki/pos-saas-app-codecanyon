import 'package:community_material_icon/community_material_icon.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mobile_pos/Provider/print_purchase_provider.dart';
import 'package:mobile_pos/Provider/transactions_provider.dart';
import 'package:mobile_pos/Screens/Purchase%20List/purchase_list_edit_screen.dart';
import 'package:mobile_pos/Widget/primary_button_widget.dart';
import 'package:mobile_pos/const_commas.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import 'package:mobile_pos/model/personal_information_model.dart';
import 'package:mobile_pos/model/product_model.dart';
import 'package:mobile_pos/model/transition_model.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../Provider/profile_provider.dart';
import '../../../constant.dart';
import '../../../model/print_transaction_model.dart';
import '../../Provider/add_to_cart_purchase.dart';
import '../../Provider/customer_provider.dart';
import '../../Provider/product_provider.dart';
import '../../currency.dart';
import '../../empty_screen_widget.dart';
import '../../generate_pdf.dart';
import '../../pdf/purchase_pdf.dart';
import '../Home/home.dart';
import '../invoice_details/purchase_invoice_details.dart';
import '../purchase return/purchase_return_screen.dart';

class PurchaseListScreen extends StatefulWidget {
  const PurchaseListScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _PurchaseReportState createState() => _PurchaseReportState();
}

class _PurchaseReportState extends State<PurchaseListScreen> {
  String? invoiceNumber;

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
            lang.S.of(context).purchaseList,
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
          final providerData = ref.watch(purchaseTransitionProvider);
          final printerData = ref.watch(printerPurchaseProviderNotifier);
          final personalData = ref.watch(profileDetailsProvider);
          final profile = ref.watch(profileDetailsProvider);
          final cart = ref.watch(cartNotifierPurchase);

          return Container(
            alignment: Alignment.topCenter,
            decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(topRight: Radius.circular(30), topLeft: Radius.circular(30))),
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
                                  PurchaseInvoiceDetails(
                                    personalInformationModel: profile.value!,
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
                                              SizedBox(
                                                width: 240,
                                                child: Text(
                                                  reTransaction[index].customerName.isNotEmpty
                                                      ? reTransaction[index].customerName
                                                      : reTransaction[index].customerPhone,
                                                  style: const TextStyle(fontSize: 16),
                                                ),
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
                                                  const SizedBox(height: 5),
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
                                                                            onPressed: () {
                                                                              printType(printerData, data, reTransaction[index], true);
                                                                            },
                                                                          ),
                                                                        ),
                                                                        Padding(
                                                                          padding: const EdgeInsets.all(8.0),
                                                                          child: PrimaryButton(
                                                                            label: "80 mm",
                                                                            isDisabled: false,
                                                                            onPressed: () {
                                                                              printType(printerData, data, reTransaction[index], false);
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
                                                        onPressed: () {
                                                          cart.clearCart();
                                                          PurchaseListEditScreen(
                                                            transitionModel: reTransaction[index],
                                                          ).launch(context);
                                                        },
                                                        icon: const Icon(
                                                          FeatherIcons.edit,
                                                          color: Colors.grey,
                                                        )),
                                                    PopupMenuButton(
                                                      offset: const Offset(0, 30),
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(4.0),
                                                      ),
                                                      padding: EdgeInsets.zero,
                                                      itemBuilder: (BuildContext bc) => [
                                                        PopupMenuItem(
                                                          child: GestureDetector(
                                                            onTap: () async => await GeneratePdf1().generatePurchaseDocument(
                                                              transaction[index],
                                                              data,
                                                              context,
                                                            ),
                                                            // onTap: () async {
                                                            //  await GeneratePdf1().generatePurchaseDocument(transaction[index], data, context,);
                                                            //   finish(context);
                                                            // },
                                                            child: Row(
                                                              children: [
                                                                const Icon(
                                                                  Icons.picture_as_pdf,
                                                                  color: Colors.grey,
                                                                ),
                                                                const SizedBox(
                                                                  width: 10.0,
                                                                ),
                                                                Text(
                                                                  'Pdf View',
                                                                  style: kTextStyle.copyWith(color: kGreyTextColor),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        PopupMenuItem(
                                                          child: GestureDetector(
                                                            onTap: () {
                                                              sharePurchasePDF(transactions: transaction[index], personalInformation: data, context: context);
                                                              // GeneratePdf().generatePurchaseDocument(transaction[index], data, context, share: true);
                                                              finish(context);
                                                            },
                                                            child: Row(
                                                              children: [
                                                                const Icon(
                                                                  CommunityMaterialIcons.share,
                                                                  color: Colors.grey,
                                                                ),
                                                                const SizedBox(
                                                                  width: 10.0,
                                                                ),
                                                                Text(
                                                                  lang.S.of(context).share,
                                                                  style: kTextStyle.copyWith(color: kGreyTextColor),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),

                                                        ///_______ List Delete_______________________________
                                                        PopupMenuItem(
                                                          child: GestureDetector(
                                                            onTap: () => showDialog(
                                                                context: context,
                                                                builder: (dontext) => AlertDialog(
                                                                      title: const Text('Are you sure to delete this invoice?'),
                                                                      content: const Text(
                                                                        'The sale will be deleted and all the data will be deleted about this purchase.Are you sure to delete this?',
                                                                        maxLines: 5,
                                                                      ),
                                                                      actions: [
                                                                        const Text('Cancel').onTap(() => Navigator.pop(dontext)),
                                                                        Padding(
                                                                          padding: const EdgeInsets.all(20.0),
                                                                          child: const Text('Yes, Delete Forever').onTap(() async {
                                                                            for (ProductModel element in reTransaction[index].productList!) {
                                                                              decreaseStock(element.productCode, element.productStock.toInt());
                                                                            }
                                                                            getSpecificCustomersDueUpdate(
                                                                              phoneNumber: reTransaction[index].customerPhone,
                                                                              isDuePaid: false,
                                                                              due: reTransaction[index].dueAmount ?? 0,
                                                                            );
                                                                            updateFromShopRemainBalance(
                                                                                isFromPurchase: true,
                                                                                paidAmount: (reTransaction[index].totalAmount ?? 0) -
                                                                                    (reTransaction[index].dueAmount ?? 0),
                                                                                t: ref);
                                                                            DatabaseReference firebaseRef = FirebaseDatabase.instance
                                                                                .ref("$constUserId/Purchase Transition/${reTransaction[index].key}");
                                                                            firebaseRef.keepSynced(true);
                                                                            await firebaseRef.remove();
                                                                            ref.refresh(purchaseTransitionProvider);
                                                                            ref.refresh(productProvider);
                                                                            ref.refresh(customerProvider);
                                                                            ref.refresh(profileDetailsProvider);
                                                                            // ignore: use_build_context_synchronously
                                                                            Navigator.pop(dontext);
                                                                            Navigator.pop(bc);
                                                                          }),
                                                                        ),
                                                                      ],
                                                                    )),
                                                            child: Row(
                                                              children: [
                                                                const Icon(
                                                                  CommunityMaterialIcons.delete,
                                                                  color: Colors.grey,
                                                                ),
                                                                const SizedBox(
                                                                  width: 10.0,
                                                                ),
                                                                Text(
                                                                  'Delete',
                                                                  style: kTextStyle.copyWith(color: kGreyTextColor),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),

                                                        ///_______Purchase_Return_______________________________
                                                        PopupMenuItem(
                                                          child: GestureDetector(
                                                            onTap: () => Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                  builder: (context) => PurchaseReturnScreen(
                                                                    purchaseTransactionModel: reTransaction[index],
                                                                  ),
                                                                )),
                                                            child: Row(
                                                              children: [
                                                                const Icon(
                                                                  CommunityMaterialIcons.keyboard_return,
                                                                  color: Colors.grey,
                                                                ),
                                                                const SizedBox(width: 10.0),
                                                                Text(
                                                                  'Purchase Return',
                                                                  style: kTextStyle.copyWith(color: kGreyTextColor),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                      onSelected: (value) {
                                                        Navigator.pushNamed(context, '$value');
                                                      },
                                                      child: const Icon(
                                                        FeatherIcons.moreVertical,
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
                              ).visible(invoiceNumber.isEmptyOrNull ? true : reTransaction[index].invoiceNumber.toString().contains(invoiceNumber!));
                            },
                          )
                        : const Padding(
                            padding: EdgeInsets.only(top: 60),
                            child: EmptyScreenWidget(),
                          );
                  }, error: (e, stack) {
                    return Text(e.toString());
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

  void printType(PrinterPurchase printerData, PersonalInformationModel data, PurchaseTransactionModel reTransaction, bool printer58) async{
    ///________Print_______________________________________________________
    await printerData.getBluetooth();
    PrintPurchaseTransactionModel model = PrintPurchaseTransactionModel(
        purchaseTransitionModel: reTransaction, personalInformationModel: data);
    if (connected) {
      await printerData.printTicket(
          printTransactionModel: model,
          productList: model.purchaseTransitionModel!.productList,
          printer58: printer58
      );
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

  }

}
