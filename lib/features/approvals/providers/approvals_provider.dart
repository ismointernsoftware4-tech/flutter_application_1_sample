import 'package:flutter/material.dart';

class ApprovalsFilterProvider extends ChangeNotifier {
  final List<String> _tabs = const ['Pending', 'Approved', 'Rejected', 'All'];
  int _activeIndex = 0;

  List<String> get tabs => _tabs;
  int get activeIndex => _activeIndex;
  String get activeFilter => _tabs[_activeIndex];

  void setActiveIndex(int index) {
    if (index == _activeIndex || index < 0 || index >= _tabs.length) return;
    _activeIndex = index;
    notifyListeners();
  }
}

