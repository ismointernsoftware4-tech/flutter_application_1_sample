import 'package:flutter/foundation.dart' show debugPrint;

import '../models/dynamic_form_models.dart';
import 'firebase_service.dart';

class SchemaService {
  /// Loads the schema from Firebase only (no fallback to local JSON)
  static Future<DynamicFormDefinition?> loadSchema([String formId = 'item_master']) async {
    try {
      final firebaseService = FirebaseService();
      final firebaseData = await firebaseService.fetchFormDefinition(formId);
      if (firebaseData != null) {
        return DynamicFormDefinition.fromMap(firebaseData);
      }
    } catch (e) {
      debugPrint('Error loading from Firebase: $e');
    }
    return null;
  }

  /// Note: Schema persistence is now handled by FirebaseService.saveFormDefinition()
  /// This method is kept for compatibility but does nothing
  static Future<void> saveSchema(DynamicFormDefinition definition, [String formId = 'item_master']) async {
    // Schema saving is now handled by FirebaseService
    // This method is kept for backward compatibility
    debugPrint('SchemaService.saveSchema is deprecated. Use FirebaseService.saveFormDefinition instead.');
  }
}
