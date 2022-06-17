import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageCoverPickerController extends ChangeNotifier {
  XFile? _file;
  final String? _url;

  ImageCoverPickerController({String? url}) : _url = url;

  // XFile? get value => _file;
  dynamic get value => _file ?? _url;

  set value(dynamic newValue) {
    _file = newValue;
    notifyListeners();
  }
}
