import 'package:stack_money/core/l10n/app_localizations.dart';

enum LoadingType {
  none,
  user,
  plan,
  bucket,
  chats,
  history,
  done,
  error;

  String message(AppLocalizations l10n) {
    switch (this) {
      case none:
      case done:
      case error:
        return '';
      case user:
        return l10n.loadingUser;
      case plan:
        return l10n.loadingPlan;
      case bucket:
        return l10n.loadingBucket;
      case chats:
        return l10n.loadingChats;
      case history:
        return l10n.loadingHistory;
    }
  }
}
