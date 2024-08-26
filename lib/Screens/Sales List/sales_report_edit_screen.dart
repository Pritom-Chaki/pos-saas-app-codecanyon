import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mobile_pos/Provider/add_to_cart.dart';
import 'package:mobile_pos/Provider/profile_provider.dart';
import 'package:mobile_pos/Screens/Sales%20List/sales_Edit_invoice_add_products.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import 'package:mobile_pos/model/transition_model.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../Provider/customer_provider.dart';
import '../../Provider/product_provider.dart';
import '../../Provider/seles_report_provider.dart';
import '../../Provider/transactions_provider.dart';
import '../../constant.dart';
import '../../currency.dart';
import '../../model/add_to_cart_model.dart';
import '../Customers/Model/customer_model.dart';

// ignore: must_be_immutable
class SalesReportEditScreen extends StatefulWidget {
  SalesReportEditScreen({super.key, required this.transitionModel});

  SalesTransitionModel transitionModel;

  @override
  State<SalesReportEditScreen> createState() => _SalesReportEditScreenState();
}

class _SalesReportEditScreenState extends State<SalesReportEditScreen> {
  @override
  void initState() {
    pastProducts = widget.transitionModel.productList!;
    // TODO: implement initState
    super.initState();
    transitionModel = widget.transitionModel;

    paidAmount = double.parse(widget.transitionModel.totalAmount.toString()) -
        double.parse(widget.transitionModel.dueAmount.toString()) +
        double.parse(widget.transitionModel.returnAmount.toString());
    discountAmount = widget.transitionModel.discountAmount!;
    // vatAmount = widget.transitionModel.vat!;
    dropdownValue = widget.transitionModel.paymentType;
    discountText.text = discountAmount.toString();
    // vatText.text = vatAmount.toString();
    paidText.text = paidAmount.toString();
    pastDue = widget.transitionModel.dueAmount!.toInt();
    returnAmount = widget.transitionModel.returnAmount!;
    invoice = widget.transitionModel.invoiceNumber.toInt();
  }

  int pastDue = 0;

  TextEditingController discountText = TextEditingController();
  // TextEditingController vatText = TextEditingController();
  TextEditingController paidText = TextEditingController();

  int invoice = 0;
  double paidAmount = 0;
  double discountAmount = 0;
  // double vatAmount = 0;
  double returnAmount = 0;
  double dueAmount = 0;
  double subTotal = 0;

  bool isGuestCustomer = false;

  List<AddToCartModel> pastProducts = [];
  List<AddToCartModel> presentProducts = [];
  List<AddToCartModel> increaseStockList = [];
  List<AddToCartModel> decreaseStockList = [];

  String? dropdownValue = 'Cash';
  String? selectedPaymentType;

  double calculateSubtotal({required double total}) {
    // subTotal = total - discountAmount;
    // return total - discountAmount;
    subTotal = total - discountAmount;
    return total - discountAmount;
  }

  double calculateReturnAmount({required double total}) {
    if (widget.transitionModel.customerType == 'Guest') {
      return 0;
    }
    returnAmount = total - paidAmount;
    return paidAmount <= 0 || paidAmount <= subTotal ? 0 : total - paidAmount;
  }

  double calculateDueAmount({required double total}) {
    if (widget.transitionModel.customerType == 'Guest') {
      return 0;
    }
    if (total < 0) {
      dueAmount = 0;
    } else {
      dueAmount = subTotal - paidAmount;
    }
    return returnAmount <= 0 ? 0 : subTotal - paidAmount;
  }

