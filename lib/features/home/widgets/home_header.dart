import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/l10n/app_localizations.dart';
import 'package:stack_money/core/theme/theme.dart';
import 'package:stack_money/domain/service/auth_service.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({required this.visibilityNotifier, super.key});

  final ValueNotifier<bool> visibilityNotifier;

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
      leading: Padding(
        padding: const EdgeInsets.only(left: AppSizes.x8),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(AppSizes.min),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [StackMoneyTheme.cyanNeon, StackMoneyTheme.background],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: CircleAvatar(
              radius: AppSizes.x9,
              backgroundColor: StackMoneyTheme.surface,
              backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
              child: photoUrl == null
                  ? const Icon(
                      Icons.person,
                      color: StackMoneyTheme.magentaNeon,
                      size: AppSizes.x9,
                    )
                  : null,
            ),
          ),
        ),
      ),

      // --- 2. DISPLAY NAME EM CIANO ---
      title: Text(
        displayName,
        style: textTheme.titleLarge?.copyWith(
          color: StackMoneyTheme.magentaNeon,
          letterSpacing: 0.5,
          fontSize: AppSizes.x10,
        ),
      ),

      // --- 3. BOTÃO DE ENGRENAGEM ---
      actions: [
        ValueListenableBuilder<bool>(
          valueListenable: visibilityNotifier,
          builder: (context, isVisible, child) {
            return IconButton(
              icon: Icon(
                isVisible
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: isVisible
                    ? StackMoneyTheme.cyanNeon
                    : StackMoneyTheme.mutedGrey,
              ),
              onPressed: () => visibilityNotifier.value = !isVisible,
            );
          },
        ),
        IconButton(
          icon: const Icon(
            Icons.settings_outlined,
            color: StackMoneyTheme.mutedGrey,
          ),
          onPressed: () {
            // TODO: Abrir configurações
          },
        ),
        const SizedBox(width: AppSizes.x4),
      ],
    );
  }
}
