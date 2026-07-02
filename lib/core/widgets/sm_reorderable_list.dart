import 'package:flutter/material.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/providers/security_provider.dart';
import 'package:stack_money/core/theme/theme.dart';

class SmReorderableList<T> extends StatelessWidget {
  final List<T> items;
  final Function(int oldIndex, int newIndex) onReorder;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final Widget Function(BuildContext context, T item, int index)
  feedbackChildBuilder;
  final Widget Function(BuildContext context, T item, int index)
  draggingChildBuilder;

  const SmReorderableList({
    required this.items,
    required this.onReorder,
    required this.itemBuilder,
    required this.feedbackChildBuilder,
    required this.draggingChildBuilder,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isSecureActive = SecurityProvider.isSecureOf(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(items.length, (index) {
        final item = items[index];
        final Widget rawChild = itemBuilder(context, item, index);

        if (isSecureActive) {
          return rawChild;
        }

        return DragTarget<int>(
          onAcceptWithDetails: (details) {
            onReorder(details.data, index);
          },
          builder: (context, candidateData, rejectedData) {
            final bool isHovered =
                candidateData.isNotEmpty && candidateData.first != index;

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.fastOutSlowIn,
                  height: isHovered ? AppSizes.x4 : 0,
                  margin: EdgeInsets.symmetric(
                    vertical: isHovered ? AppSizes.x8 : 0,
                  ),
                  decoration: BoxDecoration(
                    color: StackMoneyTheme.platinumSilver.withValues(
                      alpha: isHovered ? 0.15 : 0,
                    ),
                    borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                    border: Border.all(
                      color: StackMoneyTheme.platinumSilver.withValues(
                        alpha: isHovered ? 0.3 : 0,
                      ),
                      width: isHovered ? 0.8 : 0,
                    ),
                  ),
                ),

                LongPressDraggable<int>(
                  data: index,
                  axis: Axis.vertical,
                  maxSimultaneousDrags: 1,
                  feedback: Material(
                    color: Colors.transparent,
                    child: Opacity(
                      opacity: 0.75,
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width - AppSizes.x16,
                        child: feedbackChildBuilder(context, item, index),
                      ),
                    ),
                  ),
                  childWhenDragging: Opacity(
                    opacity: 0.15,
                    child: draggingChildBuilder(context, item, index),
                  ),
                  child: rawChild,
                ),
              ],
            );
          },
        );
      }),
    );
  }
}
