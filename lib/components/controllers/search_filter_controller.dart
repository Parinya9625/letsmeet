import 'package:flutter/material.dart';
import 'package:letsmeet/models/category.dart';

class SearchFilterController extends ChangeNotifier {
  String _mode;
  DateTimeRange? _dateRange;
  String? _type;
  Category? _category;
  double? _distance;

  SearchFilterController({
    String? mode,
    DateTimeRange? dateRange,
    String? type,
    Category? category,
    double? distance,
  })  : _mode = mode ?? "Event",
        _dateRange = dateRange,
        _type = type,
        _category = category,
        _distance = distance;

  String get mode => _mode;
  DateTimeRange? get dateRange => _dateRange;
  String? get type => _type;
  Category? get category => _category;
  double? get distance => _distance;

  set mode(String newValue) {
    _mode = newValue;
    notifyListeners();
  }

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
