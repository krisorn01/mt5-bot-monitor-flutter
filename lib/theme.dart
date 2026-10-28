import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

const kScaffold = Color(0xFF0F1419);
const kCard = Color(0xFF161C24);
const kOutline = Color(0xFF232C36);
const kText = Color(0xFFE6EDF3);
const kMuted = Color(0xFF9AA4B2);
const kGreen = Color(0xFF2ECC71);
const kRed = Color(0xFFE74C3C);
const kBlue = Color(0xFF3B82F6);
const kAmber = Color(0xFFF1C40F);

final NumberFormat kNum = NumberFormat('#,##0.00');

String money(double v) => kNum.format(v);

/// Signed P/L with explicit + / minus sign.
String signed(double v) {
  if (v > 0) return '+${kNum.format(v)}';
  if (v < 0) return '−${kNum.format(v.abs())}';
  return kNum.format(0);
}

Color pnlColor(double v) => v > 0 ? kGreen : (v < 0 ? kRed : kMuted);

ThemeData buildTheme() {
  const scheme = ColorScheme.dark(
    primary: kBlue,
    secondary: kBlue,
    surface: kCard,
    onSurface: kText,
    outline: kOutline,
    error: kRed,
  );
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: scheme,
    scaffoldBackgroundColor: kScaffold,
    canvasColor: kScaffold,
    appBarTheme: const AppBarTheme(
      backgroundColor: kScaffold,
      foregroundColor: kText,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
    cardTheme: CardThemeData(
      color: kCard,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: kOutline),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: kCard,
      indicatorColor: kBlue.withValues(alpha: 0.25),
      labelTextStyle: WidgetStateProperty.all(
        const TextStyle(fontSize: 11, color: kText),
      ),
    ),
    dividerColor: kOutline,
  );
}
