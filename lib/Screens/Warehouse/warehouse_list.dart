import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_pos/Screens/Warehouse/warehouse_model.dart';
import 'package:mobile_pos/Screens/Warehouse/wirehouse_details.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../Provider/product_provider.dart';
import '../../const_commas.dart';
import '../../constant.dart';
import '../../currency.dart';
import '../../model/product_model.dart';

class WarehouseList extends StatefulWidget {
  const WarehouseList({super.key});

  @override
  State<WarehouseList> createState() => _WarehouseListState();
}

class _WarehouseListState extends State<WarehouseList> {
  DateTime id = DateTime.now();

  bool checkWarehouse({required List<WareHouseModel> allList, required String category}) {
    for (var element in allList) {
      if (element.id == id.toString()) {
        return false;
      }
    }
    return true;
  }

  void deleteExpenseCategory({required String incomeCategoryName, required WidgetRef updateRef, required BuildContext context}) async {
    EasyLoading.show(status: 'Deleting..');
    String expenseKey = '';
    final userId = await getUserID();
    await FirebaseDatabase.instance.ref(userId).child('Warehouse List').orderByKey().get().then((value) {
      for (var element in value.children) {
        var data = jsonDecode(jsonEncode(element.value));
        if (data['warehouseName'].toString() == incomeCategoryName) {
          expenseKey = element.key.toString();
        }
      }
    });
    DatabaseReference ref = FirebaseDatabase.instance.ref("${await getUserID()}/Warehouse List/$expenseKey");
    await ref.remove();
    updateRef.refresh(warehouseProvider);
    EasyLoading.showSuccess('Done').then(
      (value) => Navigator.pop(context),
    );
  }


