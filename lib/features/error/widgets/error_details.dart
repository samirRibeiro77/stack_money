import 'package:flutter/material.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/widgets/expandable_header.dart';

class ErrorDetails extends StatelessWidget {
  final String title;
  final dynamic detail;
  final Color color;
  final _isOpen = ValueNotifier(false);

  ErrorDetails({required this.title, required this.detail, required this.color, super.key});

  void _toggleExpand() {
    _isOpen.value = !_isOpen.value;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ExpandableHeader(title: title, toggle: _toggleExpand, validation: _isOpen),
        SizedBox(height: AppSizes.sizedBoxSmall),
        ValueListenableBuilder(valueListenable: _isOpen, builder: (_, isOpen, _) {
          if (!isOpen) {
            return SizedBox.shrink();
          }

          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: AppSizes.x2,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(
                      AppSizes.navBarRadius,
                    ),
                    boxShadow: [
                      BoxShadow(
                          color: color.withAlpha(100),
                          blurRadius: 5,
                          spreadRadius: 5
                      ),
                    ],
                  ),
                ),
                SizedBox(width: AppSizes.sizedBoxMedium),
                Expanded(
                  child: SelectableText(
                    detail.toString(),
                    style: textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          );
        }),
        SizedBox(height: AppSizes.sizedBoxLarge),
      ],
    );
  }
}
