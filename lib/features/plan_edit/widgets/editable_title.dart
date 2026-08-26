import 'package:flutter/material.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/theme/theme.dart';

class EditableTitle extends StatelessWidget {
  const EditableTitle(
    this.title, {
    required this.onSave,
    bool centerTitle = false,
    this.removeUnderlineBorder = false,
    super.key,
  }) : textAlign = centerTitle ? TextAlign.center : TextAlign.left;

  final String title;
  final TextAlign textAlign;
  final bool removeUnderlineBorder;
  final ValueChanged<String> onSave;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return TextFormField(
      initialValue: title,
      onChanged: onSave,
      onFieldSubmitted: onSave,
      textAlign: textAlign,
      textCapitalization: TextCapitalization.sentences,
      style: textTheme.titleMedium,
      decoration: InputDecoration(
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: removeUnderlineBorder
                ? Colors.transparent
                : StackMoneyTheme.cyanNeon,
            width: removeUnderlineBorder ? 0 : AppSizes.min,
          ),
        ),
        filled: false,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: AppSizes.x4),
      ),
    );
  }
}
