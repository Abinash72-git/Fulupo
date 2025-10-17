import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Styles {
  // Add the responsiveFontSize method within the Styles class
  static double responsiveFontSize(BuildContext context, double baseFontSize) {
    final screenWidth = MediaQuery.of(context).size.width;
    return baseFontSize *
        (screenWidth / 375); // Adjust 375 to your base screen width
  }

  static TextStyle textStyleExtraSmall(
    BuildContext context, {
    Color color = Colors.black,
  }) {
    return GoogleFonts.dmSans(
      color: color,
      fontWeight: FontWeight.bold,
      fontSize: responsiveFontSize(context, 11),
    );
  }

  // static TextStyle textStyleSmall(
  //   BuildContext context, {
  //   Color color = Colors.black,
  // }) {
  //   return GoogleFonts.dmSans(
  //     color: color,
  //     fontWeight: FontWeight.bold,
  //     fontSize: responsiveFontSize(context, 13),
  //   );
  // }

  static TextStyle textStyleSmall(
    BuildContext context, {
    Color color = Colors.black,
    FontWeight fontWeight = FontWeight.bold,
  }) {
    return GoogleFonts.dmSans(
      color: color,
      fontWeight: fontWeight,
      fontSize: responsiveFontSize(context, 13),
    );
  }

  static TextStyle textStyleMedium(
    BuildContext context, {
    Color color = Colors.black,
  }) {
    return GoogleFonts.dmSans(
      color: color,
      fontWeight: FontWeight.bold,
      fontSize: responsiveFontSize(context, 16),
    );
  }

  static TextStyle textStyleLarge(
    BuildContext context, {
    Color color = Colors.black,
  }) {
    return GoogleFonts.dmSans(
      color: color,
      fontWeight: FontWeight.bold,
      fontSize: responsiveFontSize(context, 18),
    );
  }

  static TextStyle textStyleExtraLarge(
    BuildContext context, {
    Color color = Colors.black,
  }) {
    return GoogleFonts.dmSans(
      color: color,
      fontWeight: FontWeight.w700,
      fontSize: responsiveFontSize(context, 20),
    );
  }

  static TextStyle textStyleExtraLargeBold(
    BuildContext context, {
    Color color = Colors.black,
  }) {
    return GoogleFonts.dmSans(
      color: color,
      fontWeight: FontWeight.bold,
      fontSize: responsiveFontSize(context, 22),
    );
  }

  static TextStyle textStyleHBugeBold(
    BuildContext context, {
    Color color = Colors.black,
  }) {
    return GoogleFonts.dmSans(
      color: color,
      fontWeight: FontWeight.bold,
      fontSize: responsiveFontSize(context, 25),
    );
  }

  static TextStyle textStyleExtraHugeBold(
    BuildContext context, {
    Color color = Colors.black,
  }) {
    return GoogleFonts.dmSans(
      color: color,
      fontWeight: FontWeight.bold,
      fontSize: responsiveFontSize(context, 30),
    );
  }

  static TextStyle textStyleAnimation(
    BuildContext context, {
    Color color = Colors.black,
  }) {
    return GoogleFonts.dmSans(
      color: color,
      fontWeight: FontWeight.w500,

      fontSize: responsiveFontSize(context, 45),
    );
  }
}
