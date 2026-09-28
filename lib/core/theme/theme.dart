import 'package:blog_app/core/theme/app_pallet.dart';
import 'package:flutter/material.dart';

final class AppTheme {
  static const _fontFamily = 'Cera Pro';

  static OutlineInputBorder _border({Color color = AppPallet.borderColor}) {
    return OutlineInputBorder(
      borderSide: BorderSide(width: 2, color: color),
      borderRadius: BorderRadius.circular(10),
    );
  }

  static final darkTheme = ThemeData.dark().copyWith(
    textTheme: ThemeData.dark().textTheme.apply(fontFamily: _fontFamily),
    appBarTheme: AppBarTheme(backgroundColor: AppPallet.backgroundColor),
    scaffoldBackgroundColor: AppPallet.backgroundColor,

    inputDecorationTheme: InputDecorationTheme(
      contentPadding: const EdgeInsets.all(26),
      border: _border(),
      enabledBorder: _border(),
      focusedBorder: _border(color: AppPallet.gradient1),
      errorBorder: _border(color: AppPallet.errorColor),
    ),

    chipTheme: ChipThemeData(
      color: MaterialStatePropertyAll(AppPallet.backgroundColor),
      side: BorderSide.none,
    ),
  );
}
