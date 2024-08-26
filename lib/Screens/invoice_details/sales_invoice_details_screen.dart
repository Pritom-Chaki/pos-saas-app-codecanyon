// ignore_for_file: use_build_context_synchronously
import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mobile_pos/Provider/product_provider.dart';
import 'package:mobile_pos/Widget/primary_button_widget.dart';
import 'package:mobile_pos/const_commas.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import 'package:nb_utils/nb_utils.dart';

import '../../Provider/printer_provider.dart';
import '../../constant.dart' as mainConstant;
import '../../constant.dart' as c;
import '../../currency.dart';
import '../../invoice_constant.dart';
import '../../model/personal_information_model.dart';
import '../../model/print_transaction_model.dart';
import '../../model/transition_model.dart';
import '../../pdf/sales_pdf.dart';
import '../Home/home.dart';

class SalesInvoiceDetails extends StatefulWidget {
  const SalesInvoiceDetails({super.key, required this.transitionModel, required this.personalInformationModel});

  final SalesTransitionModel transitionModel;
  final PersonalInformationModel personalInformationModel;

  @override
  State<SalesInvoiceDetails> createState() => _SalesInvoiceDetailsState();
}

class _SalesInvoiceDetailsState extends State<SalesInvoiceDetails> {
  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, __) {
      ref.refresh(productProvider);

      final printerData = ref.watch(printerProviderNotifier);
      bool isTaxonInvoice = c.isVatAdded(products: widget.transitionModel.productList ?? []);
      return SafeArea(
        child: WillPopScope(
          onWillPop: () async {
            Navigator.pop(context);
            // Handle back button press here
            // You can navigate to the previous screen or perform a specific action
            return false; // Return true to allow the pop
          },
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
                          Text(
                            'Shop GST: ${widget.personalInformationModel.gst}',
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
                    const SizedBox(height: 5.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            widget.transitionModel.customerName,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            style: kTextStyle.copyWith(color: kGreyTextColor),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          DateFormat.yMMMd().format(DateTime.parse(widget.transitionModel.purchaseDate)),
                          textAlign: TextAlign.end,
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
                          DateFormat.jm().format(
                            DateTime.parse(widget.transitionModel.purchaseDate),
                          ),
                          style: kTextStyle.copyWith(color: kGreyTextColor),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          'Party GST: ${widget.transitionModel.customerGst}',
                          style: kTextStyle.copyWith(color: kGreyTextColor),
                        ),
                        const Spacer(),
                        Text(
                          'Seller: ${widget.transitionModel.sellerName.isEmptyOrNull ? 'Admin' : widget.transitionModel.sellerName}',
                          style: kTextStyle.copyWith(color: kTitleColor),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10.0),
                    Divider(
                      thickness: 1.0,
                      color: kGreyTextColor.withOpacity(0.1),
                    ),
                    SizedBox(
                      width: context.width(),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          SizedBox(
                            width: context.width() / (isTaxonInvoice ? 4.2 : 2.4),
                            child: Text(
                              lang.S.of(context).product,
                              maxLines: 2,
                              style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold),
                            ),
                          ),
                          SizedBox(
                            width: (context.width() - (context.width() / 2.4 + 20)) / 3,
                            child: Text(
                              lang.S.of(context).quantity,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold),
                            ),
                          ),
                          SizedBox(
                            width: (context.width() - (context.width() / 2.4 + 20)) / 3,
                            child: Text(
                              lang.S.of(context).unitPirce,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Visibility(
                            visible: isTaxonInvoice,
                            child: SizedBox(
                              width: (context.width() - (context.width() / 2.4 + 20)) / 3,
                              child: Text(
                                "TAX",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: (context.width() - (context.width() / 2.4 + 20)) / 3,
                            child: Text(
                              lang.S.of(context).totalPrice,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      thickness: 1.0,
                      color: kGreyTextColor.withOpacity(0.1),
                    ),
                    const SizedBox(height: 10.0),
                    ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: widget.transitionModel.productList!.length,
                        itemBuilder: (_, i) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 5.0, bottom: 5.0),
                            child: SizedBox(
                              width: context.width(),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    width: context.width() / (isTaxonInvoice ? 4.2 : 2.4),
                                    child: Text(
                                      widget.transitionModel.productList![i].productName.toString(),
                                      maxLines: 2,
                                      style: kTextStyle.copyWith(color: kGreyTextColor),
                                    ),
                                  ),
                                  // const Spacer(),
                                  SizedBox(
                                    width: (context.width() - (context.width() / 2.4 + 20)) / 3,
                                    child: Text(
                                      widget.transitionModel.productList![i].quantity.toString(),
                                      maxLines: 1,
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.ellipsis,
                                      style: kTextStyle.copyWith(color: kGreyTextColor),
                                    ),
                                  ),
                                  SizedBox(
                                    width: (context.width() - (context.width() / 2.4 + 20)) / 3,
                                    child: Text(
                                      '$currency ${myFormat.format(double.tryParse(widget.transitionModel.productList![i].subTotal.toString())?.round() ?? 0)}',
                                      maxLines: 1,
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.ellipsis,
                                      style: kTextStyle.copyWith(color: kGreyTextColor),
                                    ),
                                  ),
                                  Visibility(
                                    visible: isTaxonInvoice,
                                    child: SizedBox(
                                      width: (context.width() - (context.width() / 2.4 + 20)) / 3,
                                      child: Text(
                                        c.calculateProductVat(product: widget.transitionModel.productList![i]).isNotEmpty
                                            ? '$currency ${c.calculateProductVat(product: widget.transitionModel.productList![i])}'
                                            : '$currency 0',
                                        maxLines: 1,
                                        textAlign: TextAlign.center,
                                        overflow: TextOverflow.ellipsis,
                                        style: kTextStyle.copyWith(color: kGreyTextColor),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: (context.width() - (context.width() / 2.4 + 20)) / 3,
                                    child: Text(
                                      '$currency ${myFormat.format((double.tryParse(widget.transitionModel.productList![i].subTotal.toString()) ?? 0) * widget.transitionModel.productList![i].quantity)}',
                                      maxLines: 1,
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.ellipsis,
                                      style: kTextStyle.copyWith(color: kTitleColor),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                    Divider(
                      thickness: 1.0,
                      color: kGreyTextColor.withOpacity(0.1),
                    ),
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.end,
                    //   children: [
                    //     Text(
                    //       lang.S.of(context).totalVat,
                    //       maxLines: 1,
                    //       style: kTextStyle.copyWith(color: kGreyTextColor),
                    //     ),
                    //     const SizedBox(width: 20.0),
                    //     SizedBox(
                    //       width: 120,
                    //       child: Text(
                    //         '$currency ${widget.transitionModel.vat}',
                    //         maxLines: 2,
                    //         style: kTextStyle.copyWith(
                    //             color: kTitleColor,
                    //             fontWeight: FontWeight.bold),
                    //         textAlign: TextAlign.end,
                    //       ),
                    //     ),
                    //   ],
                    // ),

                    ///________vat_______________________________________________
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: c.getAllTaxFromCartList(cart: widget.transitionModel.productList ?? []).length,
                      itemBuilder: (context, index) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              c.getAllTaxFromCartList(cart: widget.transitionModel.productList ?? [])[index].name,
                              maxLines: 1,
                              style: kTextStyle.copyWith(color: kGreyTextColor),
                            ),
                            const SizedBox(width: 20.0),
                            SizedBox(
                              width: 120,
                              child: Text(
                                '${c.getAllTaxFromCartList(cart: widget.transitionModel.productList ?? [])[index].taxRate.toString()}%',
                                maxLines: 2,
                                style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.end,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 5.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          lang.S.of(context).subTotal,
                          maxLines: 1,
                          style: kTextStyle.copyWith(color: kGreyTextColor),
                        ),
                        const SizedBox(width: 20.0),
                        SizedBox(
                          width: 120,
                          child: Text(
                            '$currency ${myFormat.format(widget.transitionModel.totalAmount!.toDouble() + widget.transitionModel.discountAmount!.toDouble())}',
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
                          lang.S.of(context).discount,
                          maxLines: 1,
                          style: kTextStyle.copyWith(color: kGreyTextColor),
                        ),
                        const SizedBox(width: 20.0),
                        SizedBox(
                          width: 120,
                          child: Text(
                            '$currency ${myFormat.format(widget.transitionModel.discountAmount)}',
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
                          lang.S.of(context).deliveryCharge,
                          maxLines: 1,
                          style: kTextStyle.copyWith(color: kGreyTextColor),
                        ),
                        const SizedBox(width: 20.0),
                        SizedBox(
                          width: 120,
                          child: Text(
                            '$currency 0.00',
                            maxLines: 2,
                            style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.end,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          lang.S.of(context).totalPayable,
                          maxLines: 1,
                          style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 20.0),
                        SizedBox(
                          width: 120,
                          child: Text(
                            '$currency ${myFormat.format(widget.transitionModel.totalAmount)}',
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
                          lang.S.of(context).paid,
                          maxLines: 1,
                          style: kTextStyle.copyWith(color: kGreyTextColor),
                        ),
                        const SizedBox(width: 20.0),
                        SizedBox(
                          width: 120,
                          child: Text(
                            '$currency ${myFormat.format(widget.transitionModel.totalAmount! - widget.transitionModel.dueAmount!.toDouble())}',
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
                          lang.S.of(context).due,
                          maxLines: 1,
                          style: kTextStyle.copyWith(color: kGreyTextColor),
                        ),
                        const SizedBox(width: 20.0),
                        SizedBox(
                          width: 120,
                          child: Text(
                            '$currency ${myFormat.format(widget.transitionModel.dueAmount)}',
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
                        lang.S.of(context).thankYouForYourPurchase,
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
              child: Row(children: [
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
                            size: 20,
                          ),
                          Text(
                            lang.S.of(context).cacel,
                            style: const TextStyle(
                              fontSize: 16,
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
                                        onPressed: () =>  rePrinter(printerData, true),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: PrimaryButton(
                                        label: "80 mm",
                                        isDisabled: false,
                                        onPressed: () =>  rePrinter(printerData, false),
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
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      shareSalePDF(
                        transactions: widget.transitionModel,
                        personalInformation: widget.personalInformationModel,
                        context: context,
                      );
                      // GeneratePdf().generateSaleDocument(widget.transitionModel, widget.personalInformationModel, context, share: true);
                    },
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
              ]),
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
          ),
        ),
      );
    });
  }

  void rePrinter(Printer printerData, bool printer58) async{
    await printerData.getBluetooth();
    PrintTransactionModel model = PrintTransactionModel(transitionModel: widget.transitionModel, personalInformationModel: widget.personalInformationModel);
    mainConstant.connected
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
