import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MyButton extends StatelessWidget {
  final String text;
  final Color textcolor;
  final double textsize;
  final FontWeight fontWeight;
  final double letterspacing;
  final double buttonwidth;
  final double buttonheight;
  final Color buttoncolor;
  final Color borderColor;
  final double radius;
  final VoidCallback onTap;
  MyButton(
      {required this.text,
      required this.textcolor,
      required this.textsize,
      required this.fontWeight,
      required this.letterspacing,
      required this.buttonwidth,
      required this.buttonheight,
      required this.buttoncolor,
      required this.borderColor,
      required this.radius,
      required this.onTap});
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final responsiveTextSize = textsize * (screenWidth / 375); // Adjust to the base screen width, e.g., 375

    // TODO: implement build
    return SizedBox(
      height: buttonheight,
      width: buttonwidth,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: buttoncolor,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radius),
              side: BorderSide(
                width: 1.0,
                color: borderColor,
              )),
          elevation: 0,
        ),
        onPressed: onTap,
          child: FittedBox(
          child: Text(
            text,
            style: GoogleFonts.dmSans(
              decoration: TextDecoration.none,
              fontSize: responsiveTextSize,
              fontWeight: fontWeight,
              letterSpacing: letterspacing,
              color: textcolor,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}