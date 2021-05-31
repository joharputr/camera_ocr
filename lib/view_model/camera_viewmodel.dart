import 'package:flutter/material.dart';

class CameraViewModel extends ChangeNotifier {
  List<String> policeNumber = [];
  int timer = 10000;

  Future<void> addPoliceNumber(String policeNumber) async {
    this.policeNumber.add(policeNumber);
    notifyListeners();
  }

  Future<void> changeTimer(int timer) async {
    print("timeeer = ${timer}");
    this.timer = timer;
    notifyListeners();
  }
}
