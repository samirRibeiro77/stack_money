import 'package:cloud_firestore/cloud_firestore.dart';

class TimestampExtension {
  static Timestamp parse(Object? date) {
    if (date == null) {
      return Timestamp.now();
    }

    if (date is int) {
      return Timestamp.fromMillisecondsSinceEpoch(date);
    }

    if (date is DateTime) {
      return Timestamp.fromDate(date);
    }

    if (date is String) {
      return Timestamp.fromDate(DateTime.parse(date));
    }

    return date as Timestamp;
  }
}