import 'package:flutter/material.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/widgets/tab_content.dart';
import 'package:stack_money/domain/service/auth_service.dart';
import 'package:stack_money/features/configs/widgets/export_data_card.dart';
import 'package:stack_money/features/configs/widgets/sign_out_button.dart';
import 'package:stack_money/features/configs/widgets/system_preferences_card.dart';
import 'package:stack_money/features/configs/widgets/user_badge_card.dart';

class ConfigScreen extends StatelessWidget {
  ConfigScreen({super.key});

  final _authService = AuthService();
  final _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;
    if (user == null) return SizedBox.shrink();

    _nameController.text = user.displayName ?? '';

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: AppSizes.x12),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Settings'),
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
