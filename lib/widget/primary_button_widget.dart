import 'package:flutter/material.dart';
import 'package:mobile_pos/constant.dart';


class PrimaryButton extends StatelessWidget {
  final String label;
  final bool isDisabled;
  final bool selected;
  final VoidCallback onPressed;

  PrimaryButton({required this.label, required this.isDisabled, required this.onPressed,this.selected = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ButtonStyle(
                backgroundColor: selected ?  MaterialStateProperty.all<Color>(kMainColor): MaterialStateProperty.all<Color>(Colors.black12),
                shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(5))),
              ),
              child: Text(
                label,
                style: TextStyle(fontSize: 20,color: Colors.white ),
              ),
              onPressed: isDisabled ? null : onPressed,
            ),
          ),
        ],
      ),
    );
  }
}
