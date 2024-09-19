import 'package:flutter/material.dart';

class BaseState extends ChangeNotifier{
  bool isLoading = false;
  String? errorMessage;

  void setLoading(bool value, [String? message]) {
    isLoading = value;
    errorMessage = message;
    notifyListeners();
  }
}