import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:stack_money/features/personal_cfo/personal_cfo_screen.dart';

class AiChatManager {
  void initializeNewBucketSlot(BuildContext context) {
    if (context.mounted) {
      context.go(PersonalCfoScreen.route);
    }
  }
}