  double grandTotal = 0;
  double calculateGrandTotal(List<WareHouseModel> showAbleProducts, List<ProductModel> productSnap) {
    grandTotal = 0;
    for (var index = 0; index < showAbleProducts.length; index++) {
      for (var element in productSnap) {
        if (showAbleProducts[index].id == element.warehouseId) {
          double stockValue = (double.tryParse(element.productStock) ?? 0) * (double.tryParse(element.productSalePrice) ?? 0);
          grandTotal += stockValue;
        }
      }
    }

    return grandTotal;
  }
  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (_, ref, watch) {
        final productList = ref.watch(productProvider);
        final warehouse = ref.watch(warehouseProvider);
        return warehouse.when(data: (snapShot) {
          return productList.when(data: (productSnap) {
            return Scaffold(
              appBar: AppBar(
                elevation: 0.0,
                backgroundColor: Colors.transparent,
                title: const Text(
                  'Warehouse List',
                  style: TextStyle(color: kWhite),
                ),
                iconTheme: const IconThemeData(color: kWhite),
              ),
              backgroundColor: kMainColor,
              body: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Container(
                  height: MediaQuery.of(context).size.height,
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 2.0),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 20.0),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(8.0), color: const Color(0xFFD6FFDF)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                        '$currency ${calculateGrandTotal(snapShot , productSnap,)}',
                              style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold, fontSize: 18.0),
                            ),
                            const SizedBox(height: 4.0),
                            Text(
                              'Total value',
                              style: kTextStyle.copyWith(color: kTitleColor),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      Expanded(
                        child: ListView.builder(
                          shrinkWrap: true,
                          padding: const EdgeInsets.only(bottom: 10, top: 20),
                          itemCount: snapShot.length,
                          itemBuilder: (_, index) {
                            num stockValue = 0;
                            num totalStock = 0;
                            for (var element in productSnap) {
                              if (snapShot[index].id == element.warehouseId) {
                                stockValue += (num.tryParse(element.productStock) ?? 0) * (num.tryParse(element.productSalePrice) ?? 0);
                                totalStock += (num.tryParse(element.productStock) ?? 0);
                              }
                            }
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6.0),
                                  border: Border.all(color: kBorderColorTextField, width: 0.3),
                                ),
                                child: ListTile(
                                  visualDensity: const VisualDensity(vertical: -2),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6.0),
                                  ),
                                  contentPadding: const EdgeInsets.only(left: 10.0, right: 10.0),
                                  horizontalTitleGap: 5,
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => WarehouseDetails(warehouseName: snapShot[index].warehouseName, warehouseID: snapShot[index].id),
                                    ),
                                  ),
                                  leading: Container(
                                    height: 45,
                                    width: 45,
                                    decoration: const BoxDecoration(color: kMainColor, shape: BoxShape.circle),
                                    child: Center(
                                      child: Text(
                                        (index + 1).toString(),
                                        style: kTextStyle.copyWith(color: kWhite, fontWeight: FontWeight.bold, fontSize: 16),
                                      ),
                                    ),
                                  ),
                                  title: Row(
                                    children: [
                                      SizedBox(
                                        width: 180,
                                        child: Text(
                                          snapShot[index].warehouseName,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        'Stock:${totalStock.toString()}',
                                        overflow: TextOverflow.ellipsis,
                                        style: kTextStyle.copyWith(color: kGreyTextColor, fontSize: 14),
                                      ),
                                    ],
                                  ),
                                  subtitle: Row(
                                    children: [
                                      SizedBox(
                                        width: 140,
                                        child: Text(
                                          snapShot[index].warehouseAddress,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: kTextStyle.copyWith(color: kGreyTextColor, fontSize: 14),
                                        ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        'Value: $currency${stockValue.toString()}',
                                        overflow: TextOverflow.ellipsis,
                                        style: kTextStyle.copyWith(color: kGreyTextColor, fontSize: 14),
                                      ),
                                    ],
                                  ),
                                  isThreeLine: false,
                                  trailing: PopupMenuButton(
                                    surfaceTintColor: Colors.white,
                                    padding: EdgeInsets.zero,
                                    itemBuilder: (BuildContext bc) => [
                                      PopupMenuItem(
                                        child: GestureDetector(
                                          onTap: () {
                                            if (snapShot[index].warehouseName == 'InHouse') {
                                              EasyLoading.showInfo("InHouse can't be edited");
                                            } else {
                                              showModalBottomSheet(
                                                isScrollControlled: true,
                                                useSafeArea: false,
                                                showDragHandle: false,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(16.0),
                                                ),
                                                backgroundColor: kWhite,
                                                context: context,
                                                builder: (BuildContext context) {
                                                  return StatefulBuilder(
                                                    builder: (context, setStates) {
                                                      return EditWare(listOfWarehouse: snapShot, warehouseModel: snapShot[index], menuContext: bc);
                                                    },
                                                  );
                                                },
                                              );
                                            }
                                          },
                                          child: Row(
                                            children: [
                                              const Icon(Icons.mode_edit_outline, size: 18.0, color: kTitleColor),
                                              const SizedBox(width: 4.0),
                                              Text(
                                                'Edit',
                                                style: kTextStyle.copyWith(color: kTitleColor),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      PopupMenuItem(
                                        child: GestureDetector(
                                          onTap: () {
                                            if (checkWarehouse(allList: warehouse.value!, category: snapShot[index].warehouseName)) {
                                              snapShot[index].warehouseName == 'InHouse'
                                                  ? EasyLoading.showInfo('InHouse can\'t be delete')
                                                  : showDialog(
                                                      barrierDismissible: false,
                                                      context: context,
                                                      builder: (BuildContext dialogContext) {
                                                        return Padding(
                                                          padding: const EdgeInsets.all(20.0),
                                                          child: Center(
                                                            child: Container(
                                                              decoration: const BoxDecoration(
                                                                color: Colors.white,
                                                                borderRadius: BorderRadius.all(
                                                                  Radius.circular(15),
                                                                ),
                                                              ),
                                                              child: Padding(
                                                                padding: const EdgeInsets.all(20.0),
                                                                child: Column(
                                                                  mainAxisSize: MainAxisSize.min,
                                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                                  children: [
                                                                    Text(
                                                                      'Are you want to delete this warehouse??',
                                                                      style: kTextStyle.copyWith(color: kTitleColor, fontSize: 18.0, fontWeight: FontWeight.bold),
                                                                      textAlign: TextAlign.center,
                                                                    ),
                                                                    const SizedBox(height: 30),
                                                                    Row(
                                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                                      mainAxisSize: MainAxisSize.min,
                                                                      children: [
                                                                        SizedBox(
                                                                          width: 130,
                                                                          child: ElevatedButton(
                                                                            onPressed: () {
                                                                              Navigator.pop(dialogContext);
                                                                              Navigator.pop(bc);
                                                                            },
                                                                            style: ButtonStyle(
                                                                              shape: MaterialStateProperty.all(
                                                                                RoundedRectangleBorder(
                                                                                    borderRadius: BorderRadius.circular(8.0),
                                                                                    side: const BorderSide(color: kMainColor)),
                                                                              ),
                                                                              overlayColor: MaterialStateProperty.all<Color>(
                                                                                kMainColor.withOpacity(0.1),
                                                                              ),
                                                                              shadowColor: MaterialStateProperty.all<Color>(kMainColor.withOpacity(0.1)),
                                                                              minimumSize: MaterialStateProperty.all<Size>(
                                                                                const Size(150, 50),
                                                                              ),
                                                                              backgroundColor: MaterialStateProperty.all<Color>(kWhite),

                                                                              // Change background color
                                                                              textStyle: MaterialStateProperty.all<TextStyle>(
                                                                                  const TextStyle(color: Colors.white)), // Change text color
                                                                              // Add more properties as needed
                                                                            ),
                                                                            child: Text(
                                                                              'Cancel',
                                                                              style:
                                                                                  kTextStyle.copyWith(color: kMainColor, fontWeight: FontWeight.bold, fontSize: 16),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        const SizedBox(width: 30),
                                                                        SizedBox(
                                                                          width: 130,
                                                                          child: ElevatedButton(
                                                                            onPressed: () {
                                                                              deleteExpenseCategory(
                                                                                incomeCategoryName: snapShot[index].warehouseName,
                                                                                updateRef: ref,
                                                                                context: dialogContext,
                                                                              );
                                                                              Navigator.pop(dialogContext);
                                                                            },
                                                                            style: ButtonStyle(
                                                                              shape: MaterialStateProperty.all(
                                                                                RoundedRectangleBorder(
                                                                                  borderRadius: BorderRadius.circular(8.0),
                                                                                ),
                                                                              ),
                                                                              overlayColor: MaterialStateProperty.all<Color>(
                                                                                kWhite.withOpacity(0.1),
                                                                              ),
                                                                              shadowColor: MaterialStateProperty.all<Color>(kMainColor.withOpacity(0.1)),
                                                                              minimumSize: MaterialStateProperty.all<Size>(Size(150, 50)),
                                                                              backgroundColor: MaterialStateProperty.all<Color>(kMainColor),
                                                                              // Change background color
                                                                              textStyle: MaterialStateProperty.all<TextStyle>(
                                                                                  TextStyle(color: Colors.white)), // Change text color
                                                                              // Add more properties as needed
                                                                            ),
                                                                            child: Text(
                                                                              'Delete',
                                                                              style: kTextStyle.copyWith(color: kWhite, fontWeight: FontWeight.bold, fontSize: 16),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    )
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                      });
                                            } else {
                                              EasyLoading.showError('This category Cannot be deleted');
                                            }
                                          },
                                          child: Row(
                                            children: [
                                              const Icon(Icons.delete, size: 18.0, color: kTitleColor),
                                              const SizedBox(width: 4.0),
                                              Text(
                                                'Delete',
                                                style: kTextStyle.copyWith(color: kTitleColor),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                    onSelected: (value) {
                                      Navigator.pushNamed(context, '$value');
                                    },
                                    child: const Icon(
                                      Icons.more_vert_sharp,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              bottomNavigationBar: Container(
                padding: EdgeInsets.all(20.0),
                color: Colors.white,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      showModalBottomSheet(
                        isScrollControlled: true,
                        useSafeArea: false,
                        showDragHandle: false,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        backgroundColor: kWhite,
                        context: context,
                        builder: (BuildContext context) {
                          return StatefulBuilder(
                            builder: (context, setStates) {
                              return AddWare(listOfWarehouse: snapShot, menuContext: context);
                            },
                          );
                        },
                      );
                    },
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      overlayColor: MaterialStateProperty.all<Color>(
                        kWhite.withOpacity(0.1),
                      ),
                      shadowColor: MaterialStateProperty.all<Color>(kMainColor.withOpacity(0.1)),
                      minimumSize: MaterialStateProperty.all<Size>(Size(150, 50)),
                      backgroundColor: MaterialStateProperty.all<Color>(kMainColor),
                      // Change background color
                      textStyle: MaterialStateProperty.all<TextStyle>(TextStyle(color: Colors.white)), // Change text color
                      // Add more properties as needed
                    ),
                    child: Text(
                      'Add New',
                      style: kTextStyle.copyWith(color: kWhite, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ),
              ),
            );
          }, error: (e, stack) {
            return Center(
              child: Text(e.toString()),
            );
          }, loading: () {
            return const Center(
              child: CircularProgressIndicator(),
            );
          });
        }, error: (e, stack) {
          return Center(
            child: Text(e.toString()),
          );
        }, loading: () {
          return const Center(
            child: CircularProgressIndicator(),
          );
        });
      },
    );
  }
}

//________________________________________________________Edit_warehouse____________
class EditWare extends StatefulWidget {
  const EditWare({super.key, required this.listOfWarehouse, required this.warehouseModel, required this.menuContext});

  final List<WareHouseModel> listOfWarehouse;
  final WareHouseModel warehouseModel;
  final BuildContext menuContext;

  @override
  State<EditWare> createState() => _EditWareState();
}

class _EditWareState extends State<EditWare> {
  String warehouseAddress = '';
  String houseName = '';

  String expenseKey = '';

  void getExpenseKey() async {
    final userId = await getUserID();
    await FirebaseDatabase.instance.ref(userId).child('Warehouse List').orderByKey().get().then((value) {
      for (var element in value.children) {
        var data = jsonDecode(jsonEncode(element.value));
        if (data['warehouseName'].toString() == widget.warehouseModel.warehouseName) {
          expenseKey = element.key.toString();
        }
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    warehouseAddress = widget.warehouseModel.warehouseAddress;
    houseName = widget.warehouseModel.warehouseName;
    getExpenseKey();
  }

  @override
  Widget build(BuildContext context) {
    List<String> names = [];
    for (var element in widget.listOfWarehouse) {
      names.add(element.warehouseName.removeAllWhiteSpace().toLowerCase());
    }
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10.0, right: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Edit Warehouse',
                    style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  IconButton(onPressed: () => Navigator.pop(context), icon: Icon(Icons.clear))
                ],
              ),
            ),
            const Divider(thickness: 1.0, color: kBorderColorTextField),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    initialValue: houseName,
                    onChanged: (value) {
                      houseName = value;
                    },
                    showCursor: true,
                    cursorColor: kTitleColor,
                    decoration: kInputDecoration.copyWith(
                      labelText: 'Category Name',
                      labelStyle: kTextStyle.copyWith(color: kTitleColor),
                      hintText: 'Enter Name',
                      hintStyle: kTextStyle.copyWith(color: kGreyTextColor),
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  TextFormField(
                    initialValue: warehouseAddress,
                    onChanged: (value) {
                      warehouseAddress = value;
                    },
                    showCursor: true,
                    cursorColor: kTitleColor,
                    decoration: kInputDecoration.copyWith(
                      labelText: 'Description',
                      labelStyle: kTextStyle.copyWith(color: kTitleColor),
                      hintText: 'Add Description...',
                      hintStyle: kTextStyle.copyWith(color: kGreyTextColor),
                    ),
                  ),
                  const SizedBox(height: 50.0),
                  Padding(
                    padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 10),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: ElevatedButton(
                        onPressed: () {
                          WareHouseModel warehouse = WareHouseModel(warehouseName: houseName, warehouseAddress: warehouseAddress, id: widget.warehouseModel.id);
                          if (houseName != '' && houseName == widget.warehouseModel.warehouseName
                              ? true
                              : !names.contains(houseName.toLowerCase().removeAllWhiteSpace())) {
                            setState(() async {
                              try {
                                EasyLoading.show(status: 'Loading...', dismissOnTap: false);
                                final DatabaseReference productInformationRef =
                                    FirebaseDatabase.instance.ref().child(await getUserID()).child('Warehouse List').child(expenseKey);
                                await productInformationRef.set(warehouse.toJson());
                                EasyLoading.showSuccess('Edit Successfully', duration: const Duration(milliseconds: 500));

                                ///____provider_refresh____________________________________________
                                ref.refresh(warehouseProvider);

                                Future.delayed(const Duration(milliseconds: 100), () {
                                  Navigator.pop(context);
                                  Navigator.pop(widget.menuContext);
                                });
                              } catch (e) {
                                EasyLoading.dismiss();
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                              }
                            });
                          } else if (names.contains(houseName.toLowerCase().removeAllWhiteSpace())) {
                            EasyLoading.showError('Warehouse  Already Exists');
                          } else {
                            EasyLoading.showError('Name can\'t be empty');
                          }
                        },
                        style: ButtonStyle(
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          overlayColor: MaterialStateProperty.all<Color>(
                            kWhite.withOpacity(0.1),
                          ),
                          shadowColor: MaterialStateProperty.all<Color>(kMainColor.withOpacity(0.1)),
                          minimumSize: MaterialStateProperty.all<Size>(Size(150, 50)),
                          backgroundColor: MaterialStateProperty.all<Color>(kMainColor),
                          // Change background color
                          textStyle: MaterialStateProperty.all<TextStyle>(TextStyle(color: Colors.white)), // Change text color
                          // Add more properties as needed
                        ),
                        child: Text(
                          'Update',
                          style: kTextStyle.copyWith(color: kWhite, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        );
      },
    );
  }
}

//________________________________________________________Add_warehouse____________
class AddWare extends StatefulWidget {
  const AddWare({super.key, required this.listOfWarehouse, required this.menuContext});

  final List<WareHouseModel> listOfWarehouse;
  final BuildContext menuContext;

  @override
  State<AddWare> createState() => _AddWareState();
}

class _AddWareState extends State<AddWare> {
  String warehouseName = '';
  String address = '';
  DateTime id = DateTime.now();

  @override
  Widget build(BuildContext context) {
    List<String> names = [];
    for (var element in widget.listOfWarehouse) {
      names.add(element.warehouseName.removeAllWhiteSpace().toLowerCase());
    }
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10.0, right: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Edit Warehouse',
                    style: kTextStyle.copyWith(color: kTitleColor, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  IconButton(onPressed: () => Navigator.pop(context), icon: Icon(Icons.clear))
                ],
              ),
            ),
            const Divider(thickness: 1.0, color: kBorderColorTextField),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    onChanged: (value) {
                      warehouseName = value;
                    },
                    showCursor: true,
                    cursorColor: kTitleColor,
                    decoration: kInputDecoration.copyWith(
                      labelText: 'Warehouse Name',
                      labelStyle: kTextStyle.copyWith(color: kTitleColor),
                      hintText: 'Enter name',
                      hintStyle: kTextStyle.copyWith(color: kGreyTextColor),
                    ),
                    autofocus: true,
                  ),
                  const SizedBox(height: 20.0),
                  TextFormField(
                    onChanged: (value) {
                      address = value;
                    },
                    showCursor: true,
                    cursorColor: kTitleColor,
                    decoration: kInputDecoration.copyWith(
                      labelText: 'Address',
                      labelStyle: kTextStyle.copyWith(color: kTitleColor),
                      hintText: 'Enter address',
                      hintStyle: kTextStyle.copyWith(color: kGreyTextColor),
                    ),
                  ),
                  const SizedBox(height: 50.0),
                  Padding(
                    padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 10),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (warehouseName != '' && !names.contains(warehouseName.toLowerCase().removeAllWhiteSpace())) {
                            WareHouseModel warehouse = WareHouseModel(warehouseName: warehouseName, warehouseAddress: address, id: id.toString());
                            try {
                              EasyLoading.show(status: 'Loading...', dismissOnTap: false);
                              final DatabaseReference productInformationRef = FirebaseDatabase.instance.ref().child(await getUserID()).child('Warehouse List');
                              await productInformationRef.push().set(warehouse.toJson());
                              EasyLoading.showSuccess('Added Successfully', duration: const Duration(milliseconds: 500));

                              ///____provider_refresh____________________________________________
                              ref.refresh(warehouseProvider);

                              Future.delayed(const Duration(milliseconds: 100), () {
                                Navigator.pop(context);
                              });
                            } catch (e) {
                              EasyLoading.dismiss();
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                            }
                          } else if (names.contains(warehouseName.toLowerCase().removeAllWhiteSpace())) {
                            EasyLoading.showError('Category Name Already Exists');
                          } else {
                            EasyLoading.showError('Enter Warehouse Name');
                          }
                        },
                        style: ButtonStyle(
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          overlayColor: MaterialStateProperty.all<Color>(
                            kWhite.withOpacity(0.1),
                          ),
                          shadowColor: MaterialStateProperty.all<Color>(kMainColor.withOpacity(0.1)),
                          minimumSize: MaterialStateProperty.all<Size>(Size(150, 50)),
                          backgroundColor: MaterialStateProperty.all<Color>(kMainColor),
                          // Change background color
                          textStyle: MaterialStateProperty.all<TextStyle>(TextStyle(color: Colors.white)), // Change text color
                          // Add more properties as needed
                        ),
                        child: Text(
                          'Save',
                          style: kTextStyle.copyWith(color: kWhite, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        );
      },
    );
  }
}
