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
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
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
