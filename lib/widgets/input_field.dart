import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InputField extends StatelessWidget {
  const InputField(
      {super.key,
      required this.labelText,
      required this.hintText,
      required this.icon,
      required this.keyboardType,
      required this.controller,
      this.validator,
      this.inputFormatter});

  final String labelText;
  final String hintText;
  final Icon icon;
  final TextInputType keyboardType;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatter;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        inputFormatters: inputFormatter,
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
            borderSide: BorderSide(color: Colors.green),
          ),
          labelText: labelText,
          hintText: hintText,
          prefixIcon: icon,
        ),
        validator: validator,
      ),
    );
  }
}
