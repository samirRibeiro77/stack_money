import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stack_money/core/l10n/app_localizations.dart';
import 'package:stack_money/core/widgets/sm_dialog.dart';
import 'package:stack_money/core/widgets/sm_snack_bar.dart';
import 'package:stack_money/data/enum/snack_bar_type.dart';
import 'package:stack_money/data/models/chat_thread_model.dart';
import 'package:stack_money/domain/service/chat_service.dart';
import 'package:stack_money/features/personal_cfo/personal_cfo_screen.dart';

class ChatsManager {
  final ChatManagementService _service = ChatManagementService();
  final BuildContext _context;

  final ValueNotifier<bool> _showArchived = ValueNotifier(false);

  ValueListenable<bool> get showArchivedNotifier => _showArchived;

  ChatsManager(this._context);

  void toggleShowArchived() {
    _showArchived.value = !_showArchived.value;
  }

  void initializeNewChat(BuildContext context) {
    if (context.mounted) {
      context.push(PersonalCfoScreen.route);
    }
  }

  void openThread(BuildContext context, ChatThreadModel thread) {
    if (context.mounted) {
      context.push(PersonalCfoScreen.route, extra: thread);
    }
  }

  /// Alterna o estado de arquivado da conversa
  Future<void> toggleArchiveThread(ChatThreadModel thread) async {
    final updatedThread = thread.copyWith(isArchived: !thread.isArchived);
    await _service.saveThread(updatedThread);
  }

  Future<bool?> showTerminalConfirmDialog(String chatTitle) {
    final l10n = AppLocalizations.of(_context)!;

    return showDialog<bool>(
      context: _context,
      barrierDismissible: false,
      builder: (context) => SmDialog(
        message: l10n.deleteChatMessage,
        content: chatTitle,
        note: l10n.deleteChatNote,
        onCancel: () => Navigator.of(context).pop(false),
        onConfirm: () => Navigator.of(context).pop(true),
      ),
    );
  }

  /// Exclui a conversa do Firestore com opção de desfazer via SnackBar
  Future<void> purgeChatThread(String id) async {
    _service
        .deleteThread(id)
        .then(
          (result) => result.fold(
            onSuccess: (_) {},
            onFailure: (e) {
              if (_context.mounted) {
                final l10n = AppLocalizations.of(_context)!;
                SmSnackBar(
                  message: l10n.failedPurgeChatThread,
                  type: SnackBarType.error,
                ).show(_context);
              }
            },
          ),
        );
  }
}
