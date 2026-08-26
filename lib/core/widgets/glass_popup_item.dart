import 'package:flutter/material.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/constants/app_typography.dart';
import 'package:stack_money/core/theme/theme.dart';
import 'package:stack_money/core/widgets/glassmorphism_effect.dart';

class GlassPopupItem<T> extends PopupMenuItem<T> {
  GlassPopupItem({
    super.key,
    required super.value,
    required IconData icon,
    required String label,
    required Color color,
    required BuildContext context,
  }) : super(
         padding: EdgeInsets.symmetric(vertical: AppSizes.min),
         child: Container(
           decoration: BoxDecoration(
             borderRadius: BorderRadius.circular(AppSizes.navBarRadius),
             color: color.withValues(alpha: 0.15),
           ),
           child: GlassmorphismEffect(
             containerHeight: AppSizes.x20,
             borderColor: color,
             borderWidth: AppSizes.min,
             backgroundColor: StackMoneyTheme.background,
             child: Row(
               children: [
                 Icon(icon, color: color, size: AppSizes.x10),
                 const SizedBox(width: AppSizes.sizedBoxSmall),
                 Text(
                   label,
                   style: Theme.of(context).textTheme.bodySmall?.copyWith(
                     color: color,
                     fontWeight: AppTypography.weightBold,
                   ),
                 ),
               ],
             ),
           ),
         ),
       );
}
