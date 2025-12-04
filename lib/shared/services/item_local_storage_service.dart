import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;

class ItemLocalStorageService {
  static const String _assetPath = 'schemas/item_master/item_master_data.json';
  static const String _localPath = 'schemas/item_master/item_master_data.json';

  Future<List<Map<String, dynamic>>> loadItems() async {
    final jsonString = await _readJson();
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }
    try {
      final data = json.decode(jsonString) as List<dynamic>;
      return data
          .whereType<Map<String, dynamic>>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveItems(List<Map<String, dynamic>> items) async {
    if (kIsWeb) return;
    final file = File(_localPath);
    final payload = json.encode(items);
    await file.create(recursive: true);
    await file.writeAsString(payload);
  }

  Future<void> appendItem(Map<String, dynamic> item) async {
    if (kIsWeb) return;
    final existing = await loadItems();
    existing.add(item);
    await saveItems(existing);
  }

  Future<void> updateItem(String documentId, Map<String, dynamic> itemData) async {
    if (kIsWeb) return;
    final existing = await loadItems();
    final index = existing.indexWhere((item) => item['id'] == documentId);
    if (index != -1) {
      existing[index] = {...existing[index], ...itemData, 'id': documentId};
      await saveItems(existing);
    }
  }

  Future<void> deleteItem(String documentId) async {
    if (kIsWeb) return;
    final existing = await loadItems();
    existing.removeWhere((item) => item['id'] == documentId);
    await saveItems(existing);
  }

  Future<String?> _readJson() async {
    if (!kIsWeb) {
      try {
        final file = File(_localPath);
        if (await file.exists()) {
          return await file.readAsString();
        }
      } catch (_) {
        // ignore and fallback
      }
    }

    try {
      return await rootBundle.loadString(_assetPath);
    } catch (_) {
      return null;
    }
  }
}

