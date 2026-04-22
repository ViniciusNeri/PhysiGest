import 'package:flutter/services.dart';

class PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.length > 15) return oldValue;

    var text = newValue.text.replaceAll(RegExp(r'\D'), '');
    var formattedText = StringBuffer();
    if (text.isNotEmpty) {
      formattedText.write('(');
      if (text.length > 2) {
        formattedText.write('${text.substring(0, 2)}) ');
        if (text.length > 7) {
          formattedText.write('${text.substring(2, 7)}-${text.substring(7)}');
        } else {
          formattedText.write(text.substring(2));
        }
      } else {
        formattedText.write(text);
      }
    }

    return TextEditingValue(
      text: formattedText.toString(),
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}

class DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.length > 10) return oldValue;

    var text = newValue.text.replaceAll(RegExp(r'\D'), '');
    var formattedText = StringBuffer();
    if (text.isNotEmpty) {
      if (text.length > 2) {
        formattedText.write('${text.substring(0, 2)}/');
        if (text.length > 4) {
          formattedText.write('${text.substring(2, 4)}/${text.substring(4)}');
        } else {
          formattedText.write(text.substring(2));
        }
      } else {
        formattedText.write(text);
      }
    }

    return TextEditingValue(
      text: formattedText.toString(),
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}

/// Sanitiza o telefone (mantém apenas dígitos) e adiciona o prefixo "55" (Brasil)
String formatPhoneForApi(String phone) {
  final cleanPhone = phone.replaceAll(RegExp(r'\D'), '');
  if (cleanPhone.isEmpty) return '';
  
  // Se já começar com 55, não adiciona novamente
  if (cleanPhone.startsWith('55') && cleanPhone.length >= 12) {
    return cleanPhone;
  }
  
  return '55$cleanPhone';
}
