import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerController extends ChangeNotifier {
  XFile? _file;
  String? _url;

  ImagePickerController({String? url}) : _url = url;

  XFile? get xfile => _file;
  File? get file => _file != null ? File(_file!.path) : null;
  String? get path => _file != null ? _file!.path : _url;

  set xfile(XFile? newValue) {
    _file = newValue;
    notifyListeners();
  }

  set url(String? newValue) {
    _url = newValue;
    notifyListeners();
  }
}
