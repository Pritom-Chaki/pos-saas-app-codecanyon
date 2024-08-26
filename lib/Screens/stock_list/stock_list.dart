import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mobile_pos/const_commas.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import 'package:nb_utils/nb_utils.dart';

import '../../Provider/product_provider.dart';
import '../../constant.dart';
import '../../currency.dart';
import '../../empty_screen_widget.dart';
import '../Warehouse/warehouse_model.dart';

class StockList extends StatefulWidget {
  const StockList({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _StockListState createState() => _StockListState();
}

class _StockListState extends State<StockList> {
  num totalStock = 0;
  double totalSalePrice = 0;
  double totalParPrice = 0;
  String? productName;
  int count = 0;

  @override
  void initState() {
    super.initState();
  }

  NumberFormat decimalFormat = NumberFormat.decimalPattern('en_US');

  // //_____________________Warehouse_list____________________________________________________________________
  // WareHouseModel? selectedWareHouse;
  //
  // int j = 0;
  //
  // DropdownButton<WareHouseModel> getName({required List<WareHouseModel> list}) {
  //   // Set initial value to the first item in the list, if available
  //   // selectedWareHouse = list.isNotEmpty ? list.first : null;
  //   List<DropdownMenuItem<WareHouseModel>> dropDownItems = [];
  //   for (var element in list) {
  //     dropDownItems.add(DropdownMenuItem(
  //       alignment: AlignmentDirectional.centerEnd,
  //       value: element,
  //       child: SizedBox(
  //         width: 150,
  //         child: Text(
  //           element.warehouseName,
  //           style: kTextStyle.copyWith(color: kTitleColor, fontSize: 14),
  //           overflow: TextOverflow.ellipsis,
  //           textAlign: TextAlign.end,
  //         ),
  //       ),
  //     ));
  //     if (j == 0) {
  //       selectedWareHouse = element;
  //     }
  //     j++;
  //   }
  //
  //   return DropdownButton(
  //     icon: const Icon(
  //       Icons.keyboard_arrow_down_outlined,
  //       color: kGreyTextColor,
  //     ),
  //     items: dropDownItems,
  //     isExpanded: false,
  //     isDense: true,
  //     value: selectedWareHouse,
  //     onChanged: (WareHouseModel? value) {
  //       setState(() {
  //         selectedWareHouse = value;
  //       });
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kMainColor,
      appBar: AppBar(
        title: Text(
          lang.S.of(context).currentStock,
          style: GoogleFonts.poppins(
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        backgroundColor: kMainColor,
        elevation: 0.0,
      ),
      body: Consumer(builder: (context, ref, __) {
        final providerData = ref.watch(productProvider);
        final wareHouseList = ref.watch(warehouseProvider);
        return Container(
          alignment: Alignment.topCenter,
          decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(topRight: Radius.circular(30), topLeft: Radius.circular(30))),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  Column(
                    children: [
                      providerData.when(data: (product) {
                        if (count == 0) {
                          count++;
                          for (var element in product) {
                            totalStock = totalStock + (num.tryParse(element.productStock)??0);
                            totalSalePrice = totalSalePrice + ((num.tryParse(element.productStock)??0) * element.productSalePrice.toInt());
                            totalParPrice = totalParPrice + ((num.tryParse(element.productStock)??0) * element.productSalePrice.toInt());
                          }
                        }
                        return product.isNotEmpty
                            ? Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Container(
                                      height: 100,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                          color: kMainColor.withOpacity(0.1),
                                          border: Border.all(width: 1, color: kMainColor),
                                          borderRadius: const BorderRadius.all(Radius.circular(15))),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        children: [
                                          Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Text(
                                                myFormat.format(totalStock),
                                                style: const TextStyle(
                                                  color: Colors.green,
                                                  fontSize: 20,
                                                ),
                                              ),
                                              const SizedBox(height: 10),
                                              Text(
                                                lang.S.of(context).totalStock,
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Container(
                                            width: 1,
                                            height: 60,
                                            color: kMainColor,
                                          ),
                                          Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Text(
                                                '$currency ${myFormat.format(totalParPrice)}',
                                                style: const TextStyle(
                                                  color: Colors.orange,
                                                  fontSize: 20,
                                                ),
                                              ),
                                              const SizedBox(height: 10),
                                              Text(
                                                lang.S.of(context).totalPrice,
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  AppTextField(
                                    textFieldType: TextFieldType.NAME,
                                    onChanged: (value) {
                                      setState(() {
                                        productName = value;
                                      });
                                    },
                                    decoration: InputDecoration(
                                      contentPadding: const EdgeInsets.only(left: 8.0, right: 8.0),
                                      floatingLabelBehavior: FloatingLabelBehavior.never,
                                      labelText: lang.S.of(context).productName,
                                      hintText: lang.S.of(context).enterProductName,
                                      prefixIcon: const Icon(Icons.search),
                                      border: const OutlineInputBorder(),
                                    ),
                                  ),
                                  // const SizedBox(height: 15.0),
                                  // wareHouseList.when(
                                  //   data: (warehouse) {
                                  //     List<WareHouseModel> wareHouseList = warehouse;
                                  //
                                  //     return Row(
                                  //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  //       children: [
                                  //         Text(
                                  //           'Selected Warehouse:',
                                  //           style: kTextStyle.copyWith(color: kGreyTextColor),
                                  //         ),
                                  //         DropdownButtonHideUnderline(
                                  //           child: getName(list: warehouse ?? []),
                                  //         ),
                                  //       ],
                                  //     );
                                  //
                                  //     //   FormField(
                                  //     //   builder: (FormFieldState<dynamic> field) {
                                  //     //     return InputDecorator(
                                  //     //       decoration:  InputDecoration(
                                  //     //         border: const OutlineInputBorder(),
                                  //     //           contentPadding: const EdgeInsets.only(left: 8.0,right: 8.0),
                                  //     //           ),
                                  //     //       child: DropdownButtonHideUnderline(
                                  //     //         child: getName(list: warehouse ?? []),
                                  //     //       ),
                                  //     //     );
                                  //     //   },
                                  //     // );
                                  //   },
                                  //   error: (e, stack) {
                                  //     return Center(
                                  //       child: Text(
                                  //         e.toString(),
                                  //       ),
                                  //     );
                                  //   },
                                  //   loading: () {
                                  //     return const Center(
                                  //       child: CircularProgressIndicator(),
                                  //     );
                                  //   },
                                  // ),
                                  // const Divider(
                                  //   thickness: 1.0,
                                  //   color: kBorderColorTextField,
                                  //   height: 10,
                                  // ),
                                  // Container(
                                  //   decoration: BoxDecoration(
                                  //     color: kMainColor.withOpacity(0.2),
                                  //     borderRadius: const BorderRadius.only(
                                  //       topLeft: Radius.circular(0),
                                  //       topRight: Radius.circular(0),
                                  //     ),
                                  //   ),
                                  //   padding: const EdgeInsets.all(20),
                                  //   child: Row(
                                  //     children:  [
                                  //       Expanded(
                                  //         flex: 2,
                                  //         child: Text(
                                  //           lang.S.of(context).product,
                                  //           style: const TextStyle(fontWeight: FontWeight.bold),
                                  //         ),
                                  //       ),
                                  //       Expanded(
                                  //         flex: 2,
                                  //         child: Text(
                                  //           lang.S.of(context).quantity,
                                  //           style: const TextStyle(fontWeight: FontWeight.bold),
                                  //         ),
                                  //       ),
                                  //       Expanded(
                                  //         flex: 2,
                                  //         child: Text(
                                  //           lang.S.of(context).purchase,
                                  //           style: const TextStyle(fontWeight: FontWeight.bold),
                                  //         ),
                                  //       ),
                                  //       Text(
                                  //         lang.S.of(context).sales,
                                  //         style: const TextStyle(fontWeight: FontWeight.bold),
                                  //       ),
                                  //     ],
                                  //   ),
                                  // ),
                                  const SizedBox(height: 10),
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: DataTable(
                                      headingRowColor: MaterialStateColor.resolveWith((states) => kMainColor.withOpacity(0.2)),
                                      border: TableBorder.all(color: kBorderColorTextField, width: 0.5),
                                      columns: <DataColumn>[
                                        DataColumn(
                                          label: Text(
                                            lang.S.of(context).product,
                                          ),
                                        ),
                                        DataColumn(
                                          label: Text(
                                            lang.S.of(context).qty,
                                          ),
                                        ),
                                        const DataColumn(
                                          label: Text(
                                            'Warehouse',
                                          ),
                                        ),
                                        DataColumn(
                                          label: Text(
                                            lang.S.of(context).purchase,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                          ),
                                        ),
                                        DataColumn(
                                          label: Text(
                                            lang.S.of(context).sales,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                          ),
                                        ),
                                      ],
                                      rows: List.generate(
                                        product.length,
                                        (index) => DataRow(cells: [
                                          DataCell(Padding(
                                            padding: product.last == product[index] ? const EdgeInsets.only(top: 4) : const EdgeInsets.only(top: 4),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  product[index].productName,
                                                  textAlign: TextAlign.start,
                                                  style: GoogleFonts.poppins(
                                                    color: (num.tryParse(product[index].productStock)??0) <= product[index].lowerStockAlert ? Colors.red : Colors.black,
                                                    fontSize: 16.0,
                                                  ),
                                                ),
                                                Text(
                                                  product[index].brandName,
                                                  textAlign: TextAlign.start,
                                                  style: GoogleFonts.poppins(
                                                    color: (num.tryParse(product[index].productStock)??0) <= product[index].lowerStockAlert ? Colors.red : kGreyTextColor,
                                                    fontSize: 12.0,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )),
                                          DataCell(
                                            Text(
                                              myFormat.format(num.tryParse(product[index].productStock) ?? 0),
                                              style: GoogleFonts.poppins(
                                                color: (num.tryParse(product[index].productStock)??0) <= product[index].lowerStockAlert ? Colors.red : Colors.black,
                                              ),
                                            ),
                                          ),
                                          DataCell(
                                            Text(
                                              product[index].warehouseName,
                                              style: GoogleFonts.poppins(
                                                color: (num.tryParse(product[index].productStock)??0) <= product[index].lowerStockAlert ? Colors.red : Colors.black,
                                              ),
                                            ),
                                          ),
                                          DataCell(
                                            Text(
                                              '$currency${myFormat.format(int.tryParse(product[index].productPurchasePrice) ?? 0)}',
                                              style: GoogleFonts.poppins(
                                                color:(num.tryParse(product[index].productStock)??0) <= product[index].lowerStockAlert ? Colors.red : Colors.black,
                                              ),
                                            ),
                                          ),
                                          DataCell(Text(
                                            '$currency ${myFormat.format(int.tryParse(product[index].productSalePrice) ?? 0)}',
                                            style: GoogleFonts.poppins(
                                              color: (num.tryParse(product[index].productStock)??0) <= product[index].lowerStockAlert ? Colors.red : Colors.black,
                                            ),
                                          )),
                                        ]),
                                      ),
                                    ),
                                  ),

                                  // ListView.builder(
                                  //     itemCount: product.length,
                                  //     shrinkWrap: true,
                                  //     physics: const NeverScrollableScrollPhysics(),
                                  //     itemBuilder: (context, index) {
                                  //       return Padding(
                                  //         padding: const EdgeInsets.all(10.0),
                                  //         child: Row(
                                  //           children: [
                                  //             Column(
                                  //               mainAxisAlignment: MainAxisAlignment.start,
                                  //               crossAxisAlignment: CrossAxisAlignment.start,
                                  //               children: [
                                  //                 Text(
                                  //                   product[index].productName,
                                  //                   textAlign: TextAlign.start,
                                  //                   style: GoogleFonts.poppins(
                                  //                     color: product[index].productStock.toInt() < 20 ? Colors.red : Colors.black,
                                  //                     fontSize: 16.0,
                                  //                   ),
                                  //                 ),
                                  //                 Text(
                                  //                   product[index].brandName,
                                  //                   textAlign: TextAlign.start,
                                  //                   style: GoogleFonts.poppins(
                                  //                     color: product[index].productStock.toInt() < 20 ? Colors.red : kGreyTextColor,
                                  //                     fontSize: 12.0,
                                  //                   ),
                                  //                 ),
                                  //               ],
                                  //             ),
                                  //             Text(
                                  //               product[index].productStock,
                                  //               style: GoogleFonts.poppins(
                                  //                 color: product[index].productStock.toInt() < 20 ? Colors.red : Colors.black,
                                  //               ),
                                  //             ),
                                  //             Text(
                                  //               '$currency${product[index].productPurchasePrice}',
                                  //               style: GoogleFonts.poppins(
                                  //                 color: product[index].productStock.toInt() < 10 ? Colors.red : Colors.black,
                                  //               ),
                                  //             ),
                                  //             Text(
                                  //               '$currency${product[index].productSalePrice}',
                                  //               style: GoogleFonts.poppins(
                                  //                 color: product[index].productStock.toInt() < 20 ? Colors.red : Colors.black,
                                  //               ),
                                  //             ),
                                  //           ],
                                  //         ),
                                  //       ).visible(productName.isEmptyOrNull ? true : product[index].productName.toUpperCase().contains(productName!.toUpperCase()));
                                  //     }),
                                ],
                              )
                            : const Center(
                                child: Padding(
                                padding: EdgeInsets.only(top: 60),
                                child: EmptyScreenWidget(),
                              ));
                      }, error: (e, stack) {
                        return Text(e.toString());
                      }, loading: () {
                        return const Center(child: CircularProgressIndicator());
                      }),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
