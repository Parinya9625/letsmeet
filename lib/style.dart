import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

TextThemeFontSize appFontSize = const TextThemeFontSize(
  headlineLarge: 36,
  headline1: 16,
  headline2: 14,
  headline3: 16,
);

TextThemeFontSize webFontSize = const TextThemeFontSize(
  headlineLarge: 36,
  headline1: 20,
  headline2: 16,
  headline3: 16,
  bodyText1: 16,
);

BaseTheme lightBase = BaseTheme(
  main: const Color.fromRGBO(0, 160, 185, 1),
  title: const Color.fromRGBO(58, 58, 58, 1),
  subtitle: const Color.fromRGBO(160, 160, 160, 1),
  background: const Color.fromRGBO(242, 249, 251, 1),
  card: Colors.white,
  error: const Color.fromRGBO(255, 78, 80, 1),
  disable: const Color.fromRGBO(243, 243, 243, 1),
  highlight: const Color.fromRGBO(242, 201, 76, 1),
  eventOpen: const Color.fromRGBO(25, 214, 104, 1),
  eventClose: const Color.fromRGBO(106, 106, 106, 1),
  shimmerBase: const Color.fromRGBO(235, 235, 244, 1),
  shimmerRun: const Color.fromRGBO(244, 244, 244, 1),
  appFontSize: appFontSize,
  webFontSize: webFontSize,
);
ThemeData lightTheme = lightBase.themeData();

BaseTheme darkBase = BaseTheme(
  isDark: true,
  main: const Color.fromRGBO(5, 171, 218, 1),
  title: Colors.white,
  subtitle: const Color.fromRGBO(150, 150, 150, 1),
  background: const Color.fromRGBO(32, 33, 36, 1),
  card: const Color.fromRGBO(48, 49, 52, 1),
  error: const Color.fromRGBO(255, 89, 38, 1),
  disable: const Color.fromRGBO(59, 59, 59, 1),
  highlight: const Color.fromRGBO(255, 235, 59, 1),
  eventOpen: const Color.fromRGBO(25, 214, 104, 1),
  eventClose: const Color.fromRGBO(106, 106, 106, 1),
  shimmerBase: const Color.fromRGBO(48, 49, 52, 1),
  shimmerRun: const Color.fromRGBO(52, 54, 56, 1),
  appFontSize: appFontSize,
  webFontSize: webFontSize,
);
ThemeData darkTheme = darkBase.themeData();

class TextThemeFontSize {
  final double? headlineLarge;
  final double? headline1;
  final double? headline2;
  final double? headline3;
  final double? bodyText1;

  const TextThemeFontSize({
    this.headlineLarge,
    this.headline1,
    this.headline2,
    this.headline3,
    this.bodyText1,
  });
}

class BaseTheme {
  final bool isDark;
  final Color main;
  final Color title;
  final Color subtitle;
  final Color background;
  final Color card;
  final Color error;
  final Color disable;
  final Color highlight;
  final Color eventOpen;
  final Color eventClose;
  final Color shimmerBase;
  final Color shimmerRun;
  final TextThemeFontSize appFontSize;
  final TextThemeFontSize webFontSize;

  const BaseTheme({
    this.isDark = false,
    required this.main,
    required this.title,
    required this.subtitle,
    required this.background,
    required this.card,
    required this.error,
    required this.disable,
    required this.highlight,
    required this.eventOpen,
    required this.eventClose,
    required this.shimmerBase,
    required this.shimmerRun,
    required this.appFontSize,
    required this.webFontSize,
  });

