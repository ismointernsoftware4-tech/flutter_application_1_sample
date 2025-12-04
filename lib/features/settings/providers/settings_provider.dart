import 'package:flutter/material.dart';

import '../models/settings_models.dart';

class SettingsProvider extends ChangeNotifier {
  final TextEditingController organizationController;
  int _activeTab = 0;
  String _currency;
  String _timeZone;
  bool _emailAlerts;
  bool _lowStockWarnings;

  SettingsProvider(SystemConfiguration config)
      : organizationController =
            TextEditingController(text: config.organizationName),
        _currency = config.currency,
        _timeZone = config.timeZone,
        _emailAlerts = config.emailAlerts,
        _lowStockWarnings = config.lowStockWarnings;

  int get activeTab => _activeTab;
  String get currency => _currency;
  String get timeZone => _timeZone;
  bool get emailAlerts => _emailAlerts;
  bool get lowStockWarnings => _lowStockWarnings;

  final List<String> currencies = const ['USD (\$)', 'EUR (€)', 'INR (₹)'];
  final List<String> timeZones = const ['UTC', 'GMT+5:30', 'GMT+8'];

  void setActiveTab(int index) {
    if (index == _activeTab) return;
    _activeTab = index;
    notifyListeners();
  }

  void setCurrency(String value) {
    if (value == _currency) return;
    _currency = value;
    notifyListeners();
  }

  void setTimeZone(String value) {
    if (value == _timeZone) return;
    _timeZone = value;
    notifyListeners();
  }

  void toggleEmailAlerts(bool value) {
    if (value == _emailAlerts) return;
    _emailAlerts = value;
    notifyListeners();
  }

  void toggleLowStockWarnings(bool value) {
    if (value == _lowStockWarnings) return;
    _lowStockWarnings = value;
    notifyListeners();
  }

  SystemConfiguration toConfiguration() {
    return SystemConfiguration(
      organizationName: organizationController.text,
      currency: _currency,
      timeZone: _timeZone,
      emailAlerts: _emailAlerts,
      lowStockWarnings: _lowStockWarnings,
    );
  }

  @override
  void dispose() {
    organizationController.dispose();
    super.dispose();
  }
}

