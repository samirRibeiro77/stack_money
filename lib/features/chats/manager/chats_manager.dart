import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stack_money/core/l10n/app_localizations.dart';
import 'package:stack_money/core/widgets/sm_snack_bar.dart';
import 'package:stack_money/data/enum/snack_bar_type.dart';
import 'package:stack_money/data/models/chat_thread_model.dart';
import 'package:stack_money/domain/service/chat_service.dart';
import 'package:stack_money/features/personal_cfo/personal_cfo_screen.dart';

class ChatsManager {
  final ChatManagementService _service = ChatManagementService();
  final ValueNotifier<bool> _showArchived = ValueNotifier(false);

  ValueListenable<bool> get showArchivedNotifier => _showArchived;

  void toggleShowArchived() {
    _showArchived.value = !_showArchived.value;
  }

  void initializeNewChat(BuildContext context) {
    if (context.mounted) {
      context.push(PersonalCfoScreen.route);
    }
  }

  void openThread(BuildContext context, String threadId) {
    if (context.mounted) {
      context.push(PersonalCfoScreen.route, extra: threadId);
    }
  }

  /// Alterna o estado de arquivado da conversa
  Future<void> toggleArchiveThread(ChatThreadModel thread) async {
    final updatedThread = thread.copyWith(isArchived: !thread.isArchived);
    await _service.saveThread(updatedThread);
  }

  /// Exclui a conversa do Firestore com opção de desfazer via SnackBar
  Future<void> deleteThreadWithUndo(BuildContext context, String id) async {
    _service
        .deleteThread(id)
        .then(
          (result) => result.fold(
            onSuccess: (_) {},
            onFailure: (e) {
              if (context.mounted) {
                final l10n = AppLocalizations.of(context)!;
                SmSnackBar(
                  message: l10n.failedPurgeChatThread,
                  type: SnackBarType.error,
                ).show(context);
              }
            },
          ),
        );
  }
}
