import 'package:flutter/material.dart';

enum ExceptionScope {
  database,
  auth,
  business,
  network;

  IconData get icon {
    switch (this) {
      case ExceptionScope.database:
        return Icons.dns_rounded;
      case ExceptionScope.auth:
        return Icons.no_accounts_rounded;
      case ExceptionScope.business:
        return Icons.receipt_long_rounded;
      case ExceptionScope.network:
        return Icons.wifi_off_rounded;
    }
  }
}
