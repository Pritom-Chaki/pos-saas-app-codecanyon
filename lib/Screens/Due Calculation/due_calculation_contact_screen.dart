import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_pos/Screens/Due%20Calculation/due_collection_screen.dart';
import 'package:mobile_pos/const_commas.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import 'package:nb_utils/nb_utils.dart';

import '../../Provider/customer_provider.dart';
import '../../constant.dart';
import '../../currency.dart';
import '../../empty_screen_widget.dart';

class DueCalculationContactScreen extends StatefulWidget {
  const DueCalculationContactScreen({super.key});

  @override
  State<DueCalculationContactScreen> createState() => _DueCalculationContactScreenState();
}

class _DueCalculationContactScreenState extends State<DueCalculationContactScreen> {
  late Color color;
  bool hasAnyDur = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kMainColor,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: kMainColor,
        title: Text(
          lang.S.of(context).dueList,
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
            child: Consumer(builder: (context, ref, __) {
              final providerData = ref.watch(customerProvider);

              return providerData.when(data: (customer) {
                for (var element in customer) {
                  if (element.dueAmount.toInt() > 0) {
                    hasAnyDur = true;
                    break;
                  }
                }
                return hasAnyDur
                    ? ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: customer.length,
                        itemBuilder: (_, index) {
                          customer[index].type == 'Retailer' ? color = const Color(0xFF56da87) : Colors.white;
                          customer[index].type == 'Wholesaler' ? color = const Color(0xFF25a9e0) : Colors.white;
                          customer[index].type == 'Dealer' ? color = const Color(0xFFff5f00) : Colors.white;
                          customer[index].type == 'Supplier' ? color = const Color(0xFFA569BD) : Colors.white;

                          return customer[index].dueAmount.toInt() > 0
                              ? GestureDetector(
                                  onTap: () {
                                    DueCollectionScreen(customerModel: customer[index]).launch(context);
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
                                            radius: 50.0,
                                            child: Text(customer[index].customerName.isNotEmpty ? customer[index].customerName.substring(0,1) : '',style: const TextStyle(color: Colors.white),),
                                          ),
                                        ),
                                        title:  Row(
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
                                            Visibility(
                                              visible: customer[index].dueAmount != '' && customer[index].dueAmount != '0',
                                              child: Text(
                                                '$currency ${myFormat.format(int.tryParse(customer[index].dueAmount)??0)}',
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
                                        contentPadding: const EdgeInsets.only(left: 8.0,right: 8.0),
                                      ),
                                      Divider(
                                        height: 1,
                                        thickness: 1.0,
                                        color: kBorderColor.withOpacity(0.3),
                                      )
                                    ],
                                  ),
                                )
                              : Container();
                        })
                    : const Center(
                        child: Padding(
                        padding: EdgeInsets.only(top: 60),
                        child: EmptyScreenWidget(),
                      ));
              }, error: (e, stack) {
                return Text(e.toString());
              }, loading: () {
                return const Center(child: CircularProgressIndicator());
              });
            }),
          ),
        ),
      ),
    );
  }
}
