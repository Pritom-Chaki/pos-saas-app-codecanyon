import 'package:flutter/material.dart';
import 'package:mobile_pos/constant.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;

class PrivacyPolicy extends StatefulWidget {
  const PrivacyPolicy({super.key});

  @override
  State<PrivacyPolicy> createState() => _PrivacyPolicyState();
}

class _PrivacyPolicyState extends State<PrivacyPolicy> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kMainColor,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: kWhite),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        title: Text(lang.S.of(context).privacyPolicy,style: kTextStyle.copyWith(fontWeight: FontWeight.bold),),
      ),
      body: Container(
        decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(30),
                topLeft: Radius.circular(30)
            ),
            color: kWhite
        ),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10,),
              Text(lang.S.of(context).howWeUseYourInformation,style: kTextStyle.copyWith(fontWeight: FontWeight.bold,color: kTitleColor),),
              const SizedBox(height: 10,),
              Text(lang.S.of(context).weUseYourPersonalInformation,style: kTextStyle.copyWith(color: kGreyTextColor),),
              const SizedBox(height: 12,),
              const SizedBox(height: 10,),
              Text(lang.S.of(context).howWeProtectYourInformation,style: kTextStyle.copyWith(fontWeight: FontWeight.bold,color: kTitleColor),),
              const SizedBox(height: 10,),
              Text(lang.S.of(context).weTakeIndustryStandard,style: kTextStyle.copyWith(color: kGreyTextColor),),
              const SizedBox(height: 12,),
              const SizedBox(height: 10,),
              Text(lang.S.of(context).thirdPartyServices,style: kTextStyle.copyWith(fontWeight: FontWeight.bold,color: kTitleColor),),
              const SizedBox(height: 10,),
              Text(lang.S.of(context).weMayUseThirdPartyServicesToSupport,style: kTextStyle.copyWith(color: kGreyTextColor),),
              const SizedBox(height: 12,),
            ],
          ),
        ),
      ),
    );
  }
}
