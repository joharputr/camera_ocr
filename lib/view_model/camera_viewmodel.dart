

import 'package:flutter/material.dart';

class CameraViewModel extends ChangeNotifier {
  List<String> policeNumber = [];
  int timer = 5000;

  Future<void> addPoliceNumber(String policeNumber) async {
    this.policeNumber.add(policeNumber);
    notifyListeners();
  }

  Future<void> changeTimer(int timer) async {
    this.timer = timer;
    notifyListeners();
  }
}
