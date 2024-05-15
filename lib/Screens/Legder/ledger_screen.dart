import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_pos/const_commas.dart';
import 'package:mobile_pos/constant.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import 'package:nb_utils/nb_utils.dart';

import '../../Provider/customer_provider.dart';
import '../../currency.dart';
import '../../empty_screen_widget.dart';
import '../Customers/Model/customer_model.dart';
import 'ledger_customer_details_screen.dart';

class LedgerScreen extends StatefulWidget {
  const LedgerScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LedgerScreenState createState() => _LedgerScreenState();
}

class _LedgerScreenState extends State<LedgerScreen> {
  List<CustomerModel> retailersList = [];
  List<CustomerModel> wholesalerList = [];
  List<CustomerModel> dealerList = [];
  List<CustomerModel> supplierList = [];
  double totalSale = 0;

  Future<void> customerData() async {
    List<CustomerModel> customerList = [];
    await FirebaseDatabase.instance.ref(constUserId).child('Customers').orderByKey().get().then((value) {
      for (var element in value.children) {
        customerList.add(CustomerModel.fromJson(jsonDecode(jsonEncode(element.value))));
      }
    });

    for (var element in customerList) {
      if (element.type.contains('Retailer')) {
        retailersList.add(element);
      }
      if (element.type.contains('Wholesaler')) {
        wholesalerList.add(element);
      }
      if (element.type.contains('Dealer')) {
        dealerList.add(element);
      }
      if (element.type.contains('Supplier')) {
        supplierList.add(element);
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    customerData();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, __) {
      final customerData = ref.watch(customerProvider);
      return DefaultTabController(
        initialIndex: 0,
        length: 4,
        child: Scaffold(
          backgroundColor: kMainColor,
          appBar: AppBar(
            title: Text(
              lang.S.of(context).ledger,
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
          body: customerData.when(data: (customer) {
            return Container(
              alignment: Alignment.topCenter,
              decoration:
                  const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(topRight: Radius.circular(30), topLeft: Radius.circular(30))),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TabBar(
                      indicatorColor: kMainColor,
                      indicator: UnderlineTabIndicator(
                        borderSide: const BorderSide(color: kMainColor, width: 4),
                        borderRadius: BorderRadius.only(
                          topLeft: radiusCircular(6.0),
                          topRight: radiusCircular(6.0),
                        ),
                      ),
                      labelColor: kMainColor,
                      tabs: [
                        Tab(
                          text: lang.S.of(context).retailer,
                        ),
                        Tab(
                          text: lang.S.of(context).wholSeller,
                        ),
                        Tab(
                          text: lang.S.of(context).dealer,
                        ),
                        Tab(
                          text: lang.S.of(context).supplier,
                        ),
                      ],
                    ),
                    SizedBox(
                      height: context.height(),
                      child: TabBarView(children: [
                        customer.isNotEmpty
                            ? ListView.builder(
                                shrinkWrap: true,
                                itemCount: customer.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return GestureDetector(
                                    onTap: () {
                                      LedgerCustomerDetailsScreen(
                                        customerModel: customer[index],
                                      ).launch(context);
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        children: [
                                          SizedBox(
                                            height: 50.0,
                                            width: 50.0,
                                            child: CircleAvatar(
                                              foregroundColor: Colors.blue,
                                              backgroundColor: kMainColor,
                                              radius: 70.0,
                                              child: Text(
                                                customer[index].customerName.isNotEmpty ? customer[index].customerName.substring(0, 1) : '',
                                                style: const TextStyle(color: Colors.white),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 10.0),
                                          SizedBox(
                                            width: 180,
                                            child: Text(
                                              customer[index].customerName.isNotEmpty ? customer[index].customerName : customer[index].phoneNumber,
                                              style: GoogleFonts.poppins(
                                                color: Colors.black,
                                                fontSize: 15.0,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 2,
                                            ),
                                          ),
                                          const Spacer(),
                                          Column(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                '$currency ${myFormat.format(int.tryParse(customer[index].dueAmount) ?? 0)}',
                                                style: GoogleFonts.poppins(
                                                  color: Colors.black,
                                                  fontSize: 15.0,
                                                ),
                                              ),
                                              Text(
                                                lang.S.of(context).due,
                                                style: GoogleFonts.poppins(
                                                  color: const Color(0xFFff5f00),
                                                  fontSize: 15.0,
                                                ),
                                              ),
                                            ],
                                          ).visible(customer[index].dueAmount != '' && customer[index].dueAmount != '0'),
                                          const SizedBox(width: 20),
                                          const Icon(
                                            Icons.arrow_forward_ios,
                                            color: kGreyTextColor,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ).visible(customer[index].type == 'Retailer');
                                },
                              )
                            : const Padding(
                                padding: EdgeInsets.all(60),
                                child: EmptyScreenWidget(),
                              ),
                        customer.isNotEmpty
                            ? ListView.builder(
                                shrinkWrap: true,
                                itemCount: customer.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return GestureDetector(
                                    onTap: () {
                                      LedgerCustomerDetailsScreen(
                                        customerModel: customer[index],
                                      ).launch(context);
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        children: [
                                          SizedBox(
                                            height: 50.0,
                                            width: 50.0,
                                            child: CircleAvatar(
                                              foregroundColor: Colors.blue,
                                              backgroundColor: kMainColor,
                                              radius: 70.0,
                                              child: Text(
                                                customer[index].customerName.isNotEmpty ? customer[index].customerName.substring(0, 1) : '',
                                                style: const TextStyle(color: Colors.white),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 10.0),
                                          SizedBox(
                                            width: 180,
                                            child: Text(
                                              customer[index].customerName.isNotEmpty ? customer[index].customerName : customer[index].phoneNumber,
                                              style: GoogleFonts.poppins(
                                                color: Colors.black,
                                                fontSize: 15.0,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 2,
                                            ),
                                          ),
                                          const Spacer(),
                                          Column(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                '$currency ${myFormat.format(int.tryParse(customer[index].dueAmount) ?? 0)}',
                                                style: GoogleFonts.poppins(
                                                  color: Colors.black,
                                                  fontSize: 15.0,
                                                ),
                                              ),
                                              Text(
                                                lang.S.of(context).due,
                                                style: GoogleFonts.poppins(
                                                  color: const Color(0xFFff5f00),
                                                  fontSize: 15.0,
                                                ),
                                              ),
                                            ],
                                          ).visible(customer[index].dueAmount != '' && customer[index].dueAmount != '0'),
                                          const SizedBox(width: 20),
                                          const Icon(
                                            Icons.arrow_forward_ios,
                                            color: kGreyTextColor,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ).visible(customer[index].type == 'Wholesaler');
                                },
                              )
                            : const Padding(padding: EdgeInsets.all(60), child: EmptyScreenWidget()),
                        customer.isNotEmpty
                            ? ListView.builder(
                                shrinkWrap: true,
                                itemCount: customer.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return GestureDetector(
                                    onTap: () {
                                      LedgerCustomerDetailsScreen(
                                        customerModel: customer[index],
                                      ).launch(context);
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        children: [
                                          SizedBox(
                                            height: 50.0,
                                            width: 50.0,
                                            child: CircleAvatar(
                                              foregroundColor: Colors.blue,
                                              backgroundColor: kMainColor,
                                              radius: 70.0,
                                              child: Text(
                                                customer[index].customerName.isNotEmpty ? customer[index].customerName.substring(0, 1) : '',
                                                style: const TextStyle(color: Colors.white),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 10.0),
                                          SizedBox(
                                            width: 180,
                                            child: Text(
                                              customer[index].customerName.isNotEmpty ? customer[index].customerName : customer[index].phoneNumber,
                                              style: GoogleFonts.poppins(
                                                color: Colors.black,
                                                fontSize: 15.0,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 2,
                                            ),
                                          ),
                                          const Spacer(),
                                          Column(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                '$currency ${myFormat.format(int.tryParse(customer[index].dueAmount) ?? 0)}',
                                                style: GoogleFonts.poppins(
                                                  color: Colors.black,
                                                  fontSize: 15.0,
                                                ),
                                              ),
                                              Text(
                                                lang.S.of(context).due,
                                                style: GoogleFonts.poppins(
                                                  color: const Color(0xFFff5f00),
                                                  fontSize: 15.0,
                                                ),
                                              ),
                                            ],
                                          ).visible(customer[index].dueAmount != '' && customer[index].dueAmount != '0'),
                                          const Icon(
                                            Icons.arrow_forward_ios,
                                            color: kGreyTextColor,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ).visible(customer[index].type == 'Dealer');
                                },
                              )
                            : const Padding(padding: EdgeInsets.all(60), child: EmptyScreenWidget()),
                        customer.isNotEmpty
                            ? ListView.builder(
                                shrinkWrap: true,
                                itemCount: customer.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return GestureDetector(
                                    onTap: () {
                                      LedgerCustomerDetailsScreen(
                                        customerModel: customer[index],
                                      ).launch(context);
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        children: [
                                          SizedBox(
                                            height: 50.0,
                                            width: 50.0,
                                            child: CircleAvatar(
                                              foregroundColor: Colors.blue,
                                              backgroundColor: kMainColor,
                                              radius: 70.0,
                                              child: Text(
                                                customer[index].customerName.isNotEmpty ? customer[index].customerName.substring(0, 1) : '',
                                                style: const TextStyle(color: Colors.white),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 10.0),
                                          SizedBox(
                                            width: 180,
                                            child: Text(
                                              customer[index].customerName.isNotEmpty ? customer[index].customerName : customer[index].phoneNumber,
                                              style: GoogleFonts.poppins(
                                                color: Colors.black,
                                                fontSize: 15.0,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 2,
                                            ),
                                          ),
                                          const Spacer(),
                                          Column(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                '$currency ${myFormat.format(int.tryParse(customer[index].dueAmount) ?? 0)}',
                                                style: GoogleFonts.poppins(
                                                  color: Colors.black,
                                                  fontSize: 15.0,
                                                ),
                                              ),
                                              Text(
                                                lang.S.of(context).due,
                                                style: GoogleFonts.poppins(
                                                  color: const Color(0xFFff5f00),
                                                  fontSize: 15.0,
                                                ),
                                              ),
                                            ],
                                          ).visible(customer[index].dueAmount != '' && customer[index].dueAmount != '0'),
                                          const SizedBox(width: 20),
                                          const Icon(
                                            Icons.arrow_forward_ios,
                                            color: kGreyTextColor,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ).visible(customer[index].type == 'Supplier');
                                },
                              )
                            : const Padding(padding: EdgeInsets.all(60), child: EmptyScreenWidget()),
                      ]),
                    ),
                  ],
                ),
              ),
            );
          }, error: (e, stack) {
            return Text(e.toString());
          }, loading: () {
            return Container(
              alignment: Alignment.topCenter,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(topRight: Radius.circular(30), topLeft: Radius.circular(30)),
              ),
              child: const Padding(
                padding: EdgeInsets.only(top: 20),
                child: CircularProgressIndicator(),
              ),
            );
          }),
        ),
      );
    });
  }
}

// ignore: must_be_immutable
class ReportCard extends StatelessWidget {
  ReportCard({
    super.key,
    required this.pressed,
    required this.iconPath,
    required this.title,
  });

  // ignore: prefer_typing_uninitialized_variables
  var pressed;
  String iconPath, title;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: pressed,
      child: Card(
        elevation: 0.0,
        color: Colors.white,
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Image(
                height: 40,
                width: 40,
                image: AssetImage(
                  iconPath,
                ),
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  color: Colors.black,
                ),
              ),
            ),
            const Spacer(),
            const Padding(
              padding: EdgeInsets.all(10.0),
              child: Icon(
                Icons.arrow_forward_ios,
                color: kMainColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
