import 'dart:async';
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../../../../const_commas.dart';
import '../../../../constant.dart';
import '../../../../model/personal_information_model.dart';
import '../../../../model/transition_model.dart';
import 'loss_profit_report.dart';
import 'package:flutter/material.dart';

Future<File> createAndSaveLossProfitPDF({
  required PersonalInformationModel personalInformationModel,
  required List<SalesTransitionModel> transactions,
  required String fromDate,
  required String toDate,
  required String saleAmount,
  required String profit,
  required String loss,
  BuildContext? context,
}) async {

  final pdf = pw.Document();
  // final pw.Document doc = pw.Document();
  double totalAmount({required SalesTransitionModel transactions}) {
    double amount = 0;

    for (var element in transactions.productList!) {
      amount = amount + double.parse(element.subTotal) * double.parse(element.quantity.toString());
    }

    return double.parse(amount.toStringAsFixed(2));
  }

  pdf.addPage(
    pw.MultiPage(
      // pageFormat: PdfPageFormat.letter.copyWith(marginBottom: 1.5 * PdfPageFormat.cm),
      margin: const pw.EdgeInsets.all(14.0),
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      header: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            ///________Company_Name_________________________________________________________
            pw.Center(
              child: pw.Text(
                personalInformationModel.companyName.toString(),
                style: pw.Theme.of(context).defaultTextStyle.copyWith(color: PdfColors.black, fontSize: 25.0, fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.Center(
              child: pw.Text(
                'Address: ${personalInformationModel.companyName}, Ph.no:${personalInformationModel.phoneNumber}',
                style: pw.Theme.of(context).defaultTextStyle.copyWith(color: PdfColors.black, fontSize: 11.0),
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Center(
              child: pw.Container(
                  padding: const pw.EdgeInsets.only(bottom: 2.0),
                  decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.black))),
                  child: pw.Text(
                    'Loss/Profit Report',
                    style: pw.Theme.of(context).defaultTextStyle.copyWith(color: PdfColors.black, fontSize: 16.0, fontWeight: pw.FontWeight.bold),
                  )),
            ),
            pw.SizedBox(height: 10),
            pw.Center(
                child: pw.Text(
              'Duration: From ${DateFormat.yMd().format(DateTime.parse(fromDate))} to ${DateFormat.yMd().format(DateTime.parse(toDate))}',
              style: pw.Theme.of(context).defaultTextStyle.copyWith(color: PdfColors.black, fontSize: 11.0),
            ))
          ],
        );
      },
      footer: (pw.Context context) {
        return pw.Column(children: [
          pw.Divider(color: PdfColors.grey600),
          pw.Center(child: pw.Text('Powered By $appName', style: const pw.TextStyle(fontSize: 10, color: PdfColors.black))),
        ]);
      },
      build: (pw.Context context) => <pw.Widget>[
        pw.Column(
          children: [
            pw.SizedBox(height: 20),

            ///___________Table__________________________________________________________
            pw.Table.fromTextArray(
              headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
              context: context,
              border: const pw.TableBorder(
                left: pw.BorderSide(
                  color: PdfColors.grey600,
                ),
                right: pw.BorderSide(
                  color: PdfColors.grey600,
                ),
                bottom: pw.BorderSide(
                  color: PdfColors.grey600,
                ),
                top: pw.BorderSide(
                  color: PdfColors.grey600,
                ),
                verticalInside: pw.BorderSide(
                  color: PdfColors.grey600,
                ),
                horizontalInside: pw.BorderSide(
                  color: PdfColors.grey600,
                ),
              ),
              // headerDecoration: pw.BoxDecoration(color: PdfColor.fromHex('#D5D8DC')),
              columnWidths: <int, pw.TableColumnWidth>{
                0: const pw.FlexColumnWidth(1),
                1: const pw.FlexColumnWidth(1.5),
                2: const pw.FlexColumnWidth(1.5),
                3: const pw.FlexColumnWidth(5.0),
                4: const pw.FlexColumnWidth(2.0),
                5: const pw.FlexColumnWidth(1.7),
                6: const pw.FlexColumnWidth(1.7),
              },
              headerStyle: pw.TextStyle(color: PdfColors.black, fontSize: 11, fontWeight: pw.FontWeight.bold),
              rowDecoration: const pw.BoxDecoration(color: PdfColors.white),
              // oddRowDecoration: const pw.BoxDecoration(color: PdfColors.grey100),
              headerAlignments: <int, pw.Alignment>{
                0: pw.Alignment.center,
                1: pw.Alignment.centerLeft,
                2: pw.Alignment.center,
                3: pw.Alignment.centerLeft,
                4: pw.Alignment.center,
                5: pw.Alignment.center,
                6: pw.Alignment.center,
              },
              cellAlignments: <int, pw.Alignment>{
                0: pw.Alignment.center,
                1: pw.Alignment.centerLeft,
                2: pw.Alignment.center,
                3: pw.Alignment.centerLeft,
                4: pw.Alignment.center,
                5: pw.Alignment.center,
                6: pw.Alignment.center,
              },
              data: <List<String>>[
                <String>['SL', 'Date', 'Invoice', 'Party Name', 'Sale Amount', 'Profit', 'Loss'],
                for (int i = 0; i < transactions.length; i++)
                  <String>[
                    ('${i + 1}'),
                    (DateFormat.yMd().format(DateTime.parse(transactions.elementAt(i).purchaseDate))),
                    (transactions.elementAt(i).invoiceNumber),
                    (transactions.elementAt(i).customerName),
                    (myFormat.format(double.tryParse(transactions.elementAt(i).totalAmount.toString()) ?? 0)),
                    (myFormat.format(
                        double.tryParse(transactions.elementAt(i).lossProfit!.isNegative ? ' 0' : transactions.elementAt(i).lossProfit!.toStringAsFixed(2)) ??
                            0)),
                    (myFormat.format(
                        double.tryParse(transactions.elementAt(i).lossProfit!.isNegative ? transactions.elementAt(i).lossProfit!.toStringAsFixed(2) : ' 0') ??
                            0)),
                  ],
                <String>['', '', '', 'Sub Total:', (saleAmount.toString()), (profit.toString()), (loss.toString())],
              ],
            ),
          ],
        ),
      ],
    ),
  );

  final output = await getTemporaryDirectory();
  final file = File('${output.path}/Loss_Profit_.pdf');
  await file.writeAsBytes(await pdf.save());

  return file;
}

void shareLossProfitPDF({
  required PersonalInformationModel personalInformationModel,
  required List<SalesTransitionModel> transactions,
  required String fromDate,
  required String toDate,
  required String saleAmount,
  required String profit,
  required String loss,
  BuildContext? context,
}) async {
  final pdfFile = await createAndSaveLossProfitPDF(
    personalInformationModel: personalInformationModel,
    transactions: transactions,
    fromDate: fromDate,
    toDate: toDate,
    saleAmount: saleAmount,
    profit: profit,
    loss: loss,
    context: context,
  );
  Share.shareFiles([pdfFile.path], text: 'Share PDF');
}
