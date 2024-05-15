import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:intl/intl.dart';
import 'package:mobile_pos/Screens/Products/unit_list.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import 'package:firebase_core/firebase_core.dart' as firebase_core;
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:mobile_pos/GlobalComponents/button_global.dart';
import 'package:mobile_pos/model/product_model.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../GlobalComponents/Model/category_model.dart';
import '../../Provider/category,brans,units_provide.dart';
import '../../Provider/product_provider.dart';
import '../../const_commas.dart';
import '../../constant.dart';
import '../../currency.dart';
import '../Home/home.dart';
import '../Home/home_screen.dart';
import 'brands_list.dart';
import 'category_list.dart';

class UpdateProduct extends StatefulWidget {
  const UpdateProduct({super.key, required this.productModel, required this.productNameList, required this.productCodeList});

  final ProductModel productModel;
  final List<String> productNameList;
  final List<String> productCodeList;

  @override
  UpdateProductState createState() => UpdateProductState();
}

class UpdateProductState extends State<UpdateProduct> {
  late String productKey;
  late ProductModel updatedProductModel;
  final ImagePicker _picker = ImagePicker();
  XFile? pickedImage;
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
        updatedProductModel.productPicture = url.toString();
      });
      EasyLoading.dismiss();
    } on firebase_core.FirebaseException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.code.toString())));
    }
  }

  void getProductKey(String code) async {
    // ignore: unused_local_variable
    List<ProductModel> productList = [];

    final ref = FirebaseDatabase.instance.ref(constUserId).child('Products');

    ref.keepSynced(true);

    ref.orderByKey().get().then((value) {
      for (var element in value.children) {
        var data = jsonDecode(jsonEncode(element.value));
        if (data['productCode'].toString() == code) {
          productKey = element.key.toString();
        }
      }
    });
  }

  TextEditingController productNameController = TextEditingController();
  TextEditingController sizeController = TextEditingController();
  TextEditingController colorController = TextEditingController();
  TextEditingController weightController = TextEditingController();
  TextEditingController capacityController = TextEditingController();
  TextEditingController typeController = TextEditingController();
  TextEditingController purchasePriceController = TextEditingController();
  TextEditingController mrpController = TextEditingController();
  TextEditingController wholeSaleController = TextEditingController();
  TextEditingController dealerPriceController = TextEditingController();
  TextEditingController manufacturerController = TextEditingController();
  TextEditingController expireDateTextEditingController = TextEditingController();
  TextEditingController manufactureDateTextEditingController = TextEditingController();
  TextEditingController productStockController = TextEditingController();
  int lowerStockAlert = 5;
  String? expireDate;
  String? manufactureDate;

  @override
  void initState() {
    getProductKey(widget.productModel.productCode);
    updatedProductModel = widget.productModel;
    super.initState();

    ///________set_previous_data_________________________
    productNameController.value = TextEditingValue(text: widget.productModel.productName);
    sizeController.value = TextEditingValue(text: widget.productModel.size);
    colorController.value = TextEditingValue(text: widget.productModel.color);
    weightController.value = TextEditingValue(text: widget.productModel.weight);
    capacityController.value = TextEditingValue(text: widget.productModel.capacity);
    typeController.value = TextEditingValue(text: widget.productModel.type);
    purchasePriceController.value = TextEditingValue(text: widget.productModel.productPurchasePrice);
    mrpController.value = TextEditingValue(text: widget.productModel.productSalePrice);
    wholeSaleController.value = TextEditingValue(text: widget.productModel.productWholeSalePrice);
    dealerPriceController.value = TextEditingValue(text: widget.productModel.productDealerPrice);
    manufacturerController.value = TextEditingValue(text: widget.productModel.productManufacturer);
    productStockController.value = TextEditingValue(text: widget.productModel.productStock);
    if (widget.productModel.expiringDate != null) {
      expireDateTextEditingController.text = DateFormat.yMMMd().format(DateTime.parse(widget.productModel.expiringDate!));
      expireDate = widget.productModel.expiringDate;
    }
    if (widget.productModel.manufacturingDate != null) {
      manufactureDateTextEditingController.text = DateFormat.yMMMd().format(DateTime.parse(widget.productModel.manufacturingDate!));
      manufactureDate = widget.productModel.manufacturingDate;
    }

    lowerStockAlert = widget.productModel.lowerStockAlert;
  }

  GlobalKey<FormState> globalKey = GlobalKey<FormState>();
  GetCategoryAndVariationModel data = GetCategoryAndVariationModel(variations: [], categoryName: '');
  String productCategoryName = '';
  String productCategoryHint = 'Select Product Category';
  String brandName = '';
  String brandNameHint = 'Select Brand';
  String productUnit = '';
  String productUnitHint = 'Select Unit';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kMainColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: kMainColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          lang.S.of(context).updateProduct,
          style: GoogleFonts.poppins(
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer(builder: (context, pref, __) {
        return Container(
          alignment: Alignment.topCenter,
          decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(topRight: Radius.circular(30), topLeft: Radius.circular(30))),
          child: SingleChildScrollView(
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
                        controller: productNameController,
                        decoration: InputDecoration(
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          border: const OutlineInputBorder(),
                          labelText: lang.S.of(context).productName,
                          hintText: lang.S.of(context).enterProductName,
                        ),
                        validator: (value) {
                          if (value.isEmptyOrNull) {
                            return 'Product name is required.';
                          } else if (widget.productNameList.contains(value?.toLowerCase().removeAllWhiteSpace()) && value != widget.productModel.productName) {
                            return 'Product name is already added.';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          updatedProductModel.productName = value!;
                        },
                      ),
                    ),

                    ///______category___________________________
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: TextFormField(
                        onTap: () async {
                          data = await const CategoryList().launch(context);
                          setState(() {
                            productCategoryName = data.categoryName;
                            productCategoryHint = data.categoryName;
                            updatedProductModel.productCategory = data.categoryName;
                          });
                        },
                        readOnly: true,
                        decoration: InputDecoration(
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          hintText: widget.productModel.productCategory.isEmpty ? productCategoryHint : widget.productModel.productCategory,
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
                              controller: sizeController,
                              onSaved: (value) {
                                updatedProductModel.size = value!;
                              },
                              decoration: InputDecoration(
                                floatingLabelBehavior: FloatingLabelBehavior.always,
                                labelText: lang.S.of(context).size,
                                hintText: lang.S.of(context).enterSize,
                                border: const OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ).visible(widget.productModel.size.isNotEmpty),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: TextFormField(
                              controller: colorController,
                              onSaved: (value) {
                                updatedProductModel.color = value!;
                              },
                              decoration: InputDecoration(
                                floatingLabelBehavior: FloatingLabelBehavior.always,
                                labelText: lang.S.of(context).color,
                                hintText: lang.S.of(context).enterColor,
                                border: const OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ).visible(widget.productModel.color.isNotEmpty),
                      ],
                    ),

                    ///_______Weight & Capacity & Type_____________________________
                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: TextFormField(
                              controller: weightController,
                              onSaved: (value) {
                                updatedProductModel.weight = value!;
                              },
                              decoration: InputDecoration(
                                floatingLabelBehavior: FloatingLabelBehavior.always,
                                labelText: lang.S.of(context).weight,
                                hintText: lang.S.of(context).weight,
                                border: const OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ).visible(widget.productModel.weight.isNotEmpty),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: TextFormField(
                              controller: capacityController,
                              onSaved: (value) {
                                updatedProductModel.capacity = value!;
                              },
                              decoration: InputDecoration(
                                floatingLabelBehavior: FloatingLabelBehavior.always,
                                labelText: lang.S.of(context).capacity,
                                hintText: lang.S.of(context).enterCapacity,
                                border: const OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ).visible(widget.productModel.capacity.isNotEmpty),
                      ],
                    ),

                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: TextFormField(
                        controller: typeController,
                        onSaved: (value) {
                          updatedProductModel.type = value!;
                        },
                        decoration: InputDecoration(
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          labelText: lang.S.of(context).type,
                          hintText: 'Usb C',
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ).visible(widget.productModel.type.isNotEmpty),

                    ///___________Brand___________________________________
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: TextFormField(
                        onTap: () async {
                          String data = await const BrandsList().launch(context);
                          setState(() {
                            brandName = data;
                            brandNameHint = data;
                            updatedProductModel.brandName = brandName;
                          });
                        },
                        readOnly: true,
                        decoration: InputDecoration(
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          hintText: widget.productModel.brandName.isEmpty ? brandNameHint : widget.productModel.brandName,
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
                              readOnly: true,
                              decoration: InputDecoration(
                                floatingLabelBehavior: FloatingLabelBehavior.always,
                                hintText: widget.productModel.productCode,
                                labelText: lang.S.of(context).productCode,
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
                              readOnly: false,
                              controller: productStockController,
                              decoration: InputDecoration(
                                floatingLabelBehavior: FloatingLabelBehavior.always,
                                labelText: lang.S.of(context).stocks,
                                // hintText: widget.productModel.productStock,
                                border: const OutlineInputBorder(),
                              ),
                              onChanged: (value) {
                                final sanitizedValue = value.replaceAll(RegExp(r'[^0-9]'), '');
                                final formattedValue = myFormat.format(int.tryParse(sanitizedValue) ?? 0);
                                if (formattedValue.length > 20) {
                                  productStockController.value = productStockController.value.copyWith(
                                    text: sanitizedValue.substring(0, 20),
                                    selection: const TextSelection.collapsed(offset: 20),
                                  );
                                } else {
                                  productStockController.value = productStockController.value.copyWith(
                                    text: formattedValue,
                                    selection: TextSelection.collapsed(offset: formattedValue.length),
                                  );
                                }
                                updatedProductModel.productStock = sanitizedValue;
                              },
                              onSaved: (value) {
                                final rawValue = value!.replaceAll(RegExp(r'[^0-9]'), '');
                                updatedProductModel.productStock = rawValue;
                              },
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
                                  updatedProductModel.productUnit = productUnit;
                                });
                              },
                              decoration: InputDecoration(
                                floatingLabelBehavior: FloatingLabelBehavior.always,
                                hintText: productUnit.isEmpty ? widget.productModel.productUnit : productUnit,
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
                              readOnly: false,
                              keyboardType: TextInputType.number,
                              controller: purchasePriceController,
                              decoration: InputDecoration(
                                floatingLabelBehavior: FloatingLabelBehavior.always,
                                labelText: lang.S.of(context).purchasePrice,
                                hintText: lang.S.of(context).enterPurchasePrice,
                                border: const OutlineInputBorder(),
                              ),
                              onChanged: (value) {
                                final sanitizedValue = value.replaceAll(RegExp(r'[^0-9]'), '');
                                final formattedValue = myFormat.format(int.tryParse(sanitizedValue) ?? 0);
                                if (formattedValue.length > 20) {
                                  purchasePriceController.value = purchasePriceController.value.copyWith(
                                    text: sanitizedValue.substring(0, 20),
                                    selection: const TextSelection.collapsed(offset: 20),
                                  );
                                } else {
                                  purchasePriceController.value = purchasePriceController.value.copyWith(
                                    text: formattedValue,
                                    selection: TextSelection.collapsed(offset: formattedValue.length),
                                  );
                                }
                                updatedProductModel.productPurchasePrice = sanitizedValue;
                              },
                              onSaved: (value) {
                                final rawValue = value!.replaceAll(RegExp(r'[^0-9]'), '');
                                updatedProductModel.productPurchasePrice = rawValue;
                              },
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: TextFormField(
                              readOnly: false,
                              controller: mrpController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                floatingLabelBehavior: FloatingLabelBehavior.always,
                                labelText: lang.S.of(context).MRP,
                                hintText: lang.S.of(context).enterMrpOrRetailerPirce,
                                border: const OutlineInputBorder(),
                              ),
                              onChanged: (value) {
                                final sanitizedValue = value.replaceAll(RegExp(r'[^0-9]'), '');
                                final formattedValue = myFormat.format(int.tryParse(sanitizedValue) ?? 0);
                                if (formattedValue.length > 20) {
                                  mrpController.value = mrpController.value.copyWith(
                                    text: sanitizedValue.substring(0, 20),
                                    selection: const TextSelection.collapsed(offset: 20),
                                  );
                                } else {
                                  mrpController.value = mrpController.value.copyWith(
                                    text: formattedValue,
                                    selection: TextSelection.collapsed(offset: formattedValue.length),
                                  );
                                }
                                updatedProductModel.productSalePrice = sanitizedValue;
                              },
                              onSaved: (value) {
                                final rawValue = value!.replaceAll(RegExp(r'[^0-9]'), '');
                                updatedProductModel.productSalePrice = rawValue;
                              },
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
                              controller: wholeSaleController,
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                final sanitizedValue = value.replaceAll(RegExp(r'[^0-9]'), '');
                                final formattedValue = myFormat.format(int.tryParse(sanitizedValue) ?? 0);
                                if (formattedValue.length > 20) {
                                  wholeSaleController.value = wholeSaleController.value.copyWith(
                                    text: sanitizedValue.substring(0, 20),
                                    selection: const TextSelection.collapsed(offset: 20),
                                  );
                                } else {
                                  wholeSaleController.value = wholeSaleController.value.copyWith(
                                    text: formattedValue,
                                    selection: TextSelection.collapsed(offset: formattedValue.length),
                                  );
                                }
                                updatedProductModel.productWholeSalePrice = sanitizedValue;
                              },
                              onSaved: (value) {
                                final rawValue = value!.replaceAll(RegExp(r'[^0-9]'), '');
                                updatedProductModel.productWholeSalePrice = rawValue;
                              },
                              decoration: InputDecoration(
                                floatingLabelBehavior: FloatingLabelBehavior.always,
                                labelText: lang.S.of(context).wholeSalePrice,
                                border: const OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: TextFormField(
                              controller: dealerPriceController,
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                final sanitizedValue = value.replaceAll(RegExp(r'[^0-9]'), '');
                                final formattedValue = myFormat.format(int.tryParse(sanitizedValue) ?? 0);
                                if (formattedValue.length > 20) {
                                  dealerPriceController.value = dealerPriceController.value.copyWith(
                                    text: sanitizedValue.substring(0, 20),
                                    selection: const TextSelection.collapsed(offset: 20),
                                  );
                                } else {
                                  dealerPriceController.value = dealerPriceController.value.copyWith(
                                    text: formattedValue,
                                    selection: TextSelection.collapsed(offset: formattedValue.length),
                                  );
                                }
                                updatedProductModel.productDealerPrice = sanitizedValue;
                              },
                              onSaved: (value) {
                                final rawValue = value!.replaceAll(RegExp(r'[^0-9]'), '');
                                updatedProductModel.productDealerPrice = rawValue;
                              },
                              decoration: InputDecoration(
                                floatingLabelBehavior: FloatingLabelBehavior.always,
                                labelText: lang.S.of(context).dealerPrice,
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
                              controller: manufacturerController,
                              onSaved: (value) {
                                updatedProductModel.productManufacturer = value!;
                              },
                              decoration: InputDecoration(
                                floatingLabelBehavior: FloatingLabelBehavior.always,
                                labelText: lang.S.of(context).menufeturer,
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
                                hintText: manufactureDateTextEditingController.text.isEmpty ? 'N/A' : '',
                                border: const OutlineInputBorder(),
                                suffixIcon: IconButton(
                                  onPressed: () async {
                                    final DateTime? picked = await showDatePicker(
                                      initialDate: DateTime.tryParse(manufactureDate ?? '') ?? DateTime.now(),
                                      firstDate: DateTime(2015, 8),
                                      lastDate: DateTime(2101),
                                      context: context,
                                    );
                                    setState(() {
                                      manufactureDateTextEditingController.text = DateFormat.yMMMd().format(picked ?? DateTime.parse(manufactureDate!));
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
                                hintText: expireDateTextEditingController.text.isEmpty ? 'N/A' : '',
                                border: const OutlineInputBorder(),
                                suffixIcon: IconButton(
                                  onPressed: () async {
                                    final DateTime? picked = await showDatePicker(
                                      initialDate: DateTime.tryParse(expireDate ?? '') ?? DateTime.now(),
                                      firstDate: DateTime(2015, 8),
                                      lastDate: DateTime(2101),
                                      context: context,
                                    );
                                    setState(() {
                                      expireDateTextEditingController.text = DateFormat.yMMMd().format(picked ?? DateTime.parse(expireDate!));
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
                                      image: NetworkImage(widget.productModel.productPicture),
                                      fit: BoxFit.cover,
                                    )
                                  : DecorationImage(
                                      image: FileImage(imageFile),
                                      fit: BoxFit.cover,
                                    ),
                            ),
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
                    const SizedBox(height: 20),
                    ButtonGlobalWithoutIcon(
                      buttontext: lang.S.of(context).saveAndPublish,
                      buttonDecoration: kButtonDecoration.copyWith(color: kMainColor, borderRadius: const BorderRadius.all(Radius.circular(30))),
                      onPressed: () async {
                        if (validateAndSave()) {
                          try {
                            bool result = await InternetConnectionChecker().hasConnection;

                            result
                                ? imagePath == 'No Data'
                                    ? null
                                    : await uploadFile(imagePath)
                                : null;
                            EasyLoading.show(status: 'Loading...', dismissOnTap: false);
                            DatabaseReference ref = FirebaseDatabase.instance.ref("$constUserId/Products/$productKey");
                            ref.keepSynced(true);
                            ref.update({
                              'productName': updatedProductModel.productName,
                              'productCategory': updatedProductModel.productCategory,
                              'size': updatedProductModel.size,
                              'color': updatedProductModel.color,
                              'weight': updatedProductModel.weight,
                              'capacity': updatedProductModel.capacity,
                              'type': updatedProductModel.type,
                              'brandName': updatedProductModel.brandName,
                              'productCode': updatedProductModel.productCode,
                              'productStock': updatedProductModel.productStock,
                              'productUnit': updatedProductModel.productUnit,
                              'productSalePrice': updatedProductModel.productSalePrice,
                              'productPurchasePrice': updatedProductModel.productPurchasePrice,
                              'productDiscount': updatedProductModel.productDiscount,
                              'productWholeSalePrice': updatedProductModel.productWholeSalePrice,
                              'productDealerPrice': updatedProductModel.productDealerPrice,
                              'productManufacturer': updatedProductModel.productManufacturer,
                              'productPicture': updatedProductModel.productPicture,
                              'manufacturingDate': manufactureDate,
                              'expiringDate': expireDate,
                              'lowerStockAlert': lowerStockAlert,
                            });
                            EasyLoading.dismiss();
                            pref.refresh(productProvider);
                            pref.refresh(categoryProvider);

                            Future.delayed(const Duration(milliseconds: 100), () {
                              EasyLoading.dismiss();
                              pref.refresh(productProvider);
                              pref.refresh(categoryProvider);
                              const Home().launch(context, isNewTask: true);
                            });
                          } catch (e) {
                            EasyLoading.dismiss();
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                          }
                        }
                      },
                      buttonTextColor: Colors.white,
                    ),
                    // Column(
                    //   children: [
                    //     const SizedBox(height: 10),
                    //     GestureDetector(
                    //       onTap: () {
                    //         showDialog(
                    //             context: context,
                    //             builder: (BuildContext context) {
                    //               return Dialog(
                    //                 shape: RoundedRectangleBorder(
                    //                   borderRadius: BorderRadius.circular(12.0),
                    //                 ),
                    //                 // ignore: sized_box_for_whitespace
                    //                 child: Container(
                    //                   height: 200.0,
                    //                   width: MediaQuery.of(context).size.width - 80,
                    //                   child: Center(
                    //                     child: Row(
                    //                       mainAxisAlignment: MainAxisAlignment.center,
                    //                       children: [
                    //                         GestureDetector(
                    //                           onTap: () async {
                    //                             pickedImage = await _picker.pickImage(source: ImageSource.gallery);
                    //
                    //                             setState(() {
                    //                               imageFile = File(pickedImage!.path);
                    //                               imagePath = pickedImage!.path;
                    //                             });
                    //
                    //                             Future.delayed(const Duration(milliseconds: 100), () {
                    //                               Navigator.pop(context);
                    //                             });
                    //                           },
                    //                           child: Column(
                    //                             mainAxisAlignment: MainAxisAlignment.center,
                    //                             children: [
                    //                               const Icon(
                    //                                 Icons.photo_library_rounded,
                    //                                 size: 60.0,
                    //                                 color: kMainColor,
                    //                               ),
                    //                               Text(
                    //                                 'Gallery',
                    //                                 style: GoogleFonts.poppins(
                    //                                   fontSize: 20.0,
                    //                                   color: kMainColor,
                    //                                 ),
                    //                               ),
                    //                             ],
                    //                           ),
                    //                         ),
                    //                         const SizedBox(
                    //                           width: 40.0,
                    //                         ),
                    //                         GestureDetector(
                    //                           onTap: () async {
                    //                             pickedImage = await _picker.pickImage(source: ImageSource.camera);
                    //                             setState(() {
                    //                               imageFile = File(pickedImage!.path);
                    //                               imagePath = pickedImage!.path;
                    //                             });
                    //                             Future.delayed(const Duration(milliseconds: 100), () {
                    //                               Navigator.pop(context);
                    //                             });
                    //                           },
                    //                           child: Column(
                    //                             mainAxisAlignment: MainAxisAlignment.center,
                    //                             children: [
                    //                               const Icon(
                    //                                 Icons.camera,
                    //                                 size: 60.0,
                    //                                 color: kGreyTextColor,
                    //                               ),
                    //                               Text(
                    //                                 'Camera',
                    //                                 style: GoogleFonts.poppins(
                    //                                   fontSize: 20.0,
                    //                                   color: kGreyTextColor,
                    //                                 ),
                    //                               ),
                    //                             ],
                    //                           ),
                    //                         ),
                    //                       ],
                    //                     ),
                    //                   ),
                    //                 ),
                    //               );
                    //             });
                    //       },
                    //       child: Stack(
                    //         children: [
                    //           Container(
                    //             height: 120,
                    //             width: 120,
                    //             decoration: BoxDecoration(
                    //               border: Border.all(color: Colors.black54, width: 1),
                    //               borderRadius: const BorderRadius.all(Radius.circular(120)),
                    //               image: imagePath == 'No Data'
                    //                   ? DecorationImage(
                    //                       image: NetworkImage(productPicture),
                    //                       fit: BoxFit.cover,
                    //                     )
                    //                   : DecorationImage(
                    //                       image: FileImage(imageFile),
                    //                       fit: BoxFit.cover,
                    //                     ),
                    //             ),
                    //           ),
                    //           Container(
                    //             height: 120,
                    //             width: 120,
                    //             decoration: BoxDecoration(
                    //               border: Border.all(color: Colors.black54, width: 1),
                    //               borderRadius: const BorderRadius.all(Radius.circular(120)),
                    //               image: DecorationImage(
                    //                 image: FileImage(imageFile),
                    //                 fit: BoxFit.cover,
                    //               ),
                    //             ),
                    //             // child: imageFile.path == 'No File' ? null : Image.file(imageFile),
                    //           ),
                    //           Positioned(
                    //             bottom: 0,
                    //             right: 0,
                    //             child: Container(
                    //               height: 35,
                    //               width: 35,
                    //               decoration: BoxDecoration(
                    //                 border: Border.all(color: Colors.white, width: 2),
                    //                 borderRadius: const BorderRadius.all(Radius.circular(120)),
                    //                 color: kMainColor,
                    //               ),
                    //               child: const Icon(
                    //                 Icons.camera_alt_outlined,
                    //                 size: 20,
                    //                 color: Colors.white,
                    //               ),
                    //             ),
                    //           )
                    //         ],
                    //       ),
                    //     ),
                    //     const SizedBox(height: 10),
                    //   ],
                    // ),
                    // ButtonGlobalWithoutIcon(
                    //   buttontext: 'Save and Publish',
                    //   buttonDecoration: kButtonDecoration.copyWith(color: kMainColor, borderRadius: const BorderRadius.all(Radius.circular(30))),
                    //   onPressed: () async {
                    //     if (validateAndSave()) {
                    //       try {
                    //         EasyLoading.show(status: 'Loading...', dismissOnTap: false);
                    //
                    //         imagePath == 'No Data' ? null : await uploadFile(imagePath);
                    //         // ignore: no_leading_underscores_for_local_identifiers
                    //         final DatabaseReference _productInformationRef = FirebaseDatabase.instance
                    //             // ignore: deprecated_member_use
                    //             .reference()
                    //             .child(FirebaseAuth.instance.currentUser!.uid)
                    //             .child('Products');
                    //         ProductModel productModel = ProductModel(
                    //           productName,
                    //           productCategory,
                    //           size,
                    //           color,
                    //           weight,
                    //           capacity,
                    //           type,
                    //           brandName,
                    //           productCode,
                    //           productStock,
                    //           productUnit,
                    //           productSalePrice,
                    //           productPurchasePrice,
                    //           productDiscount,
                    //           productWholeSalePrice,
                    //           productDealerPrice,
                    //           productManufacturer,
                    //           productPicture,
                    //         );
                    //         await _productInformationRef.push().set(productModel.toJson());
                    //         Subscription.decreaseSubscriptionLimits(itemType: 'products', context: context);
                    //         EasyLoading.showSuccess('Added Successfully', duration: const Duration(milliseconds: 500));
                    //         ref.refresh(productProvider);
                    //         Future.delayed(const Duration(milliseconds: 100), () {
                    //           const Home().launch(context, isNewTask: true);
                    //         });
                    //       } catch (e) {
                    //         EasyLoading.dismiss();
                    //         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                    //       }
                    //     }
                    //   },
                    //   buttonTextColor: Colors.white,
                    // ),
                    // const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
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
