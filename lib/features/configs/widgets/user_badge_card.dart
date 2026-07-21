import 'package:flutter/material.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/theme/theme.dart';
import 'package:stack_money/core/utils/sm_logger.dart';
import 'package:stack_money/core/widgets/sm_card.dart';

class UserIdBadgeCard extends StatelessWidget {
  final String avatarUrl;
  final String email;
  final TextEditingController nameController;

  const UserIdBadgeCard({
    super.key,
    required this.avatarUrl,
    required this.email,
    required this.nameController,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final emailController = TextEditingController();
    emailController.text = email;

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
                  controller: nameController,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: StackMoneyTheme.inputDecoration(
                    'Admin Name',
                    boxHeight: AppSizes.x20,
                  ),
                ),
                const SizedBox(height: AppSizes.sizedBoxMedium),
                IgnorePointer(
                  ignoring: true,
                  child: TextFormField(
                    controller: emailController,
                    style: textTheme.bodyMedium,
                    decoration: StackMoneyTheme.inputDecoration(
                      'Admin Email',
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
            child: CircleAvatar(
              radius: AppSizes.avatarRadius,
              backgroundImage: NetworkImage(avatarUrl),
            ),
          ),
        ),
      ],
    );
  }
}