  ThemeData themeData() {
    return ThemeData(
      primaryColor: main,
      errorColor: error,
      colorScheme: isDark
          ? ColorScheme.dark(
              primary: main,
              secondary: main,
            )
          : ColorScheme.light(
              primary: main,
              secondary: main,
            ),
      textTheme: kIsWeb ? webTextTheme() : appTextTheme(),
      disabledColor: disable,
      iconTheme: IconThemeData(color: subtitle),
      scaffoldBackgroundColor: background,
      appBarTheme: AppBarTheme(
        backgroundColor: card,
        foregroundColor: title,
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: card,
        unselectedIconTheme: IconThemeData(
          color: subtitle,
        ),
      ),
      listTileTheme: ListTileThemeData(
        textColor: title,
        iconColor: title,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: card,
      ),
      tabBarTheme: TabBarTheme(
        labelColor: main,
        unselectedLabelColor: subtitle,
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(
            color: main,
            width: 2.0,
          ),
          insets: const EdgeInsets.symmetric(horizontal: 32),
        ),
      ),
      drawerTheme: DrawerThemeData(
        backgroundColor: card,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          padding: MaterialStateProperty.all(
            kIsWeb
                ? const EdgeInsets.all(24)
                : const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          ),
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
          foregroundColor: MaterialStateProperty.all(Colors.white),
          backgroundColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.disabled)) {
              return disable;
            }
            return main;
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
              return main.withOpacity(0.1);
            },
          ),
          foregroundColor: MaterialStateProperty.resolveWith(
            (states) {
              if (states.contains(MaterialState.disabled)) {
                return disable;
              }
              return main;
            },
          ),
        ),
      ),
      radioTheme: RadioThemeData(
        fillColor: MaterialStateProperty.all(main),
        overlayColor: MaterialStateProperty.all(main.withOpacity(0.1)),
      ),
      cardColor: card,
      cardTheme: CardTheme(
        elevation: 1.0,
        margin: const EdgeInsets.all(0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: card,
        prefixIconColor: subtitle,
        suffixIconColor: subtitle,
        border: const OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.all(
            Radius.circular(16),
          ),
        ),
        hintStyle: TextStyle(
          color: subtitle,
        ),
        errorStyle: TextStyle(
          color: error,
          fontSize: 12,
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        checkColor: MaterialStateProperty.all(card),
        fillColor: MaterialStateProperty.all(main),
      ),
      popupMenuTheme: PopupMenuThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: card,
      ),
      dialogTheme: DialogTheme(
        backgroundColor: card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        titleTextStyle: TextStyle(
          color: title,
          fontWeight: FontWeight.w500,
          fontSize: 20,
        ),
        contentTextStyle: TextStyle(
          fontWeight: FontWeight.normal,
          color: subtitle,
        ),
      ),
      sliderTheme: SliderThemeData.fromPrimaryColors(
        primaryColor: main,
        primaryColorDark: main,
        primaryColorLight: main,
        valueIndicatorTextStyle: TextStyle(
          fontWeight: FontWeight.normal,
          color: subtitle,
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
          rating: highlight,
          eventOpen: eventOpen,
          eventClose: eventClose,
          eventRestrict: error,
          shimmerBase: shimmerBase,
          shimmerRun: shimmerRun,
        ),
      ],
    );
  }

  TextTheme appTextTheme() {
    return TextTheme(
      headlineLarge: TextStyle(
        color: title,
        fontWeight: FontWeight.w500,
        fontSize: appFontSize.headlineLarge,
      ),
      headline1: TextStyle(
        color: title,
        fontWeight: FontWeight.w500,
        fontSize: appFontSize.headline1,
      ),
      headline2: TextStyle(
        color: title,
        fontWeight: FontWeight.w500,
        fontSize: appFontSize.headline2,
      ),
      //? link
      headline3: TextStyle(
        color: main,
        fontWeight: FontWeight.w500,
        fontSize: appFontSize.headline3,
      ),
      bodyText1: TextStyle(
        fontWeight: FontWeight.normal,
        color: subtitle,
        fontSize: appFontSize.bodyText1,
      ),
      //? TextField
      subtitle1: TextStyle(
        color: title,
      ),
      bodyText2: TextStyle(
        color: title,
      ),
    );
  }

  TextTheme webTextTheme() {
    return TextTheme(
      headlineLarge: TextStyle(
        color: title,
        fontWeight: FontWeight.w500,
        fontSize: webFontSize.headlineLarge,
      ),
      headline1: TextStyle(
        color: title,
        fontWeight: FontWeight.w500,
        fontSize: webFontSize.headline1,
      ),
      headline2: TextStyle(
        color: title,
        fontWeight: FontWeight.w500,
        fontSize: webFontSize.headline2,
      ),
      headline3: TextStyle(
        color: main,
        fontWeight: FontWeight.w500,
        fontSize: webFontSize.headline3,
      ),
      bodyText1: TextStyle(
        fontWeight: FontWeight.normal,
        color: subtitle,
        fontSize: webFontSize.bodyText1,
      ),
      subtitle1: TextStyle(
        color: title,
      ),
      bodyText2: TextStyle(
        color: title,
      ),
    );
  }
}

class LetsMeetColor extends ThemeExtension<LetsMeetColor> {
  final Color rating;
  final Color eventOpen;
  final Color eventClose;
  final Color eventRestrict;
  final Color shimmerBase;
  final Color shimmerRun;

  const LetsMeetColor({
    required this.rating,
    required this.eventOpen,
    required this.eventClose,
    required this.eventRestrict,
    required this.shimmerBase,
    required this.shimmerRun,
  });

  @override
  ThemeExtension<LetsMeetColor> copyWith({
    Color? rating,
    Color? eventOpen,
    Color? eventClose,
    Color? eventRestrict,
    Color? shimmerBase,
    Color? shimmerRun,
  }) {
    return LetsMeetColor(
      rating: rating ?? this.rating,
      eventOpen: eventOpen ?? this.eventOpen,
      eventClose: eventClose ?? this.eventClose,
      eventRestrict: eventRestrict ?? this.eventRestrict,
      shimmerBase: shimmerBase ?? this.shimmerBase,
      shimmerRun: shimmerRun ?? this.shimmerRun,
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
      shimmerBase: Color.lerp(shimmerBase, other.shimmerBase, t)!,
      shimmerRun: Color.lerp(shimmerRun, other.shimmerRun, t)!,
    );
  }
}
