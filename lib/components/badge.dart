import 'package:flutter/material.dart';

class Badge extends StatelessWidget {
  final String title;
  final Color backgroundColor;
  final Color foregroundColor;

  const Badge({
    Key? key,
    required this.title,
    this.backgroundColor = Colors.black,
    this.foregroundColor = Colors.white,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(16),
      elevation: 2,
      color: backgroundColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
        child: Text(
          title,
          style: TextStyle(color: foregroundColor),
        ),
      ),
    );
  }
}
