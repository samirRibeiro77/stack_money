import 'package:flutter/material.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/l10n/app_localizations.dart';
import 'package:stack_money/core/providers/user_settings_scope.dart';
import 'package:stack_money/core/theme/theme.dart';
import 'package:stack_money/core/utils/sm_logger.dart';
import 'package:stack_money/core/widgets/sm_card.dart';

class UserIdBadgeCard extends StatelessWidget {
  const UserIdBadgeCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final manager = UserSettingsScope.of(context);

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        Positioned(
          top: 0,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: StackMoneyTheme.cyanNeon.withValues(alpha: 0.15),
                  blurRadius: AppSizes.x10,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: CircleAvatar(radius: AppSizes.avatarRadius),
          ),
        ),

        Padding(
          padding: const EdgeInsets.only(top: AppSizes.avatarRadius),
          child: SmCard(
            shadowColor: StackMoneyTheme.cyanNeon,
            child: Column(
              children: [
                const SizedBox(height: AppSizes.avatarPadding - 15),
                TextFormField(
                  controller: manager.nameController,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: StackMoneyTheme.inputDecoration(
                    l10n.adminName,
                    boxHeight: AppSizes.x20,
                  ),
                ),
                const SizedBox(height: AppSizes.sizedBoxMedium),
                IgnorePointer(
                  ignoring: true,
                  child: TextFormField(
                    controller: manager.emailController,
                    style: textTheme.bodyMedium,
                    decoration: StackMoneyTheme.inputDecoration(
                      l10n.adminEmail,
                      readOnly: true,
                      boxHeight: AppSizes.x20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Avatar Flutuante Sobreposto na Borda
        Positioned(
          top: 0,
          child: GestureDetector(
            onTap: () => SmLogger.info('Clicked to change profile image'),
            child: ValueListenableBuilder(
              valueListenable: manager.photoUrl,
              builder: (_, photoUrl, _) {
                return CircleAvatar(
                  radius: AppSizes.avatarRadius,
                  backgroundImage: NetworkImage(photoUrl),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
