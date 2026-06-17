import 'package:flutter/material.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/theme/theme.dart';

class EditableTitle extends StatelessWidget {
  const EditableTitle(this.title, {required this.onSave, super.key});

  final String title;
  final ValueChanged<String> onSave;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return TextFormField(
      initialValue: title,
      onChanged: onSave,
      onFieldSubmitted: onSave,
      textCapitalization: TextCapitalization.sentences,
      style: textTheme.titleMedium,
      decoration: InputDecoration(
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: StackMoneyTheme.cyanNeon,
            width: AppSizes.min,
          ),
        ),
        filled: false,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: AppSizes.x4),
      ),
    );
  }
}
