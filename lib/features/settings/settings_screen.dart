import 'package:flutter/material.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/l10n/app_localizations.dart';
import 'package:stack_money/core/widgets/tab_content.dart';
import 'package:stack_money/domain/service/auth_service.dart';
import 'package:stack_money/features/settings/widgets/dashboard_filter_card.dart';
import 'package:stack_money/features/settings/widgets/export_data_card.dart';
import 'package:stack_money/features/settings/widgets/sign_out_button.dart';
import 'package:stack_money/features/settings/widgets/system_preferences_card.dart';
import 'package:stack_money/features/settings/widgets/user_badge_card.dart';

class SettingsScreen extends StatelessWidget {
  SettingsScreen({super.key});

  final _authService = AuthService();
  final _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;
    if (user == null) return SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;
    _nameController.text = user.displayName ?? l10n.unknow;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: AppSizes.x12),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(l10n.settings),
      ),
      body: SingleChildScrollView(
        child: TabContent(
          child: Column(
            children: [
              UserIdBadgeCard(
                avatarUrl: user.photoURL ?? '',
                email: user.email ?? '',
                nameController: _nameController,
              ),
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
    );
  }
}
