import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final defaultFontStyle = GoogleFonts.poppins();

TextStyle bigTextStyle(BuildContext context, {double opacity = 1}) {
  return defaultFontStyle.copyWith(
    fontSize: 30,
    color: Theme.of(context).textTheme.bodyText1!.color!.withOpacity(opacity),
    fontWeight: FontWeight.w900
  );
}

TextStyle textStyle(BuildContext context, {double opacity = 1}) {
  return defaultFontStyle.copyWith(
    fontSize: 19,
    color: Theme.of(context).textTheme.bodyText1!.color!.withOpacity(opacity),
    fontWeight: FontWeight.w600
  );
}

TextStyle subtitleTextStyle(BuildContext context, {double opacity = 1}) {
  return defaultFontStyle.copyWith(
    fontSize: 15,
    color: Theme.of(context).textTheme.bodyText1!.color!.withOpacity(opacity),
    fontWeight: FontWeight.w500
  );
}

TextStyle smallTextStyle(BuildContext context, {double opacity = 1}) {
  return defaultFontStyle.copyWith(
    fontSize: 13,
    color: Theme.of(context).textTheme.bodyText1!.color!.withOpacity(opacity),
    fontWeight: FontWeight.w500
  );
}

TextStyle tinyTextStyle(BuildContext context, {double opacity = 1}) {
  return defaultFontStyle.copyWith(
    fontSize: 11,
    color: Theme.of(context).textTheme.bodyText1!.color!.withOpacity(opacity),
    fontWeight: FontWeight.w500
  );
}