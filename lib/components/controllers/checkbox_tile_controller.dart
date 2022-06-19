import 'package:flutter/material.dart';

class CheckboxTileController extends ChangeNotifier {
  bool? _value;

  CheckboxTileController({bool? value}) : _value = value ?? false;

  bool? get value => _value;

  set value(bool? newValue) {
    _value = newValue;
    notifyListeners();
  }
}