  late SalesTransitionModel transitionModel = SalesTransitionModel(
    customerName: widget.transitionModel.customerName,
    customerAddress: widget.transitionModel.customerAddress,
    customerImage: widget.transitionModel.customerImage,
    customerGst: widget.transitionModel.customerGst,
    customerPhone: '',
    customerType: '',
    invoiceNumber: invoice.toString(),
    purchaseDate: DateTime.now().toString(),
    vat: 0,
    serviceCharge: 0,
  );
  DateTime selectedDate = DateTime.now();
  bool doNotCheckProducts = false;

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, consumerRef, __) {
      final providerData = consumerRef.watch(cartNotifier);
      final personalData = consumerRef.watch(profileDetailsProvider);
      final productList = consumerRef.watch(productProvider);

      if (!doNotCheckProducts) {
        List<AddToCartModel> list = [];
        productList.value?.forEach((products) {
          String sentProductPrice = '';

          widget.transitionModel.productList?.forEach((element) {
            if (element.productId == products.productCode &&
                element.subTotal == products.productSalePrice) {
              if (widget.transitionModel.customerType.contains('Retailer')) {
                sentProductPrice = products.productSalePrice;
              } else if (widget.transitionModel.customerType
                  .contains('Dealer')) {
                sentProductPrice = products.productDealerPrice;
              } else if (widget.transitionModel.customerType
                  .contains('Wholesaler')) {
                sentProductPrice = products.productWholeSalePrice;
              } else if (widget.transitionModel.customerType
                  .contains('Supplier')) {
                sentProductPrice = products.productPurchasePrice;
              } else if (widget.transitionModel.customerType
                  .contains('Guest')) {
                sentProductPrice = products.productSalePrice;
                isGuestCustomer = true;
              }

              AddToCartModel cartItem = AddToCartModel(
                productName: products.productName,
                warehouseName: products.warehouseName,
                warehouseId: products.warehouseId,
                productImage: products.productPicture,
                subTotal: sentProductPrice,
                quantity: element.quantity,
                productId: products.productCode,
                productBrandName: products.brandName,
                productPurchasePrice: products.productPurchasePrice,
                stock: num.parse(products.productStock),
                subTaxes: products.subTaxes,
                excTax: products.excTax,
                groupTaxName: products.groupTaxName,
                groupTaxRate: products.groupTaxRate,
                incTax: products.incTax,
                margin: products.margin,
                taxType: products.taxType,
              );
              list.add(cartItem);

              // providerData.addProductsInSales(products);
            } else if (element.productId == products.productCode) {
              if (widget.transitionModel.customerType.contains('Retailer')) {
                sentProductPrice = element.subTotal.toString();
              } else if (widget.transitionModel.customerType
                  .contains('Dealer')) {
                sentProductPrice = products.productDealerPrice;
              } else if (widget.transitionModel.customerType
                  .contains('Wholesaler')) {
                sentProductPrice = products.productWholeSalePrice;
              } else if (widget.transitionModel.customerType
                  .contains('Supplier')) {
                sentProductPrice = element.productPurchasePrice.toString();
              } else if (widget.transitionModel.customerType
                  .contains('Guest')) {
                sentProductPrice = element.subTotal.toString();
                isGuestCustomer = true;
              }

              AddToCartModel cartItem = AddToCartModel(
                productName: products.productName,
                warehouseName: products.warehouseName,
                warehouseId: products.warehouseId,
                productImage: products.productPicture,
                subTotal: sentProductPrice,
                quantity: element.quantity,
                productId: products.productCode,
                productBrandName: products.brandName,
                productPurchasePrice: element.productPurchasePrice.toString(),
                stock: num.parse(products.productStock),
                subTaxes: products.subTaxes,
                excTax: products.excTax,
                groupTaxName: products.groupTaxName,
                groupTaxRate: products.groupTaxRate,
                incTax: products.incTax,
                margin: products.margin,
                taxType: products.taxType,
              );
              list.add(cartItem);
            }
          });

          if (widget.transitionModel.productList?.length == list.length) {
            providerData.addToCartRiverPodForEdit(list);
            doNotCheckProducts = true;
          }
        });
      }
      return personalData.when(data: (data) {
        // invoice = data.invoiceCounter!.toInt();
        return Scaffold(
          backgroundColor: kMainColor,
          appBar: AppBar(
            backgroundColor: kMainColor,
            title: Text(
              lang.S.of(context).editSalesInvoice,
              style: GoogleFonts.poppins(
                color: Colors.white,
              ),
            ),
            centerTitle: true,
            iconTheme: const IconThemeData(color: Colors.white),
            elevation: 0.0,
          ),
          body: Container(
            alignment: Alignment.topCenter,
            decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(30),
                    topLeft: Radius.circular(30))),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: AppTextField(
                            textFieldType: TextFieldType.NAME,
                            readOnly: true,
                            initialValue: widget.transitionModel.invoiceNumber,
                            decoration: InputDecoration(
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.always,
                              labelText: lang.S.of(context).invNo,
                              border: const OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: AppTextField(
                            textFieldType: TextFieldType.NAME,
                            readOnly: true,
                            initialValue:
                                DateFormat.yMMMd().format(DateTime.parse(
                              widget.transitionModel.purchaseDate,
                            )),
                            decoration: InputDecoration(
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.always,
                              labelText: lang.S.of(context).date,
                              border: const OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    AppTextField(
                      textFieldType: TextFieldType.NAME,
                      readOnly: true,
                      initialValue:
                          widget.transitionModel.customerName.isNotEmpty
                              ? widget.transitionModel.customerName
                              : widget.transitionModel.customerPhone,
                      decoration: InputDecoration(
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        labelText: lang.S.of(context).customerName,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),

                    ///_______Added_ItemS__________________________________________________
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10)),
                        border: Border.all(
                            width: 1, color: const Color(0xffEAEFFA)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                              width: double.infinity,
                              decoration: const BoxDecoration(
                                color: Color(0xffEAEFFA),
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    topRight: Radius.circular(10)),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: SizedBox(
                                  width: context.width() / 1.35,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        lang.S.of(context).itemAdded,
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                      Text(
                                        lang.S.of(context).quantity,
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ],
                                  ),
                                ),
                              )),
                          ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: providerData.cartItemList.length,
                              itemBuilder: (context, index) {
                                int i = 0;
                                for (var element in pastProducts) {
                                  if (element.productId !=
                                      providerData
                                          .cartItemList[index].productId) {
                                    i++;
                                  }
                                  if (i == pastProducts.length) {
                                    bool isInTheList = false;
                                    for (var element in decreaseStockList) {
                                      if (element.productId ==
                                          providerData
                                              .cartItemList[index].productId) {
                                        element.quantity = providerData
                                            .cartItemList[index].quantity;
                                        isInTheList = true;
                                        break;
                                      }
                                    }

                                    isInTheList
                                        ? null
                                        : decreaseStockList.add(
                                            providerData.cartItemList[index]);
                                  }
                                }
                                TextEditingController quantityController =
                                    TextEditingController(
                                        text: providerData
                                            .cartItemList[index].quantity
                                            .toString());
                                return Padding(
                                  padding: const EdgeInsets.only(
                                      left: 10, right: 10),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.all(0),
                                    title: Text(providerData
                                        .cartItemList[index].productName
                                        .toString()),
                                    subtitle: Text(
                                        '${providerData.cartItemList[index].quantity} X ${providerData.cartItemList[index].subTotal} = ${double.parse(providerData.cartItemList[index].subTotal) * providerData.cartItemList[index].quantity}'),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SizedBox(
                                          width: 100,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              GestureDetector(
                                                onTap: () {
                                                  providerData
                                                      .quantityDecrease(index);
                                                },
                                                child: Container(
                                                  height: 20,
                                                  width: 20,
                                                  decoration:
                                                      const BoxDecoration(
                                                    color: kMainColor,
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                10)),
                                                  ),
                                                  child: const Center(
                                                    child: Text(
                                                      '-',
                                                      style: TextStyle(
                                                          fontSize: 14,
                                                          color: Colors.white),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 5),
                                              // Text(
                                              //   '${providerData.cartItemList[index].quantity}',
                                              //   style: GoogleFonts.poppins(
                                              //     color: kGreyTextColor,
                                              //     fontSize: 15.0,
                                              //   ),
                                              // ),
                                              SizedBox(
                                                width: 50,
                                                child: TextFormField(
                                                  // initialValue: quantityController.text,
                                                  controller:
                                                      quantityController,
                                                  textAlign: TextAlign.center,
                                                  keyboardType:
                                                      TextInputType.phone,
                                                  onFieldSubmitted: (value) {
                                                    num stock = (num.tryParse(
                                                            providerData
                                                                .cartItemList[
                                                                    index]
                                                                .stock
                                                                .toString()) ??
                                                        0);
                                                    if (value.isEmpty ||
                                                        value == '0' ||
                                                        num.tryParse(value) ==
                                                            null) {
                                                      value = '1';
                                                    } else if (stock <
                                                        num.parse(value)) {
                                                      EasyLoading.showError(
                                                          'Out of Stock');
                                                      value = '1';
                                                    }
                                                    providerData
                                                            .cartItemList[index]
                                                            .quantity =
                                                        num.parse(value);
                                                  },
                                                  decoration:
                                                      const InputDecoration(
                                                          border:
                                                              InputBorder.none),
                                                ),
                                              ),
                                              const SizedBox(width: 5),
                                              GestureDetector(
                                                onTap: () {
                                                  providerData
                                                      .quantityIncrease(index);
                                                },
                                                child: Container(
                                                  height: 20,
                                                  width: 20,
                                                  decoration:
                                                      const BoxDecoration(
                                                    color: kMainColor,
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                10)),
                                                  ),
                                                  child: const Center(
                                                      child: Text(
                                                    '+',
                                                    style: TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.white),
                                                  )),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        GestureDetector(
                                          onTap: () {
                                            int i = 0;
                                            for (var element in pastProducts) {
                                              if (element.productId !=
                                                  providerData
                                                      .cartItemList[index]
                                                      .productId) {
                                                i++;
                                              }
                                              if (i == pastProducts.length) {
                                                decreaseStockList.removeWhere(
                                                    (element) =>
                                                        element.productId ==
                                                        providerData
                                                            .cartItemList[index]
                                                            .productId);
                                              }
                                            }

                                            providerData.deleteToCart(index);
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            color: Colors.red.withOpacity(0.1),
                                            child: const Icon(
                                              Icons.delete,
                                              size: 20,
                                              color: Colors.red,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                        ],
                      ).visible(providerData.cartItemList.isNotEmpty),
                    ),
                    const SizedBox(height: 20),

                    ///_______Add_Button__________________________________________________
                    GestureDetector(
                      onTap: () {
                        EditSaleInvoiceSaleProducts(
                          catName: null,
                          customerModel: CustomerModel(
                              widget.transitionModel.customerName,
                              widget.transitionModel.customerPhone,
                              widget.transitionModel.customerType,
                              '',
                              '',
                              gst: widget.transitionModel.customerGst,
                              'customerAddress',
                              '',
                              '',
                              '',
                              ''),
                          transitionModel: widget.transitionModel,
                        ).launch(context);
                      },
                      child: Container(
                        height: 50,
                        width: double.infinity,
                        decoration: BoxDecoration(
                            color: kMainColor.withOpacity(0.1),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10))),
                        child: Center(
                            child: Text(
                          lang.S.of(context).addItems,
                          style:
                              const TextStyle(color: kMainColor, fontSize: 20),
                        )),
                      ),
                    ),
                    const SizedBox(height: 20),

                    ///_____Total______________________________
                    Container(
                      decoration: BoxDecoration(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10)),
                          border: Border.all(
                              color: Colors.grey.shade300, width: 1)),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: const BoxDecoration(
                                color: Color(0xffEAEFFA),
                                borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(10),
                                    topLeft: Radius.circular(10))),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  lang.S.of(context).subTotal,
                                  style: const TextStyle(fontSize: 16),
                                ),
                                Text(
                                  providerData.getTotalAmount().toString(),
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  lang.S.of(context).discount,
                                  style: const TextStyle(fontSize: 16),
                                ),
                                SizedBox(
                                  width: context.width() / 4,
                                  child: TextField(
                                    controller: discountText,
                                    onChanged: (value) {
                                      if (value == '') {
                                        setState(() {
                                          discountAmount = 0;
                                        });
                                      } else {
                                        if (value.toInt() <=
                                            providerData.getTotalAmount()) {
                                          setState(() {
                                            discountAmount =
                                                double.parse(value);
                                          });
                                        } else {
                                          discountText.clear();
                                          setState(() {
                                            discountAmount = 0;
                                          });
                                          EasyLoading.showError(
                                              'Enter a valid Discount');
                                        }
                                      }
                                    },
                                    textAlign: TextAlign.right,
                                    decoration: const InputDecoration(
                                      hintText: '0',
                                    ),
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: getAllTaxFromCartList(
                                      cart: providerData.cartItemList)
                                  .length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        getAllTaxFromCartList(
                                                cart: providerData
                                                    .cartItemList)[index]
                                            .name,
                                        style: TextStyle(fontSize: 16),
                                      ),
                                      Row(
                                        children: [
                                          SizedBox(
                                            width: context.width() / 4,
                                            height: 40.0,
                                            child: Center(
                                              child: AppTextField(
                                                inputFormatters: [
                                                  FilteringTextInputFormatter
                                                      .allow(RegExp(
                                                          r'^\d*\.?\d{0,2}'))
                                                ],
                                                initialValue: getAllTaxFromCartList(
                                                            cart: providerData
                                                                .cartItemList)[
                                                        index]
                                                    .taxRate
                                                    .toString(),
                                                readOnly: true,
                                                textAlign: TextAlign.right,
                                                decoration: InputDecoration(
                                                  contentPadding:
                                                      const EdgeInsets.only(
                                                          right: 6.0),
                                                  hintText: '0',
                                                  border:
                                                      const OutlineInputBorder(
                                                          gapPadding: 0.0,
                                                          borderSide: BorderSide(
                                                              color: Color(
                                                                  0xFFff5f00))),
                                                  enabledBorder:
                                                      const OutlineInputBorder(
                                                          gapPadding: 0.0,
                                                          borderSide: BorderSide(
                                                              color: Color(
                                                                  0xFFff5f00))),
                                                  disabledBorder:
                                                      const OutlineInputBorder(
                                                          gapPadding: 0.0,
                                                          borderSide: BorderSide(
                                                              color: Color(
                                                                  0xFFff5f00))),
                                                  focusedBorder:
                                                      const OutlineInputBorder(
                                                          gapPadding: 0.0,
                                                          borderSide: BorderSide(
                                                              color: Color(
                                                                  0xFFff5f00))),
                                                  prefixIconConstraints:
                                                      const BoxConstraints(
                                                          maxWidth: 30.0,
                                                          minWidth: 30.0),
                                                  prefixIcon: Container(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 8.0,
                                                            left: 8.0),
                                                    height: 40,
                                                    decoration: const BoxDecoration(
                                                        color:
                                                            Color(0xFFff5f00),
                                                        borderRadius:
                                                            BorderRadius.only(
                                                                topLeft: Radius
                                                                    .circular(
                                                                        4.0),
                                                                bottomLeft: Radius
                                                                    .circular(
                                                                        4.0))),
                                                    child: const Text(
                                                      '%',
                                                      style: TextStyle(
                                                          fontSize: 18.0,
                                                          color: Colors.white),
                                                    ),
                                                  ),
                                                ),
                                                textFieldType:
                                                    TextFieldType.PHONE,
                                              ),
                                            ),
                                          ),
                                          // const SizedBox(width: 4.0),
                                          // SizedBox(
                                          //   width: context.width() / 4,
                                          //   height: 40.0,
                                          //   child: Center(
                                          //     child: AppTextField(
                                          //       inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
                                          //       initialValue: (calculateSubtotal(total: providerData.getTotalAmount()) * (providerData.taxRates[index].taxRate.toInt() / 100)).toString(),
                                          //       readOnly: true,
                                          //       onChanged: (value) {
                                          //         if (value == '') {
                                          //           setState(() {
                                          //             vatAmount = 0;
                                          //             vatPercentageEditingController.clear();
                                          //           });
                                          //         } else {
                                          //           setState(() {
                                          //             vatAmount = double.parse(value);
                                          //             vatPercentageEditingController.text = ((vatAmount * 100) / providerData.getTotalAmount()).toString();
                                          //           });
                                          //         }
                                          //       },
                                          //       textAlign: TextAlign.right,
                                          //       decoration: InputDecoration(
                                          //         contentPadding: const EdgeInsets.only(right: 6.0),
                                          //         hintText: '0',
                                          //         border: const OutlineInputBorder(gapPadding: 0.0, borderSide: BorderSide(color: kMainColor)),
                                          //         enabledBorder: const OutlineInputBorder(gapPadding: 0.0, borderSide: BorderSide(color: kMainColor)),
                                          //         disabledBorder: const OutlineInputBorder(gapPadding: 0.0, borderSide: BorderSide(color: kMainColor)),
                                          //         focusedBorder: const OutlineInputBorder(gapPadding: 0.0, borderSide: BorderSide(color: kMainColor)),
                                          //         prefixIconConstraints: const BoxConstraints(maxWidth: 30.0, minWidth: 30.0),
                                          //         prefixIcon: Container(
                                          //           alignment: Alignment.center,
                                          //           height: 40,
                                          //           decoration: const BoxDecoration(
                                          //               color: kMainColor,
                                          //               borderRadius: BorderRadius.only(topLeft: Radius.circular(4.0), bottomLeft: Radius.circular(4.0))),
                                          //           child: Text(
                                          //             currency,
                                          //             style: const TextStyle(fontSize: 14.0, color: Colors.white),
                                          //           ),
                                          //         ),
                                          //       ),
                                          //       textFieldType: TextFieldType.PHONE,
                                          //     ),
                                          //   ),
                                          // ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              }),
                          // Padding(
                          //   padding: const EdgeInsets.all(10.0),
                          //   child: Row(
                          //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          //     children: [
                          //       const Text(
                          //         'Vat',
                          //         style: TextStyle(fontSize: 16),
                          //       ),
                          //       SizedBox(
                          //         width: context.width() / 4,
                          //         child: TextField(
                          //           controller: vatText,
                          //           onChanged: (value) {
                          //             if (value == '') {
                          //               setState(() {
                          //                 vatAmount = 0;
                          //               });
                          //             } else {
                          //               if (value.toInt() <= providerData.getTotalAmount()) {
                          //                 setState(() {
                          //                   vatAmount = double.parse(value);
                          //                 });
                          //               } else {
                          //                 vatText.clear();
                          //                 setState(() {
                          //                   vatAmount = 0;
                          //                 });
                          //                 EasyLoading.showError('Enter a valid Discount');
                          //               }
                          //             }
                          //           },
                          //           textAlign: TextAlign.right,
                          //           decoration: const InputDecoration(
                          //             hintText: '0',
                          //           ),
                          //           keyboardType: TextInputType.number,
                          //         ),
                          //       ),
                          //     ],
                          //   ),
                          // ),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  lang.S.of(context).total,
                                  style: const TextStyle(fontSize: 16),
                                ),
                                Text(
                                  calculateSubtotal(
                                          total: providerData.getTotalAmount())
                                      .toString(),
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                          Visibility(
                            visible:
                                widget.transitionModel.customerType != 'Guest',
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    lang.S.of(context).previousPayAmounts,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  Text(
                                    (double.parse(widget
                                                .transitionModel.totalAmount
                                                .toString()) -
                                            double.parse(widget
                                                .transitionModel.dueAmount
                                                .toString()) +
                                            double.parse(widget
                                                .transitionModel.returnAmount
                                                .toString()))
                                        .toString(),
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          Visibility(
                            visible:
                                widget.transitionModel.customerType != 'Guest',
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    lang.S.of(context).paidAmount,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  SizedBox(
                                    width: context.width() / 4,
                                    child: TextField(
                                      controller: paidText,
                                      keyboardType: TextInputType.number,
                                      onChanged: (value) {
                                        if (value == '') {
                                          setState(() {
                                            paidAmount = 0;
                                          });
                                        } else {
                                          setState(() {
                                            paidAmount = double.parse(value);
                                          });
                                        }
                                      },
                                      textAlign: TextAlign.right,
                                      decoration:
                                          const InputDecoration(hintText: '0'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  lang.S.of(context).returnAmount,
                                  style: const TextStyle(fontSize: 16),
                                ),
                                Text(
                                  calculateReturnAmount(total: subTotal)
                                      .abs()
                                      .toString(),
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  lang.S.of(context).dueAmount,
                                  style: const TextStyle(fontSize: 16),
                                ),
                                Text(
                                  calculateDueAmount(total: subTotal)
                                      .toString(),
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      height: 1,
                      width: double.infinity,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              lang.S.of(context).paymentType,
                              style: const TextStyle(
                                  fontSize: 16, color: Colors.black54),
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            const Icon(
                              Icons.wallet,
                              color: Colors.green,
                            )
                          ],
                        ),
                        DropdownButton(
                          value: dropdownValue,
                          icon: const Icon(Icons.keyboard_arrow_down),
                          items: paymentsTypeList.map((String items) {
                            return DropdownMenuItem(
                              value: items,
                              child: Text(items),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            setState(() {
                              dropdownValue = newValue.toString();
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      height: 1,
                      width: double.infinity,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 30),
                    Row(
                      children: [
                        Expanded(
                          child: AppTextField(
                            textFieldType: TextFieldType.NAME,
                            onChanged: (value) {
                              setState(() {});
                            },
                            decoration: InputDecoration(
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.always,
                              labelText: lang.S.of(context).describtion,
                              hintText: lang.S.of(context).addNote,
                              border: const OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Container(
                          height: 60,
                          width: 100,
                          decoration: BoxDecoration(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(10)),
                              color: Colors.grey.shade200),
                          child: Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  FeatherIcons.camera,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  lang.S.of(context).image,
                                  style: const TextStyle(
                                      color: Colors.grey, fontSize: 16),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ).visible(false),
                    Row(
                      children: [
                        Expanded(
                            child: GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(30)),
                            ),
                            child: Center(
                              child: Text(
                                lang.S.of(context).cacel,
                                style: const TextStyle(fontSize: 18),
                              ),
                            ),
                          ),
                        )),
                        const SizedBox(width: 10),
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              if (providerData.cartItemList.isNotEmpty) {
                                try {
                                  EasyLoading.show(
                                      status: 'Loading...',
                                      dismissOnTap: false);

                                  dueAmount <= 0
                                      ? transitionModel.isPaid = true
                                      : transitionModel.isPaid = false;
                                  dueAmount <= 0
                                      ? transitionModel.dueAmount = 0
                                      : transitionModel.dueAmount = dueAmount;
                                  returnAmount < 0
                                      ? transitionModel.returnAmount =
                                          returnAmount.abs()
                                      : transitionModel.returnAmount = 0;
                                  transitionModel.discountAmount =
                                      discountAmount;
                                  transitionModel.vat = 0;
                                  transitionModel.totalAmount = subTotal;

                                  transitionModel.productList =
                                      providerData.cartItemList;
                                  transitionModel.paymentType = dropdownValue;
                                  transitionModel.invoiceNumber =
                                      invoice.toString();

                                  ///________________updateInvoice___________________________________________________________
                                  final ref = FirebaseDatabase.instance
                                      .ref(constUserId)
                                      .child('Sales Transition');
                                  ref.keepSynced(true);
                                  String? key;
                                  ref.orderByKey().get().then((value) async {
                                    for (var element in value.children) {
                                      final t = SalesTransitionModel.fromJson(
                                          jsonDecode(
                                              jsonEncode(element.value)));
                                      if (transitionModel.invoiceNumber ==
                                          t.invoiceNumber) {
                                        key = element.key;
                                        ref
                                            .child(element.key.toString())
                                            .update(transitionModel.toJson());

                                        ///__________StockMange_________________________________________________

                                        presentProducts =
                                            transitionModel.productList!;

                                        for (var pastElement in pastProducts) {
                                          int i = 0;
                                          for (var futureElement
                                              in presentProducts) {
                                            if (pastElement.productId ==
                                                futureElement.productId) {
                                              if (pastElement.quantity <
                                                      futureElement.quantity &&
                                                  pastElement.quantity !=
                                                      futureElement.quantity) {
                                                decreaseStockList.contains(
                                                        pastElement.productId)
                                                    ? null
                                                    : decreaseStockList.add(
                                                        AddToCartModel(
                                                          productName:
                                                              pastElement
                                                                  .productName,
                                                          warehouseName:
                                                              pastElement
                                                                  .warehouseName,
                                                          warehouseId:
                                                              pastElement
                                                                  .warehouseId,
                                                          productImage:
                                                              pastElement
                                                                  .productImage,
                                                          productId: pastElement
                                                              .productId,
                                                          quantity: futureElement
                                                                  .quantity -
                                                              pastElement
                                                                  .quantity,
                                                          subTaxes: pastElement
                                                              .subTaxes,
                                                          excTax: pastElement
                                                              .excTax,
                                                          groupTaxName:
                                                              pastElement
                                                                  .groupTaxName,
                                                          groupTaxRate:
                                                              pastElement
                                                                  .groupTaxRate,
                                                          incTax: pastElement
                                                              .incTax,
                                                          margin: pastElement
                                                              .margin,
                                                          taxType: pastElement
                                                              .taxType,
                                                        ),
                                                      );
                                              } else if (pastElement.quantity >
                                                      futureElement.quantity &&
                                                  pastElement.quantity !=
                                                      futureElement.quantity) {
                                                increaseStockList.contains(
                                                        pastElement.productId)
                                                    ? null
                                                    : increaseStockList.add(
                                                        AddToCartModel(
                                                          productImage:
                                                              pastElement
                                                                  .productImage,
                                                          productName:
                                                              pastElement
                                                                  .productName,
                                                          warehouseName:
                                                              pastElement
                                                                  .warehouseName,
                                                          warehouseId:
                                                              pastElement
                                                                  .warehouseId,
                                                          productId: pastElement
                                                              .productId,
                                                          quantity: pastElement
                                                                  .quantity -
                                                              futureElement
                                                                  .quantity,
                                                          subTaxes: pastElement
                                                              .subTaxes,
                                                          excTax: pastElement
                                                              .excTax,
                                                          groupTaxName:
                                                              pastElement
                                                                  .groupTaxName,
                                                          groupTaxRate:
                                                              pastElement
                                                                  .groupTaxRate,
                                                          incTax: pastElement
                                                              .incTax,
                                                          margin: pastElement
                                                              .margin,
                                                          taxType: pastElement
                                                              .taxType,
                                                        ),
                                                      );
                                              }
                                              break;
                                            } else {
                                              i++;
                                              if (i == presentProducts.length) {
                                                increaseStockList.add(
                                                  AddToCartModel(
                                                    productImage: pastElement
                                                        .productImage,
                                                    productName:
                                                        pastElement.productName,
                                                    warehouseName: pastElement
                                                        .warehouseName,
                                                    warehouseId:
                                                        pastElement.warehouseId,
                                                    productId:
                                                        pastElement.productId,
                                                    quantity:
                                                        pastElement.quantity,
                                                    subTaxes:
                                                        pastElement.subTaxes,
                                                    excTax: pastElement.excTax,
                                                    groupTaxName: pastElement
                                                        .groupTaxName,
                                                    groupTaxRate: pastElement
                                                        .groupTaxRate,
                                                    incTax: pastElement.incTax,
                                                    margin: pastElement.margin,
                                                    taxType:
                                                        pastElement.taxType,
                                                  ),
                                                );
                                              }
                                            }
                                          }
                                        }

                                        ///_____________StockUpdate_______________________________________________________

                                        for (var element in decreaseStockList) {
                                          decreaseStock(element.productId,
                                              element.quantity);
                                        }

                                        for (var element in increaseStockList) {
                                          increaseStock(element.productId,
                                              element.quantity);
                                        }
                                        // double due = transitionModel.dueAmount! - widget.transitionModel.dueAmount!;
                                        // print(due.toInt());

                                        ///_________DueUpdate______________________________________________________
                                        if (pastDue <
                                            transitionModel.dueAmount!) {
                                          double due =
                                              double.parse(pastDue.toString()) -
                                                  double.parse(transitionModel
                                                              .dueAmount ==
                                                          null
                                                      ? '0'
                                                      : transitionModel
                                                          .dueAmount
                                                          .toString());
                                          getSpecificCustomersDueUpdate(
                                              phoneNumber: widget
                                                  .transitionModel
                                                  .customerPhone,
                                              isDuePaid: false,
                                              due: due.toInt());
                                        } else if (pastDue >
                                            transitionModel.dueAmount!) {
                                          double due =
                                              transitionModel.dueAmount! -
                                                  pastDue;
                                          getSpecificCustomersDueUpdate(
                                              phoneNumber: widget
                                                  .transitionModel
                                                  .customerPhone,
                                              isDuePaid: true,
                                              due: due.toInt());
                                        }
                                        // getSpecificCustomersDueUpdate(phoneNumber: widget.transitionModel.customerPhone, isDuePaid: true, due: 20);

                                        providerData.clearCart();
                                        consumerRef.refresh(customerProvider);
                                        consumerRef.refresh(productProvider);
                                        consumerRef
                                            .refresh(salesReportProvider);
                                        consumerRef.refresh(transitionProvider);
                                        consumerRef
                                            .refresh(profileDetailsProvider);

                                        EasyLoading.dismiss();

                                        // ignore: use_build_context_synchronously
                                        await Future.delayed(const Duration(
                                                microseconds: 100))
                                            .then((value) =>
                                                Navigator.pop(context));
                                      }
                                    }
                                  });
                                } catch (e) {
                                  EasyLoading.showError(e.toString());
                                }
                              } else {
                                EasyLoading.showError('Add product first');
                              }
                            },
                            child: Container(
                              height: 60,
                              decoration: const BoxDecoration(
                                color: kMainColor,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(30)),
                              ),
                              child: Center(
                                child: Text(
                                  lang.S.of(context).save,
                                  style: const TextStyle(
                                      fontSize: 18, color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      }, error: (e, stack) {
        return Center(
          child: Text(e.toString()),
        );
      }, loading: () {
        return const Center(child: CircularProgressIndicator());
      });
    });
  }
}
