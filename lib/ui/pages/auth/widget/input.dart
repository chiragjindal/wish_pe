import 'package:flutter/material.dart';
import 'package:wish_pe/ui/theme/theme.dart';

// ignore: must_be_immutable
class Input extends StatelessWidget {
  Input(
      {Key? key,
      required this.hint,
      required this.controller,
      required this.icon,
      this.isPassword = false})
      : super(key: key);

  String hint;
  IconData icon;
  TextEditingController controller;
  bool isPassword;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      obscureText: isPassword,
      decoration: InputDecoration(
          labelText: hint,
          labelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
          ),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(26),
              borderSide: BorderSide(color: ColorConstants.starterWhite)),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: ColorConstants.primaryColor),
            borderRadius: const BorderRadius.all(Radius.circular(26)),
          ),
          suffixIcon: Icon(icon)),
    );
  }
}
