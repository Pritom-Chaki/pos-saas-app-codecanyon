import 'package:bluetooth_thermal_printer/bluetooth_thermal_printer.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_pos/model/product_model.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:image/image.dart' as IMG;
import 'package:http/http.dart' as http;

import '../WAVE PRINTER/wave_printer_functions.dart';
import '../constant.dart';
import '../model/print_transaction_model.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart';

final printerPurchaseProviderNotifier = ChangeNotifierProvider((ref) => PrinterPurchase());

class PrinterPurchase extends ChangeNotifier {
  List availableBluetoothDevices = [];
  Future<void> getBluetooth() async {
    final List? bluetooths = await BluetoothThermalPrinter.getBluetooths;
    availableBluetoothDevices = bluetooths!;
    notifyListeners();
  }

  Future<bool> setConnect(String mac) async {
    bool status = false;
    final String? result = await BluetoothThermalPrinter.connect(mac);
    if (result == "true") {
      connected = true;
      status = true;
    }
    notifyListeners();
    return status;
  }

  Future<bool> printTicket({required PrintPurchaseTransactionModel printTransactionModel, required List<ProductModel>? productList, required bool printer58}) async {
    bool isPrinted = false;
    String? isConnected = await BluetoothThermalPrinter.connectionStatus;
    if (isConnected == "true") {
      List<int> bytes = await getTicket(printTransactionModel: printTransactionModel, productList: productList);
      if (productList!.isNotEmpty) {
        await BluetoothThermalPrinter.writeBytes(bytes);
      } else {
        toast('No Product Found');
      }

      isPrinted = true;
    } else {
      isPrinted = false;
    }
    notifyListeners();
    return isPrinted;
  }

  Future<List<int>> getTicket({required PrintPurchaseTransactionModel printTransactionModel, required List<ProductModel>? productList}) async {
    List<int> bytes = [];
    http.Response response = await http.get(
      Uri.parse(printTransactionModel.personalInformationModel.pictureUrl ?? ''),
    );
    response.bodyBytes;
    final decodedImage = IMG.decodeImage(response.bodyBytes);
    final resizedImage = IMG.copyResize(decodedImage!, width: 120, height: 120); //Uint8List
    final encodedImage = IMG.encodeJpg(resizedImage);
    Uint8List byteList = Uint8List.fromList(encodedImage);

    CapabilityProfile profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm58, profile);
    final Uint8List imageBytes = byteList;
    bytes += generator.image(decodeImage(imageBytes)!);
    bytes += generator.text(printTransactionModel.personalInformationModel.companyName ?? '',
        styles: const PosStyles(
          align: PosAlign.center,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ),
        linesAfter: 1);

    bytes += generator.text(printTransactionModel.personalInformationModel.countryName ?? '', styles: const PosStyles(align: PosAlign.center));
    bytes += generator.text('Tel: ${printTransactionModel.personalInformationModel.phoneNumber ?? ''}',
        styles: const PosStyles(align: PosAlign.center), linesAfter: printTransactionModel.personalInformationModel.gst.trim().isNotEmpty ? 0 : 1);
    printTransactionModel.personalInformationModel.gst.trim().isNotEmpty
        ? bytes += generator.text('Shop GST: ${printTransactionModel.personalInformationModel.gst ?? ''}', styles: const PosStyles(align: PosAlign.center), linesAfter: 1)
        : null;
    bytes += generator.text('Name: ${printTransactionModel.purchaseTransitionModel?.customerName ?? 'Guest'}', styles: const PosStyles(align: PosAlign.left));
    (printTransactionModel.purchaseTransitionModel?.customerGst.trim().isNotEmpty ?? false)
        ? bytes += generator.text('Party GST: ${printTransactionModel.purchaseTransitionModel?.customerGst ?? 'Not Provided'}', styles: const PosStyles(align: PosAlign.left))
        : null;
    bytes += generator.text('mobile: ${printTransactionModel.purchaseTransitionModel?.customerPhone ?? 'Not Provided'}', styles: const PosStyles(align: PosAlign.left), linesAfter: 1);
    bytes += generator.hr();
    bytes += generator.text('Items        Rate   Qty    Total', styles: const PosStyles(bold: true));
    // bytes += generator.row([
    //   PosColumn(text: 'Item', width: 5, styles: const PosStyles(align: PosAlign.left, bold: true)),
    //   PosColumn(text: 'Price', width: 2, styles: const PosStyles(align: PosAlign.center, bold: true)),
    //   PosColumn(text: 'Qty', width: 2, styles: const PosStyles(align: PosAlign.center, bold: true)),
    //   PosColumn(text: 'Total', width: 3, styles: const PosStyles(align: PosAlign.right, bold: true)),
    // ]);
    bytes += generator.hr();
    bytes += await productTable(productList:[],purchaseProduct: printTransactionModel.purchaseTransitionModel?.productList??[], isFour: false);
    // List.generate(productList?.length ?? 1, (index) {
    //   return bytes += generator.row([
    //     PosColumn(text: productList?[index].productName ?? 'Not Defined', width: 5, styles: const PosStyles(align: PosAlign.left)),
    //     PosColumn(
    //         text: productList?[index].productPurchasePrice ?? 'Not Defined',
    //         width: 2,
    //         styles: const PosStyles(
    //           align: PosAlign.center,
    //         )),
    //     PosColumn(text: productList?[index].productStock.toString() ?? 'Not Defined', width: 2, styles: const PosStyles(align: PosAlign.center)),
    //     PosColumn(text: "${double.parse(productList?[index].productPurchasePrice ?? '') * productList![index].productStock.toInt()}", width: 3, styles: const PosStyles(align: PosAlign.right)),
    //   ]);
    // });

