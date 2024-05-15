import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import 'package:nb_utils/nb_utils.dart';

import '../../constant.dart';

class PurchaseList extends StatefulWidget {
  const PurchaseList({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _PurchaseListState createState() => _PurchaseListState();
}

class _PurchaseListState extends State<PurchaseList> {
  final dateController = TextEditingController();

  String dropdownValue = 'Last 30 Days';

  DropdownButton<String> getCategory() {
    List<String> dropDownItems = ['Last 7 Days', 'Last 30 Days', 'Current year', 'Last Year'];
    return DropdownButton(
      items: dropDownItems.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      value: dropdownValue,
      onChanged: (value) {
        setState(() {
          dropdownValue = value!;
        });
      },
    );
  }

  @override
  void dispose() {
    dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kMainColor,
      appBar: AppBar(
        title: Text(
          lang.S.of(context).purchaseList,
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
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              Column(
                children: [
                  const SizedBox(
                    height: 10.0,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Container(
                            height: 60.0,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5.0),
                              border: Border.all(color: kGreyTextColor),
                            ),
                            child: Center(child: getCategory()),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: AppTextField(
                            textFieldType: TextFieldType.NAME,
                            readOnly: true,
                            onTap: () async {
                              var date =
                                  await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(1900), lastDate: DateTime(2100));
                              setState(() {
                                dateController.text = date.toString().substring(0, 10);
                              });
                            },
                            controller: dateController,
                            decoration:  InputDecoration(
                                border: const OutlineInputBorder(),
                                floatingLabelBehavior: FloatingLabelBehavior.always,
                                labelText: lang.S.of(context).startDate,
                                hintText: lang.S.of(context).pickStartDate),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: AppTextField(
                            textFieldType: TextFieldType.OTHER,
                            readOnly: true,
                            onTap: () async {
                              var date =
                                  await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(1900), lastDate: DateTime(2100));
                              dateController.text = date.toString().substring(0, 10);
                            },
                            controller: dateController,
                            decoration:  InputDecoration(
                                border: const OutlineInputBorder(),
                                floatingLabelBehavior: FloatingLabelBehavior.always,
                                labelText: lang.S.of(context).endDate,
                                hintText: lang.S.of(context).pickEndDate),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: DataTable(
                      columnSpacing: 80,
                      horizontalMargin: 0,
                      headingRowColor: MaterialStateColor.resolveWith((states) => kDarkWhite),
                      columns:  <DataColumn>[
                        DataColumn(
                          label: Text(
                            lang.S.of(context).name,
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            lang.S.of(context).quantity,
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            lang.S.of(context).amount,
                          ),
                        ),
                      ],
                      rows: <DataRow>[
                        DataRow(
                          cells: <DataCell>[
                            DataCell(
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.only(right: 3.0),
                                    height: 30.0,
                                    width: 30.0,
                                    child: const CircleAvatar(
                                      backgroundImage: AssetImage('images/profile.png'),
                                    ),
                                  ),
                                  Text(
                                    'Riead',
                                    textAlign: TextAlign.start,
                                    style: GoogleFonts.poppins(
                                      color: Colors.black,
                                      fontSize: 15.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const DataCell(
                              Text('2'),
                            ),
                            const DataCell(
                              Text('25'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Spacer(),
              DataTable(
                columnSpacing: 120,
                headingRowColor: MaterialStateColor.resolveWith((states) => kDarkWhite),
                columns:  <DataColumn>[
                  DataColumn(
                    label: Text(
                      lang.S.of(context).totals,
                    ),
                  ),
                  const DataColumn(
                    label: Text(
                      '8',
                    ),
                  ),
                  const DataColumn(
                    label: Text(
                      '50',
                    ),
                  ),
                ],
                rows: const [],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
