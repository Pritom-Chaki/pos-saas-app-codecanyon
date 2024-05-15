import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_pos/constant.dart';
import 'package:nb_utils/nb_utils.dart';

import '../Customers/Model/customer_model.dart';
import 'ledger_customer_details_screen.dart';

class RetailerLedgerScreen extends StatefulWidget {
  const RetailerLedgerScreen({super.key, required this.retailers, required this.type});

  final List<CustomerModel> retailers;
  final String type;

  @override
  State<RetailerLedgerScreen> createState() => _RetailerLedgerScreenState();
}

class _RetailerLedgerScreenState extends State<RetailerLedgerScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kMainColor,
      appBar: AppBar(
        title: Text(
          widget.type,
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
      body: Column(children: [
        ListView.builder(
          shrinkWrap: true,
          itemCount: widget.retailers.length,
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
              onTap: () {
                LedgerCustomerDetailsScreen(
                  customerModel: widget.retailers[index],
                ).launch(context);
              },
              leading: Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  image: DecorationImage(image: NetworkImage(widget.retailers[index].profilePicture)),
                  borderRadius: const BorderRadius.all(Radius.circular(50)),
                ),
              ),
              title: Text(widget.retailers[index].customerName),
              trailing: const Icon(Icons.arrow_forward_ios_sharp),
            );
          },
        )
      ]),
    );
  }
}
