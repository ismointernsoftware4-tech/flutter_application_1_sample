import 'package:flutter/material.dart';

class AddLocationProvider extends ChangeNotifier {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController managerController = TextEditingController();
  final TextEditingController capacityController =
      TextEditingController(text: '0');
  final TextEditingController descriptionController = TextEditingController();

  final List<String> types = const [
    'Warehouse',
    'Room',
    'Rack',
    'Shelf',
    'Bin',
    'Cabinet',
  ];

  final List<String> statuses = const ['Active', 'Inactive', 'Empty'];

  late List<String> parentLocations;

  String _selectedType = 'Warehouse';
  String _selectedStatus = 'Active';
  String _selectedParent = 'None (Top Level)';

  AddLocationProvider(List<String> availableParents) {
    parentLocations = ['None (Top Level)', ...availableParents];
  }

  String get selectedType => _selectedType;
  String get selectedStatus => _selectedStatus;
  String get selectedParent => _selectedParent;

  bool get canSubmit => nameController.text.trim().isNotEmpty;

  void setType(String value) {
    if (value == _selectedType) return;
    _selectedType = value;
    notifyListeners();
  }

  void setStatus(String value) {
    if (value == _selectedStatus) return;
    _selectedStatus = value;
    notifyListeners();
  }

  void setParent(String value) {
    if (value == _selectedParent) return;
    _selectedParent = value;
    notifyListeners();
  }

  void onFieldChanged() {
    notifyListeners();
  }

  int parsedCapacity() {
    return int.tryParse(capacityController.text.trim()) ?? 0;
  }

  @override
  void dispose() {
    nameController.dispose();
    managerController.dispose();
    capacityController.dispose();
    descriptionController.dispose();
    super.dispose();
  }
}

