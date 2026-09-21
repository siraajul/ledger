import 'package:flutter/material.dart';

// Neo Brutalism theme constants
const kBg = Color(0xFFF5F0E8);
const kBlack = Color(0xFF1A1A1A);
const kWhite = Color(0xFFFFFFFF);
const kYellow = Color(0xFFFFE500);
const kPink = Color(0xFFFF6B9D);
const kBlue = Color(0xFF00C2FF);
const kGreen = Color(0xFF00E676);
const kOrange = Color(0xFFFF9100);
const kPurple = Color(0xFFBB86FC);

const kBorder = BorderRadius.zero;
const kShadow = BoxShadow(
  offset: Offset(4, 4),
  color: kBlack,
);

const kCardShadow = BoxShadow(
  offset: Offset(5, 5),
  color: kBlack,
);

final kAppTheme = ThemeData(
  scaffoldBackgroundColor: kBg,
  colorScheme: const ColorScheme.light(
    primary: kBlack,
    secondary: kYellow,
    surface: kBg,
  ),
);
