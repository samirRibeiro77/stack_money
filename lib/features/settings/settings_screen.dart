import 'package:flutter/material.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/l10n/app_localizations.dart';
import 'package:stack_money/core/providers/user_settings_scope.dart';
import 'package:stack_money/core/theme/theme.dart';
import 'package:stack_money/core/widgets/tab_content.dart';
import 'package:stack_money/features/settings/manager/user_settings_manager.dart';
import 'package:stack_money/features/settings/widgets/dashboard_filter_card.dart';
import 'package:stack_money/features/settings/widgets/export_data_card.dart';
import 'package:stack_money/features/settings/widgets/sign_out_button.dart';
import 'package:stack_money/features/settings/widgets/system_preferences_card.dart';
import 'package:stack_money/features/settings/widgets/user_badge_card.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _manager = UserSettingsManager();

  @override
  void initState() {
    super.initState();
    _manager.loadData(context);
  }

  @override
  void dispose() {
    _manager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return UserSettingsScope(
      manager: _manager,
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) return;
          final canLeave = await _manager.handlePopScope(context);
          if (canLeave && context.mounted) {
            Navigator.of(context).pop();
          }
        },
        child: Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                floating: true,
                snap: true,
                pinned: false,
                backgroundColor: StackMoneyTheme.background,
                leading: IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: AppSizes.x12,
                  ),
                  onPressed: () async {
                    final canLeave = await _manager.handlePopScope(context);
                    if (canLeave && context.mounted) {
                      Navigator.of(context).pop();
                    }
                  },
                ),
                title: Text(l10n.settings),
              ),
              SliverToBoxAdapter(
                child: TabContent(
                  child: Column(
                    children: [
                      UserIdBadgeCard(),
                      SizedBox(height: AppSizes.sizedBoxLarge),
                      SystemPreferencesCard(),
                      SizedBox(height: AppSizes.sizedBoxLarge),
                      DashboardFilterCard(),
                      SizedBox(height: AppSizes.sizedBoxLarge),
                      ExportDataCard(),
                      SizedBox(height: AppSizes.sizedBoxLarge * 2),
                      SignOutButton(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
