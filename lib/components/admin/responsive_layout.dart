import 'package:flutter/material.dart';

// ignore: non_constant_identifier_names
dynamic ResponsiveValue({
  required BuildContext context,
  dynamic small,
  dynamic medium,
  dynamic large,
}) {
  if (ResponsiveLayout.isLargeSize(context)) {
    return large;
  } else if (ResponsiveLayout.isMediumSize(context)) {
    return medium ?? large;
  } else if (ResponsiveLayout.isSmallSize(context)) {
    return small ?? medium ?? large;
  }
}

class ResponsiveLayout extends StatelessWidget {
  final Widget? small;
  final Widget? medium;
  final Widget? large;
  final bool autoUseLargerSize;

  const ResponsiveLayout({
    Key? key,
    this.small,
    this.medium,
    this.large,
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
    return MediaQuery.of(context).size.width > 1024;
  }

  Widget placeholder() {
    return const SizedBox();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (autoUseLargerSize) {
          if (isLargeSize(context)) {
            return large ?? placeholder();
          } else if (isMediumSize(context)) {
            return medium ?? large ?? placeholder();
          }
          return small ?? medium ?? large ?? placeholder();
        } else {
          if (isLargeSize(context)) {
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
