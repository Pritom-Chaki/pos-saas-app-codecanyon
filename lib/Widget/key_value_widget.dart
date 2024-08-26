import 'package:flutter/material.dart';

import '../constant.dart';


class KeyValueWidget extends StatelessWidget {
  const KeyValueWidget({super.key,required this.keys, required this.value,this.textColor,});
  final String keys;
  final String value;
  final Color ? textColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
            flex: 3,
            child: Text(keys,style: kTextStyle.copyWith(color: kGreyTextColor,fontSize: 16),)),
        const Expanded(
          flex: 0,
          child: Row(
            children: [
              Text(':'),
              SizedBox(width: 10,)
            ],
          ),),
        Expanded(
            flex: 5,
            child: Text(value,style: kTextStyle.copyWith(color: textColor??kTitleColor,fontSize: 16),))
      ],
    );
  }
}