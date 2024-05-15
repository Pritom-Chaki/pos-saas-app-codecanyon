import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class CustomTextInputFormatter extends TextInputFormatter {
  final NumberFormat _numberFormat = NumberFormat.decimalPattern();

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String newText = _numberFormat.format(int.parse(newValue.text.replaceAll(',', ''))); // Remove any dots added by the formatter
    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
