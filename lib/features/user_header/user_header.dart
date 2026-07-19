import 'package:flutter/material.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/constants/app_typography.dart';
import 'package:stack_money/core/l10n/app_localizations.dart';
import 'package:stack_money/core/providers/security_provider.dart';
import 'package:stack_money/core/theme/theme.dart';
import 'package:stack_money/features/user_header/manager/user_header_manager.dart';

class UserHeader extends StatefulWidget {
  const UserHeader({super.key});

  @override
  State<UserHeader> createState() => _UserHeaderState();
}

class _UserHeaderState extends State<UserHeader> {
  late final UserHeaderManager _manager;

  @override
  void initState() {
    super.initState();
    _manager = UserHeaderManager();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final isSecure = SecurityProvider.isSecureOf(context);
    _manager.checkCurrentPlan(context, isSecure);
  }

  @override
  Widget build(BuildContext context) {
    final isSecure = SecurityProvider.isSecureOf(context);

    return SliverAppBar(
      backgroundColor: StackMoneyTheme.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      pinned: false,
      floating: true,
      snap: true,
      leadingWidth: AppSizes.max,
      leading: _buildAvatar(context, isSecure),
      title: _buildName(context),
      actions: [
        _buildContributionAction(context, isSecure),
        _buildVisibilityAction(context, isSecure),
      ],
    );
  }

  Widget _buildAvatar(BuildContext context, bool isSecure) {
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
              backgroundImage: _manager.photoUrl != null
                  ? NetworkImage(_manager.photoUrl!)
                  : null,
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
        _manager.displayName(l10n.unknow),
        style: textTheme.titleLarge?.copyWith(
          letterSpacing: AppTypography.spacingSmall,
        ),
      ),
    );
  }

  Widget _buildContributionAction(BuildContext context, bool isSecure) {
    if (isSecure) return const SizedBox.shrink();

    return IconButton(
      icon: const Icon(Icons.add_rounded, color: StackMoneyTheme.cyanNeon),
      onPressed: () => _manager.startMoneySprint(context),
    );
  }

  Widget _buildVisibilityAction(BuildContext context, bool isSecure) {
    return IconButton(
      icon: Icon(
        isSecure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
        color: isSecure ? StackMoneyTheme.mutedGrey : StackMoneyTheme.cyanNeon,
      ),
      onPressed: () async => await SecurityProvider.toggleOf(context),
    );
  }
}
