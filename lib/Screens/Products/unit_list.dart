import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_pos/Screens/Products/Model/unit_model.dart';
import 'package:mobile_pos/constant.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import 'package:nb_utils/nb_utils.dart';

import '../../GlobalComponents/button_global.dart';
import '../../currency.dart';
import 'add_units.dart';

// ignore: must_be_immutable
class UnitList extends StatefulWidget {
  const UnitList({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _UnitListState createState() => _UnitListState();
}

class _UnitListState extends State<UnitList> {
  String search = '';
  List<String> unitList = [
    'PIECES (Pcs)',
    'BAGS (Bag)',
    'BOX ( Box )',
    'PACKS (Pac)',
    'PAIRS (Prs)',
    'LITRE (Ltr)',
    'CANS (Can)',
    'ROLLS (Rol)',
    'QUINTAL (Qtl)',
    'CARTONS (Ctn)',
    'DOZENS (Dzn)',
    'MILILITRE (Mr)',
    'BOTTLES (Blt)',
    'BUNDLES (Bdl)',
    'GRAMMES (Gm)',
    'KILOGRAMS (Kg)',
    'NUMBERS (Nos)',
    'TABLETS (Tbs)',
    'SQUARE FEET (Sqf)',
    'SQUARE METERS (Sqm)',
  ];

  Future<List<UnitModel>> getUnits() async {
    DatabaseReference ref = FirebaseDatabase.instance.ref();
    List<UnitModel> list = [];
    final model = await ref.child('$constUserId/Units').get();

    var data = jsonDecode(jsonEncode(model.value));
    if (data == null) {
      return list;
    } else {
      return data;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kMainColor,
      appBar: AppBar(
        title: Text(
          lang.S.of(context).units,
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
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      flex: 3,
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
                            search = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 10.0),
                    Expanded(
                      flex: 1,
                      child: GestureDetector(
                        onTap: () {
                          const AddUnits().launch(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                          height: 60.0,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5.0),
                            border: Border.all(color: kGreyTextColor),
                          ),
                          child: const Icon(
                            Icons.add,
                            color: kGreyTextColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SingleChildScrollView(
                  child: FirebaseAnimatedList(
                    controller: ScrollController(keepScrollOffset: false),
                    defaultChild: Padding(
                      padding: const EdgeInsets.only(top: 30.0, bottom: 30.0),
                      child: Loader(
                        color: Colors.white.withOpacity(0.2),
                        size: 60,
                      ),
                    ),
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    query:
                        // ignore: deprecated_member_use
                        FirebaseDatabase.instance.reference().child(constUserId).child('Units'),
                    itemBuilder: (context, snapshot, animation, index) {
                      final json = snapshot.value as Map<dynamic, dynamic>;
                      final title = UnitModel.fromJson(json);
                      return title.unitName.contains(search)
                          ? Padding(
                              padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      title.unitName,
                                      style: GoogleFonts.poppins(
                                        fontSize: 18.0,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: ButtonGlobalWithoutIcon(
                                      buttontext: lang.S.of(context).select,
                                      buttonDecoration: kButtonDecoration.copyWith(color: kMainColor,borderRadius: BorderRadius.circular(50.0)),
                                      onPressed: () {
                                        Navigator.pop(context, title.unitName.toString());
                                        // AddProduct(
                                        //   unitsName: title.unitName,
                                        // ).launch(context);
                                      },
                                      buttonTextColor: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Container();
                    },
                  ),
                ),
                ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: unitList.length,
                    itemBuilder: (_, index) {
                      return Padding(
                        padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Text(
                                unitList[index],
                                style: GoogleFonts.poppins(
                                  fontSize: 18.0,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: ButtonGlobalWithoutIcon(
                                buttontext: 'Select',
                                buttonDecoration: kButtonDecoration.copyWith(color: kMainColor,borderRadius: BorderRadius.circular(50.0)),
                                onPressed: () {
                                  Navigator.pop(context, unitList[index]);
                                  // AddProduct(
                                  //   unitsName: title.unitName,
                                  // ).launch(context);
                                },
                                buttonTextColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      );
                    })
              ],
            ),
          ),
        ),
      ),
    );
  }
}
