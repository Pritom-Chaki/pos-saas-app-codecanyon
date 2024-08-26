import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_pos/Screens/tax%20report/tax_model.dart';
import 'package:mobile_pos/constant.dart';
import 'add_new_tax_group.dart';
import 'create_single_tax.dart';
import 'edit_group_tax.dart';

class TaxReport extends StatefulWidget {
  const TaxReport({super.key});

  @override
  State<TaxReport> createState() => _TaxReportState();
}

class _TaxReportState extends State<TaxReport> {
  void deleteTax({required String name, required WidgetRef updateRef, required BuildContext context}) async {
    EasyLoading.show(status: 'Deleting..');
    String expenseKey = '';
    final userId = await getUserID();
    await FirebaseDatabase.instance.ref(userId).child('Tax List').orderByKey().get().then((value) {
      for (var element in value.children) {
        var data = jsonDecode(jsonEncode(element.value));
        if (data['name'].toString() == name) {
          expenseKey = element.key.toString();
        }
      }
    });
    DatabaseReference ref = FirebaseDatabase.instance.ref("${await getUserID()}/Tax List/$expenseKey");
    if (expenseKey != '') {
      await ref.remove();
      updateRef.refresh(taxProvider);
      EasyLoading.showSuccess('Done').then(
        (value) => Navigator.pop(context),
      );
    }
  }

