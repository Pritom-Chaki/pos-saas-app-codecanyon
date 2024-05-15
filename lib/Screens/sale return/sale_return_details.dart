// ignore_for_file: use_build_context_synchronously
import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mobile_pos/Provider/product_provider.dart';
import 'package:mobile_pos/Screens/sale%20return/sale_return_pdf.dart';
import 'package:mobile_pos/const_commas.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import 'package:nb_utils/nb_utils.dart';

import '../../Provider/printer_provider.dart';
import '../../constant.dart' as mainConstant;
import '../../currency.dart';
import '../../invoice_constant.dart';
import '../../model/personal_information_model.dart';
import '../../model/print_transaction_model.dart';
import '../../model/transition_model.dart';
import '../../pdf/sales_pdf.dart';
import '../Home/home.dart';

class SaleReturnDetails extends StatefulWidget {
  const SaleReturnDetails({super.key, required this.transitionModel, required this.personalInformationModel});

  final SalesTransitionModel transitionModel;
  final PersonalInformationModel personalInformationModel;

  @override
  State<SaleReturnDetails> createState() => _SaleReturnDetailsState();
}

class _SaleReturnDetailsState extends State<SaleReturnDetails> {
  double totalAmount({required SalesTransitionModel transactions}) {
    double amount = 0;

    for (var element in transactions.productList!) {
      amount = amount + double.parse(element.subTotal) * double.parse(element.quantity.toString());
    }

    return double.parse(amount.toStringAsFixed(2));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, __) {
      ref.refresh(productProvider);
      final printerData = ref.watch(printerProviderNotifier);
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
                          '',
                          style: kTextStyle.copyWith(color: kTitleColor),
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
                            width: context.width() / 2.4,
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
                                    width: context.width() / 2.4,
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
                                      '$currency ${myFormat.format(int.tryParse(widget.transitionModel.productList![i].subTotal) ?? 0)}',
                                      maxLines: 1,
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.ellipsis,
                                      style: kTextStyle.copyWith(color: kGreyTextColor),
                                    ),
                                  ),
                                  SizedBox(
                                    width: (context.width() - (context.width() / 2.4 + 20)) / 3,
                                    child: Text(
                                      '$currency ${myFormat.format(double.parse(widget.transitionModel.productList![i].subTotal) * widget.transitionModel.productList![i].quantity)}',
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'Return Amount',
                          maxLines: 1,
                          style: kTextStyle.copyWith(color: kGreyTextColor),
                        ),
                        const SizedBox(width: 20.0),
                        SizedBox(
                          width: 120,
                          child: Text(
                            myFormat.format(double.tryParse(totalAmount(transactions: widget.transitionModel).toString()) ?? 0),
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
                          'Service/Shipping',
                          maxLines: 1,
                          style: kTextStyle.copyWith(color: kGreyTextColor),
                        ),
                        const SizedBox(width: 20.0),
                        SizedBox(
                          width: 120,
                          child: Text(
                            '$currency ${0}',
                            maxLines: 2,
                            style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.end,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5.0),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SizedBox(
                          width: 300,
                          child: Divider(color: Colors.grey),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'Total Return Amount',
                          maxLines: 1,
                          style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 20.0),
                        SizedBox(
                          width: 120,
                          child: Text(
                            myFormat.format(double.tryParse(widget.transitionModel.totalAmount.toString()) ?? 0),
                            maxLines: 2,
                            style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.end,
                          ),
                        ),
                      ],
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
                      await SaleReturn().generateSaleReturn(widget.personalInformationModel, widget.transitionModel, context);
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
                      shareSaleReturnPDF(
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
}
