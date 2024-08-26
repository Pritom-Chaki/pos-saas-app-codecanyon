// ignore_for_file: unused_result, use_build_context_synchronously
import 'dart:io';
import 'package:firebase_core/firebase_core.dart' as firebase_core;
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:intl/intl.dart';
import 'package:mobile_pos/GlobalComponents/button_global.dart';
import 'package:mobile_pos/Provider/category,brans,units_provide.dart';
import 'package:mobile_pos/Screens/Products/brands_list.dart';
import 'package:mobile_pos/Screens/Products/category_list.dart';
import 'package:mobile_pos/Screens/Products/product_list.dart';
import 'package:mobile_pos/Screens/Products/unit_list.dart';
import 'package:mobile_pos/const_commas.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import 'package:mobile_pos/model/product_model.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../GlobalComponents/Model/category_model.dart';
import '../../Provider/product_provider.dart';
import '../../constant.dart';
import '../../currency.dart';
import '../../subscription.dart';
import '../Warehouse/warehouse_model.dart';
import '../tax report/tax_model.dart';
import 'excel_upload screen.dart';

class AddProduct extends StatefulWidget {
  const AddProduct({super.key, required this.productNameList, required this.productCodeList, required this.warehouseBasedProductModel});

  final List<WarehouseBasedProductModel> warehouseBasedProductModel;
  final List<String> productNameList;
  final List<String> productCodeList;

  @override
  AddProductState createState() => AddProductState();
}

class AddProductState extends State<AddProduct> {
  bool saleButtonClicked = false;
  GlobalKey<FormState> globalKey = GlobalKey<FormState>();
  GetCategoryAndVariationModel data = GetCategoryAndVariationModel(variations: [], categoryName: '');
  String productCategory = '';
  String productCategoryHint = 'Select Product Category';
  String brandName = '';
  String brandNameHint = 'Select Brand';
  String productUnit = '';
  String productUnitHint = 'Select Unit';
  late String productName, productStock, productSalePrice, productPurchasePrice, productCode;
  String productWholeSalePrice = '0';
  String productDealerPrice = '0';
  String productManufacturer = '';
  int lowerStockAlert = 5;
  String size = '';
  String color = '';
  String weight = '';
  String capacity = '';
  String type = '';
  String productPicture = 'https://firebasestorage.googleapis.com/v0/b/maanpos.appspot.com/o/Customer%20Picture%2FNo_Image_Available.jpeg?alt=media&token=3de0d45e-0e4a-4a7b-b115-9d6722d5031f';
  String productDiscount = '';
  final ImagePicker _picker = ImagePicker();
  XFile? pickedImage;
  TextEditingController productCodeController = TextEditingController();
  File imageFile = File('No File');
  String imagePath = 'No Data';

  Future<void> uploadFile(String filePath) async {
    File file = File(filePath);
    try {
      EasyLoading.show(
        status: 'Uploading... ',
        dismissOnTap: false,
      );
      var snapshot = await FirebaseStorage.instance.ref('Product Picture/${DateTime.now().millisecondsSinceEpoch}').putFile(file);
      var url = await snapshot.ref.getDownloadURL();

      setState(() {
        productPicture = url.toString();
      });
    } on firebase_core.FirebaseException catch (e) {
      EasyLoading.dismiss();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.code.toString())));
    }
  }

  // Future<void> scanBarcodeNormal() async {
  //   String barcodeScanRes;
  //   try {
  //     barcodeScanRes = await FlutterBarcodeScanner.scanBarcode('#ff6666', 'Cancel', true, ScanMode.BARCODE);
  //   } on PlatformException {
  //     barcodeScanRes = 'Failed to get platform version.';
  //   }
  //   if (!mounted) return;
  //   if (widget.productCodeList.contains(barcodeScanRes)) {
  //     EasyLoading.showError('This Product Already added!');
  //   } else {
  //     if (barcodeScanRes != '-1') {
  //       productCodeController.value = TextEditingValue(text: barcodeScanRes);
  //     }
  //   }
  // }

  final TextEditingController productPurchasePriceController = TextEditingController();
  final TextEditingController productSalePriceController = TextEditingController();
  final TextEditingController productWholesalePriceController = TextEditingController();
  final TextEditingController productDealerPriceController = TextEditingController();
  final TextEditingController stockController = TextEditingController();
  TextEditingController totalAmountController = TextEditingController();
  TextEditingController incTaxController = TextEditingController();
  TextEditingController excTaxController = TextEditingController();
  TextEditingController marginController = TextEditingController();

  String mrpText = '';
  String purchaseText = '';
  String wholesaleText = '';
  String dealerText = '';
  String stockText = '';
  TextEditingController productNameController = TextEditingController();
  TextEditingController productDescriptionController = TextEditingController();

  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    final cleanText = newValue.text.replaceAll(',', ''); // Remove commas
    final formattedText = _formatWithCommas(cleanText);

    return newValue.copyWith(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }

  String _formatWithCommas(String text) {
    final intValue = int.tryParse(text);
    if (intValue == null) {
      return text; // Invalid input, don't format
    }

    return myFormat.format(intValue);
  }

  String _formatNumber(String s) => myFormat.format(int.parse(s));
  TextEditingController expireDateTextEditingController = TextEditingController();
  TextEditingController manufactureDateTextEditingController = TextEditingController();

  String? expireDate;
  String? manufactureDate;

