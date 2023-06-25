import 'package:flutter/material.dart';

import '../utilities/app_colors.dart';

class commontextfield extends StatelessWidget {
  const commontextfield({
    super.key, required this.controller, required this.validator, required this.hinttext, this.textInputType, this.maxline,
  });

  final TextEditingController controller;
  final Function(String?) validator;
  final String hinttext;
  final TextInputType? textInputType;
  final int? maxline;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: (value) => validator(value),
      keyboardType: textInputType,
      maxLines: maxline,
      decoration: InputDecoration(
        hintText: hinttext,
        helperStyle: TextStyle(
            color: softGreyColor
        ),

        contentPadding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12

        ),
        border: OutlineInputBorder(
            borderSide: BorderSide(color: primaryColor,width: 2)
        ),
        enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: primaryColor,width: 2)
        ),
        focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: primaryColor,width: 2)
        ),
      ),
    );
  }
}