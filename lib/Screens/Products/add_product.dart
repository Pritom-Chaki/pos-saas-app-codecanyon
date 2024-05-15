// ignore_for_file: unused_result, use_build_context_synchronously

import 'dart:io';

import 'package:firebase_core/firebase_core.dart' as firebase_core;
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
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

  final TextEditingController purchaseController = TextEditingController();
  final TextEditingController mrpController = TextEditingController();
  final TextEditingController wholesaleController = TextEditingController();
  final TextEditingController delaerController = TextEditingController();
  final TextEditingController stockController = TextEditingController();

  String mrpText = '';
  String purchaseText = '';
  String wholesaleText = '';
  String dealerText = '';
  String stockText = '';
  TextEditingController productNameController = TextEditingController();

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
                                              productCodeController.text = productCode;
                                              globalKey.currentState!.save();
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

                    ///__________purchase & sale price_______________________________
                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: TextFormField(
                              controller: purchaseController,
                              keyboardType: TextInputType.number,
                              // initialValue: myFormat.format(purchaseController),
                              onChanged: (value) {
                                purchaseText = value.replaceAll(',', '');
                                var formattedText = myFormat.format(int.parse(purchaseText));
                                purchaseController.value = purchaseController.value.copyWith(
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
                                purchaseController.text = value!;
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
                              controller: mrpController,
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                mrpText = value.replaceAll(',', '');
                                var formattedText = myFormat.format(int.parse(mrpText));
                                mrpController.value = mrpController.value.copyWith(
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
                                mrpController.text = value!;
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
                              controller: wholesaleController,
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                wholesaleText = value.replaceAll(',', '');
                                var formattedText = myFormat.format(int.parse(wholesaleText));
                                wholesaleController.value = wholesaleController.value.copyWith(
                                  text: formattedText,
                                  selection: TextSelection.collapsed(offset: formattedText.length),
                                );
                              },
                              onSaved: (value) {
                                wholesaleController.text = value!;
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
                              controller: delaerController,
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                dealerText = value.replaceAll(',', '');
                                var formattedText = myFormat.format(int.parse(dealerText));
                                delaerController.value = delaerController.value.copyWith(
                                  text: formattedText,
                                  selection: TextSelection.collapsed(offset: formattedText.length),
                                );
                              },
                              onSaved: (value) {
                                delaerController.text = value!;
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
                                  final availableSubscription = await Subscription.availableSubscription(context: context);
                                  final availableLimit = await Subscription.availableLimit(itemType: 'products', context: context);
                                  if (!availableSubscription) {
                                    return EasyLoading.showError("Please update your subscription. Subscription date is expired.");
                                  } else if (!availableLimit) {
                                    return EasyLoading.showError("Please Update Your Subscription. Your products limit is expired.");
                                  }

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

                                    // final availableSubscription = await Subscription.availableSubscription(context: context);
                                    // final availableLimit = await Subscription.availableLimit(itemType: 'products', context: context);
                                    print(availableLimit);
                                    print(availableSubscription);
                                    if (availableSubscription && availableLimit) {
                                      final DatabaseReference _productInformationRef = FirebaseDatabase.instance
                                          // ignore: deprecated_member_use
                                          .reference()
                                          .child(constUserId)
                                          .child('Products');
                                      _productInformationRef.keepSynced(true);
                                      ProductModel productModel = ProductModel(
                                        productName: productNameController.text,
                                        productCategory: productCategory,
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
                                      );
                                      _productInformationRef.push().set(productModel.toJson());
                                      Subscription.decreaseSubscriptionLimits(itemType: 'products', context: context);
                                      EasyLoading.dismiss();
                                      _productInformationRef.onChildAdded.listen((event) {
                                        ref.refresh(productProvider);
                                        ref.refresh(categoryProvider);
                                        ref.refresh(brandsProvider);
                                      });

                                      Future.delayed(const Duration(milliseconds: 100), () {
                                        const ProductList().launch(context, isNewTask: true);
                                      });
                                    } else {
                                      EasyLoading.dismiss();
                                      EasyLoading.showError("Please Update Your Subscription");
                                    }
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
