import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_pos/Screens/Customers/add_customer.dart';
import 'package:mobile_pos/Screens/Purchase/add_purchase.dart';
import 'package:mobile_pos/const_commas.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import 'package:nb_utils/nb_utils.dart';

import '../../Provider/add_to_cart_purchase.dart';
import '../../Provider/customer_provider.dart';
import '../../constant.dart';
import '../../currency.dart';
import '../../empty_screen_widget.dart';

class PurchaseContacts extends StatefulWidget {
  const PurchaseContacts({super.key});

  @override
  State<PurchaseContacts> createState() => _PurchaseContactsState();
}

class _PurchaseContactsState extends State<PurchaseContacts> {
  Color color = Colors.black26;
  String searchCustomer = '';
  int counter = 0;
  bool hasAnyDur = false;

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, __) {
      final providerData = ref.watch(customerProvider);
      final cart = ref.watch(cartNotifierPurchase);
      return Scaffold(
        backgroundColor: kMainColor,
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          backgroundColor: kMainColor,
          title: Text(
            lang.S.of(context).choseASupplier,
            style: GoogleFonts.poppins(
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white),
          elevation: 0.0,
        ),
        body: Container(
          alignment: Alignment.topCenter,
          decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(topRight: Radius.circular(30), topLeft: Radius.circular(30))),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: providerData.when(data: (customer) {
                for (var element in customer) {
                  if (element.type == 'Supplier') {
                    hasAnyDur = true;
                    break;
                  }
                }
                return hasAnyDur
                    ? Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: AppTextField(
                              textFieldType: TextFieldType.NAME,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: 'Search',
                                prefixIcon: Icon(
                                  Icons.search,
                                ),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  searchCustomer = value;
                                });
                              },
                            ),
                          ),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: customer.length,
                            itemBuilder: (_, index) {
                              customer[index].type == 'Supplier' ? color = const Color(0xFFA569BD) : Colors.white;
                              customer[index].type == 'Supplier' ? counter++ : null;
                              return customer[index].customerName.contains(searchCustomer) && customer[index].type.contains('Supplier')
                                  ? GestureDetector(
                                      onTap: () {
                                        AddPurchaseScreen(customerModel: customer[index]).launch(context);
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
                                            horizontalTitleGap: 10.0,
                                            contentPadding: const EdgeInsets.only(left: 8,right: 8.0),
                                          )
                                        ],
                                      ),
                                    )
                                  : Container();
                            },
                          ),
                        ],
                      )
                    : const Padding(
                        padding: EdgeInsets.only(top: 60),
                        child: EmptyScreenWidget(),
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
                fromWhere: "purchase",
              ).launch(context);
            }),
      );
    });
  }
}
