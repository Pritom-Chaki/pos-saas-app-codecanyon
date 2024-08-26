import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mobile_pos/GlobalComponents/button_global.dart';
import 'package:mobile_pos/Provider/customer_provider.dart';
import 'package:mobile_pos/Screens/Customers/add_customer.dart';
import 'package:mobile_pos/Screens/Customers/customer_details.dart';
import 'package:mobile_pos/const_commas.dart';
import 'package:mobile_pos/constant.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import 'package:nb_utils/nb_utils.dart';

import '../../currency.dart';
import '../../empty_screen_widget.dart';
import '../Home/home.dart';

class CustomerList extends StatefulWidget {
  const CustomerList({super.key});

  @override
  State<CustomerList> createState() => _CustomerListState();
}

class _CustomerListState extends State<CustomerList> with SingleTickerProviderStateMixin {
  late Color color;
  List<String> type = ['All', 'Retailer', 'Supplier', 'Wholesaler', 'Dealer'];

  String typeName = 'All';
  int typeIndex = 0;
  String? partyName;
  TabController? tabController;

  @override
  void initState() {
    tabController = TabController(length: 5, vsync: this);
    super.initState();
  }

  String _formatAmount(String? amountString) {
    final amount = int.tryParse(amountString ?? '0') ?? 0;
    final myFormat = NumberFormat.decimalPattern('en_US');
    return myFormat.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 0,
      length: type.length,
      child: Scaffold(
        backgroundColor: kMainColor,
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          backgroundColor: kMainColor,
          title: Text(
            lang.S.of(context).partiesList,
            style: GoogleFonts.poppins(
              color: Colors.white,
            ),
          ),
          leading: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ).onTap(() async {
            await Future.delayed(const Duration(microseconds: 100)).then((value) => const Home().launch(context));
          }),
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white),
          elevation: 0.0,
        ),
        body: WillPopScope(
          onWillPop: () async {
            await Future.delayed(const Duration(microseconds: 100)).then((value) {
              if (mounted) {
                const Home().launch(context);
                return true;
              } else {
                return false;
              }
            });
            return false;
          },
          child: Container(
            alignment: Alignment.topCenter,
            decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(topRight: Radius.circular(30), topLeft: Radius.circular(30))),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(
                    height: 10.0,
                  ),
                  TabBar(
                    controller: tabController,
                    tabAlignment: TabAlignment.start,
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelColor: kMainColor,
                    unselectedLabelColor: kGreyTextColor,
                    onTap: (val) {
                      setState(() {
                        typeName = type[tabController!.index];
                        typeIndex = tabController!.index;
                      });
                    },
                    padding: EdgeInsets.zero,
                    isScrollable: true,
                    tabs: List.generate(
                      type.length,
                      (index) => Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(
                          type[index],
                          style: const TextStyle(fontSize: 18.0),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20.0,20.0,20.0,0.0),
                    child: AppTextField(
                      textFieldType: TextFieldType.NAME,
                      onChanged: (value) {
                        setState(() {
                          partyName = value;
                        });
                      },
                      decoration: const InputDecoration(
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                          labelText: 'Party Name',
                          hintText: 'Enter Party Name',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.search)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10,right: 10,top: 10),
                    child: Consumer(
                      builder: (context, ref, __) {
                        final providerData = ref.watch(customerProvider);

                        return providerData.when(
                          data: (customer) {
                            return customer.isNotEmpty
                                ? SizedBox(
                                    height: customer.length * 73,
                                    child: TabBarView(
                                      controller: tabController,
                                      children: [
                                        ListView.builder(
                                            shrinkWrap: true,
                                            physics: const NeverScrollableScrollPhysics(),
                                            itemCount: customer.length,
                                            itemBuilder: (_, index) {
                                              customer[index].type == 'Retailer' ? color = const Color(0xFF56da87) : Colors.white;
                                              customer[index].type == 'Wholesaler' ? color = const Color(0xFF25a9e0) : Colors.white;
                                              customer[index].type == 'Dealer' ? color = const Color(0xFFff5f00) : Colors.white;
                                              customer[index].type == 'Supplier' ? color = const Color(0xFFA569BD) : Colors.white;

                                              return Column(
                                                children: [
                                                  GestureDetector(
                                                    onTap: () {
                                                      CustomerDetails(
                                                        customerModel: customer[index],
                                                      ).launch(context);
                                                    },
                                                    child: Visibility(
                                                      visible: partyName.isEmptyOrNull
                                                          ? true
                                                          : customer[index].customerName.toUpperCase().contains(partyName!.toUpperCase()) ||
                                                              customer[index].phoneNumber.contains(partyName!),
                                                      child: ListTile(
                                                        horizontalTitleGap: 10,
                                                        contentPadding: EdgeInsets.zero,
                                                        leading: SizedBox(
                                                          height: 50.0,
                                                          width: 50.0,
                                                          child: CircleAvatar(
                                                            foregroundColor: Colors.blue,
                                                            backgroundColor: kMainColor,
                                                            radius: 70.0,
                                                            child: ClipOval(
                                                              child: Text(
                                                                customer[index].customerName.isNotEmpty ? customer[index].customerName.substring(0, 1) : '',
                                                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        title: Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            Flexible(
                                                              child: Text(
                                                                customer[index].customerName.isNotEmpty
                                                                    ? customer[index].customerName
                                                                    : customer[index].phoneNumber,
                                                                style: kTextStyle.copyWith(color: kTitleColor),
                                                                maxLines: 1,
                                                                overflow: TextOverflow.ellipsis,
                                                              ),
                                                            ),
                                                            const SizedBox(width: 10),
                                                            Visibility(
                                                              visible: customer[index].dueAmount != '' && customer[index].dueAmount != '0',
                                                              child: Text(
                                                                '$currency ${myFormat.format(int.tryParse(customer[index].dueAmount.toString()) ?? 0)}',
                                                                style: GoogleFonts.poppins(
                                                                  color: Colors.black,
                                                                  fontSize: 15.0,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        subtitle: Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            Text(
                                                              customer[index].type,
                                                              style: kTextStyle.copyWith(color: color, fontSize: 15.0),
                                                            ),
                                                            Visibility(
                                                              visible: customer[index].dueAmount != '' && customer[index].dueAmount != '0',
                                                              child: Text(
                                                                lang.S.of(context).due,
                                                                style: kTextStyle.copyWith(color: const Color(0xFFff5f00), fontSize: 15),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        trailing: const Icon(
                                                          Icons.arrow_forward_ios,
                                                          color: kGreyTextColor,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Divider(
                                                    height: 1,
                                                    thickness: 1.0,
                                                    color: kBorderColor.withOpacity(0.3),
                                                  )
                                                ],
                                              );
                                            }),
                                        ListView.builder(
                                            itemCount: customer.length,
                                            itemBuilder: (_, index) {
                                              customer[index].type == 'Retailer' ? color = const Color(0xFF56da87) : Colors.white;
                                              customer[index].type == 'Wholesaler' ? color = const Color(0xFF25a9e0) : Colors.white;
                                              customer[index].type == 'Dealer' ? color = const Color(0xFFff5f00) : Colors.white;
                                              customer[index].type == 'Supplier' ? color = const Color(0xFFA569BD) : Colors.white;

                                              return Column(
                                                children: [
                                                  GestureDetector(
                                                    onTap: () {
                                                      CustomerDetails(
                                                        customerModel: customer[index],
                                                      ).launch(context);
                                                    },
                                                    child: Column(
                                                      children: [
                                                        ListTile(
                                                          horizontalTitleGap: 10,
                                                          contentPadding: EdgeInsets.zero,
                                                          leading: SizedBox(
                                                            height: 50.0,
                                                            width: 50.0,
                                                            child: CircleAvatar(
                                                              foregroundColor: Colors.blue,
                                                              backgroundColor: kMainColor,
                                                              radius: 70.0,
                                                              child: ClipOval(
                                                                child: Text(
                                                                  customer[index].customerName.isNotEmpty ? customer[index].customerName.substring(0, 1) : '',
                                                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          title: Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            children: [
                                                              Flexible(
                                                                child: Text(
                                                                  customer[index].customerName.isNotEmpty
                                                                      ? customer[index].customerName
                                                                      : customer[index].phoneNumber,
                                                                  style: kTextStyle.copyWith(color: kTitleColor),
                                                                  maxLines: 1,
                                                                  overflow: TextOverflow.ellipsis,
                                                                ),
                                                              ),
                                                              const SizedBox(width: 10),
                                                              Visibility(
                                                                visible: customer[index].dueAmount != '' && customer[index].dueAmount != '0',
                                                                child: Text(
                                                                  '$currency ${myFormat.format(int.tryParse(customer[index].dueAmount) ?? 0)}',
                                                                  style: GoogleFonts.poppins(
                                                                    color: Colors.black,
                                                                    fontSize: 15.0,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          subtitle: Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            children: [
                                                              Text(
                                                                customer[index].type,
                                                                style: kTextStyle.copyWith(color: color, fontSize: 15.0),
                                                              ),
                                                              Visibility(
                                                                visible: customer[index].dueAmount != '' && customer[index].dueAmount != '0',
                                                                child: Text(
                                                                  lang.S.of(context).due,
                                                                  style: kTextStyle.copyWith(color: const Color(0xFFff5f00), fontSize: 15),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          trailing: const Icon(
                                                            Icons.arrow_forward_ios,
                                                            color: kGreyTextColor,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Divider(
                                                    height: 1,
                                                    thickness: 1.0,
                                                    color: kBorderColor.withOpacity(0.3),
                                                  )
                                                ],
                                              ).visible(customer[index].type == 'Retailer');
                                            }),
                                        ListView.builder(
                                            itemCount: customer.length,
                                            itemBuilder: (_, index) {
                                              customer[index].type == 'Retailer' ? color = const Color(0xFF56da87) : Colors.white;
                                              customer[index].type == 'Wholesaler' ? color = const Color(0xFF25a9e0) : Colors.white;
                                              customer[index].type == 'Dealer' ? color = const Color(0xFFff5f00) : Colors.white;
                                              customer[index].type == 'Supplier' ? color = const Color(0xFFA569BD) : Colors.white;

                                              return Column(
                                                children: [
                                                  GestureDetector(
                                                    onTap: () {
                                                      CustomerDetails(
                                                        customerModel: customer[index],
                                                      ).launch(context);
                                                    },
                                                    child: Column(
                                                      children: [
                                                        ListTile(
                                                          horizontalTitleGap: 10,
                                                          contentPadding: EdgeInsets.zero,
                                                          leading: SizedBox(
                                                            height: 50.0,
                                                            width: 50.0,
                                                            child: CircleAvatar(
                                                              foregroundColor: Colors.blue,
                                                              backgroundColor: kMainColor,
                                                              radius: 70.0,
                                                              child: ClipOval(
                                                                child: Text(
                                                                  customer[index].customerName.isNotEmpty ? customer[index].customerName.substring(0, 1) : '',
                                                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          title: Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            children: [
                                                              Flexible(
                                                                child: Text(
                                                                  customer[index].customerName.isNotEmpty
                                                                      ? customer[index].customerName
                                                                      : customer[index].phoneNumber,
                                                                  style: kTextStyle.copyWith(color: kTitleColor),
                                                                  maxLines: 1,
                                                                  overflow: TextOverflow.ellipsis,
                                                                ),
                                                              ),
                                                              const SizedBox(width: 10),
                                                              Visibility(
                                                                visible: customer[index].dueAmount != '' && customer[index].dueAmount != '0',
                                                                child: Text(
                                                                  '$currency ${myFormat.format(int.tryParse(customer[index].dueAmount) ?? 0)}',
                                                                  style: GoogleFonts.poppins(
                                                                    color: Colors.black,
                                                                    fontSize: 15.0,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          subtitle: Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            children: [
                                                              Text(
                                                                customer[index].type,
                                                                style: kTextStyle.copyWith(color: color, fontSize: 15.0),
                                                              ),
                                                              Visibility(
                                                                visible: customer[index].dueAmount != '' && customer[index].dueAmount != '0',
                                                                child: Text(
                                                                  lang.S.of(context).due,
                                                                  style: kTextStyle.copyWith(color: const Color(0xFFff5f00), fontSize: 15),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          trailing: const Icon(
                                                            Icons.arrow_forward_ios,
                                                            color: kGreyTextColor,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Divider(
                                                    height: 1,
                                                    thickness: 1.0,
                                                    color: kBorderColor.withOpacity(0.3),
                                                  )
                                                ],
                                              ).visible(customer[index].type == 'Supplier');
                                            }),
                                        ListView.builder(
                                            itemCount: customer.length,
                                            itemBuilder: (_, index) {
                                              customer[index].type == 'Retailer' ? color = const Color(0xFF56da87) : Colors.white;
                                              customer[index].type == 'Wholesaler' ? color = const Color(0xFF25a9e0) : Colors.white;
                                              customer[index].type == 'Dealer' ? color = const Color(0xFFff5f00) : Colors.white;
                                              customer[index].type == 'Supplier' ? color = const Color(0xFFA569BD) : Colors.white;

                                              return Column(
                                                children: [
                                                  GestureDetector(
                                                    onTap: () {
                                                      CustomerDetails(
                                                        customerModel: customer[index],
                                                      ).launch(context);
                                                    },
                                                    child: Column(
                                                      children: [
                                                        ListTile(
                                                          horizontalTitleGap: 10,
                                                          contentPadding: EdgeInsets.zero,
                                                          leading: SizedBox(
                                                            height: 50.0,
                                                            width: 50.0,
                                                            child: CircleAvatar(
                                                              foregroundColor: Colors.blue,
                                                              backgroundColor: kMainColor,
                                                              radius: 70.0,
                                                              child: ClipOval(
                                                                child: Text(
                                                                  customer[index].customerName.isNotEmpty ? customer[index].customerName.substring(0, 1) : '',
                                                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          title: Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            children: [
                                                              Flexible(
                                                                child: Text(
                                                                  customer[index].customerName.isNotEmpty
                                                                      ? customer[index].customerName
                                                                      : customer[index].phoneNumber,
                                                                  style: kTextStyle.copyWith(color: kTitleColor),
                                                                  maxLines: 1,
                                                                  overflow: TextOverflow.ellipsis,
                                                                ),
                                                              ),
                                                              const SizedBox(width: 10),
                                                              Visibility(
                                                                visible: customer[index].dueAmount != '' && customer[index].dueAmount != '0',
                                                                child: Text(
                                                                  '$currency ${myFormat.format(int.tryParse(customer[index].dueAmount) ?? 0)}',
                                                                  style: GoogleFonts.poppins(
                                                                    color: Colors.black,
                                                                    fontSize: 15.0,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          subtitle: Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            children: [
                                                              Text(
                                                                customer[index].type,
                                                                style: kTextStyle.copyWith(color: color, fontSize: 15.0),
                                                              ),
                                                              Visibility(
                                                                visible: customer[index].dueAmount != '' && customer[index].dueAmount != '0',
                                                                child: Text(
                                                                  lang.S.of(context).due,
                                                                  style: kTextStyle.copyWith(color: const Color(0xFFff5f00), fontSize: 15),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          trailing: const Icon(
                                                            Icons.arrow_forward_ios,
                                                            color: kGreyTextColor,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Divider(
                                                    height: 1,
                                                    thickness: 1.0,
                                                    color: kBorderColor.withOpacity(0.3),
                                                  )
                                                ],
                                              ).visible(customer[index].type == 'Wholesaler');
                                            }),
                                        ListView.builder(
                                            itemCount: customer.length,
                                            itemBuilder: (_, index) {
                                              customer[index].type == 'Retailer' ? color = const Color(0xFF56da87) : Colors.white;
                                              customer[index].type == 'Wholesaler' ? color = const Color(0xFF25a9e0) : Colors.white;
                                              customer[index].type == 'Dealer' ? color = const Color(0xFFff5f00) : Colors.white;
                                              customer[index].type == 'Supplier' ? color = const Color(0xFFA569BD) : Colors.white;

                                              return Column(
                                                children: [
                                                  GestureDetector(
                                                    onTap: () {
                                                      CustomerDetails(
                                                        customerModel: customer[index],
                                                      ).launch(context);
                                                    },
                                                    child: Column(
                                                      children: [
                                                        ListTile(
                                                          horizontalTitleGap: 10,
                                                          contentPadding: EdgeInsets.zero,
                                                          leading: SizedBox(
                                                            height: 50.0,
                                                            width: 50.0,
                                                            child: CircleAvatar(
                                                              foregroundColor: Colors.blue,
                                                              backgroundColor: kMainColor,
                                                              radius: 70.0,
                                                              child: ClipOval(
                                                                child: Text(
                                                                  customer[index].customerName.isNotEmpty ? customer[index].customerName.substring(0, 1) : '',
                                                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          title: Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            children: [
                                                              Flexible(
                                                                child: Text(
                                                                  customer[index].customerName.isNotEmpty
                                                                      ? customer[index].customerName
                                                                      : customer[index].phoneNumber,
                                                                  style: kTextStyle.copyWith(color: kTitleColor),
                                                                  maxLines: 1,
                                                                  overflow: TextOverflow.ellipsis,
                                                                ),
                                                              ),
                                                              const SizedBox(width: 10),
                                                              Visibility(
                                                                visible: customer[index].dueAmount != '' && customer[index].dueAmount != '0',
                                                                child: Text(
                                                                  '$currency ${myFormat.format(int.tryParse(customer[index].dueAmount) ?? 0)}',
                                                                  style: GoogleFonts.poppins(
                                                                    color: Colors.black,
                                                                    fontSize: 15.0,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          subtitle: Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            children: [
                                                              Text(
                                                                customer[index].type,
                                                                style: kTextStyle.copyWith(color: color, fontSize: 15.0),
                                                              ),
                                                              Visibility(
                                                                visible: customer[index].dueAmount != '' && customer[index].dueAmount != '0',
                                                                child: Text(
                                                                  lang.S.of(context).due,
                                                                  style: kTextStyle.copyWith(color: const Color(0xFFff5f00), fontSize: 15),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          trailing: const Icon(
                                                            Icons.arrow_forward_ios,
                                                            color: kGreyTextColor,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Divider(
                                                    height: 1,
                                                    thickness: 1.0,
                                                    color: kBorderColor.withOpacity(0.3),
                                                  )
                                                ],
                                              ).visible(customer[index].type == 'Dealer');
                                            }),
                                      ],
                                    ),
                                  )
                                : const Padding(
                                    padding: EdgeInsets.only(top: 60),
                                    child: EmptyScreenWidget(),
                                  );
                          },
                          error: (e, stack) {
                            return Text(e.toString());
                          },
                          loading: () {
                            return const Center(child: CircularProgressIndicator());
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: Container(
          color: Colors.white,
          child: ButtonGlobal(
            iconWidget: Icons.add,
            buttontext: lang.S.of(context).addCustomer,
            iconColor: Colors.white,
            buttonDecoration: kButtonDecoration.copyWith(color: kMainColor, borderRadius: const BorderRadius.all(Radius.circular(30))),
            onPressed: () {
              const AddCustomer(
                fromWhere: 'customer_list',
              ).launch(context);
            },
          ),
        ),
      ),
    );
  }
}
