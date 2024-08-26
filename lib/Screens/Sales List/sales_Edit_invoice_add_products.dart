// ignore_for_file: file_names

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_cart/flutter_cart.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_pos/Provider/product_provider.dart';
import 'package:mobile_pos/Screens/Customers/Model/customer_model.dart';
import 'package:mobile_pos/const_commas.dart';
import 'package:mobile_pos/constant.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../Provider/add_to_cart.dart';
import '../../currency.dart';
import '../../model/add_to_cart_model.dart';
import '../../model/product_model.dart';
import '../../model/transition_model.dart';
import '../Warehouse/warehouse_model.dart';

// ignore: must_be_immutable
class EditSaleInvoiceSaleProducts extends StatefulWidget {
  EditSaleInvoiceSaleProducts({super.key, @required this.catName, this.customerModel, required this.transitionModel});

  // ignore: prefer_typing_uninitialized_variables
  var catName;
  CustomerModel? customerModel;
  SalesTransitionModel transitionModel;

  @override
  // ignore: library_private_types_in_public_api
  _EditSaleInvoiceSaleProductsState createState() => _EditSaleInvoiceSaleProductsState();
}

class _EditSaleInvoiceSaleProductsState extends State<EditSaleInvoiceSaleProducts> {
  String dropdownValue = '';
  String productCode = '';
  String productName = '';

  var salesCart = FlutterCart();
  String productPrice = '0';
  String sentProductPrice = '';

  @override
  void initState() {
    widget.catName == null ? dropdownValue = 'Fashion' : dropdownValue = widget.catName;
    super.initState();
  }

  // Future<void> scanBarcodeNormal() async {
  //   String barcodeScanRes;
  //   try {
  //     barcodeScanRes = await FlutterBarcodeScanner.scanBarcode('#ff6666', 'Cancel', true, ScanMode.BARCODE);
  //   } on PlatformException {
  //     barcodeScanRes = 'Failed to get platform version.';
  //   }
  //   if (!mounted) return;
  //
  //   setState(() {
  //     productCode = barcodeScanRes;
  //   });
  // }

  // //_____________________Warehouse_list____________________________________________________________________
  // WareHouseModel? selectedWareHouse;
  //
  // int j = 0;
  //
  // DropdownButton<WareHouseModel> getName({required List<WareHouseModel> list}) {
  //   // Set initial value to the first item in the list, if available
  //   // selectedWareHouse = list.isNotEmpty ? list.first : null;
  //   List<DropdownMenuItem<WareHouseModel>> dropDownItems = [];
  //   for (var element in list) {
  //     dropDownItems.add(DropdownMenuItem(
  //       alignment: AlignmentDirectional.centerEnd,
  //       value: element,
  //       child: SizedBox(
  //         width: 150,
  //         child: Text(
  //           element.warehouseName,
  //           style: kTextStyle.copyWith(color: kTitleColor, fontSize: 14),
  //           overflow: TextOverflow.ellipsis,
  //           textAlign: TextAlign.end,
  //         ),
  //       ),
  //     ));
  //     if (j == 0) {
  //       selectedWareHouse = element;
  //     }
  //     j++;
  //   }
  //
  //   return DropdownButton(
  //     icon: const Icon(
  //       Icons.keyboard_arrow_down_outlined,
  //       color: kGreyTextColor,
  //     ),
  //     items: dropDownItems,
  //     isExpanded: false,
  //     isDense: true,
  //     value: selectedWareHouse,
  //     onChanged: (WareHouseModel? value) {
  //       setState(() {
  //         selectedWareHouse = value;
  //       });
  //     },
  //   );
  // }

  TextEditingController scarchController = TextEditingController();

