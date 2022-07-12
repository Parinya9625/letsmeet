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
Color _subtitle = const Color.fromRGBO(160, 160, 160, 1);
Color _background = const Color.fromRGBO(242, 249, 251, 1);
Color _card = Colors.white;
Color _error = const Color.fromRGBO(255, 78, 80, 1);
Color _disable = const Color.fromRGBO(243, 243, 243, 1);
Color _highlight = const Color.fromRGBO(242, 201, 76, 1);
Color _green = const Color.fromRGBO(25, 214, 104, 1);
Color _description = const Color.fromRGBO(106, 106, 106, 1);

// // Debug
// Color _debug = const Color.fromRGBO(212, 41, 255, 1);
// Color _main = _debug;
// Color _title = _debug;
// Color _subtitle = _debug;
// Color _background = _debug;
// Color _card = _debug;
// Color _error = _debug;
// Color _disable = _debug;
// Color _highlight = _debug;
// Color _green = _debug;

ThemeData lightTheme = ThemeData(
  primaryColor: _main,
  errorColor: _error,
  colorScheme: ColorScheme.light(
    primary: _main,
    secondary: _main,
  ),
  textTheme: TextTheme(
    headlineLarge: TextStyle(
      color: _title,
      fontWeight: FontWeight.w500,
      fontSize: 36,
    ),
    headline1: TextStyle(
      color: _title,
      fontWeight: FontWeight.w500,
      fontSize: 16,
    ),
    headline2: TextStyle(
      color: _title,
      fontWeight: FontWeight.w500,
      fontSize: 14,
    ),
    //? link
    headline3: TextStyle(
      color: _main,
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
  tabBarTheme: TabBarTheme(
    labelColor: _main,
    unselectedLabelColor: _subtitle,
    indicator: UnderlineTabIndicator(
      borderSide: BorderSide(
        color: _main,
        width: 2.0,
      ),
      insets: const EdgeInsets.symmetric(horizontal: 32),
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      padding: MaterialStateProperty.all(
          const EdgeInsets.symmetric(vertical: 16, horizontal: 24)),
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
  textButtonTheme: TextButtonThemeData(
    style: ButtonStyle(
      shape: MaterialStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      overlayColor: MaterialStateProperty.resolveWith(
        (states) {
          if (states.contains(MaterialState.disabled)) {
            return Colors.transparent;
          }
          return _main.withOpacity(0.1);
        },
      ),
      foregroundColor: MaterialStateProperty.resolveWith(
        (states) {
          if (states.contains(MaterialState.disabled)) {
            return _disable;
          }
          return _main;
        },
      ),
    ),
  ),
  radioTheme: RadioThemeData(
    fillColor: MaterialStateProperty.all(_main),
    overlayColor: MaterialStateProperty.all(_main.withOpacity(0.1)),
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
    prefixIconColor: _subtitle,
    suffixIconColor: _subtitle,
    border: const OutlineInputBorder(
      borderSide: BorderSide.none,
      borderRadius: BorderRadius.all(
        Radius.circular(16),
      ),
    ),
    hintStyle: TextStyle(
      color: _subtitle,
    ),
    errorStyle: TextStyle(
      color: _error,
      fontSize: 12,
    ),
  ),
  checkboxTheme: CheckboxThemeData(
    checkColor: MaterialStateProperty.all(_card),
    fillColor: MaterialStateProperty.all(_main),
  ),
  popupMenuTheme: PopupMenuThemeData(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    color: _card,
  ),
  dialogTheme: DialogTheme(
    backgroundColor: _card,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    titleTextStyle: TextStyle(
      color: _title,
      fontWeight: FontWeight.w500,
      fontSize: 20,
    ),
    contentTextStyle: TextStyle(
      fontWeight: FontWeight.normal,
      color: _subtitle,
    ),
  ),
  sliderTheme: SliderThemeData.fromPrimaryColors(
    primaryColor: _main,
    primaryColorDark: _main,
    primaryColorLight: _main,
    valueIndicatorTextStyle: TextStyle(
      fontWeight: FontWeight.normal,
      color: _subtitle,
    ),
  ),
  snackBarTheme: SnackBarThemeData(
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  ),
  extensions: [
    LetsMeetColor(
      rating: _highlight,
      eventOpen: _green,
      eventClose: _description,
      eventRestrict: _error,
    ),
  ],
);

class LetsMeetColor extends ThemeExtension<LetsMeetColor> {
  final Color rating;
  final Color eventOpen;
  final Color eventClose;
  final Color eventRestrict;

  const LetsMeetColor({
    required this.rating,
    required this.eventOpen,
    required this.eventClose,
    required this.eventRestrict,
  });

  @override
  ThemeExtension<LetsMeetColor> copyWith(
      {Color? rating,
      Color? eventOpen,
      Color? eventClose,
      Color? eventRestrict}) {
    return LetsMeetColor(
      rating: rating ?? this.rating,
      eventOpen: eventOpen ?? this.eventOpen,
      eventClose: eventClose ?? this.eventClose,
      eventRestrict: eventRestrict ?? this.eventRestrict,
    );
  }

  @override
  ThemeExtension<LetsMeetColor> lerp(
      ThemeExtension<LetsMeetColor>? other, double t) {
    if (other is! LetsMeetColor) {
      return this;
    }

    return LetsMeetColor(
      rating: Color.lerp(rating, other.rating, t)!,
      eventOpen: Color.lerp(eventOpen, other.eventOpen, t)!,
      eventClose: Color.lerp(eventClose, other.eventClose, t)!,
      eventRestrict: Color.lerp(eventRestrict, other.eventRestrict, t)!,
    );
  }
}
