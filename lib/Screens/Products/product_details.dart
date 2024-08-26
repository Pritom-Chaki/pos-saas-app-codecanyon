import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconly/iconly.dart';
import 'package:mobile_pos/Screens/Products/update_product.dart';
import 'package:mobile_pos/currency.dart';
import 'package:mobile_pos/model/product_model.dart';
import '../../constant.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import '../tax report/tax_model.dart';

class ProductDetails extends StatefulWidget {
  const ProductDetails({super.key, required this.productModel});
  final ProductModel productModel;
  @override
  State<ProductDetails> createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails> {
  late String productKey;

  void getProductKey(String productCode) async {
    final ref = FirebaseDatabase.instance.ref(constUserId).child('Products');
    ref.keepSynced(true);
    ref.orderByKey().get().then((value) {
      for (var element in value.children) {
        var data = jsonDecode(jsonEncode(element.value));
        if (data['productCode'].toString() == productCode) {
          productKey = element.key.toString();
        }
      }
    });
  }

  @override
  void initState() {
    getProductKey(widget.productModel.productCode);
    super.initState();
  }

  List<String> productCodeList = [];
  List<String> productNameList = [];
  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context,ref,__){
        final groupTax = ref.watch(groupTaxProvider);
        return Scaffold(
          backgroundColor: kMainColor,
          appBar: AppBar(
            backgroundColor: kMainColor,
            title: Text(
              'Product Details',
              style: GoogleFonts.poppins(
                color: Colors.white,
              ),
            ),
            actions: [
              IconButton(
                  onPressed: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>UpdateProduct(productModel: widget.productModel, productNameList: productNameList, productCodeList: productCodeList, groupTaxModel: groupTax.value ?? [])));
                  },
                  icon: Row(
                    children: [
                      const Icon(IconlyBold.edit,color: kWhite,size: 18,),
                      Text('Edit',style: kTextStyle.copyWith(fontSize: 13),)
                    ],
                  ))
            ],
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20,),
                    Center(
                      child: Container(
                        height: 206,
                        width: 236,
                        decoration: BoxDecoration(
                            image: DecorationImage(fit: BoxFit.cover,image: NetworkImage(widget.productModel.productPicture))
                        ),
                      ),
                    ),
                    const SizedBox(height: 20,),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.productModel.productName,style: kTextStyle.copyWith(fontWeight: FontWeight.bold,color: kTitleColor,fontSize: 20),),
                            Text(widget.productModel.productCategory,style: kTextStyle.copyWith(color: kGreyTextColor),),
                          ],
                        ),
                        const Spacer(),
                        Text('$currency ${widget.productModel.productSalePrice}',style: kTextStyle.copyWith(fontSize: 20,fontWeight: FontWeight.bold,color: kTitleColor),)
                      ],
                    ),
                    const SizedBox(height: 20,),
                    Text('Details',style: kTextStyle.copyWith(fontWeight: FontWeight.bold,color: kTitleColor),),
                    const SizedBox(height: 10,),
                    Text(widget.productModel.productDescription,style: kTextStyle.copyWith(color: kGreyTextColor),),
                    const SizedBox(height: 20,),
                    Container(
                      decoration: const BoxDecoration(
                        color: Color(0xffEEF3FF),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Purchase Price',style: kTextStyle.copyWith(color: kTitleColor,fontSize: 16,),),
                                Text('$currency ${widget.productModel.productPurchasePrice}',style: kTextStyle.copyWith(color: kGreyTextColor),),
                                const SizedBox(height: 20,),
                                Text('Wholesale price',style: kTextStyle.copyWith(color: kTitleColor,fontSize: 16),),
                                Text('$currency ${widget.productModel.productWholeSalePrice}',style: kTextStyle.copyWith(color: kGreyTextColor),)
                              ],
                            ),
                            RotatedBox(
                              quarterTurns: 1,
                              child: Container(
                                height: 1,
                                width: 100,
                                color: kBorderColorTextField,
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Stock',style: kTextStyle.copyWith(color: kTitleColor,fontSize: 16,),),
                                Text(widget.productModel.productStock,style: kTextStyle.copyWith(color: kGreyTextColor),),
                                const SizedBox(height: 20,),
                                Text('Dealer price',style: kTextStyle.copyWith(color: kTitleColor,fontSize: 16),),
                                Text('$currency ${widget.productModel.productDealerPrice}',style: kTextStyle.copyWith(color: kGreyTextColor),)
                              ],
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
