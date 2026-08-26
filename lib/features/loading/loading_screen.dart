import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/constants/app_typography.dart';
import 'package:stack_money/core/helpers/stack_money_string.dart';
import 'package:stack_money/core/l10n/app_localizations.dart';
import 'package:stack_money/core/providers/app_coordinator.dart';
import 'package:stack_money/core/theme/theme.dart';
import 'package:stack_money/data/enum/loading_type.dart';
import 'package:stack_money/features/loading/widget/loading_linear_progress_bar.dart';
import 'package:stack_money/features/main_navigation/main_navigation_wrapper.dart';

class LoadingScreen extends StatefulWidget {
  static const route = '/loading';

  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppCoordinator.instance.initApp(context);
      AppCoordinator.instance.loading.addListener(_navigateHome);
    });
  }

  @override
  void dispose() {
    AppCoordinator.instance.loading.removeListener(_navigateHome);
    super.dispose();
  }

  void _navigateHome() {
    if (!mounted) return;
    final loading = AppCoordinator.instance.loading.value;
    if (loading == LoadingType.done) {
      context.go(MainNavigationWrapper.route);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: StackMoneyTheme.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.x20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                /// Header
                Text(
                  '[  ${StackMoneyString.formatTitle(l10n.systemCode)}  //  ${StackMoneyString.formatTitle(l10n.appName)}  ]',
                  style: textTheme.labelLarge,
                ),
                const SizedBox(height: AppSizes.sizedBoxSmall),

                /// Title
                Text(
                  l10n.initializing,
                  style: textTheme.headlineLarge?.copyWith(
                    fontWeight: AppTypography.weightBold,
                  ),
                  textAlign: TextAlign.start,
                ),
                const SizedBox(height: AppSizes.sizedBoxLarge),

                /// Progress bar
                LoadingLinearProgressBar(),
                const SizedBox(height: AppSizes.sizedBoxLarge),

                /// Enum message
                ValueListenableBuilder(
                  valueListenable: AppCoordinator.instance.loading,
                  builder: (_, loading, _) {
                    return Row(
                      children: [
                        const Text(
                          '> ',
                          style: TextStyle(
                            color: StackMoneyTheme.magentaNeon,
                            fontWeight: AppTypography.weightBold,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            loading.message(l10n),
                            style: textTheme.bodyMedium?.copyWith(
                              color: StackMoneyTheme.cyanNeon,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
