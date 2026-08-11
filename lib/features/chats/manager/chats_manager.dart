import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stack_money/features/personal_cfo/personal_cfo_screen.dart';

class ChatsManager {
  final ValueNotifier<bool> _showArchived = ValueNotifier(false);

  ValueListenable<bool> get showArchivedNotifier => _showArchived;

  void toggleShowArchived() {
    _showArchived.value = !_showArchived.value;
  }

  void initializeNewBucketSlot(BuildContext context) {
    if (context.mounted) {
      context.push(PersonalCfoScreen.route);
    }
  }
}