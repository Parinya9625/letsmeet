import 'package:flutter/material.dart';

//* -- Main Style --
// main color                         >  Theme.of(context).primaryColor
// title                              >  Theme.of(context).textTheme.headline1
// description                        >  Theme.of(context).textTheme.bodyText1
// placeholder (large area)           >  Theme.of(context).disabledColor
//
// other style (card, appbar, etc.)   >  Auto set by default

Color _main = const Color.fromRGBO(0, 160, 185, 1);
Color _title = const Color.fromRGBO(58, 58, 58, 1);
Color _subtitle = const Color.fromRGBO(170, 170, 170, 1);
Color _background = const Color.fromRGBO(242, 249, 251, 1);
Color _card = Colors.white;
Color _error = const Color.fromRGBO(255, 78, 80, 1);
Color _disable = const Color.fromRGBO(243, 243, 243, 1);
// Color _description = const Color.fromRGBO(106, 106, 106, 1);

// // Debug
// Color _debug = const Color.fromRGBO(212, 41, 255, 1);
// Color _main = _debug;
// Color _title = _debug;
// Color _subtitle = _debug;
// Color _background = _debug;
// Color _card = _debug;
// Color _error = _debug;
// Color _disable = _debug;

ThemeData lightTheme = ThemeData(
  primaryColor: _main,
  colorScheme: ColorScheme.fromSwatch(
    accentColor: _main,
    errorColor: _error,
  ),
  textTheme: TextTheme(
    headline1: TextStyle(
      color: _title,
      fontWeight: FontWeight.w500,
      fontSize: 16,
    ),
    bodyText1: TextStyle(
      fontWeight: FontWeight.normal,
      color: _subtitle,
    ),
  ),
  textSelectionTheme: TextSelectionThemeData(
    cursorColor: _main,
    selectionColor: _main,
    selectionHandleColor: _main,
  ),
  disabledColor: _disable,
  iconTheme: IconThemeData(color: _subtitle),
  scaffoldBackgroundColor: _background,
  appBarTheme: AppBarTheme(
    backgroundColor: _card,
    foregroundColor: _title,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      elevation: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.disabled)) {
          return 0;
        }
        return 2;
      }),
      shape: MaterialStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      backgroundColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.disabled)) {
          return _disable;
        }
        return _main;
      }),
    ),
  ),
  cardColor: _card,
  cardTheme: CardTheme(
    elevation: 1.0,
    margin: const EdgeInsets.all(0),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: _card,
    border: const OutlineInputBorder(
      borderSide: BorderSide.none,
      borderRadius: BorderRadius.all(
        Radius.circular(16),
      ),
    ),
    hintStyle: TextStyle(
      color: _subtitle,
    ),
  ),
);
