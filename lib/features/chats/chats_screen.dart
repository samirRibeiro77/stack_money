import 'package:flutter/material.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/helpers/time_ago_formatter.dart';
import 'package:stack_money/core/l10n/app_localizations.dart';
import 'package:stack_money/core/providers/app_coordinator.dart';
import 'package:stack_money/core/theme/theme.dart';
import 'package:stack_money/core/widgets/card_initialize_slot.dart';
import 'package:stack_money/core/widgets/expandable_header.dart';
import 'package:stack_money/data/models/chat_thread_model.dart';
import 'package:stack_money/features/chats/manager/chats_manager.dart';

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key = const ValueKey(route)});

  static const route = '/chats';

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  final _manager = ChatsManager();

  /// Modal de Confirmação para Exclusão
  Future<bool?> _showDeleteConfirmation(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: StackMoneyTheme.carbonGrey,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          side: const BorderSide(color: StackMoneyTheme.magentaNeon),
        ),
        title: const Text(
          'Excluir Conversa?',
          style: TextStyle(color: StackMoneyTheme.cyanNeon),
        ),
        content: const Text(
          'Esta ação removerá o histórico do terminal do CFO.',
          style: TextStyle(color: StackMoneyTheme.mutedGrey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(
              'CANCELAR',
              style: TextStyle(color: StackMoneyTheme.mutedGrey),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(
              'EXCLUIR',
              style: TextStyle(
                color: StackMoneyTheme.magentaNeon,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        ExpandableHeader(
          title: l10n.plansConfig,
          validation: _manager.showArchivedNotifier,
          toggle: _manager.toggleShowArchived,
          activeIcon: Icons.archive_outlined,
          inactiveIcon: Icons.unarchive_outlined,
          activeColor: StackMoneyTheme.magentaNeon,
          inactiveColor: StackMoneyTheme.cyanNeon,
        ),
        const SizedBox(height: AppSizes.sizedBoxMedium),
        CardInitializeSlot(
          l10n.newChat,
          onTap: () => _manager.initializeNewChat(context),
        ),
        const SizedBox(height: AppSizes.sizedBoxMedium),
        ValueListenableBuilder(
          valueListenable: AppCoordinator.instance.chats,
          builder: (_, allThreads, _) {
            return ValueListenableBuilder(valueListenable: _manager.showArchivedNotifier, builder: (_, showArchived, _) {
              return Column(
                children: List.generate(allThreads.length, (index) {
                  final thread = allThreads[index];

                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSizes.x3),
                    child: Dismissible(
                      key: ValueKey(thread.id),

                      // Swipe Esquerda -> Direita (Arquivar / Prata)
                      background: Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(horizontal: AppSizes.x5),
                        decoration: BoxDecoration(
                          color: StackMoneyTheme.mutedGrey.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                        ),
                        child: const Icon(
                          Icons.archive_outlined,
                          color: StackMoneyTheme.mutedGrey,
                        ),
                      ),

                      // Swipe Direita -> Esquerda (Deletar / Magenta)
                      secondaryBackground: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: AppSizes.x5),
                        decoration: BoxDecoration(
                          color: StackMoneyTheme.magentaNeon.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                          border: Border.all(color: StackMoneyTheme.magentaNeon),
                        ),
                        child: const Icon(
                          Icons.delete_outline,
                          color: StackMoneyTheme.magentaNeon,
                        ),
                      ),

                      // Validação do Swipe
                      confirmDismiss: (direction) async {
                        if (direction == DismissDirection.endToStart) {
                          // Deletar -> Modal de confirmação
                          return await _showDeleteConfirmation(context);
                        }
                        // Arquivar -> Executa direto
                        return true;
                      },

                      onDismissed: (direction) {
                        if (direction == DismissDirection.endToStart) {
                          _manager.deleteThreadWithUndo(context, thread.id);
                        } else {
                          _manager.toggleArchiveThread(thread);
                        }
                      },

                      /// Card da Conversa (Borda Neon + Layout Cyberpunk)
                      child: InkWell(
                        onTap: () => _manager.openThread(context, thread.id),
                        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                        child: Container(
                          padding: const EdgeInsets.all(AppSizes.x4),
                          decoration: BoxDecoration(
                            color: StackMoneyTheme.carbonGrey,
                            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                            border: Border.all(
                              color: StackMoneyTheme.cyanNeon.withValues(alpha: 0.4),
                              width: AppSizes.min,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Título em Ciano Neon
                              Text(
                                thread.title,
                                style: textTheme.titleMedium?.copyWith(
                                  color: StackMoneyTheme.cyanNeon,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: AppSizes.x2),

                              // Última Mensagem Truncada (...) em Muted Grey
                              Text(
                                thread.lastMessage,
                                style: textTheme.bodySmall?.copyWith(
                                  color: StackMoneyTheme.mutedGrey,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: AppSizes.x2),

                              // Data Relativa Pequena em Magenta Neon no Canto Inferior Direito
                              Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  TimeAgoFormatter.format(l10n, thread.updatedAt),
                                  style: textTheme.labelSmall?.copyWith(
                                    color: StackMoneyTheme.magentaNeon,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              );
            });
          },
        ),
      ],
    );
  }
}