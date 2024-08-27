import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:mobile_pos/model/product_model.dart';

import '../constant.dart';
import '../model/add_to_cart_model.dart';

Future<List<int>> productTable(bool printer58,
    {required List<AddToCartModel> productList,
    required List<ProductModel>? purchaseProduct,
    required bool isFour}) async {
  List<int> data = [];
  if (purchaseProduct != null) {
    for (var element in purchaseProduct) {
      data += await tableItem(
        printer58,
        items: [
          element.productName ?? '',
          (double.tryParse(element.productPurchasePrice) ?? 0)
              .round()
              .toString(),
          element.productStock,
          "${(double.tryParse(element.productPurchasePrice) ?? 0) * (double.tryParse(element.productStock) ?? 0)}",
        ],
        isFour: true,
      );
    }
  } else {
    for (var element in productList) {
      data += isFour
          ? await tableItem(
              printer58,
              items: [
                element.productName ?? '',
                (double.tryParse(element.subTotal.toString()) ?? 0)
                    .toStringAsFixed(0),
                element.quantity.toString(),
                "${double.parse(element.subTotal.toString()) * int.parse(element.quantity.toString())}",
              ],
              isFour: true,
            )
          : await tableItem(
              printer58,
              items: [
                element.productName ?? '',
                (double.tryParse(element.subTotal) ?? 0).round().toString(),
                element.quantity.toString(),
                calculateProductVat(product: element),
                "${double.parse(element.subTotal) * element.quantity.toInt()}",
              ],
              isFour: false,
            );
    }
  }

  return data;
}

Future<List<int>> productTable2(Generator generator,
    {required List<AddToCartModel> productList,
    required List<ProductModel>? purchaseProduct,
    required bool isFour}) async {
  List<int> data = [];
  if (purchaseProduct != null) {
    for (var element in purchaseProduct) {
      data += generator.row([
        PosColumn(
            text: element.productName ?? '',
            width: 4,
            styles: const PosStyles(align: PosAlign.left, bold: true)),
        PosColumn(
            text: (double.tryParse(element.productPurchasePrice) ?? 0)
                .round()
                .toString(),
            width: 2,
            styles: const PosStyles(align: PosAlign.right, bold: true)),
        PosColumn(
            text: element.productStock,
            width: 2,
            styles: const PosStyles(align: PosAlign.right, bold: true)),
        PosColumn(
            text:
                "${(double.tryParse(element.productPurchasePrice) ?? 0) * (double.tryParse(element.productStock) ?? 0)}",
            width: 4,
            styles: const PosStyles(align: PosAlign.right, bold: true)),
      ]);
    }
  } else {
    for (var element in productList) {
      data += isFour
          ? generator.row([
              PosColumn(
                  text: element.productName ?? '',
                  width: 4,
                  styles: const PosStyles(align: PosAlign.left, bold: true)),
              PosColumn(
                  text: (double.tryParse(element.subTotal.toString()) ?? 0)
                      .toStringAsFixed(0),
                  width: 2,
                  styles: const PosStyles(align: PosAlign.right, bold: true)),
              PosColumn(
                  text: element.quantity.toString(),
                  width: 2,
                  styles: const PosStyles(align: PosAlign.right, bold: true)),
              PosColumn(
                  text:
                      "${double.parse(element.subTotal.toString()) * int.parse(element.quantity.toString())}",
                  width: 4,
                  styles: const PosStyles(align: PosAlign.right, bold: true)),
            ])
          : generator.row([
              PosColumn(
                  text: element.productName ?? '',
                  width: 3,
                  styles: const PosStyles(align: PosAlign.left, bold: true)),
              PosColumn(
                  text: (double.tryParse(element.subTotal.toString()) ?? 0)
                      .toStringAsFixed(0),
                  width: 2,
                  styles: const PosStyles(align: PosAlign.right, bold: true)),
              PosColumn(
                  text: element.quantity.toString(),
                  width: 2,
                  styles: const PosStyles(align: PosAlign.right, bold: true)),
              PosColumn(
                  text: calculateProductVat(product: element),
                  width: 2,
                  styles: const PosStyles(align: PosAlign.right, bold: true)),
              PosColumn(
                  text:
                      "${double.parse(element.subTotal.toString()) * int.parse(element.quantity.toString())}",
                  width: 3,
                  styles: const PosStyles(align: PosAlign.right, bold: true)),
            ]);
    }
  }

  return data;
}

List<String> largeTextSplit({required String text, required int letterCount}) {
  List<String> lines = [];

  int textLength = text.length;
  int numLines = (textLength / letterCount).ceil();

  for (int i = 0; i < numLines; i++) {
    int start = i * letterCount;
    int end = (i + 1) * letterCount;
    if (end > textLength) {
      end = textLength;
    }
    lines.add(text.substring(start, end));
  }

  print(lines);

  return lines;
}

Future<List<int>> tableItem(bool printer58,
    {required List<String> items, required bool isFour}) async {
  CapabilityProfile profile = await CapabilityProfile.load();
  final generator = Generator(PaperSize.mm58, profile);
  List<int> data = [];
  List<String> lines = largeTextSplit(text: items.first, letterCount: 10);

  for (var eachLine in lines) {
    if (printer58) {
      if (eachLine == lines.first) {
        items[0] = eachLine;
        data += isFour
            ? generator.text(
                generateLine(items: items, spacing: [12, 6, 5, 6]),
              )
            : generator
                .text(generateLine(items: items, spacing: [10, 5, 4, 4, 5]));
      } else {
        data += isFour
            ? generator
                .text(generateLine(items: [eachLine], spacing: [12, 6, 5, 6]))
            : generator.text(
                generateLine(items: [eachLine], spacing: [10, 5, 4, 4, 5]));
      }
    } else {
      if (eachLine == lines.first) {
        items[0] = eachLine;
        data += isFour
            ? generator.text(
                generateLine(items: items, spacing: [16, 9, 7, 9]),
              )
            : generator
                .text(generateLine(items: items, spacing: [15, 7, 6, 6, 7]));
      } else {
        data += isFour
            ? generator
                .text(generateLine(items: [eachLine], spacing: [16, 9, 7, 9]))
            : generator.text(
                generateLine(items: [eachLine], spacing: [15, 7, 6, 6, 7]));
      }
    }
  }
  return data;
}

String generateLine({required List<String> items, required List<int> spacing}) {
  if (items.length == 1) {
    return addSpace(text: items.first, count: 32);
  } else {
    return spacing.length == 4
        ? '${addSpace(text: items[0], count: spacing[0])} ${addSpace(text: items[1], count: spacing[1])} ${addSpace(text: items[2], count: spacing[2])} ${addSpace(text: items[3], count: spacing[3])}'
        : '${addSpace(text: items[0], count: spacing[0])} ${addSpace(text: items[1], count: spacing[1])} ${addSpace(text: items[2], count: spacing[2])} ${addSpace(text: items[3], count: spacing[3])} ${addSpace(text: items[4], count: spacing[4])}';
  }
}

String addSpace({required String text, required int count}) {
  final trimmedText = text.trim();
  final neededSpaces = count - trimmedText.length;
  if (neededSpaces.isNegative) {
    return text.substring(0, (trimmedText.length - (neededSpaces.abs())));
  }
  return '$trimmedText${' ' * neededSpaces}';
}
