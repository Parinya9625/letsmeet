import 'package:flutter/material.dart';
import 'package:letsmeet/models/category.dart';

class SearchFilterController extends ChangeNotifier {
  DateTimeRange? _dateRange;
  String? _type;
  Category? _category;
  double? _distance;

  DateTimeRange? get dateRange => _dateRange;
  String? get type => _type;
  Category? get category => _category;
  double? get distance => _distance;

  set dateRange(DateTimeRange? newValue) {
    _dateRange = newValue;
    notifyListeners();
  }

  set type(String? newValue) {
    _type = newValue;
    notifyListeners();
  }

  set category(Category? newValue) {
    _category = newValue;
    notifyListeners();
  }

  set distance(double? newValue) {
    _distance = newValue;
    notifyListeners();
  }
}
