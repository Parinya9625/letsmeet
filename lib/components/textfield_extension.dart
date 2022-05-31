import 'package:flutter/material.dart';

extension TextFieldExtension on TextField {
  // -- How to use --
  // TextField(...).withElevation(),

  Material withElevation() {
    return Material(
      elevation: 1.0,
      borderRadius: const BorderRadius.all(
        Radius.circular(16),
      ),
      child: this,
    );
  }
}