  final GlobalKey<FormState> _key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, __) {
      List<WarehouseBasedProductModel> warehouseBasedProductModel = [];
      List<String> allWarehouseId = [];
      final providerData = ref.watch(cartNotifier);
      final productList = ref.watch(productProvider);
      final wareHouseList = ref.watch(warehouseProvider);

      return Scaffold(
        backgroundColor: kMainColor,
        appBar: AppBar(
          title: Text(
            lang.S.of(context).addItems,
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
        body: Container(
          alignment: Alignment.topCenter,
          decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(topRight: Radius.circular(30), topLeft: Radius.circular(30))),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 10.0),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: SizedBox(
                          height: 56.0,
                          child: Form(
                            key: _key,
                            child: TextFormField(
                              controller: scarchController,
                              onChanged: (value) {
                                setState(() {
                                  productCode = value;
                                  productName = value;
                                });
                              },
                              onSaved: (newValue) {
                                setState(() {
                                  productCode = newValue ?? '';
                                  productName = newValue ?? '';
                                });
                              },
                              decoration: InputDecoration(
                                floatingLabelBehavior: FloatingLabelBehavior.always,
                                labelText: 'Product code/Name',
                                hintText: productCode.isEmpty ? 'Search by product code or name' : productCode,
                                border: const OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10.0),
                      GestureDetector(
                        onTap: () async {
                          await showDialog(
                            barrierDismissible: true,
                            context: context,
                            builder: (context1) {
                              MobileScannerController controller = MobileScannerController(
                                torchEnabled: false,
                                returnImage: false,
                              );
                              return Container(
                                decoration: BoxDecoration(borderRadius: BorderRadiusDirectional.circular(6.0)),
                                child: Column(
                                  children: [
                                    AppBar(
                                      backgroundColor: Colors.transparent,
                                      iconTheme: const IconThemeData(color: Colors.white),
                                      leading: IconButton(
                                        icon: const Icon(Icons.arrow_back),
                                        onPressed: () {
                                          Navigator.pop(context1);
                                        },
                                      ),
                                    ),
                                    Expanded(
                                      child: MobileScanner(
                                        fit: BoxFit.contain,
                                        controller: controller,
                                        onDetect: (capture) {
                                          final List<Barcode> barcodes = capture.barcodes;

                                          if (barcodes.isNotEmpty) {
                                            final Barcode barcode = barcodes.first;
                                            debugPrint('Barcode found! ${barcode.rawValue}');

                                            productCode = barcode.rawValue!;
                                            scarchController.text = productCode;
                                            _key.currentState!.save();

                                            Navigator.pop(context1);
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                        child: Container(
                          height: 56.0,
                          width: 56.0,
                          padding: const EdgeInsets.all(5.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5.0),
                            border: Border.all(color: kGreyTextColor),
                          ),
                          child: SvgPicture.asset(
                            'images/scan.svg',
                            height: 40.0,
                            width: 40.0,
                            allowDrawingOutsideViewBox: false,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Padding(
                //   padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                //   child: wareHouseList.when(
                //     data: (warehouse) {
                //       List<WareHouseModel> wareHouseList = warehouse;
                //       // List<WareHouseModel> wareHouseList = [];
                //       return Row(
                //         crossAxisAlignment: CrossAxisAlignment.start,
                //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //         children: [
                //           Text(
                //             'Selected Warehouse:',
                //             style: kTextStyle.copyWith(color: kGreyTextColor),
                //           ),
                //           DropdownButtonHideUnderline(
                //             child: getName(list: warehouse ?? []),
                //           ),
                //         ],
                //       );
                //
                //       //   FormField(
                //       //   builder: (FormFieldState<dynamic> field) {
                //       //     return InputDecorator(
                //       //       decoration:  InputDecoration(
                //       //         border: const OutlineInputBorder(),
                //       //           contentPadding: const EdgeInsets.only(left: 8.0,right: 8.0),
                //       //           ),
                //       //       child: DropdownButtonHideUnderline(
                //       //         child: getName(list: warehouse ?? []),
                //       //       ),
                //       //     );
                //       //   },
                //       // );
                //     },
                //     error: (e, stack) {
                //       return Center(
                //         child: Text(
                //           e.toString(),
                //         ),
                //       );
                //     },
                //     loading: () {
                //       return const Center(
                //         child: CircularProgressIndicator(),
                //       );
                //     },
                //   ),
                // ),
                // const Divider(
                //   thickness: 1.0,
                //   color: kBorderColorTextField,
                //   height: 0,
                // ),
                productList.when(data: (products) {
                  List<ProductModel> showAbleProducts = [];
                  for (var element in products) {
                    // productNameList.add(element.productName.removeAllWhiteSpace().toLowerCase());
                    // productCodeList.add(element.productCode.removeAllWhiteSpace().toLowerCase());
                    warehouseBasedProductModel.add(WarehouseBasedProductModel(element.productName, element.warehouseId));

                    allWarehouseId.add(element.warehouseId);
                    if (productCode != '' &&
                        (element.productName.removeAllWhiteSpace().toLowerCase().contains(productName.toString().toLowerCase()) || element.productCode.contains(productCode.toString()))) {
                      showAbleProducts.add(element);
                    } else if (productCode == '') {
                      showAbleProducts.add(element);
                    }
                  }
                  return showAbleProducts.isNotEmpty
                      ? ListView.builder(
                          padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: showAbleProducts.length,
                          itemBuilder: (_, i) {
                            if (widget.customerModel!.type.contains('Retailer')) {
                              productPrice = showAbleProducts[i].productSalePrice;
                            } else if (widget.customerModel!.type.contains('Dealer')) {
                              productPrice = showAbleProducts[i].productDealerPrice;
                            } else if (widget.customerModel!.type.contains('Wholesaler')) {
                              productPrice = showAbleProducts[i].productWholeSalePrice;
                            } else if (widget.customerModel!.type.contains('Supplier')) {
                              productPrice = showAbleProducts[i].productPurchasePrice;
                            } else if (widget.customerModel!.type.contains('Guest')) {
                              productPrice = showAbleProducts[i].productSalePrice;
                            }
                            return GestureDetector(
                              onTap: () async {
                                if (showAbleProducts[i].productStock.toInt() <= 0) {
                                  EasyLoading.showError('Out of stock');
                                } else {
                                  if (widget.customerModel!.type.contains('Retailer')) {
                                    sentProductPrice = showAbleProducts[i].productSalePrice;
                                  } else if (widget.customerModel!.type.contains('Dealer')) {
                                    sentProductPrice = showAbleProducts[i].productDealerPrice;
                                  } else if (widget.customerModel!.type.contains('Wholesaler')) {
                                    sentProductPrice = showAbleProducts[i].productWholeSalePrice;
                                  } else if (widget.customerModel!.type.contains('Supplier')) {
                                    sentProductPrice = showAbleProducts[i].productPurchasePrice;
                                  } else if (widget.customerModel!.type.contains('Guest')) {
                                    sentProductPrice = showAbleProducts[i].productSalePrice;
                                  }

                                  AddToCartModel cartItem = AddToCartModel(
                                    productName: showAbleProducts[i].productName,
                                    warehouseName: showAbleProducts[i].warehouseName,
                                    warehouseId: showAbleProducts[i].warehouseId,
                                    subTotal: sentProductPrice,
                                    productImage: showAbleProducts[i].productPicture,
                                    productId: showAbleProducts[i].productCode,
                                    productBrandName: showAbleProducts[i].brandName,
                                    stock: int.parse(showAbleProducts[i].productStock),
                                    subTaxes: showAbleProducts[i].subTaxes,
                                    excTax: showAbleProducts[i].excTax,
                                    groupTaxName: showAbleProducts[i].groupTaxName,
                                    groupTaxRate: showAbleProducts[i].groupTaxRate,
                                    incTax: showAbleProducts[i].incTax,
                                    margin: showAbleProducts[i].margin,
                                    taxType: showAbleProducts[i].taxType,
                                  );
                                  providerData.addToCartRiverPod(cartItem);
                                  providerData.addProductsInSales(showAbleProducts[i]);
                                  Navigator.pop(context);
                                }
                              },
                              child: ProductCard(
                                productTitle: showAbleProducts[i].productName,
                                productDescription: showAbleProducts[i].brandName,
                                productPrice: productPrice,
                                productImage: showAbleProducts[i].productPicture,
                                stock: showAbleProducts[i].productStock,
                                warehouseName: showAbleProducts[i].warehouseName,
                              ).visible(productName.isEmptyOrNull
                                  ? true
                                  : showAbleProducts[i].productName.toUpperCase().contains(productName.toUpperCase()) ||
                                      (productName.isEmpty || productCode.isEmpty || showAbleProducts[i].productCode.contains(productCode) || productCode == '0000' || productCode == '-1') &&
                                          productPrice != '0'),
                            );
                          })
                      : const Center(
                          child: Text('No product Found'),
                        );
                }, error: (e, stack) {
                  return Text(e.toString());
                }, loading: () {
                  return const Center(child: CircularProgressIndicator());
                }),
              ],
            ),
          ),
        ),
      );
    });
  }
}

// ignore: must_be_immutable
class ProductCard extends StatefulWidget {
  ProductCard({super.key, required this.productTitle, required this.productDescription, required this.productPrice, required this.productImage, required this.stock, required this.warehouseName});

  // final Product product;
  String productImage, productTitle, productDescription, productPrice, stock, warehouseName;

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  num quantity = 0;

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, __) {
      final providerData = ref.watch(cartNotifier);
      for (var element in providerData.cartItemList) {
        if (element.productName == widget.productTitle) {
          quantity = element.quantity;
        }
      }
      return Padding(
        padding: const EdgeInsets.all(5.0),
        child: Column(
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  color: kMainColor,
                  borderRadius: BorderRadius.circular(90.0),
                ),
                child: Center(
                  child: Text(
                    widget.productTitle.substring(0, 1),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
              title: Row(
                children: [
                  SizedBox(
                    width: 160,
                    child: Text(
                      widget.productTitle,
                      style: GoogleFonts.jost(
                        fontSize: 15.0,
                        color: Colors.black,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: 125,
                    child: Text(
                      widget.warehouseName,
                      textAlign: TextAlign.end,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.jost(
                        fontSize: 15.0,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
              subtitle: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.productDescription,
                    style: GoogleFonts.jost(
                      fontSize: 15.0,
                      color: kGreyTextColor,
                    ),
                  ),
                  Text(
                    'Stock:${widget.stock}',
                    style: GoogleFonts.jost(
                      fontSize: 15.0,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}
