// ignore_for_file: unused_result, must_be_immutable

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
import 'package:mobile_pos/constant.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import 'package:mobile_pos/model/product_model.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../Provider/add_to_cart.dart';
import '../../Provider/add_to_cart_purchase.dart';
import '../Warehouse/warehouse_model.dart';

class PurchaseProducts extends StatefulWidget {
  PurchaseProducts({super.key, @required this.catName, this.customerModel});

  // ignore: prefer_typing_uninitialized_variables
  var catName;
  CustomerModel? customerModel;

  @override
  State<PurchaseProducts> createState() => _PurchaseProductsState();
}

class _PurchaseProductsState extends State<PurchaseProducts> {
  String dropdownValue = '';
  String productCode = '';
  String productName = '';

  var salesCart = FlutterCart();
  String total = 'Cart Is Empty';
  int items = 0;
  String productPrice = '0';
  String productStock = '0';
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

  List<String> productCodeList = [];
  List<String> productNameList = [];
  TextEditingController scarchController = TextEditingController();

  final GlobalKey<FormState> _key = GlobalKey();

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

  bool isRegularSelected = true;

  @override
  Widget build(BuildContext context) {
    List<WarehouseBasedProductModel> warehouseBasedProductModel = [];
    List<String> allWarehouseId = [];
    return Consumer(builder: (context, ref, __) {
      final providerData = ref.watch(cartNotifierPurchase);
      final productList = ref.watch(productProvider);
      final wareHouseList = ref.watch(warehouseProvider);
      return Scaffold(
        backgroundColor: kMainColor,
        appBar: AppBar(
          title: Text(
            lang.S.of(context).productList,
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
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 10.0,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 0.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
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
                                contentPadding: const EdgeInsets.only(left: 8.0, right: 8.0),
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
                              return WillPopScope(
                                onWillPop: () async => false,
                                child: Container(
                                  decoration: BoxDecoration(borderRadius: BorderRadiusDirectional.circular(6.0)),
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
                              );
                            },
                          );
                        },
                        child: Container(
                          height: 48.0,
                          width: 48.0,
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
                const SizedBox(
                  height: 10.0,
                ),
                productList.when(data: (products) {
                  List<ProductModel> showAbleProducts = [];
                  for (var element in products) {
                    // productNameList.add(element.productName.removeAllWhiteSpace().toLowerCase());
                    // productCodeList.add(element.productCode.removeAllWhiteSpace().toLowerCase());
                    warehouseBasedProductModel.add(WarehouseBasedProductModel(element.productName, element.warehouseId));

                    allWarehouseId.add(element.warehouseId);
                    if (!isRegularSelected) {
                      if (((element.productName.removeAllWhiteSpace().toLowerCase().contains(productCode.toString().toLowerCase()) ||
                              element.productName.contains(productCode.toString()))) &&
                          element.expiringDate != null &&
                          ((DateTime.tryParse(element.expiringDate ?? '') ?? DateTime.now()).isBefore(DateTime.now().add(const Duration(days: 7))))) {
                        showAbleProducts.add(element);
                      }
                    } else {
                      if (productCode != '' &&
                          (element.productName.removeAllWhiteSpace().toLowerCase().contains(productCode.toString().toLowerCase()) ||
                              element.productName.contains(productCode.toString()))) {
                        showAbleProducts.add(element);
                      } else if (productCode == '') {
                        showAbleProducts.add(element);
                      }
                    }
                  }

                  return showAbleProducts.isNotEmpty
                      ? ListView.builder(
                          padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: showAbleProducts.length,
                          itemBuilder: (_, i) {
                            if (widget.customerModel!.type.contains('Retailer')) {
                              productPrice = showAbleProducts[i].productSalePrice;
                              productStock = showAbleProducts[i].productStock;
                            } else if (widget.customerModel!.type.contains('Dealer')) {
                              productPrice = showAbleProducts[i].productDealerPrice;
                              productStock = showAbleProducts[i].productStock;
                            } else if (widget.customerModel!.type.contains('Wholesaler')) {
                              productPrice = showAbleProducts[i].productWholeSalePrice;
                              productStock = showAbleProducts[i].productStock;
                            } else if (widget.customerModel!.type.contains('Supplier')) {
                              productPrice = showAbleProducts[i].productPurchasePrice;
                              productStock = showAbleProducts[i].productStock;
                            }
                            return GestureDetector(
                              onTap: () {
                                showDialog(
                                    context: context,
                                    builder: (_) {
                                      ProductModel tempProductModel = ProductModel(
                                        type: showAbleProducts[i].type,
                                        weight: showAbleProducts[i].weight,
                                        size: showAbleProducts[i].size,
                                        color: showAbleProducts[i].color,
                                        manufacturingDate: showAbleProducts[i].manufacturingDate,
                                        lowerStockAlert: showAbleProducts[i].lowerStockAlert,
                                        expiringDate: showAbleProducts[i].expiringDate,
                                        brandName: showAbleProducts[i].brandName,
                                        capacity: showAbleProducts[i].capacity,
                                        productCategory: showAbleProducts[i].productCategory,
                                        productCode: showAbleProducts[i].productCode,
                                        productDealerPrice: showAbleProducts[i].productDealerPrice,
                                        productDiscount: showAbleProducts[i].productDiscount,
                                        productManufacturer: showAbleProducts[i].productManufacturer,
                                        warehouseName: showAbleProducts[i].warehouseName,
                                        warehouseId: showAbleProducts[i].warehouseId,
                                        productName: showAbleProducts[i].productName,
                                        productPicture: showAbleProducts[i].productPicture,
                                        productPurchasePrice: showAbleProducts[i].productPurchasePrice,
                                        productSalePrice: showAbleProducts[i].productSalePrice,
                                        productStock: '0',
                                        productUnit: showAbleProducts[i].productUnit,
                                        productWholeSalePrice: showAbleProducts[i].productWholeSalePrice,
                                        serialNumber: showAbleProducts[i].serialNumber,
                                      );
                                      // ProductModel tempProductModel = products[i];
                                      // tempProductModel.productStock = '0';
                                      return AlertDialog(
                                          content: SizedBox(
                                        child: SingleChildScrollView(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(bottom: 10),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text(
                                                      lang.S.of(context).addItems,
                                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                                    ),
                                                    GestureDetector(
                                                        onTap: () {
                                                          Navigator.pop(context);
                                                        },
                                                        child: const Icon(
                                                          Icons.cancel,
                                                          color: kMainColor,
                                                        )),
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                height: 1,
                                                width: double.infinity,
                                                color: Colors.grey,
                                              ),
                                              const SizedBox(height: 10),
                                              ListTile(
                                                contentPadding: EdgeInsets.zero,
                                                title: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Flexible(
                                                      child: Text(
                                                        showAbleProducts[i].productName,
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                        style: const TextStyle(fontSize: 16),
                                                      ),
                                                    ),
                                                    SizedBox(width: 10.0),
                                                    Text(
                                                      lang.S.of(context).stocks,
                                                      style: const TextStyle(fontSize: 16),
                                                    ),
                                                  ],
                                                ),
                                                subtitle: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text(
                                                      showAbleProducts[i].brandName,
                                                      style: const TextStyle(
                                                        fontSize: 16,
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                    Text(
                                                      showAbleProducts[i].productStock,
                                                      style: const TextStyle(
                                                        fontSize: 16,
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(height: 20),
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Expanded(
                                                    child: AppTextField(
                                                      textFieldType: TextFieldType.PHONE,
                                                      onChanged: (value) {
                                                        tempProductModel.productStock = value;
                                                      },
                                                      decoration: InputDecoration(
                                                        floatingLabelBehavior: FloatingLabelBehavior.always,
                                                        labelText: lang.S.of(context).quantity,
                                                        border: const OutlineInputBorder(),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 20),
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Expanded(
                                                    child: AppTextField(
                                                      initialValue: showAbleProducts[i].productPurchasePrice,
                                                      keyboardType: TextInputType.number,
                                                      textFieldType: TextFieldType.NAME,
                                                      onChanged: (value) {
                                                        tempProductModel.productPurchasePrice = value;
                                                      },
                                                      decoration: InputDecoration(
                                                        floatingLabelBehavior: FloatingLabelBehavior.always,
                                                        labelText: lang.S.of(context).purchasePrice,
                                                        border: const OutlineInputBorder(),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Expanded(
                                                    child: AppTextField(
                                                      initialValue: showAbleProducts[i].productSalePrice,
                                                      keyboardType: TextInputType.number,
                                                      textFieldType: TextFieldType.NAME,
                                                      onChanged: (value) {
                                                        tempProductModel.productSalePrice = value;
                                                      },
                                                      decoration: InputDecoration(
                                                        floatingLabelBehavior: FloatingLabelBehavior.always,
                                                        labelText: lang.S.of(context).salePrice,
                                                        border: const OutlineInputBorder(),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 20),
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Expanded(
                                                    child: AppTextField(
                                                      initialValue: showAbleProducts[i].productWholeSalePrice,
                                                      keyboardType: TextInputType.number,
                                                      textFieldType: TextFieldType.NAME,
                                                      onChanged: (value) {
                                                        tempProductModel.productWholeSalePrice = value;
                                                      },
                                                      decoration: InputDecoration(
                                                        floatingLabelBehavior: FloatingLabelBehavior.always,
                                                        labelText: lang.S.of(context).wholeSalePrice,
                                                        border: const OutlineInputBorder(),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Expanded(
                                                    child: AppTextField(
                                                      initialValue: showAbleProducts[i].productDealerPrice,
                                                      keyboardType: TextInputType.number,
                                                      textFieldType: TextFieldType.NAME,
                                                      onChanged: (value) {
                                                        tempProductModel.productDealerPrice = value;
                                                      },
                                                      decoration: InputDecoration(
                                                        floatingLabelBehavior: FloatingLabelBehavior.always,
                                                        labelText: lang.S.of(context).dealerPrice,
                                                        border: const OutlineInputBorder(),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 20),
                                              GestureDetector(
                                                onTap: () {
                                                  if (tempProductModel.productStock != '0') {
                                                    providerData.addToCartRiverPod(tempProductModel);
                                                    providerData.addProductsInSales(products[i]);
                                                    ref.refresh(productProvider);
                                                    int count = 0;
                                                    Navigator.popUntil(context, (route) {
                                                      return count++ == 2;
                                                    });
                                                  } else {
                                                    EasyLoading.showError('Please add quantity');
                                                  }
                                                },
                                                child: Container(
                                                  height: 60,
                                                  width: context.width(),
                                                  decoration: const BoxDecoration(color: kMainColor, borderRadius: BorderRadius.all(Radius.circular(30))),
                                                  child: Center(
                                                    child: Text(
                                                      lang.S.of(context).save,
                                                      style: const TextStyle(fontSize: 18, color: Colors.white),
                                                    ),
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ));
                                    });
                                // if (products[i].productStock.toInt() <= 0) {
                                //   EasyLoading.showError('Out of stock');
                                // } else {
                                //   if (widget.customerModel!.type.contains('Retailer')) {
                                //     sentProductPrice = products[i].productSalePrice;
                                //   } else if (widget.customerModel!.type.contains('Dealer')) {
                                //     sentProductPrice = products[i].productDealerPrice;
                                //   } else if (widget.customerModel!.type.contains('Wholesaler')) {
                                //     sentProductPrice = products[i].productWholeSalePrice;
                                //   } else if (widget.customerModel!.type.contains('Supplier')) {
                                //     sentProductPrice = products[i].productPurchasePrice;
                                //   }
                                //
                                //   AddToCartModel cartItem = AddToCartModel(
                                //     productName: products[i].productName,
                                //     subTotal: sentProductPrice,
                                //     productId: products[i].productCode,
                                //     productBrandName: products[i].brandName,
                                //     stock: int.parse(products[i].productStock),
                                //   );
                                //   providerData.addToCartRiverPod(cartItem);
                                //
                                //   EasyLoading.showSuccess('Added To Cart');
                                //   Navigator.pop(context);
                                // }
                              },
                              child: ProductCard(
                                productTitle: showAbleProducts[i].productName,
                                productDescription: showAbleProducts[i].brandName,
                                stock: showAbleProducts[i].productStock,
                                productImage: showAbleProducts[i].productPicture,
                                warehouseName: showAbleProducts[i].warehouseName,
                              ).visible(
                                  productName.isEmptyOrNull
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

class ProductCard extends StatefulWidget {
  ProductCard(
      {super.key, required this.productTitle, required this.productDescription, required this.stock, required this.productImage, required this.warehouseName});

  // final Product product;
  String productImage, productTitle, productDescription, stock, warehouseName;

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  int quantity = 0;

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, __) {
      final providerData = ref.watch(cartNotifier);
      for (var element in providerData.cartItemList) {
        if (element.productName == widget.productTitle) {
          quantity = element.quantity;
        }
      }
      return Column(
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
      );
    });
  }
}
