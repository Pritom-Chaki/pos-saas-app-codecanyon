import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_pos/Provider/add_to_cart.dart';
import 'package:mobile_pos/Screens/Customers/Model/customer_model.dart';
import 'package:mobile_pos/Screens/Customers/add_customer.dart';
import 'package:mobile_pos/Screens/Sales/add_sales.dart';
import 'package:mobile_pos/const_commas.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import 'package:nb_utils/nb_utils.dart';

import '../../Provider/customer_provider.dart';
import '../../constant.dart';
import '../../currency.dart';

class SalesContact extends StatefulWidget {
  const SalesContact({super.key, required this.isFromHome});
  final bool isFromHome;

  @override
  // ignore: library_private_types_in_public_api
  _SalesContactState createState() => _SalesContactState();
}

class _SalesContactState extends State<SalesContact> {
  Color color = Colors.black26;
  String searchCustomer = '';

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, __) {
      final providerData = ref.watch(customerProvider);
      final cart = ref.watch(cartNotifier);
      return Scaffold(
        backgroundColor: kMainColor,
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          backgroundColor: kMainColor,
          title: Text(
            lang.S.of(context).choseACustomer,
            style: GoogleFonts.poppins(
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white),
          elevation: 0.0,
          automaticallyImplyLeading: widget.isFromHome ? false : true,
        ),
        body: Container(
          alignment: Alignment.topCenter,
          decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(topRight: Radius.circular(30), topLeft: Radius.circular(30))),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: providerData.when(data: (customer) {
                return customer.isNotEmpty
                    ? Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: AppTextField(
                              textFieldType: TextFieldType.NAME,
                              decoration: InputDecoration(
                                border: const OutlineInputBorder(),
                                hintText: lang.S.of(context).search,
                                prefixIcon: Icon(
                                  Icons.search,
                                  color: kGreyTextColor.withOpacity(0.5),
                                ),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  searchCustomer = value;
                                });
                              },
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              CustomerModel guestModel = CustomerModel(
                                'Guest',
                                'Guest',
                                'Guest',
                                'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460__340.png',
                                'Guest',
                                'Guest',
                                '0',
                                '0',
                                '',
                                '',
                              gst:   '',
                              );
                              AddSalesScreen(customerModel: guestModel).launch(context);
                              cart.clearCart();
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      const SizedBox(
                                        height: 50.0,
                                        width: 50.0,
                                        child: CircleAvatar(
                                          foregroundColor: Colors.blue,
                                          backgroundColor: kMainColor,
                                          radius: 70.0,
                                          child: Text(
                                            'G',
                                            style: TextStyle(color: Colors.white),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10.0),
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            lang.S.of(context).walkInCustomer,
                                            style: GoogleFonts.poppins(
                                              color: Colors.black,
                                              fontSize: 15.0,
                                            ),
                                          ),
                                          Text(
                                            lang.S.of(context).guest,
                                            style: GoogleFonts.poppins(
                                              color: Colors.grey,
                                              fontSize: 15.0,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Spacer(),
                                      const SizedBox(width: 20),
                                      const Icon(
                                        Icons.arrow_forward_ios,
                                        color: kGreyTextColor,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0,right: 10.0),
                            child: Divider(
                              height: 1,
                              thickness: 1.0,
                              color: kBorderColor.withOpacity(0.3),
                            ),
                          ),
                          ListView.builder(
                            padding: const EdgeInsets.only(left: 8.0,right: 10.0),
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: customer.length,
                              itemBuilder: (_, index) {
                                customer[index].type == 'Retailer' ? color = const Color(0xFF56da87) : Colors.white;
                                customer[index].type == 'Wholesaler' ? color = const Color(0xFF25a9e0) : Colors.white;
                                customer[index].type == 'Dealer' ? color = const Color(0xFFff5f00) : Colors.white;
                                customer[index].type == 'Supplier' ? color = const Color(0xFFA569BD) : Colors.white;
                                return customer[index].customerName.contains(searchCustomer) && !customer[index].type.contains('Supplier')
                                    ? Column(
                                      children: [
                                        GestureDetector(
                                            onTap: () {
                                              AddSalesScreen(customerModel: customer[index]).launch(context);
                                              cart.clearCart();
                                            },
                                            child: Column(
                                              children: [
                                                ListTile(
                                                  leading: SizedBox(
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
                                                  title: Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Flexible(
                                                        child: Text(
                                                          customer[index].customerName.isNotEmpty ? customer[index].customerName : customer[index].phoneNumber,
                                                          style: GoogleFonts.poppins(
                                                            color: Colors.black,
                                                            fontSize: 15.0,

                                                          ),
                                                          maxLines: 1,
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 10.0),
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
                                                        style: GoogleFonts.poppins(
                                                          color: color,
                                                          fontSize: 15.0,
                                                        ),
                                                      ),
                                                      Visibility(
                                                        visible: customer[index].dueAmount != '' && customer[index].dueAmount != '0',
                                                        child: Text(
                                                          lang.S.of(context).due,
                                                          style: GoogleFonts.poppins(
                                                            color: const Color(0xFFff5f00),
                                                            fontSize: 15.0,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  trailing: const Icon(
                                                    Icons.arrow_forward_ios,
                                                    color: kGreyTextColor,
                                                  ),
                                                  contentPadding: EdgeInsets.zero,
                                                  horizontalTitleGap: 10,
                                                )
                                              ],
                                            ),
                                          ),
                                        Divider(
                                          height: 1,
                                          thickness: 1.0,
                                          color: kBorderColor.withOpacity(0.3),
                                        )
                                      ],
                                    )
                                    : Container();
                              }),
                        ],
                      )
                    : GestureDetector(
                        onTap: () {
                          CustomerModel guestModel = CustomerModel(
                            'Guest',
                            'Guest',
                            'Guest',
                            'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460__340.png',
                            'Guest',
                            'Guest',
                            '0',
                            '0',
                            '',
                            '',
                            gst: '',
                          );
                          AddSalesScreen(customerModel: guestModel).launch(context);
                          cart.clearCart();
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              const SizedBox(
                                height: 50.0,
                                width: 50.0,
                                child: CircleAvatar(
                                  foregroundColor: Colors.blue,
                                  backgroundColor: kMainColor,
                                  radius: 70.0,
                                  child: Text(
                                    'G',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10.0),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    lang.S.of(context).walkInCustomer,
                                    style: GoogleFonts.poppins(
                                      color: Colors.black,
                                      fontSize: 15.0,
                                    ),
                                  ),
                                  Text(
                                    lang.S.of(context).guest,
                                    style: GoogleFonts.poppins(
                                      color: Colors.grey,
                                      fontSize: 15.0,
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              const SizedBox(width: 20),
                              const Icon(
                                Icons.arrow_forward_ios,
                                color: kGreyTextColor,
                              ),
                            ],
                          ),
                        ),
                      );
              }, error: (e, stack) {
                return Text(e.toString());
              }, loading: () {
                return const Center(child: CircularProgressIndicator());
              }),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
            child: const Icon(Icons.add),
            onPressed: () {
              const AddCustomer(
                fromWhere: 'sales',
              ).launch(context);
            }),
      );
    });
  }
}
