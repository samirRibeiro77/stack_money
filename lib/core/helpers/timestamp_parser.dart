import 'package:cloud_firestore/cloud_firestore.dart';

/// A utility class to parse various data types into Firestore [Timestamp] objects.
class TimestampParser {

  /// Parses a non-nullable value into a [Timestamp].
  ///
  /// Accepts [Timestamp], [DateTime], or an ISO 8601 [String].
  /// Returns [Timestamp.now()] if the value is null or unsupported.
  /// Throws a [FormatException] if the string parsing fails.
  static Timestamp fromJson(Object? value) {
    if (value == null) {
      return Timestamp.now();
    }

    if (value is Timestamp) {
      return value;
    }

    if (value is DateTime) {
      return Timestamp.fromDate(value);
    }

    if (value is String) {
      try {
        DateTime parsedDate = DateTime.parse(value);
        return Timestamp.fromDate(parsedDate);
      } catch (e) {
        throw FormatException(
          "The provided string is not in a valid date format (ISO 8601). Error: \$e",
        );
      }
    }

    return Timestamp.now();
  }

  /// Parses a nullable value into a [Timestamp].
  ///
  /// Accepts [Timestamp], [DateTime], or an ISO 8601 [String].
  /// Returns `null` if the value is null or unsupported.
  /// Throws a [FormatException] if the string parsing fails.
  static Timestamp? fromJsonNullable(Object? value) {
    if (value == null) {
      return null;
    }

    if (value is Timestamp) {
      return value;
    }

    if (value is DateTime) {
      return Timestamp.fromDate(value);
    }

    if (value is String) {
      try {
        DateTime parsedDate = DateTime.parse(value);
        return Timestamp.fromDate(parsedDate);
      } catch (e) {
        throw FormatException(
          "The provided string is not in a valid date format (ISO 8601). Error: \$e",
        );
      }
    }

    return null;
  }
}
