import 'package:flutter/material.dart';

class IconsPickerController extends ChangeNotifier {
  IconData? _value;

  IconsPickerController({IconData? value}) : _value = value;

  IconData? get value => _value;

  set value(IconData? newValue) {
    _value = newValue;
    notifyListeners();
  }
}
