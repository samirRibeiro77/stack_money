import 'package:flutter/material.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/helpers/stack_money_string.dart';
import 'package:stack_money/core/l10n/app_localizations.dart';
import 'package:stack_money/core/theme/theme.dart';
import 'package:stack_money/data/enum/wizard_button_action.dart';
import 'package:stack_money/features/contribution_sprint/manager/contribution_sprint_manager.dart';
import 'package:stack_money/features/contribution_sprint/widgets/bucket_form_card.dart';
import 'package:stack_money/features/contribution_sprint/widgets/sprint_progress_bar.dart';
import 'package:stack_money/features/contribution_sprint/widgets/sprint_wizard_button.dart';

class ContributionSprintScreen extends StatefulWidget {
  const ContributionSprintScreen({super.key});

  static const route = '/contribution_wizard';

  @override
  State<ContributionSprintScreen> createState() =>
      _ContributionSprintScreenState();
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
    final textTheme = Theme.of(context).textTheme;

    return ValueListenableBuilder<bool>(
      valueListenable: _manager.isLoadingNotifier,
      builder: (context, isLoading, child) {
        if (isLoading) {
          return const Scaffold(
            backgroundColor: StackMoneyTheme.background,
            body: Center(
              child: CircularProgressIndicator(color: StackMoneyTheme.cyanNeon),
            ),
          );
        }

        return ValueListenableBuilder<int>(
          valueListenable: _manager.currentIndexNotifier,
          builder: (context, currentIndex, _) {
            final currentBucket = _manager.buckets[currentIndex];
            final lastValue = _manager.getLastKnownValueForBucket(
              currentBucket,
            );

            final isFirst = currentIndex == 0;
            final isLast = currentIndex == _manager.buckets.length - 1;

            return Scaffold(
              appBar: AppBar(
                backgroundColor: StackMoneyTheme.background,
                elevation: 2,
                scrolledUnderElevation: 2,
                leading: IconButton(
                  icon: Icon(
                    isFirst
                        ? WizardButtonAction.exit.icon
                        : WizardButtonAction.previous.icon,
                    size: AppSizes.x12,
                  ),
                  onPressed: () => _manager.previousStep(context),
                ),
                title: Text(
                  StackMoneyString.formatTitle(l10n.moneySprint),
                  style: textTheme.titleMedium,
                ),
                centerTitle: true,
                actions: [
                  IconButton(
                    icon: Icon(
                      isLast
                          ? WizardButtonAction.finish.icon
                          : WizardButtonAction.next.icon,
                      size: AppSizes.x12,
                    ),
                    onPressed: () => _manager.nextStep(context),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.x8,
                  vertical: AppSizes.x6,
                ),
                child: SingleChildScrollView(
                  clipBehavior: Clip.none,
                  child: Column(
                    children: [
                      BucketFormCard(
                        bucket: currentBucket,
                        lastKnowValue: lastValue,
                        categoryController: _manager.nameController,
                        whereController: _manager.whereController,
                        minValueController: _manager.minValueController,
                        actualValueController: _manager.actualValueController,
                        setMinSign: _manager.minIsPositive,
                        switchActualSign: _manager.changeActualSign,
                        switchLiquidity: _manager.changeLiquidity,
                      ),
                      const SizedBox(height: AppSizes.sizedBoxLarge),
                      Row(
                        children: [
                          Expanded(
                            child: SprintWizardButton(
                              onPressed: () => _manager.previousStep(context),
                              action: isFirst
                                  ? WizardButtonAction.exit
                                  : WizardButtonAction.previous,
                            ),
                          ),
                          const SizedBox(width: AppSizes.sizedBoxLarge),
                          Expanded(
                            child: SprintWizardButton(
                              onPressed: () => _manager.nextStep(context),
                              action: isLast
                                  ? WizardButtonAction.finish
                                  : WizardButtonAction.next,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
