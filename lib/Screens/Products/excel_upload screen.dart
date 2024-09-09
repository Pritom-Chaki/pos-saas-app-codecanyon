import 'dart:io';
import 'package:excel/excel.dart' as e;
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_pos/Provider/category,brans,units_provide.dart';
import 'package:mobile_pos/Provider/product_provider.dart';
import 'package:mobile_pos/constant.dart';
import 'package:mobile_pos/model/product_model.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xls;

import '../../GlobalComponents/Model/category_model.dart';
import '../../currency.dart';
import '../../subscription.dart';

class ExcelUploader extends StatefulWidget {
  const ExcelUploader({super.key, required this.previousProductName, required this.previousProductCode});

  final List<String> previousProductName;
  final List<String> previousProductCode;

  @override
  State<ExcelUploader> createState() => _ExcelUploaderState();
}

class _ExcelUploaderState extends State<ExcelUploader> {
  List<String> allCategory = [];
  List<String> allNameInThisFile = [];
  List<String> allCodeInThisFile = [];
  // List<String> allBrand = [];
  // List<String> allUnit = [];
  String? filePat;
  File? file;
  String getFileExtension(String fileName) {
    return fileName.split('/').last;
  }

  Future<bool> requestStoragePermission() async {
    var status = await Permission.storage.status;
    if (status.isGranted) {
      return true;
    }

    // Request permission if not granted
    var requestResult = await Permission.storage.request();
    if (requestResult == PermissionStatus.granted) {
      return true;
    }

    return false;
  }

