import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/l10n/app_localizations.dart';
import 'package:stack_money/core/theme/theme.dart';
import 'package:stack_money/domain/service/auth_service.dart';

class UserHeader extends StatelessWidget {
  const UserHeader({required this.switchSecurity, required this.isSecurity, super.key});

  final VoidCallback switchSecurity;
  final ValueListenable<bool> isSecurity;

  void _openConfig() {
    print('Open config page');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;

    final User? user = AuthService().currentUser;
    final String displayName = user?.displayName ?? l10n.unknow;
    final String? photoUrl = user?.photoURL;

    return SliverAppBar(
      backgroundColor: StackMoneyTheme.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      pinned: false,
      floating: true,
      snap: true,
      leadingWidth: AppSizes.max,

      // --- 1. User image
      leading: _buildAvatar(photoUrl),

      // --- 2. DISPLAY NAME ---
      title: _buildName(displayName, textTheme),

      // --- 3. BOTÃO DE ENGRENAGEM ---
      actions: [_buildVisibilityAction()],
    );
  }

  Widget _buildAvatar(String? photoUrl) {
    return GestureDetector(
      onTap: _openConfig,
      child: Padding(
        padding: const EdgeInsets.only(left: AppSizes.x8),
        child: Center(
          child: ValueListenableBuilder<bool>(
            valueListenable: isSecurity,
            builder: (_, isVisible, _) {
              final gradientColors = isVisible
                  ? [StackMoneyTheme.cyanNeon, StackMoneyTheme.background]
                  : [StackMoneyTheme.background, StackMoneyTheme.magentaNeon];

              return Container(
                padding: const EdgeInsets.all(AppSizes.min),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: CircleAvatar(
                  radius: AppSizes.x9,
                  backgroundColor: StackMoneyTheme.surface,
                  backgroundImage: photoUrl != null
                      ? NetworkImage(photoUrl)
                      : null,
                  child: photoUrl == null
                      ? const Icon(
                          Icons.person,
                          color: StackMoneyTheme.platinumSilver,
                          size: AppSizes.x9,
                        )
                      : null,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildName(String displayName, TextTheme textTheme) {
    return GestureDetector(
      onTap: _openConfig,
      child: Text(
        displayName,
        style: textTheme.titleLarge?.copyWith(
          color: StackMoneyTheme.platinumSilver,
          letterSpacing: 0.5,
          fontSize: AppSizes.x10,
        ),
      ),
    );
  }

  Widget _buildVisibilityAction() {
    return ValueListenableBuilder<bool>(
      valueListenable: isSecurity,
      builder: (_, isVisible, _) {
        return IconButton(
          icon: Icon(
            isVisible
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            color: isVisible
                ? StackMoneyTheme.cyanNeon
                : StackMoneyTheme.mutedGrey,
          ),
          onPressed: switchSecurity,
        );
      },
    );
  }
}
