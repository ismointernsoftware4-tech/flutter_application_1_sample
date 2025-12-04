import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/procurement_models.dart';
import '../../../shared/utils/csv_file_helper.dart';

class ProcurementProvider extends ChangeNotifier {
  int _activeTab = 0;
  ProcurementFilter _filter = const ProcurementFilter();
  String _searchQuery = '';

  int get activeTab => _activeTab;
  ProcurementFilter get filter => _filter;
  String get searchQuery => _searchQuery;

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
    _filter = const ProcurementFilter(); // Reset filter on tab change
    notifyListeners();
  }

  void updateFilter(ProcurementFilter filter) {
    _filter = filter;
    notifyListeners();
  }

  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // Filter methods for each tab
  List<Map<String, dynamic>> filterPRs(List<Map<String, dynamic>> all) {
    return all.where((pr) {
      final matchesFilter = _filter.matchesPRMap(pr);
      final query = _searchQuery.trim().toLowerCase();
      final prId = (pr['id'] ?? '').toString().toLowerCase();
      final requestedBy = (pr['requestedBy'] ?? '').toString().toLowerCase();
      final department = (pr['department'] ?? '').toString().toLowerCase();
      final matchesSearch =
          query.isEmpty ||
          prId.contains(query) ||
          requestedBy.contains(query) ||
          department.contains(query);
      return matchesFilter && matchesSearch;
    }).toList();
  }

  List<Map<String, dynamic>> filterPOs(List<Map<String, dynamic>> all) {
    return all.where((po) {
      final matchesFilter = _filter.matchesPOMap(po);
      final query = _searchQuery.trim().toLowerCase();
      final poId = (po['id'] ?? '').toString().toLowerCase();
      final vendor = (po['vendor'] ?? '').toString().toLowerCase();
      final matchesSearch =
          query.isEmpty ||
          poId.contains(query) ||
          vendor.contains(query);
      return matchesFilter && matchesSearch;
    }).toList();
  }

  List<Map<String, dynamic>> filterVendors(List<Map<String, dynamic>> all) {
    return all.where((v) {
      final matchesFilter = _filter.matchesVendorMap(v);
      final query = _searchQuery.trim().toLowerCase();
      final name = (v['name'] ?? '').toString().toLowerCase();
      final category = (v['category'] ?? '').toString().toLowerCase();
      final matchesSearch =
          query.isEmpty ||
          name.contains(query) ||
          category.contains(query);
      return matchesFilter && matchesSearch;
    }).toList();
  }

  // Export methods
  Future<String> exportPRs(List<Map<String, dynamic>> data) async {
    final rows = <List<String>>[
      ['PR ID', 'Requested By', 'Department', 'Date', 'Priority', 'Status'],
      ...data.map(
        (pr) => [
          (pr['id'] ?? '').toString(),
          (pr['requestedBy'] ?? '').toString(),
          (pr['department'] ?? '').toString(),
          (pr['date'] ?? '').toString(),
          (pr['priority'] ?? '').toString(),
          (pr['status'] ?? '').toString(),
        ],
      ),
    ];
    return _exportToCsv(rows, 'purchase_requisitions');
  }

  Future<String> exportPOs(List<Map<String, dynamic>> data) async {
    final rows = <List<String>>[
      ['PO ID', 'Vendor', 'Date', 'Amount', 'Status'],
      ...data.map((po) => [
        (po['id'] ?? '').toString(),
        (po['vendor'] ?? '').toString(),
        (po['date'] ?? '').toString(),
        (po['amount'] ?? '').toString(),
        (po['status'] ?? '').toString(),
      ]),
    ];
    return _exportToCsv(rows, 'purchase_orders');
  }

  Future<String> exportVendors(List<Map<String, dynamic>> data) async {
    final rows = <List<String>>[
      ['Name', 'Category', 'Contact Name', 'Email', 'Phone', 'Status'],
      ...data.map(
        (v) => [
          (v['name'] ?? '').toString(),
          (v['category'] ?? '').toString(),
          (v['contactName'] ?? '').toString(),
          (v['email'] ?? '').toString(),
          (v['phone'] ?? '').toString(),
          (v['status'] ?? '').toString(),
        ],
      ),
    ];
    return _exportToCsv(rows, 'vendors');
  }

  Future<String> _exportToCsv(List<List<String>> rows, String prefix) async {
    final buffer = StringBuffer();
    for (final row in rows) {
      buffer.writeln(row.map(_escapeCsv).join(','));
    }
    final fileName = '${prefix}_${DateTime.now().millisecondsSinceEpoch}.csv';
    final result = await saveCsvFile(buffer.toString(), fileName);
    return kIsWeb ? result : 'CSV saved to $result';
  }

  String _escapeCsv(String value) {
    final safe = value.replaceAll('"', '""');
    return '"$safe"';
  }
}
