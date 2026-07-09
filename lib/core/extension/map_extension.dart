import 'package:flutter/foundation.dart';

/// Extension on Map for convenient type-safe decoding of JSON lists.
extension MapDecodeExtension on Map {
  /// Decodes a JSON list at the specified key into a List of objects of type T.
  ///
  /// Parameters:
  /// - key: The key in the map where the list is stored
  /// - decoder: A function that converts each map element to type T, possibly returning null
  ///
  /// Returns a `List<T>` containing the decoded objects, or `null` if no valid data is found.
  List<T>? decodeList<T>(
    String key,
    T? Function(Map<String, Object?>?) decoder,
  ) {
    // Check if the key exists and the value is a non-null List
    if (!containsKey(key) || this[key] == null || this[key] is! List) {
      return null;
    }

    try {
      final decodedItems = <T>[];

      for (final item in this[key] as List) {
        if (item is! Map) continue;

        final Map<String, Object?> mapItem = Map<String, Object?>.from(item);
        final decodedItem = decoder(mapItem);

        if (decodedItem != null) {
          decodedItems.add(decodedItem);
        }
      }

      return decodedItems.isEmpty ? null : decodedItems;
    } catch (e) {
      debugPrint('Error decoding list for key $key: $e');
      return null;
    }
  }
}