//_____________________Warehouse_list____________________________________________________________________
  late WareHouseModel? selectedWareHouse;

  int i = 0;

  DropdownButton<WareHouseModel> getName({required List<WareHouseModel> list}) {
    List<DropdownMenuItem<WareHouseModel>> dropDownItems = [
      // DropdownMenuItem(
      //   enabled: false,
      //   value: ar,
      //   child: Text(ar.warehouseName),
      // )
    ];
    for (var element in list) {
      dropDownItems.add(DropdownMenuItem(
        value: element,
        child: SizedBox(
          width: 110,
          child: Text(
            element.warehouseName,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ));
      if (i == 0) {
        selectedWareHouse = element;
      }
      i++;
    }
    return DropdownButton(
      items: dropDownItems,
      value: selectedWareHouse,
      onChanged: (value) {
        setState(() {
          selectedWareHouse = value!;
        });
      },
    );
  }

  bool checkProductName({required String name, required String id}) {
    for (var element in widget.warehouseBasedProductModel) {
      print('name: ${element.productName}, id: ${element.productID}');
      if (element.productName.toLowerCase() == name.toLowerCase() && element.productID == id) {
        return false;
      }
    }

    return true;
  }

  bool isIncludeTax = true;

  GroupTaxModel? selectedGroupTaxModel;

  //___________________________________tax_type____________________________________
  List<String> status = [
    'Inclusive',
    'Exclusive',
  ];

  String selectedTaxType = 'Exclusive';
  DropdownButton<String> getTaxType() {
    List<DropdownMenuItem<String>> dropDownItems = [];
    for (String des in status) {
      var item = DropdownMenuItem(
        value: des,
        child: Text(des),
      );
      dropDownItems.add(item);
    }
    return DropdownButton(
      hint: const Text('Select Tax type'),
      items: dropDownItems,
      value: selectedTaxType,
      onChanged: (value) {
        setState(() {
          selectedTaxType = value!;
          adjustSalesPrices();
        });
      },
    );
  }

  //___________________________________calculate_total_with_tax____________________
  double totalAmount = 0.0;
  void calculateTotal() {
    String saleAmountText = productPurchasePriceController.text.replaceAll(',', '');
    double saleAmount = double.tryParse(saleAmountText) ?? 0.0;
    if (selectedGroupTaxModel != null) {
      double taxRate = double.parse(selectedGroupTaxModel!.taxRate.toString());
      double totalAmount = calculateTotalAmount(saleAmount, taxRate);
      setState(() {
        totalAmountController.text = totalAmount.toStringAsFixed(2);
        this.totalAmount = totalAmount;
      });
    }
  }

  double calculateTotalAmount(double saleAmount, double taxRate) {
    double taxDecimal = taxRate / 100;
    double totalAmount = saleAmount + (saleAmount * taxDecimal);
    return totalAmount;
  }

  void adjustSalesPrices() {
    // double taxAmount =
    //     double.tryParse(selectedGroupTaxModel?.taxRate.toString() ?? '') ?? 0.0;
    double margin = double.tryParse(marginController.text) ?? 0;
    double purchasePrice = double.tryParse(purchaseText) ?? 0;
    double salesPrice = 0;
    double excPrice = 0;
    double taxAmount = calculateAmountFromPercentage((selectedGroupTaxModel?.taxRate.toString() ?? '').toDouble(), purchasePrice);

    if (selectedTaxType == 'Inclusive') {
      salesPrice = purchasePrice + calculateAmountFromPercentage(margin, purchasePrice);
      // salesPrice -= calculateAmountFromPercentage(double.parse(selectedGroupTaxModel!.taxRate.toString()), purchasePrice);
      mrpText = salesPrice.toString();
      dealerText = salesPrice.toString();
      wholesaleText = salesPrice.toString();
      incTaxAmount = salesPrice.toString();
      excTaxAmount = salesPrice.toString();
    } else {
      salesPrice = purchasePrice + calculateAmountFromPercentage(margin, purchasePrice) + taxAmount;
      excPrice = purchasePrice + taxAmount;
      mrpText = salesPrice.toString();
      dealerText = salesPrice.toString();
      wholesaleText = salesPrice.toString();
      incTaxAmount = salesPrice.toString();
      excTaxAmount = excPrice.toString();
    }

    // Add margin to prices if margin is provided

    // Update controllers with adjusted prices
    productSalePriceController.text = salesPrice.toStringAsFixed(2);
    productWholesalePriceController.text = salesPrice.toStringAsFixed(2);
    productDealerPriceController.text = salesPrice.toStringAsFixed(2);
    incTaxController.text = salesPrice.toStringAsFixed(2);
    excTaxController.text = excPrice.toStringAsFixed(2);
  }

  // Function to calculate the amount from a given percentage
  double calculateAmountFromPercentage(double percentage, double price) {
    return price * (percentage / 100);
  }

  String excTaxAmount = '';
  String incTaxAmount = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    productPurchasePriceController.addListener(calculateTotal);
    marginController.addListener(() {
      setState(() {
        adjustSalesPrices();
      });
    });
  }

  @override
  void dispose() {
    productPurchasePriceController.removeListener(calculateTotal);
    productPurchasePriceController.dispose();
    totalAmountController.dispose();
    marginController.dispose();
    productSalePriceController.dispose();
    productDealerPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kMainColor,
      appBar: AppBar(
        backgroundColor: kMainColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          lang.S.of(context).addNewProduct,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ExcelUploader(
                              previousProductCode: widget.productCodeList,
                              previousProductName: widget.productNameList,
                            )));
              },
              style: ButtonStyle(backgroundColor: MaterialStatePropertyAll(kMainColor.withOpacity(0.2))),
              icon: const Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Bulk\nUpload',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 8, color: Colors.white),
                  ),
                  SizedBox(
                    width: 3,
                  ),
                  Image(
                    height: 25,
                    width: 25,
                    image: AssetImage('images/excel-file.png'),
                  ),
                  // Icon(Icons.upload,),
                ],
              ))
        ],
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        alignment: Alignment.topCenter,
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(topRight: Radius.circular(30), topLeft: Radius.circular(30))),
        child: Consumer(builder: (context, ref, __) {
          final wareHouseList = ref.watch(warehouseProvider);
          final groupTax = ref.watch(groupTaxProvider);
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 10),
              child: Form(
                key: globalKey,
                child: Column(
                  children: [
                    ///________Name__________________________________________
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: TextFormField(
                        decoration: InputDecoration(
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          border: const OutlineInputBorder(),
                          labelText: lang.S.of(context).productName,
                          hintText: lang.S.of(context).enterProductName,
                        ),
                        validator: (value) {
                          if (value?.removeAllWhiteSpace().toLowerCase().isEmptyOrNull ?? true) {
                            return 'Product name is required.';
                          } else if (!checkProductName(name: value!, id: selectedWareHouse!.id)) {
                            return 'Product Name already exists in this warehouse.';
                          } else {
                            return null; // Validation passes
                          }
                        },
                        // validator: (value) {
                        //   if (value.isEmptyOrNull) {
                        //     return 'Product name is required.';
                        //   } else if (widget.productNameList.contains(value?.toLowerCase().removeAllWhiteSpace())) {
                        //     return 'Product name is already added.';
                        //   }
                        //   return null;
                        // },
                        controller: productNameController,
                        onSaved: (value) {
                          productNameController.text = value!;
                        },
                        // onSaved: (value) {
                        //   productName = value!;
                        // },
                      ),
                    ),

                    ///______category___________________________
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: TextFormField(
                        readOnly: true,
                        onTap: () async {
                          data = await const CategoryList().launch(context);
                          setState(() {
                            productCategory = data.categoryName;
                            productCategoryHint = data.categoryName;
                          });
                        },
                        decoration: InputDecoration(
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          hintText: productCategoryHint,
                          labelText: lang.S.of(context).category,
                          border: const OutlineInputBorder(),
                          suffixIcon: const Icon(Icons.keyboard_arrow_down),
                        ),
                      ),
                    ),

                    ///_____SIZE & Color__________________________
                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: TextFormField(
                              onSaved: (value) {
                                size = value!;
                              },
                              decoration: InputDecoration(
                                floatingLabelBehavior: FloatingLabelBehavior.always,
                                labelText: lang.S.of(context).size,
                                hintText: lang.S.of(context).enterSize,
                                border: const OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ).visible(data.variations.contains('Size')),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: TextFormField(
                              onSaved: (value) {
                                color = value!;
                              },
                              decoration: InputDecoration(
                                floatingLabelBehavior: FloatingLabelBehavior.always,
                                labelText: lang.S.of(context).color,
                                hintText: lang.S.of(context).enterColor,
                                border: const OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ).visible(data.variations.contains('Color')),
                      ],
                    ),

                    ///_______Weight & Capacity & Type_____________________________
                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: TextFormField(
                              onSaved: (value) {
                                weight = value!;
                              },
                              decoration: InputDecoration(
                                floatingLabelBehavior: FloatingLabelBehavior.always,
                                labelText: lang.S.of(context).weight,
                                hintText: lang.S.of(context).enterWeight,
                                border: const OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ).visible(data.variations.contains('Weight')),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: TextFormField(
                              onSaved: (value) {
                                capacity = value!;
                              },
                              decoration: InputDecoration(
                                floatingLabelBehavior: FloatingLabelBehavior.always,
                                labelText: lang.S.of(context).capacity,
                                hintText: lang.S.of(context).enterCapacity,
                                border: const OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ).visible(data.variations.contains('Capacity')),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: TextFormField(
                        onSaved: (value) {
                          type = value!;
                        },
                        decoration: InputDecoration(
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          labelText: lang.S.of(context).type,
                          hintText: lang.S.of(context).enterType,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ).visible(data.variations.contains('Type')),

                    ///___________Brand___________________________________
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: TextFormField(
                        readOnly: true,
                        onTap: () async {
                          String data = await const BrandsList().launch(context);
                          setState(() {
                            brandName = data;
                            brandNameHint = data;
                          });
                        },
                        decoration: InputDecoration(
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          hintText: brandNameHint,
                          labelText: lang.S.of(context).brand,
                          border: const OutlineInputBorder(),
                          suffixIcon: const Icon(Icons.keyboard_arrow_down),
                        ),
                      ),
                    ),

                    ///_________product_code_______________________________
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: TextFormField(
                              controller: productCodeController,
                              validator: (value) {
                                if (value.isEmptyOrNull) {
                                  return 'Product Code is Required';
                                } else if (widget.productCodeList.contains(value?.toLowerCase().removeAllWhiteSpace())) {
                                  return 'This Product Already added!';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                productCode = value!;
                              },
                              decoration: InputDecoration(
                                floatingLabelBehavior: FloatingLabelBehavior.always,
                                labelText: lang.S.of(context).productCode,
                                hintText: lang.S.of(context).enterProductCodeOrScan,
                                border: const OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: GestureDetector(
                              onTap: () async {
                                await showDialog(
                                  context: context,
                                  useSafeArea: true,
                                  builder: (context1) {
                                    MobileScannerController controller = MobileScannerController(
                                      torchEnabled: false,
                                      returnImage: false,
                                    );
                                    return Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadiusDirectional.circular(6.0),
                                      ),
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
                                                  productCodeController.text = productCode;
                                                  globalKey.currentState!.save();
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

                                // await showDialog(
                                //   context: context,
                                //   useSafeArea: true,
                                //   builder: (context1) {
                                //     MobileScannerController controller = MobileScannerController(
                                //       torchEnabled: false,
                                //       returnImage: false,
                                //     );
                                //     return Container(
                                //       decoration: BoxDecoration(borderRadius: BorderRadiusDirectional.circular(6.0)),
                                //       child: MobileScanner(
                                //         fit: BoxFit.contain,
                                //         controller: controller,
                                //         onDetect: (capture) {
                                //           final List<Barcode> barcodes = capture.barcodes;
                                //
                                //           if (barcodes.isNotEmpty) {
                                //             final Barcode barcode = barcodes.first;
                                //             debugPrint('Barcode found! ${barcode.rawValue}');
                                //             productCode = barcode.rawValue!;
                                //             productCodeController.text = productCode;
                                //             globalKey.currentState!.save();
                                //             Navigator.pop(context1);
                                //           }
                                //         },
                                //       ),
                                //     );
                                //   },
                                // );
                              },
                              child: Container(
                                height: 60.0,
                                width: 100.0,
                                padding: const EdgeInsets.all(5.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.0),
                                  border: Border.all(color: kGreyTextColor),
                                ),
                                child: const Image(
                                  image: AssetImage('images/barcode.png'),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    ///_______stock & unit______________________
                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: TextFormField(
                              controller: stockController,
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                stockText = value.replaceAll(',', '');
                                var formattedText = myFormat.format(int.parse(stockText));
                                stockController.value = stockController.value.copyWith(
                                  text: formattedText,
                                  selection: TextSelection.collapsed(offset: formattedText.length),
                                );
                              },
                              validator: (value) {
                                if (value.isEmptyOrNull) {
                                  return 'Stock is required';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                productStock = value!;
                              },
                              decoration: InputDecoration(
                                floatingLabelBehavior: FloatingLabelBehavior.always,
                                labelText: lang.S.of(context).stocks,
                                hintText: lang.S.of(context).enterStocks,
                                border: const OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: TextFormField(
                              readOnly: true,
                              onTap: () async {
                                String data = await const UnitList().launch(context);
                                setState(() {
                                  productUnit = data;
                                  productUnitHint = data;
                                });
                              },
                              decoration: InputDecoration(
                                floatingLabelBehavior: FloatingLabelBehavior.always,
                                hintText: productUnitHint,
                                labelText: lang.S.of(context).units,
                                border: const OutlineInputBorder(),
                                suffixIcon: const Icon(Icons.keyboard_arrow_down),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    Row(
                      children: [
                        Expanded(
                            child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: TextFormField(
                            keyboardType: TextInputType.number,
                            onSaved: (value) {
                              productDiscount = value!;
                            },
                            decoration: InputDecoration(
                              floatingLabelBehavior: FloatingLabelBehavior.always,
                              labelText: lang.S.of(context).discount,
                              hintText: lang.S.of(context).enterDiscount,
                              border: const OutlineInputBorder(),
                            ),
                          ),
                        )).visible(false),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: TextFormField(
                              onSaved: (value) {
                                productManufacturer = value!;
                              },
                              decoration: InputDecoration(
                                floatingLabelBehavior: FloatingLabelBehavior.always,
                                labelText: lang.S.of(context).menufeturer,
                                hintText: lang.S.of(context).enterManufacturer,
                                border: const OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ),
                        wareHouseList.when(
                          data: (warehouse) {
                            List<WareHouseModel> wareHouseList = warehouse;
                            // List<WareHouseModel> wareHouseList = [];
                            return Expanded(
                              child: FormField(
                                builder: (FormFieldState<dynamic> field) {
                                  return InputDecorator(
                                    decoration: const InputDecoration(
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                                          borderSide: BorderSide(color: kBorderColorTextField, width: 2),
                                        ),
                                        contentPadding: EdgeInsets.all(8.0),
                                        floatingLabelBehavior: FloatingLabelBehavior.always,
                                        labelText: 'Warehouse'),
                                    child: DropdownButtonHideUnderline(
                                      child: getName(list: warehouse ?? []),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                          error: (e, stack) {
                            return Center(
                              child: Text(
                                e.toString(),
                              ),
                            );
                          },
                          loading: () {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          },
                        ),
                      ],
                    ),

                    //______________________________________________________________Tax________________
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        children: [
                          groupTax.when(
                            data: (groupTax) {
                              // List<WareHouseModel> wareHouseList = [];
                              return Expanded(
                                child: FormField(
                                  builder: (FormFieldState<dynamic> field) {
                                    return InputDecorator(
                                      decoration: const InputDecoration(
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(Radius.circular(8.0)),
                                            borderSide: BorderSide(color: kBorderColorTextField, width: 2),
                                          ),
                                          contentPadding: EdgeInsets.all(8.0),
                                          floatingLabelBehavior: FloatingLabelBehavior.always,
                                          labelText: 'Applicable Tax'),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<GroupTaxModel>(
                                          hint: const Text('Select Tax'),
                                          items: groupTax.map((e) {
                                            return DropdownMenuItem<GroupTaxModel>(
                                              value: e,
                                              child: Text(e.name),
                                            );
                                          }).toList(),
                                          value: selectedGroupTaxModel,
                                          onChanged: (value) {
                                            setState(() {
                                              selectedGroupTaxModel = value;
                                              calculateTotal();
                                              adjustSalesPrices(); // Update total amount when tax changes
                                            });
                                          },
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                            error: (e, stack) {
                              return Center(
                                child: Text(
                                  e.toString(),
                                ),
                              );
                            },
                            loading: () {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            },
                          ),
                          SizedBox(
                            width: 10.0,
                          ),
                          Expanded(
                            child: FormField(
                              builder: (FormFieldState<dynamic> field) {
                                return InputDecorator(
                                  decoration: const InputDecoration(
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                                        borderSide: BorderSide(color: kBorderColorTextField, width: 2),
                                      ),
                                      contentPadding: EdgeInsets.all(8.0),
                                      floatingLabelBehavior: FloatingLabelBehavior.always,
                                      labelText: 'Tax Type'),
                                  child: DropdownButtonHideUnderline(
                                    child: getTaxType(),
                                  ),
                                );
                              },
                            ),
                          )
                          // Checkbox(
                          //   value: isIncludeTax,
                          //   onChanged: (value) {
                          //     setState(() {
                          //       isIncludeTax = value!;
                          //     });
                          //   },
                          // ),
                          // Text('Included Tax'),
                        ],
                      ),
                    ),

                    //______________________________________________________________Tax_Amount________________
                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: TextFormField(
                              controller: marginController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                floatingLabelBehavior: FloatingLabelBehavior.always,
                                labelText: 'Margin',
                                hintText: '0',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ),
                        Visibility(
                          visible: selectedTaxType == 'Inclusive',
                          child: Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: TextFormField(
                                readOnly: true,
                                controller: incTaxController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  floatingLabelBehavior: FloatingLabelBehavior.always,
                                  labelText: 'Inc. tax:',
                                  hintText: '0',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Visibility(
                          visible: selectedTaxType == 'Exclusive',
                          child: Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: TextFormField(
                                controller: excTaxController,
                                readOnly: true,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  floatingLabelBehavior: FloatingLabelBehavior.always,
                                  labelText: 'Exc. Tax',
                                  hintText: '0',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    ///__________purchase & sale price_______________________________
                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: TextFormField(
                              controller: productPurchasePriceController,
                              keyboardType: TextInputType.number,
                              // initialValue: myFormat.format(purchaseController),
                              onChanged: (value) {
                                purchaseText = value.replaceAll(',', '');
                                adjustSalesPrices();
                                var formattedText = myFormat.format(int.parse(purchaseText));
                                productPurchasePriceController.value = productPurchasePriceController.value.copyWith(
                                  text: formattedText,
                                  selection: TextSelection.collapsed(offset: formattedText.length),
                                );
                              },
                              validator: (value) {
                                if (value.isEmptyOrNull) {
                                  return 'Purchase Price is required';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                productPurchasePriceController.text = value!;
                              },
                              decoration: InputDecoration(
                                floatingLabelBehavior: FloatingLabelBehavior.always,
                                labelText: lang.S.of(context).purchasePrice,
                                hintText: lang.S.of(context).enterPurchasePrice,
                                border: const OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: TextFormField(
                              controller: productSalePriceController,
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                mrpText = value.replaceAll(',', '');
                                var formattedText = myFormat.format(int.parse(mrpText));
                                productSalePriceController.value = productSalePriceController.value.copyWith(
                                  text: formattedText,
                                  selection: TextSelection.collapsed(offset: formattedText.length),
                                );
                              },
                              validator: (value) {
                                if (value.isEmptyOrNull) {
                                  return 'MRP is required';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                productSalePriceController.text = value!;
                              },
                              decoration: InputDecoration(
                                floatingLabelBehavior: FloatingLabelBehavior.always,
                                labelText: lang.S.of(context).MRP,
                                hintText: lang.S.of(context).enterMrpOrRetailerPirce,
                                border: const OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    ///___________wholeSale_DealerPrice____________________________
                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: TextFormField(
                              controller: productWholesalePriceController,
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                wholesaleText = value.replaceAll(',', '');
                                var formattedText = myFormat.format(int.parse(wholesaleText));
                                productWholesalePriceController.value = productWholesalePriceController.value.copyWith(
                                  text: formattedText,
                                  selection: TextSelection.collapsed(offset: formattedText.length),
                                );
                              },
                              onSaved: (value) {
                                productWholesalePriceController.text = value!;
                              },
                              decoration: InputDecoration(
                                floatingLabelBehavior: FloatingLabelBehavior.always,
                                labelText: lang.S.of(context).wholeSalePrice,
                                hintText: lang.S.of(context).enterWholeSalePrice,
                                border: const OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: TextFormField(
                              controller: productDealerPriceController,
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                dealerText = value.replaceAll(',', '');
                                var formattedText = myFormat.format(int.parse(dealerText));
                                productDealerPriceController.value = productDealerPriceController.value.copyWith(
                                  text: formattedText,
                                  selection: TextSelection.collapsed(offset: formattedText.length),
                                );
                              },
                              onSaved: (value) {
                                productDealerPriceController.text = value!;
                              },
                              decoration: InputDecoration(
                                floatingLabelBehavior: FloatingLabelBehavior.always,
                                labelText: lang.S.of(context).dealerPrice,
                                hintText: lang.S.of(context).enterDealerPrice,
                                border: const OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    ///______________ExpireDate______________________
                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: AppTextField(
                              textFieldType: TextFieldType.NAME,
                              readOnly: true,
                              validator: (value) {
                                return null;
                              },
                              controller: manufactureDateTextEditingController,
                              decoration: InputDecoration(
                                floatingLabelBehavior: FloatingLabelBehavior.always,
                                labelText: "Manufacture Date",
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
                                      picked != null ? manufactureDateTextEditingController.text = DateFormat.yMMMd().format(picked) : null;
                                      picked != null ? manufactureDate = picked.toString() : null;
                                    });
                                  },
                                  icon: const Icon(FeatherIcons.calendar),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: AppTextField(
                              textFieldType: TextFieldType.NAME,
                              readOnly: true,
                              validator: (value) {
                                return null;
                              },
                              controller: expireDateTextEditingController,
                              decoration: InputDecoration(
                                floatingLabelBehavior: FloatingLabelBehavior.always,
                                labelText: 'Expire Date',
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
                                      picked != null ? expireDateTextEditingController.text = DateFormat.yMMMd().format(picked) : null;
                                      picked != null ? expireDate = picked.toString() : null;
                                    });
                                  },
                                  icon: const Icon(FeatherIcons.calendar),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    ///_______Lower_stock___________________________
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: TextFormField(
                        initialValue: lowerStockAlert.toString(),
                        onSaved: (value) {
                          lowerStockAlert = int.tryParse(value ?? '') ?? 5;
                        },
                        decoration: const InputDecoration(
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          labelText: 'Low Stock Alert',
                          hintText: 'Enter Low Stock Alert Quantity',
                          border: OutlineInputBorder(),
                        ),
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      ),
                    ),

                    ///---------product description--------------------
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: TextFormField(
                        maxLines: 3,
                        keyboardType: TextInputType.multiline,
                        decoration: const InputDecoration(
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          border: OutlineInputBorder(),
                          labelText: 'Description',
                          hintText: 'Enter Description',
                        ),
                        // validator: (value) {
                        //   if (value?.removeAllWhiteSpace().toLowerCase().isEmptyOrNull ?? true) {
                        //     return 'Product name is required.';
                        //   } else if (!checkProductName(name: value!, id: selectedWareHouse!.id)) {
                        //     return 'Product Name already exists in this warehouse.';
                        //   } else {
                        //     return null; // Validation passes
                        //   }
                        // },
                        controller: productDescriptionController,
                        onSaved: (value) {
                          productDescriptionController.text = value!;
                        },
                        // onSaved: (value) {
                        //   productName = value!;
                        // },
                      ),
                    ),

                    Column(
                      children: [
                        const SizedBox(height: 10),
                        GestureDetector(
                          onTap: () {
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return Dialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    // ignore: sized_box_for_whitespace
                                    child: Container(
                                      height: 200.0,
                                      width: MediaQuery.of(context).size.width - 80,
                                      child: Center(
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            GestureDetector(
                                              onTap: () async {
                                                pickedImage = await _picker.pickImage(source: ImageSource.gallery);

                                                setState(() {
                                                  imageFile = File(pickedImage!.path);
                                                  imagePath = pickedImage!.path;
                                                });

                                                Future.delayed(const Duration(milliseconds: 100), () {
                                                  Navigator.pop(context);
                                                });
                                              },
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  const Icon(
                                                    Icons.photo_library_rounded,
                                                    size: 60.0,
                                                    color: kMainColor,
                                                  ),
                                                  Text(
                                                    lang.S.of(context).gallary,
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 20.0,
                                                      color: kMainColor,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 40.0,
                                            ),
                                            GestureDetector(
                                              onTap: () async {
                                                pickedImage = await _picker.pickImage(source: ImageSource.camera);
                                                setState(() {
                                                  imageFile = File(pickedImage!.path);
                                                  imagePath = pickedImage!.path;
                                                });
                                                Future.delayed(const Duration(milliseconds: 100), () {
                                                  Navigator.pop(context);
                                                });
                                              },
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  const Icon(
                                                    Icons.camera,
                                                    size: 60.0,
                                                    color: kGreyTextColor,
                                                  ),
                                                  Text(
                                                    lang.S.of(context).camera,
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 20.0,
                                                      color: kGreyTextColor,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                });
                          },
                          child: Stack(
                            children: [
                              Container(
                                height: 120,
                                width: 120,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black54, width: 1),
                                  borderRadius: const BorderRadius.all(Radius.circular(120)),
                                  image: imagePath == 'No Data'
                                      ? DecorationImage(
                                          image: NetworkImage(productPicture),
                                          fit: BoxFit.cover,
                                        )
                                      : DecorationImage(
                                          image: FileImage(imageFile),
                                          fit: BoxFit.cover,
                                        ),
                                ),
                              ),
                              Container(
                                height: 120,
                                width: 120,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black54, width: 1),
                                  borderRadius: const BorderRadius.all(Radius.circular(120)),
                                  image: DecorationImage(
                                    image: FileImage(imageFile),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                // child: imageFile.path == 'No File' ? null : Image.file(imageFile),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  height: 35,
                                  width: 35,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.white, width: 2),
                                    borderRadius: const BorderRadius.all(Radius.circular(120)),
                                    color: kMainColor,
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt_outlined,
                                    size: 20,
                                    color: Colors.white,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                    ButtonGlobalWithoutIcon(
                      buttontext: lang.S.of(context).saveAndPublish,
                      buttonDecoration: kButtonDecoration.copyWith(color: kMainColor, borderRadius: const BorderRadius.all(Radius.circular(30))),
                      onPressed: saleButtonClicked
                          ? () {}
                          : () async {
                              if (!isDemo) {
                                if (validateAndSave()) {
                                  try {
                                    setState(() {
                                      saleButtonClicked = true;
                                    });
                                    EasyLoading.show(status: 'Loading...', dismissOnTap: false);
                                    bool result = await InternetConnectionChecker().hasConnection;

                                    result
                                        ? imagePath == 'No Data'
                                            ? null
                                            : await uploadFile(imagePath)
                                        : null;
                                    // ignore: no_leading_underscores_for_local_identifiers
                                    final DatabaseReference _productInformationRef = FirebaseDatabase.instance.ref().child(constUserId).child('Products');
                                    _productInformationRef.keepSynced(true);
                                    ProductModel productModel = ProductModel(
                                      productName: productNameController.text,
                                      productCategory: productCategory,
                                      productDescription: productDescriptionController.text,
                                      size: size,
                                      color: color,
                                      weight: weight,
                                      capacity: capacity,
                                      type: type,
                                      brandName: brandName,
                                      productCode: productCode,
                                      productStock: stockText,
                                      productUnit: productUnit,
                                      productSalePrice: mrpText,
                                      productPurchasePrice: purchaseText,
                                      productDiscount: productDiscount,
                                      productWholeSalePrice: wholesaleText,
                                      productDealerPrice: dealerText,
                                      productManufacturer: productManufacturer,
                                      warehouseName: selectedWareHouse!.warehouseName,
                                      warehouseId: selectedWareHouse!.id,
                                      productPicture: productPicture,
                                      expiringDate: expireDate,
                                      manufacturingDate: manufactureDate,
                                      lowerStockAlert: lowerStockAlert,
                                      serialNumber: [],
                                      taxType: selectedTaxType,
                                      margin: num.tryParse(marginController.text) ?? 0,
                                      excTax: num.tryParse(excTaxAmount) ?? 0,
                                      incTax: num.tryParse(incTaxAmount) ?? 0,
                                      groupTaxName: selectedGroupTaxModel?.name ?? '',
                                      groupTaxRate: selectedGroupTaxModel?.taxRate ?? 0,
                                      subTaxes: selectedGroupTaxModel?.subTaxes ?? [],
                                    );
                                    print(productModel.toJson());
                                    _productInformationRef.push().set(productModel.toJson());


                                    // ref.refresh(productProvider);

                                    // ref.refresh(brandsProvider);
                                    Subscription.decreaseSubscriptionLimits(itemType: 'products', context: context);
                                    EasyLoading.dismiss();
                                    // ref.refresh(categoryProvider);
                                    ref.refresh(productProvider);

                                    // _productInformationRef.onChildAdded.listen((event) {
                                    //   ref.refresh(productProvider);
                                    //   ref.refresh(categoryProvider);
                                    //   ref.refresh(brandsProvider);
                                    // });
                                    Navigator.pop(context, true);

                                    // Future.delayed(const Duration(milliseconds: 100), () {
                                    //   const ProductList().launch(context, isNewTask: true);
                                    // });
                                  } catch (e) {
                                    setState(() {
                                      saleButtonClicked = false;
                                    });
                                    EasyLoading.dismiss();
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                                  }
                                }
                              } else {
                                EasyLoading.showError(demoText);
                              }
                            },
                      buttonTextColor: Colors.white,
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  bool validateAndSave() {
    final form = globalKey.currentState;
    if (form!.validate()) {
      form.save();
      return true;
    }
    return false;
  }
}
