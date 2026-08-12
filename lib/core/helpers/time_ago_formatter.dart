import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stack_money/core/l10n/app_localizations.dart';

class TimeAgoFormatter {
  static String format(AppLocalizations l10n, Timestamp timestamp) {
    final now = DateTime.now();
    final dateTime = timestamp.toDate();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return l10n.timeAgoJustNow;
    } else if (difference.inMinutes < 60) {
      return l10n.timeAgoMin(difference.inMinutes);
    } else if (difference.inHours < 24) {
      return l10n.timeAgoHour(difference.inHours);
    } else if (difference.inDays == 1) {
      return l10n.timeAgoYesterday;
    } else if (difference.inDays < 7) {
      return l10n.timeAgoDay(difference.inDays);
    } else {
      return l10n.timeAgoWhen(
        dateTime.day.toString().padLeft(2, '0'),
        dateTime.month.toString().padLeft(2, '0'),
        dateTime.year,
      );
    }
  }
}
