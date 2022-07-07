import 'package:flutter/material.dart';

class LocationPickerController extends ChangeNotifier {
  String? _placeId;
  String? _name;
  double? _lat;
  double? _lng;

  LocationPickerController({
    String? placeId,
    String? name,
    double? lat,
    double? lng,
  })  : _placeId = placeId,
        _name = name,
        _lat = lat,
        _lng = lng;

  String? get placeId => _placeId;
  String? get name => _name;
  double? get lat => _lat;
  double? get lng => _lng;

  set placeId(String? newValue) {
    _placeId = newValue;
    notifyListeners();
  }

  set name(String? newValue) {
    _name = newValue;
    notifyListeners();
  }

  set lat(double? newValue) {
    _lat = newValue;
    notifyListeners();
  }

  set lng(double? newValue) {
    _lng = newValue;
    notifyListeners();
  }
}