  void deleteTaxReport({required String name, required WidgetRef updateRef, required BuildContext context}) async {
    EasyLoading.show(status: 'Deleting..');
    String expenseKey = '';
    final userId = await getUserID();
    await FirebaseDatabase.instance.ref(userId).child('Group Tax List').orderByKey().get().then((value) {
      for (var element in value.children) {
        var data = jsonDecode(jsonEncode(element.value));
        if (data['name'].toString() == name) {
          expenseKey = element.key.toString();
        }
      }
    });
    DatabaseReference ref = FirebaseDatabase.instance.ref("${await getUserID()}/Group Tax List/$expenseKey");
    if (expenseKey != '') {
      await ref.remove();
      updateRef.refresh(groupTaxProvider);
      EasyLoading.showSuccess('Done').then(
        (value) => Navigator.pop(context),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kMainColor,
      appBar: AppBar(
        title: Text(
          'Tax Report',
          style: GoogleFonts.poppins(
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        backgroundColor: kMainColor,
        elevation: 0.0,
      ),
      body: Consumer(
        builder: (_, ref, watch) {
          final tax = ref.watch(taxProvider);
          final groupTax = ref.watch(groupTaxProvider);
          return Container(
            padding: const EdgeInsets.all(15),
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(30),
                topLeft: Radius.circular(30),
              ),
            ),
            child: tax.when(
              data: (taxData) {
                return groupTax.when(
                  data: (groupTaxSnap) {
                    return SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          //___________________________________Tax Rates______________________________
                          Row(
                            children: [
                              Text(
                                'Tax rates- Manage your Tax rates',
                                style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold),
                              ),
                              const Spacer(),
                              SizedBox(
                                height: 30.0,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.only(left: 2, right: 2),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4.0),
                                    ),
                                    backgroundColor: kMainColor,
                                    elevation: 1.0,
                                    foregroundColor: kGreyTextColor.withOpacity(0.1),
                                    shadowColor: kMainColor,
                                    animationDuration: const Duration(milliseconds: 300),
                                    textStyle: const TextStyle(color: Colors.white, fontFamily: 'Display', fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                  onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CreateSingleTax(
                                        listOfTax: taxData ?? [],
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        FeatherIcons.plus,
                                        size: 15,
                                        color: kWhite,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'Add',
                                        style: kTextStyle.copyWith(color: kWhite, fontSize: 12, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10.0),
                          SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: DataTable(
                              headingRowColor: MaterialStateColor.resolveWith((states) => Colors.white),
                              border: TableBorder.all(borderRadius: BorderRadius.circular(2.0), color: kBorderColorTextField),
                              dividerThickness: 1.0,
                              dataTextStyle: kTextStyle.copyWith(color: kTitleColor),
                              sortAscending: true,
                              showCheckboxColumn: false,
                              horizontalMargin: 5.0,
                              columnSpacing: 10,
                              dataRowMinHeight: 45,
                              showBottomBorder: true,
                              checkboxHorizontalMargin: 0.0,
                              columns: const <DataColumn>[
                                DataColumn(
                                  label: Text(
                                    'Name',
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    'Tax rate',
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    'Acton',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                              rows: List.generate(
                                taxData.length,
                                (index) => DataRow(
                                  cells: [
                                    DataCell(
                                      SizedBox(
                                        width: MediaQuery.of(context).size.width * .30,
                                        child: Text(
                                          taxData[index].name ?? '',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.start,
                                          style: kTextStyle.copyWith(color: kGreyTextColor),
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Center(child: Text(
                                        taxData[index].taxRate.toString(),

                                        textAlign: TextAlign.center,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: kTextStyle.copyWith(color: kGreyTextColor),
                                      ),)

                                    ),
                                    DataCell(
                                      Row(
                                        children: [
                                          SizedBox(
                                            height: 25.0,
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                padding: const EdgeInsets.only(left: 2, right: 2),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(4.0),
                                                ),
                                                backgroundColor: kMainColor,
                                                elevation: 1.0,
                                                foregroundColor: kGreyTextColor.withOpacity(0.1),
                                                shadowColor: kMainColor,
                                                animationDuration: const Duration(milliseconds: 300),
                                                textStyle: const TextStyle(color: Colors.white, fontFamily: 'Display', fontSize: 16, fontWeight: FontWeight.bold),
                                              ),
                                              onPressed: () => Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => EditSingleTax(
                                                    taxList: taxData,
                                                    taxModel: taxData[index],
                                                  ),
                                                ),
                                              ),
                                              child: Row(
                                                children: [
                                                  const Icon(
                                                    FeatherIcons.edit,
                                                    size: 15,
                                                    color: kWhite,
                                                  ),
                                                  SizedBox(width: 4),
                                                  Text(
                                                    'Edit',
                                                    style: kTextStyle.copyWith(color: kWhite, fontSize: 12, fontWeight: FontWeight.bold),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 5.0),
                                          SizedBox(
                                            height: 25.0,
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                padding: const EdgeInsets.only(left: 2, right: 2),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(4.0),
                                                ),
                                                backgroundColor: Colors.red,
                                                elevation: 1.0,
                                                foregroundColor: Colors.white.withOpacity(0.1),
                                                shadowColor: Colors.red,
                                                animationDuration: const Duration(milliseconds: 300),
                                                textStyle: kTextStyle.copyWith(color: kWhite),
                                              ),
                                              onPressed: () {
                                                showDialog(
                                                    barrierDismissible: false,
                                                    context: context,
                                                    builder: (BuildContext dialogContext) {
                                                      return Padding(
                                                        padding: const EdgeInsets.all(20.0),
                                                        child: Center(
                                                          child: Container(
                                                            decoration: const BoxDecoration(
                                                              color: Colors.white,
                                                              borderRadius: BorderRadius.all(
                                                                Radius.circular(15),
                                                              ),
                                                            ),
                                                            child: Padding(
                                                              padding: const EdgeInsets.all(20.0),
                                                              child: Column(
                                                                mainAxisSize: MainAxisSize.min,
                                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                children: [
                                                                  Text(
                                                                    'Are you sure want to delete this Tax ?',
                                                                    style: kTextStyle.copyWith(color: kTitleColor, fontSize: 18.0, fontWeight: FontWeight.bold),
                                                                    textAlign: TextAlign.center,
                                                                  ),
                                                                  const SizedBox(height: 30),
                                                                  Row(
                                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                                    mainAxisSize: MainAxisSize.min,
                                                                    children: [
                                                                      SizedBox(
                                                                        width: 130,
                                                                        child: ElevatedButton(
                                                                          onPressed: () {
                                                                            Navigator.pop(dialogContext);
                                                                          },
                                                                          style: ButtonStyle(
                                                                            shape: MaterialStateProperty.all(
                                                                              RoundedRectangleBorder(
                                                                                  borderRadius: BorderRadius.circular(8.0), side: const BorderSide(color: kMainColor)),
                                                                            ),
                                                                            overlayColor: MaterialStateProperty.all<Color>(
                                                                              kMainColor.withOpacity(0.1),
                                                                            ),
                                                                            shadowColor: MaterialStateProperty.all<Color>(kMainColor.withOpacity(0.1)),
                                                                            minimumSize: MaterialStateProperty.all<Size>(
                                                                              const Size(150, 50),
                                                                            ),
                                                                            backgroundColor: MaterialStateProperty.all<Color>(kWhite),

                                                                            // Change background color
                                                                            textStyle:
                                                                                MaterialStateProperty.all<TextStyle>(const TextStyle(color: Colors.white)), // Change text color
                                                                            // Add more properties as needed
                                                                          ),
                                                                          child: Text(
                                                                            'Cancel',
                                                                            style: kTextStyle.copyWith(color: kMainColor, fontWeight: FontWeight.bold, fontSize: 16),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      const SizedBox(width: 30),
                                                                      SizedBox(
                                                                        width: 130,
                                                                        child: ElevatedButton(
                                                                          onPressed: () {
                                                                            deleteTax(
                                                                              name: taxData[index].name,
                                                                              updateRef: ref,
                                                                              context: dialogContext,
                                                                            );
                                                                            Navigator.pop(dialogContext);
                                                                          },
                                                                          style: ButtonStyle(
                                                                            shape: MaterialStateProperty.all(
                                                                              RoundedRectangleBorder(
                                                                                borderRadius: BorderRadius.circular(8.0),
                                                                              ),
                                                                            ),
                                                                            overlayColor: MaterialStateProperty.all<Color>(
                                                                              kWhite.withOpacity(0.1),
                                                                            ),
                                                                            shadowColor: MaterialStateProperty.all<Color>(kMainColor.withOpacity(0.1)),
                                                                            minimumSize: MaterialStateProperty.all<Size>(Size(150, 50)),
                                                                            backgroundColor: MaterialStateProperty.all<Color>(kMainColor),
                                                                            // Change background color
                                                                            textStyle: MaterialStateProperty.all<TextStyle>(TextStyle(color: Colors.white)), // Change text color
                                                                            // Add more properties as needed
                                                                          ),
                                                                          child: Text(
                                                                            'Delete',
                                                                            style: kTextStyle.copyWith(color: kWhite, fontWeight: FontWeight.bold, fontSize: 16),
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
                                                    });
                                              },
                                              child: Row(
                                                children: [
                                                  const Icon(
                                                    Icons.delete_outline,
                                                    size: 17,
                                                    color: kWhite,
                                                  ),
                                                  SizedBox(width: 4),
                                                  Text(
                                                    'Delete',
                                                    style: kTextStyle.copyWith(color: kWhite, fontSize: 12, fontWeight: FontWeight.bold),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                  color: MaterialStateColor.resolveWith(
                                    (Set<MaterialState> states) {
                                      // Use index to determine whether the row is even or odd
                                      return index % 2 == 0 ? Colors.grey.shade100 : Colors.white;
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),

                          //___________________________________Tax Group______________________________
                          const SizedBox(height: 40.0),
                          Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Tax Group',
                                    style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    '(Combination of multiple taxes)',
                                    style: kTextStyle.copyWith(color: kGreyTextColor),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              SizedBox(
                                height: 30.0,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.only(left: 2, right: 2),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4.0),
                                    ),
                                    backgroundColor: kMainColor,
                                    elevation: 1.0,
                                    foregroundColor: kGreyTextColor.withOpacity(0.1),
                                    shadowColor: kMainColor,
                                    animationDuration: const Duration(milliseconds: 300),
                                    textStyle: const TextStyle(color: Colors.white, fontFamily: 'Display', fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                  onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AddTaxGroup(
                                        listOfGroupTax: groupTaxSnap,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        FeatherIcons.plus,
                                        size: 15,
                                        color: kWhite,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'Add',
                                        style: kTextStyle.copyWith(color: kWhite, fontSize: 12, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10.0),
                          const SizedBox(height: 10.0),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              headingRowColor: MaterialStateColor.resolveWith((states) => Colors.white),
                              border: TableBorder.all(borderRadius: BorderRadius.circular(2.0), color: kBorderColorTextField),
                              dividerThickness: 1.0,
                              dataTextStyle: kTextStyle.copyWith(color: kTitleColor),
                              sortAscending: true,
                              showCheckboxColumn: false,
                              horizontalMargin: 5.0,
                              columnSpacing: 10,
                              dataRowMinHeight: 45,
                              showBottomBorder: true,
                              checkboxHorizontalMargin: 0.0,
                              columns: const <DataColumn>[
                                DataColumn(
                                  label: Text(
                                    'Name',
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    'Tax Rate %',
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    'Sub Taxes',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    'Acton',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                              rows: List.generate(
                                groupTaxSnap.length,
                                (index) => DataRow(
                                  cells: [
                                    DataCell(
                                      Text(
                                        groupTaxSnap[index].name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.start,
                                        style: kTextStyle.copyWith(color: kGreyTextColor),
                                      ),
                                    ),
                                    DataCell(
                                        Center(child: Text(
                                          groupTaxSnap[index].taxRate.toString(),
                                          textAlign: TextAlign.start,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: kTextStyle.copyWith(color: kGreyTextColor),
                                        ),),

                                    ),
                                    DataCell(
                                      Wrap(
                                        children: List.generate(
                                          groupTaxSnap[index].subTaxes?.length ?? 0,
                                          (i) {
                                            return Text(
                                              (i > 0 ? ' + ' : '') + (groupTaxSnap[index].subTaxes?[i].name.toString() ?? ''), // Join with comma if not the first item
                                              maxLines: 1,
                                              textAlign: TextAlign.start,
                                              overflow: TextOverflow.ellipsis,
                                              style: kTextStyle.copyWith(color: kGreyTextColor),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Row(
                                        children: [
                                          SizedBox(
                                            height: 25.0,
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                padding: const EdgeInsets.only(left: 2, right: 2),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(4.0),
                                                ),
                                                backgroundColor: kMainColor,
                                                elevation: 1.0,
                                                foregroundColor: kGreyTextColor.withOpacity(0.1),
                                                shadowColor: kMainColor,
                                                animationDuration: const Duration(milliseconds: 300),
                                                textStyle: const TextStyle(color: Colors.white, fontFamily: 'Display', fontSize: 16, fontWeight: FontWeight.bold),
                                              ),
                                              onPressed: () => Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => EditGroupTax(
                                                    listOfGroupTax: groupTaxSnap,
                                                    groupTaxModel: groupTaxSnap[index],
                                                  ),
                                                ),
                                              ),
                                              child: Row(
                                                children: [
                                                  const Icon(
                                                    FeatherIcons.edit,
                                                    size: 15,
                                                    color: kWhite,
                                                  ),
                                                  SizedBox(width: 4),
                                                  Text(
                                                    'Edit',
                                                    style: kTextStyle.copyWith(color: kWhite, fontSize: 12, fontWeight: FontWeight.bold),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 5.0),
                                          SizedBox(
                                            height: 25.0,
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                padding: const EdgeInsets.only(left: 2, right: 2),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(4.0),
                                                ),
                                                backgroundColor: Colors.red,
                                                elevation: 1.0,
                                                foregroundColor: Colors.white.withOpacity(0.1),
                                                shadowColor: Colors.red,
                                                animationDuration: const Duration(milliseconds: 300),
                                                textStyle: kTextStyle.copyWith(color: kWhite),
                                              ),
                                              onPressed: () {
                                                showDialog(
                                                    barrierDismissible: false,
                                                    context: context,
                                                    builder: (BuildContext dialogContext) {
                                                      return Padding(
                                                        padding: const EdgeInsets.all(20.0),
                                                        child: Center(
                                                          child: Container(
                                                            decoration: const BoxDecoration(
                                                              color: Colors.white,
                                                              borderRadius: BorderRadius.all(
                                                                Radius.circular(15),
                                                              ),
                                                            ),
                                                            child: Padding(
                                                              padding: const EdgeInsets.all(20.0),
                                                              child: Column(
                                                                mainAxisSize: MainAxisSize.min,
                                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                children: [
                                                                  Text(
                                                                    'Are you sure want to delete this Tax Group?',
                                                                    style: kTextStyle.copyWith(color: kTitleColor, fontSize: 18.0, fontWeight: FontWeight.bold),
                                                                    textAlign: TextAlign.center,
                                                                  ),
                                                                  const SizedBox(height: 30),
                                                                  Row(
                                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                                    mainAxisSize: MainAxisSize.min,
                                                                    children: [
                                                                      SizedBox(
                                                                        width: 130,
                                                                        child: ElevatedButton(
                                                                          onPressed: () {
                                                                            Navigator.pop(dialogContext);
                                                                          },
                                                                          style: ButtonStyle(
                                                                            shape: MaterialStateProperty.all(
                                                                              RoundedRectangleBorder(
                                                                                  borderRadius: BorderRadius.circular(8.0), side: const BorderSide(color: kMainColor)),
                                                                            ),
                                                                            overlayColor: MaterialStateProperty.all<Color>(
                                                                              kMainColor.withOpacity(0.1),
                                                                            ),
                                                                            shadowColor: MaterialStateProperty.all<Color>(kMainColor.withOpacity(0.1)),
                                                                            minimumSize: MaterialStateProperty.all<Size>(
                                                                              const Size(150, 50),
                                                                            ),
                                                                            backgroundColor: MaterialStateProperty.all<Color>(kWhite),

                                                                            // Change background color
                                                                            textStyle:
                                                                                MaterialStateProperty.all<TextStyle>(const TextStyle(color: Colors.white)), // Change text color
                                                                            // Add more properties as needed
                                                                          ),
                                                                          child: Text(
                                                                            'Cancel',
                                                                            style: kTextStyle.copyWith(color: kMainColor, fontWeight: FontWeight.bold, fontSize: 16),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      const SizedBox(width: 30),
                                                                      SizedBox(
                                                                        width: 130,
                                                                        child: ElevatedButton(
                                                                          onPressed: () {
                                                                            deleteTaxReport(
                                                                              name: groupTaxSnap[index].name,
                                                                              updateRef: ref,
                                                                              context: dialogContext,
                                                                            );
                                                                            Navigator.pop(dialogContext);
                                                                          },
                                                                          style: ButtonStyle(
                                                                            shape: MaterialStateProperty.all(
                                                                              RoundedRectangleBorder(
                                                                                borderRadius: BorderRadius.circular(8.0),
                                                                              ),
                                                                            ),
                                                                            overlayColor: MaterialStateProperty.all<Color>(
                                                                              kWhite.withOpacity(0.1),
                                                                            ),
                                                                            shadowColor: MaterialStateProperty.all<Color>(kMainColor.withOpacity(0.1)),
                                                                            minimumSize: MaterialStateProperty.all<Size>(Size(150, 50)),
                                                                            backgroundColor: MaterialStateProperty.all<Color>(kMainColor),
                                                                            // Change background color
                                                                            textStyle: MaterialStateProperty.all<TextStyle>(TextStyle(color: Colors.white)), // Change text color
                                                                            // Add more properties as needed
                                                                          ),
                                                                          child: Text(
                                                                            'Delete',
                                                                            style: kTextStyle.copyWith(color: kWhite, fontWeight: FontWeight.bold, fontSize: 16),
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
                                                    });
                                              },
                                              child: Row(
                                                children: [
                                                  const Icon(
                                                    Icons.delete_outline,
                                                    size: 17,
                                                    color: kWhite,
                                                  ),
                                                  SizedBox(width: 4),
                                                  Text(
                                                    'Delete',
                                                    style: kTextStyle.copyWith(color: kWhite, fontSize: 12, fontWeight: FontWeight.bold),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                  color: MaterialStateColor.resolveWith(
                                    (Set<MaterialState> states) {
                                      // Use index to determine whether the row is even or odd
                                      return index % 2 == 0 ? Colors.grey.shade100 : Colors.white;
                                    },
                                  ),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    );
                  },
                  error: (e, stack) {
                    print(stack);
                    return Center(
                      child: Text(e.toString()),
                    );
                  },
                  loading: () {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  },
                );
              },
              error: (e, stack) {
                return Center(
                  child: Text(e.toString()),
                );
              },
              loading: () {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
