import 'package:flutter/material.dart';
import 'package:letsmeet/models/category.dart';

class InterestCategorySelectorController extends ChangeNotifier {
  List<Category> _selectedValue;

  InterestCategorySelectorController({List<Category>? selectedCategory})
      : _selectedValue = selectedCategory ?? [];

  List<Category> get value => List<Category>.from(_selectedValue);

  void select(Category category) {
    if (_selectedValue.contains(category)) {
      _selectedValue.remove(category);
    } else {
      _selectedValue.add(category);
    }
    notifyListeners();
  }

  void clear() {
    _selectedValue.clear();
    notifyListeners();
  }

  set value(List<Category> newValue) {
    _selectedValue = List<Category>.from(newValue);
    notifyListeners();
  }
}
