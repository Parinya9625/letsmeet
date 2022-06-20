import 'package:flutter/material.dart';

class ReviewUserController extends ChangeNotifier {
  int? _value;

  ReviewUserController({int? value}) : _value = value ?? 0;

  int get value => _value!;

  set value(int? newValue) {
    _value = newValue;
    notifyListeners();
  }
}
