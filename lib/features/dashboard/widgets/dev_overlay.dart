import 'package:flutter/material.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/providers/security_provider.dart';
import 'package:stack_money/core/theme/theme.dart';
import 'package:stack_money/core/widgets/sm_card.dart';
import 'package:stack_money/core/widgets/sm_chip_button.dart';
import 'package:stack_money/features/dashboard/manager/data_pipeline_manager.dart';

class DevOverlay extends StatelessWidget {
  DevOverlay({super.key});

  final _manager = DataPipelineManager();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isSecureActive = SecurityProvider.isSecureOf(context);

    if (isSecureActive) {
      return SizedBox.shrink();
    }

    return SmCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Icon(
            Icons.developer_board_rounded,
            color: StackMoneyTheme.magentaNeon,
            size: AppSizes.x20,
          ),
          Column(
            children: [
              Text('Developer Card Options', style: textTheme.titleMedium),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SmChipButton('Bucket', onTap: _manager.loadBuckets),
                  SizedBox(width: AppSizes.sizedBoxMedium),
                  SmChipButton('History', onTap: _manager.loadHistory),
                  SizedBox(width: AppSizes.sizedBoxMedium),
                  SmChipButton('Plans'),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