  Future<void> createExcelFile() async {
    if (!await requestStoragePermission()) {
      EasyLoading.showError('Storage permission is required to create Excel file!');
      return;
    }
    EasyLoading.show();
    final List<e.CellValue> excelData = [
       e.TextCellValue('SL'),
       e.TextCellValue('Product Name*'),
       e.TextCellValue('Product Code*'),
       e.TextCellValue('Product Stock*'),
       e.TextCellValue('Purchase Price*'),
       e.TextCellValue('Sale Price*'),
       e.TextCellValue('Wholesale Price'),
       e.TextCellValue('Dealer Price'),
       e.TextCellValue('Category*'),
       e.TextCellValue('Brand'),
       e.TextCellValue('Units'),
       e.TextCellValue('Manufacturer'),
       e.TextCellValue('Manufacture Date (ex: Month/Day/Year)'),
       e.TextCellValue('Expire Data (ex: Month/Day/Year)'),
       e.TextCellValue('Low Stock Alert'),
       e.TextCellValue('Serial Numbers (ex. TFD3763, 34384SJHG)'),
    ];
    e.CellStyle cellStyle = e.CellStyle(
      bold: true,
      textWrapping: e.TextWrapping.WrapText,
      rotation: 0,
    );
    var excel = e.Excel.createExcel();
    var sheet = excel['Sheet1'];

    sheet.appendRow(excelData);

    for (int i = 0; i < excelData.length; i++) {
      var cell = sheet.cell(e.CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
      cell.cellStyle = cellStyle;
    }
    const downloadsFolderPath = '/storage/emulated/0/Download/';
    Directory dir = Directory(downloadsFolderPath);
    final file = File('${dir.path}/${invoiceName}_bulk_product_upload.xlsx');
    if (await file.exists()) {
      EasyLoading.showSuccess('The Excel file has already been downloaded');
    } else {
      await file.writeAsBytes(excel.encode()!);

      EasyLoading.showSuccess('Downloaded successfully in download folder');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Excel Uploader'),
      ),
      body: Consumer(builder: (context, ref, __) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Visibility(
                  visible: file != null,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Card(
                        child: ListTile(
                            leading: Container(
                                height: 40,
                                width: 40,
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                                ),
                                child: const Image(image: AssetImage('images/excel.png'))),
                            title: Text(
                              getFileExtension(file?.path ?? ''),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    file = null;
                                  });
                                },
                                child: const Text('Remove')))),
                  ),
                ),
                Visibility(
                  visible: file == null,
                  child: const Padding(
                      padding: EdgeInsets.only(bottom: 20),
                      child: Image(
                        height: 100,
                        width: 100,
                        image: AssetImage('images/file-upload.png'),
                      )),
                ),
                ElevatedButton(
                  style: const ButtonStyle(backgroundColor: MaterialStatePropertyAll(kMainColor)),
                  onPressed: () async {
                    if (file == null) {
                      await pickAndUploadFile(ref: ref);
                    } else {
                      EasyLoading.show(status: 'Uploading...');
                      await uploadProducts(ref: ref, file: file!, context: context);
                      EasyLoading.dismiss();
                    }
                  },
                  child: Text(file == null ? 'Pick and Upload File' : 'Upload', style: const TextStyle(color: Colors.white)),
                ),
                TextButton(
                  // onPressed: () async => await downloadFile('excel_file.xlsx'),
                  onPressed: () async {
                    await createExcelFile();
                  },
                  child: const Text('Download Excel Format'),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Future<void> pickAndUploadFile({required WidgetRef ref}) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );
    if (result != null) {
      setState(() {
        file = File(result.files.single.path!);
      });
    }
  }
  // Future<void> uploadProductsNew({
  //   required File file,
  //   required WidgetRef ref,
  //   required BuildContext context,
  // }) async {
  //   try {
  //     // Read Excel data
  //     final workbook = await xls.Workbook();
  //     workbook.
  //     final worksheet = workbook.worksheets[0];
  //
  //     for (int rowIndex = 1; rowIndex <= worksheet.rowCount; rowIndex++) {
  //       final row = worksheet.rows[rowIndex];
  //
  //       // Create ProductModel object using the updated function
  //       final productModel = await createProductModelFromExcelData(row: row, ref: ref);
  //
  //       if (productModel != null) {
  //         final productInformationRef = FirebaseDatabase.instance.ref().child(constUserId).child('Products');
  //         productInformationRef.keepSynced(true);
  //         productInformationRef.push().set(productModel.toJson());
  //         Subscription.decreaseSubscriptionLimits(itemType: 'products', context: null);
  //       }
  //     }
  //
  //     ref.refresh(productProvider);
  //     ref.refresh(categoryProvider);
  //
  //     Future.delayed(const Duration(seconds: 1), () {
  //       EasyLoading.showSuccess('Upload Done');
  //       int count = 0;
  //       Navigator.popUntil(context, (route) {
  //         return count++ == 2;
  //       });
  //     });
  //   }  catch (e) {
  //     EasyLoading.showError(e.toString());
  //   }}

  Future<void> uploadProducts({
    required File file,
    required WidgetRef ref,
    required BuildContext context,
  }) async {
    // print(file.readAsBytesSync());
    try {
      // List<int> data =   file.readAsBytesSync();
      // print(data);
      e.Excel excel = e.Excel.decodeBytes(file.readAsBytesSync());
      var sheet = excel.sheets.keys.first;
      var table = excel.tables[sheet]!;
      for (var row in table.rows) {
        ProductModel? data = createProductModelFromExcelData(row: row, ref: ref);

        if (data != null) {
          final DatabaseReference productInformationRef = FirebaseDatabase.instance.ref().child(constUserId).child('Products');
          productInformationRef.keepSynced(true);
          productInformationRef.push().set(data.toJson());
          Subscription.decreaseSubscriptionLimits(itemType: 'products', context: null);
        }
      }
      ref.refresh(productProvider);
      ref.refresh(categoryProvider);

      Future.delayed(const Duration(seconds: 1), () {
        EasyLoading.showSuccess('Upload Done');
        int count = 0;
        Navigator.popUntil(context, (route) {
          return count++ == 2;
        });
      });
    } catch (e) {
      EasyLoading.showError(e.toString());
      return;
      throw UnsupportedError('Excel format unsupported. Only .xlsx files are supported');
    }
// e.Excel excel= e.Excel.createExcel();
  }

  ProductModel? createProductModelFromExcelData({required List<e.Data?> row, required WidgetRef ref}) {
    bool isProductNameUnique({required String? productName}) {
      for (var name in widget.previousProductName) {
        if (name.toLowerCase().trim() == productName?.trim().toLowerCase()) {
          return false;
        }
      }
      for (var element in allNameInThisFile) {
        if (element.toLowerCase().trim() == productName?.trim().toLowerCase()) {
          return false;
        }
      }

      productName != null ? allNameInThisFile.add(productName) : null;

      return true;
    }

    bool isProductCodeUnique({required String? productCode}) {
      for (var name in widget.previousProductCode) {
        if (name.toLowerCase().trim() == productCode?.trim().toLowerCase()) {
          return false;
        }
      }
      for (var element in allCodeInThisFile) {
        if (element.toLowerCase().trim() == productCode?.trim().toLowerCase()) {
          return false;
        }
      }

      productCode != null ? allCodeInThisFile.add(productCode) : null;

      return true;
    }

    String getCategoryFromDatabase({required WidgetRef ref, required String givenCategoryName}) {
      final categoryData = ref.watch(categoryProvider);
      categoryData.when(
        data: (categories) {
          bool pos = true;
          for (var element in categories) {
            if (element.categoryName.toLowerCase().trim() == givenCategoryName.toLowerCase().trim()) {
              pos = false;
              break;
            }
          }
          for (var element in allCategory) {
            if (element.toLowerCase().trim() == givenCategoryName.toLowerCase().trim()) {
              pos = false;
              break;
            }
          }
          pos ? addCategory(categoryName: givenCategoryName) : null;
          allCategory.add(givenCategoryName.trim().toLowerCase());

          return givenCategoryName;
        },
        error: (error, stackTrace) {},
        loading: () {},
      );
      return givenCategoryName;
    }

    List<String> getSerialNumbers(String? serialNumberString) {
      List<String> data = serialNumberString?.split(",") ?? [];
      List<String> data2 = [];
      for (var element in data) {
        data2.add(element.removeAllWhiteSpace().trim());
      }
      return data2;
    }

    ProductModel productModel = ProductModel(
      productName: '',
      productDescription: '',
      productCategory: '',
      size: '',
      color: '',
      weight: '',
      capacity: '',
      type: '',
      brandName: '',
      productCode: '',
      productStock: '',
      productUnit: '',
      productSalePrice: '',
      productPurchasePrice: '',
      productDiscount: '',
      productWholeSalePrice: '',
      productDealerPrice: '',
      productManufacturer: '',
      warehouseName: '',
      warehouseId: '',
      productPicture: 'https://firebasestorage.googleapis.com/v0/b/maanpos.appspot.com/o/Customer%20Picture%2FNo_Image_Available.jpeg?alt=media&token=3de0d45e-0e4a-4a7b-b115-9d6722d5031f',
      serialNumber: [],
      lowerStockAlert: 0,
      taxType: '',
      margin: 0,
      excTax: 0,
      incTax: 0,
      groupTaxName: '',
      groupTaxRate: 0,
      subTaxes: [],
    );
    for (var element in row) {
      if (element?.rowIndex == 0) {
        return null;
      }
      switch (element?.columnIndex) {
        case 1:
          if (element?.value == null || !isProductNameUnique(productName: element?.value.toString())) return null;
          productModel.productName = element?.value.toString() ?? '';
          break;
        case 2:
          if (element?.value == null || !isProductCodeUnique(productCode: element?.value.toString())) return null;
          productModel.productCode = element?.value.toString() ?? '';
          break;
        case 3:
          if (element?.value == null && num.tryParse(element?.value.toString() ?? '') != null) return null;
          productModel.productStock = element?.value.toString() ?? '';
          break;
        case 5:
          if (element?.value == null && num.tryParse(element?.value.toString() ?? '') != null) return null;
          productModel.productSalePrice = element?.value.toString() ?? '';
          break;
        case 4:
          if (element?.value == null && num.tryParse(element?.value.toString() ?? '') != null) return null;
          productModel.productPurchasePrice = element?.value.toString() ?? '';
          break;
        case 6:
          element?.value != null ? productModel.productWholeSalePrice = element!.value.toString() : null;
          break;
        case 7:
          element?.value != null ? productModel.productDealerPrice = element!.value.toString() : null;
          break;
        case 8:
          if (element?.value == null) return null;
          productModel.productCategory = getCategoryFromDatabase(ref: ref, givenCategoryName: element!.value.toString());
          break;
        case 9:
          // productModel.brandName = getBrandsFromDatabase(ref: ref, givenBrandName: element?.value.toString()) ?? '';
          element?.value != null ? productModel.brandName = element!.value.toString() : null;
          break;
        case 10:
          // productModel.productUnit = getUnitFromDatabase(ref: ref, givenUnitName: element?.value.toString()) ?? '';
          element?.value != null ? productModel.productUnit = element!.value.toString() : null;
          break;
        case 11:
          element?.value != null ? productModel.productManufacturer = element!.value.toString() : null;
          break;
        case 12:
          element?.value != null ? productModel.manufacturingDate = element?.value.toString() : null;
          break;
        case 13:
          element?.value != null ? productModel.expiringDate = element?.value.toString() : null;
          break;
        case 14:
          productModel.lowerStockAlert = int.tryParse(element?.value.toString() ?? '') ?? 0;
          break;
        case 15:
          element?.value != null ? productModel.serialNumber = getSerialNumbers(element?.value.toString()) : null;
          break;
      }
    }
    return productModel;
  }

  void addCategory({required String categoryName}) {
    final DatabaseReference categoryInformationRef = FirebaseDatabase.instance.ref().child(constUserId).child('Categories');
    categoryInformationRef.keepSynced(true);
    CategoryModel categoryModel = CategoryModel(
      categoryName: categoryName,
      size: false,
      color: false,
      capacity: false,
      type: false,
      weight: false,
      warranty: false,
    );
    categoryInformationRef.push().set(categoryModel.toJson());
  }
}
