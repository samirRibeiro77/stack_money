import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/constants/app_typography.dart';
import 'package:stack_money/core/l10n/app_localizations.dart';
import 'package:stack_money/core/providers/security_provider.dart';
import 'package:stack_money/core/theme/theme.dart';
import 'package:stack_money/core/utils/sm_logger.dart';
import 'package:stack_money/domain/service/auth_service.dart';

// 🔥 NOVO IMPORT: Aponta diretamente para a nossa esteira de aportes sequenciais
import 'package:stack_money/features/contribution_sprint/contribution_sprint_screen.dart';
import 'package:stack_money/features/user_header/manager/user_header_manager.dart';

class UserHeader extends StatelessWidget {
  UserHeader({super.key});

  final _manager = UserHeaderManager();

  @override
  Widget build(BuildContext context) {
    final isSecure = SecurityProvider.isSecureOf(context);

    if (!isSecure) {
      _manager.checkCurrentPlan(context);
    }

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
      leading: _buildAvatar(context),

      // --- 2. DISPLAY NAME ---
      title: _buildName(context),

      // --- 3. BOTOÕES DE COMANDO ---
      actions: [
        _buildContributionAction(context),
        _buildVisibilityAction(context),
      ],
    );
  }

  Widget _buildAvatar(BuildContext context) {
    final isSecure = SecurityProvider.isSecureOf(context);

    final gradientColors = isSecure
        ? [StackMoneyTheme.background, StackMoneyTheme.magentaNeon]
        : [StackMoneyTheme.cyanNeon, StackMoneyTheme.background];

    return GestureDetector(
      onTap: _manager.openConfigs,
      child: Padding(
        padding: const EdgeInsets.only(left: AppSizes.x8),
        child: Center(
          child: Container(
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
              backgroundImage: _manager.photoUrl != null ? NetworkImage(_manager.photoUrl!) : null,
              child: _manager.photoUrl == null
                  ? const Icon(
                      Icons.person,
                      color: StackMoneyTheme.platinumSilver,
                      size: AppSizes.x9,
                    )
                  : null,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildName(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: _manager.openConfigs,
      child: Text(
        _manager.displayName(l10n),
        style: textTheme.titleLarge?.copyWith(
          color: StackMoneyTheme.platinumSilver,
          letterSpacing: AppTypography.spacingSmall,
          fontSize: AppTypography.fontTitleLarge,
        ),
      ),
    );
  }

  Widget _buildContributionAction(BuildContext context) {
    final isSecure = SecurityProvider.isSecureOf(context);

    if (isSecure) return const SizedBox.shrink();

    return IconButton(
      icon: const Icon(Icons.add_rounded, color: StackMoneyTheme.cyanNeon),
      onPressed: () => _manager.startMoneySprint(context),
    );
  }

  Widget _buildVisibilityAction(BuildContext context) {
    final isSecure = SecurityProvider.isSecureOf(context);

    return IconButton(
      icon: Icon(
        isSecure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
        color: isSecure ? StackMoneyTheme.mutedGrey : StackMoneyTheme.cyanNeon,
      ),
      onPressed: () async => await SecurityProvider.toggleOf(context),
    );
  }
}
