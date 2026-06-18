import 'package:flutter/material.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/constants/app_typography.dart';
import 'package:stack_money/core/helpers/stack_money_number.dart';
import 'package:stack_money/core/helpers/stack_money_string.dart';
import 'package:stack_money/core/l10n/app_localizations.dart';
import 'package:stack_money/core/theme/theme.dart';
import 'package:stack_money/core/widgets/stack_money_card.dart';
import 'package:stack_money/features/contribution_sprint/manager/contribution_sprint_manager.dart';
import 'package:stack_money/features/contribution_sprint/widgets/bucket_form_card.dart';
import 'package:stack_money/features/contribution_sprint/widgets/sprint_progress_bar.dart';

class ContributionSprintScreen extends StatefulWidget {
  const ContributionSprintScreen({super.key});

  @override
  State<ContributionSprintScreen> createState() => _ContributionSprintScreenState();
}

class _ContributionSprintScreenState extends State<ContributionSprintScreen> {
  final _manager = ContributionSprintManager();

  @override
  void initState() {
    super.initState();
    _manager.initializeSprint();
  }

  @override
  void dispose() {
    _manager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ValueListenableBuilder<bool>(
      valueListenable: _manager.isLoadingNotifier,
      builder: (context, isLoading, child) {
        if (isLoading) {
          return const Scaffold(
            backgroundColor: StackMoneyTheme.background,
            body: Center(child: CircularProgressIndicator(color: StackMoneyTheme.cyanNeon)),
          );
        }

        return ValueListenableBuilder<int>(
          valueListenable: _manager.currentIndexNotifier,
          builder: (context, currentIndex, _) {
            final currentBucket = _manager.buckets[currentIndex];
            final bool isLast = currentIndex == _manager.buckets.length - 1;
            final double lastValue = _manager.getLastKnownValueForBucket(currentBucket);

            return Scaffold(
              backgroundColor: StackMoneyTheme.background,
              appBar: AppBar(
                backgroundColor: StackMoneyTheme.background,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: AppSizes.x10),
                  onPressed: () {
                    if (currentIndex == 0) {
                      Navigator.of(context).pop();
                    } else {
                      _manager.previousStep();
                    }
                  },
                ),
                title: Text(
                  'Money_Sprint'.toUpperCase(),
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                centerTitle: true,
                actions: [
                  // TODO: tem que sumir no ultimo sprint
                  IconButton(
                    icon: const Icon(Icons.arrow_forward_ios_rounded, size: AppSizes.x10, color: StackMoneyTheme.platinumSilver),
                    onPressed: () => _manager.skipStep(context),
                  ),
                ],
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(AppSizes.min),
                  child: SprintProgressBar(
                    current: currentIndex,
                    total: _manager.buckets.length,
                  ),
                ),
              ),
              body: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.x8, vertical: AppSizes.x6),
                child: Column(
                  children: [
                    BucketFormCard(
                      bucket: currentBucket,
                      nameController: _manager.nameController,
                      whereController: _manager.whereController,
                      minValueController: _manager.minValueController,
                      actualValueController: _manager.actualValueController,

                      // Montagem limpa de strings internacionais injetadas na view
                      labelLastValueKnown: 'LAST_KNOWN_VALUE: ${StackMoneyString.formatMoney(lastValue, symbol: true)}',
                      labelActualValue: 'ACTUAL_VALUE (R\$)',
                      labelCategory: l10n.category,
                      labelWhere: l10n.where,
                      labelMinValue: '${l10n.minValue} (R\$)',
                      statusLiquid: '[ LIQUID ]',
                      statusLocked: '[ LOCKED ]',
                    ),
                    const SizedBox(height: AppSizes.x6),
                    ListenableBuilder(
                        listenable: _manager.actualValueController,
                        builder: (context, _) {
                          final String rawText = _manager.actualValueController.text;
                          final double currentInput = rawText.isNotEmpty
                              ? StackMoneyNumber.parseMoneyStringToDouble(rawText)
                              : 0.0;

                          // Condição de performance: Se o valor digitado for estritamente superior ao histórico, brilha Ciano. Caso contrário, Magenta.
                          final bool isGrowing = currentInput > lastValue;
                          final Color activeColor = isGrowing ? StackMoneyTheme.cyanNeon : StackMoneyTheme.magentaNeon;

                          return StackMoneyCard(
                            shadowColor: activeColor,
                            child: GestureDetector(
                              onTap: () => _manager.nextStep(context),
                              behavior: HitTestBehavior.opaque,
                              child: Center(
                                child: Text(
                                  isLast ? '[ FINISH_SPRINT ]' : '[ NEXT_BUCKET ]',
                                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                    color: activeColor,
                                    fontWeight: AppTypography.weightBold,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}