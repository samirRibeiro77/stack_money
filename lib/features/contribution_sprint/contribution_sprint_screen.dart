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
              backgroundColor: StackMoneyTheme.background,
              appBar: AppBar(
                backgroundColor: StackMoneyTheme.background,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  onPressed: () => _manager.previousStep(context),
                ),
                title: Text(
                  StackMoneyString.formatTitle(l10n.moneySprint),
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                centerTitle: true,
                actions: [
                  IconButton(
                    icon: Icon(
                      isLast ? Icons.check : Icons.arrow_forward_ios_rounded,
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
                        nameController: _manager.nameController,
                        whereController: _manager.whereController,
                        minValueController: _manager.minValueController,
                        actualValueController: _manager.actualValueController,
                        setMinSign: _manager.minIsPositive,
                        switchActualSign: _manager.changeActualSign,
                        changeLiquidity: () {},
                      ),
                      const SizedBox(height: AppSizes.x6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SprintWizardButton(
                            onPressed: () => _manager.previousStep(context),
                            action: isFirst ? WizardButtonAction.exit : WizardButtonAction.previous,
                          ),
                          SprintWizardButton(
                            onPressed: () => _manager.nextStep(context),
                            action: isLast ? WizardButtonAction.finish : WizardButtonAction.next,
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
