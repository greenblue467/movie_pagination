import 'package:flutter/material.dart';

class AnimationVm with ChangeNotifier {
  bool _showUp = false;

  bool get showUp => _showUp;

  void setShowUp(bool val) {
    _showUp = val;
    notifyListeners();
  }
}