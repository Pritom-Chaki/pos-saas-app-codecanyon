import 'package:flutter/material.dart';
import 'package:mobile_pos/constant.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
class TermOfUse extends StatefulWidget {
  const TermOfUse({super.key});

  @override
  State<TermOfUse> createState() => _TermOfUseState();
}

class _TermOfUseState extends State<TermOfUse> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kMainColor,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: kWhite),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        title: Text(lang.S.of(context).termsOfUse,style: kTextStyle.copyWith(fontWeight: FontWeight.bold),),
      ),
      body: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(30),
            topLeft: Radius.circular(30)
          ),
          color: kWhite
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10,),
                Text(lang.S.of(context).acceptanceOfTerms,style: kTextStyle.copyWith(fontWeight: FontWeight.bold,color: kTitleColor),),
                const SizedBox(height: 10,),
                Text(lang.S.of(context).byAccessingOrUsingThePointOfSales,style: kTextStyle.copyWith(color: kGreyTextColor),),
                const SizedBox(height: 12,),
                Text(lang.S.of(context).useOfTheSystem,style: kTextStyle.copyWith(color: kTitleColor,fontWeight: FontWeight.bold),),
                const SizedBox(height: 10,),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Container(height: 6,width: 6,decoration: const BoxDecoration(shape: BoxShape.circle,color: kTitleColor),),
                    ),
                    const SizedBox(width: 10,),
                    Text(lang.S.of(context).aTheSystemIsProvided,style: kTextStyle.copyWith(color: kGreyTextColor),)
                  ],
                ),
                const SizedBox(height: 10,),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Container(height: 6,width: 6,decoration: const BoxDecoration(shape: BoxShape.circle,color: kTitleColor),),
                    ),
                    const SizedBox(width: 10,),
                    Text(lang.S.of(context).bYouMustBeAtLeastYearsOld,style: kTextStyle.copyWith(color: kGreyTextColor),)
                  ],
                ),
                const SizedBox(height: 10,),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Container(height: 6,width: 6,decoration: const BoxDecoration(shape: BoxShape.circle,color: kTitleColor),),
                    ),
                    const SizedBox(width: 10,),
                    Text(lang.S.of(context).cYouHaveResponsiveForEnsuring,style: kTextStyle.copyWith(color: kGreyTextColor),)
                  ],
                ),
                const SizedBox(height: 12,),
                Text(lang.S.of(context).accountRegistration,style: kTextStyle.copyWith(fontWeight: FontWeight.bold,color: kTitleColor),),
                const SizedBox(height: 10,),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Container(height: 6,width: 6,decoration: const BoxDecoration(shape: BoxShape.circle,color: kTitleColor),),
                    ),
                    const SizedBox(width: 12,),
                    Text(lang.S.of(context).aToUseTheSystem,style: kTextStyle.copyWith(color: kGreyTextColor),)
                  ],
                ),
                const SizedBox(height: 8,),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Container(height: 6,width: 6,decoration: const BoxDecoration(shape: BoxShape.circle,color: kTitleColor),),
                    ),
                    const SizedBox(width: 12,),
                    Text(lang.S.of(context).bYouHaveResponsiveFor,style: kTextStyle.copyWith(color: kGreyTextColor),)
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
