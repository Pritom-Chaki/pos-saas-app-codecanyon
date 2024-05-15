import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_pos/GlobalComponents/Model/category_model.dart';
import 'package:mobile_pos/GlobalComponents/button_global.dart';
import 'package:mobile_pos/Provider/category,brans,units_provide.dart';
import 'package:mobile_pos/constant.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import 'package:nb_utils/nb_utils.dart';

import '../../currency.dart';

class AddCategory extends StatefulWidget {
  const AddCategory({super.key});

  @override
  _AddCategoryState createState() => _AddCategoryState();
}

class _AddCategoryState extends State<AddCategory> {
  bool showProgress = false;
  late String categoryName;
  bool sizeCheckbox = false;
  bool colorCheckbox = false;
  bool weightCheckbox = false;
  bool capacityCheckbox = false;
  bool typeCheckbox = false;

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, __) {
      final allCategory = ref.watch(categoryProvider);
      return Scaffold(
        backgroundColor: kMainColor,
        appBar: AppBar(
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Image(
                image: AssetImage('images/x.png'),
              )),
          title: Text(
            lang.S.of(context).addCategory,
            style: GoogleFonts.poppins(
              color: Colors.white,
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
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Visibility(
                    visible: showProgress,
                    child: const CircularProgressIndicator(
                      color: kMainColor,
                      strokeWidth: 5.0,
                    ),
                  ),
                  AppTextField(
                    textFieldType: TextFieldType.NAME,
                    onChanged: (value) {
                      setState(() {
                        categoryName = value;
                      });
                    },
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      hintText: lang.S.of(context).enterCategoryName,
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      labelText: lang.S.of(context).cateogryName,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(lang.S.of(context).selectvariations),
                  Row(
                    children: [
                      Expanded(
                        child: CheckboxListTile(
                          title: Text(
                            lang.S.of(context).size,
                            overflow: TextOverflow.ellipsis,
                          ),
                          value: sizeCheckbox,
                          checkboxShape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(50))),
                          onChanged: (newValue) {
                            setState(() {
                              sizeCheckbox = newValue!;
                            });
                          },
                          controlAffinity: ListTileControlAffinity.leading, //  <-- leading Checkbox
                        ),
                      ),
                      Expanded(
                        child: CheckboxListTile(
                          title: Text(
                            lang.S.of(context).color,
                            overflow: TextOverflow.ellipsis,
                          ),
                          value: colorCheckbox,
                          checkboxShape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(50))),
                          onChanged: (newValue) {
                            setState(() {
                              colorCheckbox = newValue!;
                            });
                          },
                          controlAffinity: ListTileControlAffinity.leading, //  <-- leading Checkbox
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: CheckboxListTile(
                          title: Text(
                            lang.S.of(context).weight,
                            overflow: TextOverflow.ellipsis,
                          ),
                          checkboxShape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(50))),
                          value: weightCheckbox,
                          onChanged: (newValue) {
                            setState(() {
                              weightCheckbox = newValue!;
                            });
                          },
                          controlAffinity: ListTileControlAffinity.leading, //  <-- leading Checkbox
                        ),
                      ),
                      Expanded(
                        child: CheckboxListTile(
                          title: Text(
                            lang.S.of(context).capacity,
                            overflow: TextOverflow.ellipsis,
                          ),
                          checkboxShape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(50))),
                          value: capacityCheckbox,
                          onChanged: (newValue) {
                            setState(() {
                              capacityCheckbox = newValue!;
                            });
                          },
                          controlAffinity: ListTileControlAffinity.leading, //  <-- leading Checkbox
                        ),
                      ),
                    ],
                  ),
                  CheckboxListTile(
                    title: Text(
                      lang.S.of(context).type,
                      overflow: TextOverflow.ellipsis,
                    ),
                    checkboxShape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(50))),
                    value: typeCheckbox,
                    onChanged: (newValue) {
                      setState(() {
                        typeCheckbox = newValue!;
                      });
                    },
                    controlAffinity: ListTileControlAffinity.leading, //  <-- leading Checkbox
                  ),
                  ButtonGlobalWithoutIcon(
                    buttontext: lang.S.of(context).save,
                    buttonDecoration: kButtonDecoration.copyWith(color: kMainColor),
                    onPressed: () async {
                      bool isAlreadyAdded = false;
                      allCategory.value?.forEach((element) {
                        if (element.categoryName.toLowerCase().removeAllWhiteSpace().contains(
                              categoryName.toLowerCase().removeAllWhiteSpace(),
                            )) {
                          isAlreadyAdded = true;
                        }
                      });
                      setState(() {
                        showProgress = true;
                      });
                      // ignore: no_leading_underscores_for_local_identifiers
                      final DatabaseReference _categoryInformationRef = FirebaseDatabase.instance.ref().child(constUserId).child('Categories');
                      _categoryInformationRef.keepSynced(true);
                      CategoryModel categoryModel = CategoryModel(
                        categoryName: categoryName,
                        size: sizeCheckbox,
                        color: colorCheckbox,
                        capacity: capacityCheckbox,
                        type: typeCheckbox,
                        weight: weightCheckbox,
                        warranty: false,
                      );
                      isAlreadyAdded ? EasyLoading.showError('Already Added') : _categoryInformationRef.push().set(categoryModel.toJson());
                      setState(() {
                        showProgress = false;
                        isAlreadyAdded ? null : ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Data Saved Successfully")));
                      });

                      // ignore: use_build_context_synchronously
                      isAlreadyAdded ? null : Navigator.pop(context);
                    },
                    buttonTextColor: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
