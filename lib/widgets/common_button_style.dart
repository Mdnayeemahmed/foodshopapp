import 'package:flutter/material.dart';

import '../utilities/app_colors.dart';

class commonbuttonstyle extends StatelessWidget {
  const commonbuttonstyle({
    super.key, required this.tittle, required this.onTap,
  });
  final String tittle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor),
            onPressed: onTap,
            child: Text(
              tittle,
              style: TextStyle(
                  fontWeight: FontWeight.w400, letterSpacing: 0.6),
            )));
  }
}