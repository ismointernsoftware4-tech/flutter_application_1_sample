import 'package:flutter/material.dart';

class ClinicWorkspaceProvider extends ChangeNotifier {
  final List<String> _sections = const [
    'Clinic Dashboard',
    'Clinic Details',
    'Clinic Branches',
    'Clinic Users',
    'Clinic Roles',
    'Clinic Settings',
  ];

  String _selectedSection = 'Clinic Dashboard';

  List<String> get sections => _sections;
  String get selectedSection => _selectedSection;

  void setSection(String section) {
    if (_selectedSection == section) return;
    _selectedSection = section;
    notifyListeners();
  }
}

