import 'package:flutter/material.dart';

// ignore: non_constant_identifier_names
dynamic ResponsiveValue({
  required BuildContext context,
  dynamic small,
  dynamic medium,
  dynamic large,
  dynamic extraLarge,
}) {
  if (ResponsiveLayout.isExtraLargeSize(context)) {
    return extraLarge;
  } else if (ResponsiveLayout.isLargeSize(context)) {
    return large ?? extraLarge;
  } else if (ResponsiveLayout.isMediumSize(context)) {
    return medium ?? large ?? extraLarge;
  } else if (ResponsiveLayout.isSmallSize(context)) {
    return small ?? medium ?? large ?? extraLarge;
  }
}

class ResponsiveLayout extends StatelessWidget {
  final Widget? small;
  final Widget? medium;
  final Widget? large;
  final Widget? extraLarge;
  final bool autoUseLargerSize;

  const ResponsiveLayout({
    Key? key,
    this.small,
    this.medium,
    this.large,
    this.extraLarge,
    this.autoUseLargerSize = true,
  }) : super(key: key);

  static bool isSmallSize(BuildContext context) {
    return MediaQuery.of(context).size.width <= 768;
  }

  static bool isMediumSize(BuildContext context) {
    return MediaQuery.of(context).size.width > 768 &&
        MediaQuery.of(context).size.width <= 1024;
  }

  static bool isLargeSize(BuildContext context) {
    return MediaQuery.of(context).size.width > 1024 &&
        MediaQuery.of(context).size.width < 1440;
  }

  static bool isExtraLargeSize(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1440;
  }

  Widget placeholder() {
    return const SizedBox();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (autoUseLargerSize) {
          if (isExtraLargeSize(context)) {
            return extraLarge ?? placeholder();
          } else if (isLargeSize(context)) {
            return large ?? extraLarge ?? placeholder();
          } else if (isMediumSize(context)) {
            return medium ?? large ?? extraLarge ?? placeholder();
          }
          return small ?? medium ?? large ?? extraLarge ?? placeholder();
        } else {
          if (isExtraLargeSize(context)) {
            return extraLarge ?? placeholder();
          } else if (isLargeSize(context)) {
            return large ?? placeholder();
          } else if (isMediumSize(context)) {
            return medium ?? placeholder();
          }
          return small ?? placeholder();
        }
      },
    );
  }
}
