import 'package:flutter/material.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/l10n/app_localizations.dart';
import 'package:stack_money/core/theme/theme.dart';
import 'package:stack_money/core/widgets/glass_popup_item.dart';
import 'package:stack_money/data/enum/stack_money_popup_menu_item.dart';

class GlassPopupMenu<T extends StackMoneyPopupMenuItem> extends StatelessWidget {
  final PopupMenuItemSelected<T> onSelected;
  final Color iconColor;
  final double iconSize;
  final List<T> items;

  const GlassPopupMenu({
    required this.onSelected,
    required this.items,
    this.iconColor = StackMoneyTheme.mutedGrey,
    this.iconSize = AppSizes.x12,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return PopupMenuButton<T>(
      color: Colors.transparent,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      padding: EdgeInsets.zero,
      elevation: 1,
      icon: Icon(
        Icons.more_vert_rounded,
        color: iconColor,
        size: iconSize,
      ),
      onSelected: onSelected,
      itemBuilder: (context) => items.map((action) {
        return GlassPopupItem(
          value: action,
          icon: action.icon,
          label: action.label(l10n),
          color: action.color,
          context: context,
        );
      }).toList(),
    );
  }
}
