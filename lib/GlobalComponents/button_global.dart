import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';

// ignore: must_be_immutable
class ButtonGlobal extends StatelessWidget {
  // ignore: prefer_typing_uninitialized_variables
  var iconWidget;
  final String buttontext;
  final Color iconColor;
  final Decoration buttonDecoration;
  // ignore: prefer_typing_uninitialized_variables
  var onPressed;

  // ignore: use_key_in_widget_constructors
  ButtonGlobal({required this.iconWidget, required this.buttontext, required this.iconColor, required this.buttonDecoration, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
        decoration: buttonDecoration,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              buttontext,
              style: GoogleFonts.jost(fontSize: 20.0, color: Colors.white),
            ),
            Icon(
              iconWidget,
              color: iconColor,
            ).visible(false),
          ],
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class ButtonGlobalWithoutIcon extends StatelessWidget {
  final String buttontext;
  final Decoration buttonDecoration;
  // ignore: prefer_typing_uninitialized_variables
  var onPressed;
  final Color buttonTextColor;

  // ignore: use_key_in_widget_constructors
  ButtonGlobalWithoutIcon({required this.buttontext, required this.buttonDecoration, required this.onPressed, required this.buttonTextColor});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(8.0),
        decoration: buttonDecoration,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              buttontext,
              style: GoogleFonts.jost(fontSize: 14.0, color: buttonTextColor),
            ),
          ],
        ),
      ),
    );
  }
}
