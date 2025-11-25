import 'package:flutter/material.dart';

class ProcurementProvider extends ChangeNotifier {
  int _activeTab = 0;
  bool _showCreateForm = false;

  int get activeTab => _activeTab;
  bool get showCreateForm => _showCreateForm;

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

  void openCreateForm() {
    if (_showCreateForm) return;
    _showCreateForm = true;
    notifyListeners();
  }

  void closeCreateForm() {
    if (!_showCreateForm) return;
    _showCreateForm = false;
    notifyListeners();
  }
}


