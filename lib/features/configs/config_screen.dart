import 'package:flutter/material.dart';
import 'package:stack_money/core/widgets/tab_content.dart';
import 'package:stack_money/domain/service/auth_service.dart';
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
      appBar: AppBar(title: Text('Settings'), centerTitle: false),
      body: TabContent(
        child: Column(
          children: [
            UserIdBadgeCard(
              avatarUrl: user.photoURL ?? '',
              email: user.email ?? '',
              nameController: _nameController,
            ),
          ],
        ),
      ),
    );
  }
}
