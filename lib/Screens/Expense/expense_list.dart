import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mobile_pos/GlobalComponents/button_global.dart';
import 'package:mobile_pos/Screens/Expense/add_erxpense.dart';
import 'package:mobile_pos/const_commas.dart';
import 'package:mobile_pos/currency.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import 'package:mobile_pos/model/expense_model.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../Provider/all_expanse_provider.dart';
import '../../constant.dart';

class ExpenseList extends StatefulWidget {
  const ExpenseList({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ExpenseListState createState() => _ExpenseListState();
}

class _ExpenseListState extends State<ExpenseList> {
  final dateController = TextEditingController();
  TextEditingController fromDateTextEditingController = TextEditingController(text: DateFormat.yMMMd().format(DateTime(2021)));
  TextEditingController toDateTextEditingController = TextEditingController(text: DateFormat.yMMMd().format(DateTime.now()));
  DateTime fromDate = DateTime(2021);
  DateTime toDate = DateTime.now();
  double totalExpense = 0;

  @override
  void dispose() {
    dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    totalExpense = 0;
    return Consumer(builder: (context, ref, __) {
      final expenseData = ref.watch(expenseProvider);

      return Scaffold(
        backgroundColor: kMainColor,
        appBar: AppBar(
          backgroundColor: kMainColor,
          title: Text(
            lang.S.of(context).expenseReport,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 20.0,
            ),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          centerTitle: true,
          elevation: 0.0,
        ),
        body: Container(
          alignment: Alignment.topCenter,
          decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(topRight: Radius.circular(30), topLeft: Radius.circular(30))),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 10.0, left: 10.0, top: 10, bottom: 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: AppTextField(
                            textFieldType: TextFieldType.NAME,
                            readOnly: true,
                            controller: fromDateTextEditingController,
                            decoration: InputDecoration(
                              floatingLabelBehavior: FloatingLabelBehavior.always,
                              labelText: lang.S.of(context).formDate,
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
                                    fromDateTextEditingController.text = DateFormat.yMMMd().format(picked ?? DateTime.now());
                                    fromDate = picked!;
                                    totalExpense = 0;
                                  });
                                },
                                icon: const Icon(FeatherIcons.calendar),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: AppTextField(
                            textFieldType: TextFieldType.NAME,
                            readOnly: true,
                            controller: toDateTextEditingController,
                            decoration: InputDecoration(
                              floatingLabelBehavior: FloatingLabelBehavior.always,
                              labelText: lang.S.of(context).toDate,
                              border: const OutlineInputBorder(),
                              suffixIcon: IconButton(
                                onPressed: () async {
                                  final DateTime? picked = await showDatePicker(
                                    initialDate: toDate,
                                    firstDate: DateTime(2015, 8),
                                    lastDate: DateTime(2101),
                                    context: context,
                                  );
                                  setState(() {
                                    toDateTextEditingController.text = DateFormat.yMMMd().format(picked ?? DateTime.now());
                                    picked!.isToday ? toDate = DateTime.now() : toDate = picked;
                                    totalExpense = 0;
                                  });
                                },
                                icon: const Icon(FeatherIcons.calendar),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20,),

                  ///__________expense_data_table____________________________________________

                  expenseData.when(data: (mainData) {
                    if (mainData.isNotEmpty) {
                      final List<ExpenseModel> data = mainData.reversed.toList();
                      for (var element in data) {
                        if ((fromDate.isBefore(DateTime.parse(element.expenseDate)) || DateTime.parse(element.expenseDate).isAtSameMomentAs(fromDate)) &&
                            (toDate.isAfter(DateTime.parse(element.expenseDate)) || DateTime.parse(element.expenseDate).isAtSameMomentAs(toDate))) {
                          totalExpense += element.amount.toDouble();
                        }
                        else{
                          totalExpense += element.amount.toDouble();
                        }
                      }
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          headingRowColor: MaterialStateColor.resolveWith((states) => kMainColor.withOpacity(0.2)),
                          border: TableBorder.all(color: kBorderColorTextField,width: 0.5),
                          columns:  <DataColumn>[
                            DataColumn(
                              label: Text(
                                lang.S.of(context).expenseFor,
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                lang.S.of(context).date,
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                lang.S.of(context).amount,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                            ),
                          ],
                          rows: List.generate(
                            data.length,
                                (index) => DataRow(cells: [
                              DataCell(Padding(
                                padding: data.last == data[index]
                                    ? const EdgeInsets.only(top: 4)
                                    : const EdgeInsets.only(top: 4),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      data[index].expanseFor,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      data[index].category == '' ? 'Not Provided' : data[index].category,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(color: Colors.grey, fontSize: 11),
                                    ),
                                  ],
                                ),
                              )),
                              DataCell(Text(
                                DateFormat.yMMMd().format(DateTime.parse(data[index].expenseDate)),
                                style: GoogleFonts.poppins(
                                  // color: product[index].productStock.toInt() < 20 ? Colors.red : Colors.black,
                                ),
                              ),),
                              DataCell(Text(
                                '$currency${myFormat.format(int.tryParse(data[index].amount)??0)}',
                                style: GoogleFonts.poppins(
                                ),
                              ),),
                            ]),
                          ),
                        ),
                      );
                      //  SizedBox(
                      //   width: context.width(),
                      //   child: ListView.builder(
                      //     shrinkWrap: true,
                      //     itemCount: data.length,
                      //     physics: const NeverScrollableScrollPhysics(),
                      //     itemBuilder: (BuildContext context, int index) {
                      //       return (fromDate.isBefore(DateTime.parse(data[index].expenseDate)) ||
                      //                   DateTime.parse(data[index].expenseDate).isAtSameMomentAs(fromDate)) &&
                      //               (toDate.isAfter(DateTime.parse(data[index].expenseDate)) || DateTime.parse(data[index].expenseDate).isAtSameMomentAs(toDate))
                      //           ? Column(
                      //               children: [
                      //                 Padding(
                      //                   padding: const EdgeInsets.all(10.0),
                      //                   child: Row(
                      //                     crossAxisAlignment: CrossAxisAlignment.center,
                      //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //                     children: [
                      //                       SizedBox(
                      //                         width: 130,
                      //                         child: Column(
                      //                           crossAxisAlignment: CrossAxisAlignment.start,
                      //                           mainAxisAlignment: MainAxisAlignment.center,
                      //                           children: [
                      //                             Text(
                      //                               data[index].expanseFor,
                      //                               maxLines: 2,
                      //                               overflow: TextOverflow.ellipsis,
                      //                             ),
                      //                             const SizedBox(height: 5),
                      //                             Text(
                      //                               data[index].category == '' ? 'Not Provided' : data[index].category,
                      //                               maxLines: 2,
                      //                               overflow: TextOverflow.ellipsis,
                      //                               style: const TextStyle(color: Colors.grey, fontSize: 11),
                      //                             ),
                      //                           ],
                      //                         ),
                      //                       ),
                      //                       SizedBox(
                      //
                      //                         child: Text(
                      //                           DateFormat.yMMMd().format(DateTime.parse(data[index].expenseDate)),
                      //                         ),
                      //                       ),
                      //                       Container(
                      //                         alignment: Alignment.centerRight,
                      //                         child: Text('$currency${data[index].amount}'),
                      //                       )
                      //                     ],
                      //                   ),
                      //                 ),
                      //                 Container(
                      //                   height: 1,
                      //                   color: Colors.black12,
                      //                 )
                      //               ],
                      //             )
                      //           : Container();
                      //     },
                      //   ),
                      // );
                    } else {
                      return  Padding(
                        padding: const EdgeInsets.all(20),
                        child: Center(child: Text(lang.S.of(context).noDataAvailable)),
                      );
                    }
                  }, error: (Object error, StackTrace? stackTrace) {
                    return Text(error.toString());
                  }, loading: () {
                    return const Center(child: CircularProgressIndicator());
                  }),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: Container(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ///_________total______________________________________________
                Container(
                  height: 50,
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(color: kDarkWhite),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                       Text(
                        lang.S.of(context).totalExpense,
                      ),
                      Text('$currency${myFormat.format(totalExpense)}')
                    ],
                  ),
                ),

                ///________button________________________________________________
                ButtonGlobalWithoutIcon(
                  buttontext: lang.S.of(context).addExpense,
                  buttonDecoration: kButtonDecoration.copyWith(color: kMainColor),
                  onPressed: () {
                    const AddExpense().launch(context);
                  },
                  buttonTextColor: Colors.white,
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
