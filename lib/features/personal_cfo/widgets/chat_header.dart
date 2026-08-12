import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/theme/theme.dart';
import 'package:stack_money/core/widgets/glassmorphism_effect.dart';
import 'package:stack_money/features/plan_edit/widgets/editable_title.dart';

class ChatHeader extends StatelessWidget {
  final String title;
  final ValueChanged<String> saveTitle;

  const ChatHeader({required this.title, required this.saveTitle, super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        /// Leading
        SizedBox(width: AppSizes.sizedBoxSmall),
        GestureDetector(
          onTap: () => context.pop(),
          child: GlassmorphismEffect(
            borderRadius: AppSizes.avatarRadius,
            borderColor: StackMoneyTheme.magentaNeon,
            borderWidth: AppSizes.min,
            containerHeight: AppSizes.cfoAppBarHeight,
            child: SizedBox.square(
              dimension: AppSizes.x12,
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: StackMoneyTheme.magentaNeon,
                size: AppSizes.x10,
              ),
            ),
          ),
        ),

        /// Title
        SizedBox(width: AppSizes.sizedBoxLarge),
        Expanded(
          child: GlassmorphismEffect(
            borderColor: StackMoneyTheme.cyanNeon,
            borderWidth: AppSizes.min,
            containerHeight: AppSizes.cfoAppBarHeight,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSizes.min),
              child: EditableTitle(title, removeUnderlineBorder: true, onSave: saveTitle),
            ),
          ),
        ),
        SizedBox(width: AppSizes.sizedBoxLarge),

        /// Actions
        InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(AppSizes.avatarRadius),
          highlightColor: StackMoneyTheme.magentaNeon.withValues(alpha: 0.1),
          splashColor: StackMoneyTheme.magentaNeon.withValues(alpha: 0.15),
          child: GlassmorphismEffect(
            borderRadius: AppSizes.avatarRadius,
            borderColor: StackMoneyTheme.magentaNeon,
            borderWidth: AppSizes.min,
            containerHeight: AppSizes.cfoAppBarHeight,
            child: SizedBox.square(
              dimension: AppSizes.x12,
              child: Icon(
                Icons.more_vert_rounded,
                color: StackMoneyTheme.magentaNeon,
                size: AppSizes.x10,
              ),
            ),
          ),
        ),
        SizedBox(width: AppSizes.sizedBoxSmall),
      ],
    );
  }
}
