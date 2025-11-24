import 'package:flutter/material.dart';

class ProcurementProvider extends ChangeNotifier {
  int _activeTab = 0;

  int get activeTab => _activeTab;

  String get primaryButtonLabel {
    switch (_activeTab) {
      case 0:
        return 'Create New PR';
      case 1:
        return 'Create PO';
      default:
        return 'Add Vendor';
    }
  }

  void setActiveTab(int index) {
    if (index == _activeTab) return;
    _activeTab = index;
    notifyListeners();
  }
}