    // bytes += generator.row([
    //   PosColumn(
    //       text: "Sada Dosa",
    //       width: 5,
    //       styles: PosStyles(
    //         align: PosAlign.left,
    //       )),
    //   PosColumn(
    //       text: "30",
    //       width: 2,
    //       styles: PosStyles(
    //         align: PosAlign.center,
    //       )),
    //   PosColumn(text: "1", width: 2, styles: PosStyles(align: PosAlign.center)),
    //   PosColumn(text: "30", width: 3, styles: PosStyles(align: PosAlign.right)),
    // ]);
    //
    // bytes += generator.row([
    //   PosColumn(
    //       text: "Masala Dosa",
    //       width: 5,
    //       styles: PosStyles(
    //         align: PosAlign.left,
    //       )),
    //   PosColumn(
    //       text: "50",
    //       width: 2,
    //       styles: PosStyles(
    //         align: PosAlign.center,
    //       )),
    //   PosColumn(text: "1", width: 2, styles: PosStyles(align: PosAlign.center)),
    //   PosColumn(text: "50", width: 3, styles: PosStyles(align: PosAlign.right)),
    // ]);
    //
    // bytes += generator.row([
    //   PosColumn(
    //       text: "Rova Dosa",
    //       width: 5,
    //       styles: PosStyles(
    //         align: PosAlign.left,
    //       )),
    //   PosColumn(
    //       text: "70",
    //       width: 2,
    //       styles: PosStyles(
    //         align: PosAlign.center,
    //       )),
    //   PosColumn(text: "1", width: 2, styles: PosStyles(align: PosAlign.center)),
    //   PosColumn(text: "70", width: 3, styles: PosStyles(align: PosAlign.right)),
    // ]);
    bytes += generator.hr();
    bytes += generator.row([
      PosColumn(
          text: 'Subtotal',
          width: 8,
          styles: const PosStyles(
            align: PosAlign.left,
          )),
      PosColumn(
          text: '${printTransactionModel.purchaseTransitionModel!.totalAmount!.toDouble() + printTransactionModel.purchaseTransitionModel!.discountAmount!.toDouble()}',
          width: 4,
          styles: const PosStyles(
            align: PosAlign.right,
          )),
    ]);
    bytes += generator.row([
      PosColumn(
          text: 'Discount',
          width: 8,
          styles: const PosStyles(
            align: PosAlign.left,
          )),
      PosColumn(
          text: printTransactionModel.purchaseTransitionModel?.discountAmount.toString() ?? '',
          width: 4,
          styles: const PosStyles(
            align: PosAlign.right,
          )),
    ]);
    bytes += generator.hr();
    bytes += generator.row([
      PosColumn(text: 'TOTAL', width: 8, styles: const PosStyles(align: PosAlign.left, bold: true)),
      PosColumn(text: printTransactionModel.purchaseTransitionModel?.totalAmount.toString() ?? '', width: 4, styles: const PosStyles(align: PosAlign.right, bold: true)),
    ]);

    // bytes += generator.hr(ch: '=', linesAfter: 1);
    // bytes += generator.hr();

    bytes += generator.row([
      PosColumn(
          text: 'Payment Type:',
          width: 8,
          styles: const PosStyles(
            align: PosAlign.left,
          )),
      PosColumn(
          text: printTransactionModel.purchaseTransitionModel?.paymentType ?? 'Cash',
          width: 4,
          styles: const PosStyles(
            align: PosAlign.right,
          )),
    ]);
    bytes += generator.row([
      PosColumn(
          text: 'Payment Amount:',
          width: 8,
          styles: const PosStyles(
            align: PosAlign.left,
          )),
      PosColumn(
          text: '${printTransactionModel.purchaseTransitionModel!.totalAmount!.toDouble() - printTransactionModel.purchaseTransitionModel!.dueAmount!.toDouble()}',
          width: 4,
          styles: const PosStyles(
            align: PosAlign.right,
          )),
    ]);
    bytes += generator.row([
      PosColumn(
          text: 'Return amount:',
          width: 8,
          styles: const PosStyles(
            align: PosAlign.left,
          )),
      PosColumn(
          text: printTransactionModel.purchaseTransitionModel!.returnAmount.toString(),
          width: 4,
          styles: const PosStyles(
            align: PosAlign.right,
          )),
    ]);
    bytes += generator.row([
      PosColumn(
          text: 'Due Amount:',
          width: 8,
          styles: const PosStyles(
            align: PosAlign.left,
          )),
      PosColumn(
          text: printTransactionModel.purchaseTransitionModel!.dueAmount.toString(),
          width: 4,
          styles: const PosStyles(
            align: PosAlign.right,
          )),
    ]);
    bytes += generator.hr(ch: '=', linesAfter: 1);

    // ticket.feed(2);
    bytes += generator.text('Thank you!', styles: const PosStyles(align: PosAlign.center, bold: true));

    bytes += generator.text(printTransactionModel.purchaseTransitionModel!.purchaseDate, styles: const PosStyles(align: PosAlign.center), linesAfter: 1);

    bytes += generator.text('Note: Goods once sold will not be taken back or exchanged.', styles: const PosStyles(align: PosAlign.center, bold: false), linesAfter: 1);

    // bytes += generator.qrcode('https://posbharat.com', size: QRSize.Size4);
    bytes += generator.text('Developed By: $invoiceName', styles: const PosStyles(align: PosAlign.center), linesAfter: 1);
    bytes += generator.cut();
    return bytes;
  }
}
