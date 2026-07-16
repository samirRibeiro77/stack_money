import 'package:flutter/material.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/constants/app_typography.dart';
import 'package:stack_money/core/helpers/money_input_formatter.dart';
import 'package:stack_money/core/helpers/stack_money_number.dart';
import 'package:stack_money/core/helpers/stack_money_string.dart';
import 'package:stack_money/core/l10n/app_localizations.dart';
import 'package:stack_money/core/providers/security_provider.dart';
import 'package:stack_money/core/theme/theme.dart';
import 'package:stack_money/core/widgets/security_text.dart';
import 'package:stack_money/core/widgets/sign_toggle_button.dart';
import 'package:stack_money/core/widgets/sm_card.dart';
import 'package:stack_money/data/enum/security_type.dart';
import 'package:stack_money/data/enum/value_sign.dart';
import 'package:stack_money/data/models/bucket.dart';
import 'package:stack_money/features/bucket_card/manager/bucket_card_manager.dart';

class BucketCard extends StatefulWidget {
  final Bucket bucket;
  final bool isExpanded;
  final VoidCallback onHeaderTap;
  final VoidCallback? onDismissed;

  const BucketCard({
    required this.bucket,
    required this.isExpanded,
    required this.onHeaderTap,
    this.onDismissed,
    super.key,
  });

  @override
  State createState() => _BucketCardState();
}

class _BucketCardState extends State<BucketCard> {
  late final BucketCardManager _cardManager;

  @override
  void initState() {
    super.initState();
    _cardManager = BucketCardManager(widget.bucket);
  }

  @override
  void dispose() {
    _cardManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSecureActive = SecurityProvider.isSecureOf(context);
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;

    return ValueListenableBuilder(
      valueListenable: _cardManager.techColor,
      builder: (_, techColor, _) {
        return Dismissible(
          key: Key(_cardManager.bucket.id),
          direction: isSecureActive
              ? DismissDirection.none
              : DismissDirection.endToStart,
          confirmDismiss: (_) async => _cardManager.confirmPurge(context),
          onDismissed: (_) async {
            await _cardManager.purgeSelf();
            if (widget.onDismissed != null) widget.onDismissed!();
          },
          background: Container(
            margin: const EdgeInsets.symmetric(vertical: AppSizes.x3),
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.x10),
            decoration: BoxDecoration(
              color: StackMoneyTheme.magentaNeon.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
              border: Border.all(
                color: StackMoneyTheme.magentaNeon.withValues(alpha: 0.3),
                width: 0.5,
              ),
            ),
            alignment: Alignment.centerRight,
            child: const Icon(
              Icons.delete_sweep_rounded,
              color: StackMoneyTheme.magentaNeon,
              size: AppSizes.x12,
            ),
          ),
          child: ValueListenableBuilder(
            valueListenable: _cardManager.isSaving,
            builder: (_, saving, _) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.fastOutSlowIn,
                margin: const EdgeInsets.symmetric(vertical: AppSizes.x3),
                decoration: BoxDecoration(
                  color: StackMoneyTheme.surface,
                  borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                  border: Border.all(
                    color: saving
                        ? techColor
                        : Colors.white.withValues(alpha: 0.04),
                    width: saving ? 1.0 : 0.5,
                  ),
                  boxShadow: saving
                      ? [
                          BoxShadow(
                            color: techColor.withValues(alpha: 0.3),
                            blurRadius: AppSizes.radiusMedium,
                            spreadRadius: 1,
                          ),
                        ]
                      : null,
                ),
                child: SmCard(
                  shadowColor: techColor,
                  removePadding: true,
                  child: Column(
                    children: [
                      _buildHeader(isSecureActive, textTheme, techColor),
                      if (widget.isExpanded && !isSecureActive) ...[
                        const Divider(
                          color: StackMoneyTheme.background,
                          height: 1,
                        ),
                        _buildExpandedForm(l10n, textTheme, techColor),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildHeader(
    bool isSecureActive,
    TextTheme textTheme,
    Color techColor,
  ) {
    return GestureDetector(
      onTap: () {
        if (isSecureActive) return;
        widget.onHeaderTap();
      },
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.x8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ValueListenableBuilder(
              valueListenable: _cardManager.isImmediateLiquidity,
              builder: (_, liquidity, _) {
                return Container(
                  width: AppSizes.x2,
                  height: AppSizes.x12,
                  decoration: BoxDecoration(
                    color: liquidity
                        ? techColor
                        : StackMoneyTheme.mutedGrey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
                  ),
                );
              },
            ),
            const SizedBox(width: AppSizes.sizedBoxSmall),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ValueListenableBuilder(
                  valueListenable: _cardManager.categoryController,
                  builder: (_, value, _) {
                    return SecurityText(
                      StackMoneyString.formatTitle(value.text),
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: AppTypography.weightBold,
                      ),
                      type: SecurityType.systemLocked,
                    );
                  },
                ),
                ValueListenableBuilder(
                  valueListenable: _cardManager.whereController,
                  builder: (_, value, _) {
                    return SecurityText(
                      StackMoneyString.formatTitle(value.text),
                      style: textTheme.titleSmall?.copyWith(
                        fontSize: AppTypography.fontSmallest,
                      ),
                      activeColor: StackMoneyTheme.mutedGrey,
                    );
                  },
                ),
              ],
            ),
            const Expanded(child: SizedBox()),
            ValueListenableBuilder(
              valueListenable: _cardManager.minValueSign,
              builder: (_, minValueSign, _) {
                return ValueListenableBuilder(
                  valueListenable: _cardManager.minValueController,
                  builder: (_, value, _) {
                    var minValue = StackMoneyNumber.parseMoneyStringToDouble(
                      value.text,
                    );

                    if (minValueSign.isNegative) minValue = -minValue;

                    return SecurityText(
                      StackMoneyString.formatMoney(minValue, symbol: true),
                      type: SecurityType.mask,
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: AppTypography.weightBold,
                      ),
                      activeColor: techColor,
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedForm(
    AppLocalizations l10n,
    TextTheme textTheme,
    Color techColor,
  ) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.x8),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _cardManager.whereController,
                  focusNode: _cardManager.whereFocus,
                  style: textTheme.bodySmall,
                  decoration: StackMoneyTheme.inputDecoration(
                    l10n.where,
                    color: techColor,
                  ),
                ),
              ),
              const SizedBox(width: AppSizes.sizedBoxMedium),
              Expanded(
                child: TextFormField(
                  controller: _cardManager.categoryController,
                  focusNode: _cardManager.categoryFocus,
                  style: textTheme.bodySmall,
                  decoration: StackMoneyTheme.inputDecoration(
                    l10n.category,
                    color: techColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.sizedBoxMedium),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              ValueListenableBuilder(
                valueListenable: _cardManager.minValueSign,
                builder: (_, minValueSign, _) {
                  return SignToggleButton(
                    _cardManager.toggleValueSign,
                    initialValue: minValueSign.isNegative
                        ? ValueSign.negative
                        : ValueSign.positive,
                  );
                },
              ),
              const SizedBox(width: AppSizes.sizedBoxMedium),
              Expanded(
                flex: 3,
                child: TextFormField(
                  controller: _cardManager.minValueController,
                  keyboardType: TextInputType.number,
                  focusNode: _cardManager.minValueFocus,
                  style: textTheme.bodySmall,
                  decoration: StackMoneyTheme.inputDecoration(
                    l10n.minValue,
                    color: techColor,
                  ),
                  inputFormatters: [MoneyInputFormatter()],
                ),
              ),
              const SizedBox(width: AppSizes.sizedBoxMedium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      StackMoneyString.formatTitle(l10n.liquidity),
                      style: textTheme.bodySmall?.copyWith(
                        fontSize: AppTypography.fontSmallest,
                        color: StackMoneyTheme.mutedGrey,
                      ),
                    ),
                    SizedBox(
                      height: AppSizes.x16,
                      child: Center(
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: ValueListenableBuilder(
                            valueListenable: _cardManager.isImmediateLiquidity,
                            builder: (_, liquidity, _) {
                              return Switch(
                                value: liquidity,
                                activeThumbColor: techColor,
                                activeTrackColor: techColor.withValues(
                                  alpha: 0.15,
                                ),
                                inactiveThumbColor: StackMoneyTheme.mutedGrey,
                                inactiveTrackColor: StackMoneyTheme.surface,
                                onChanged: _cardManager.updateLiquidity,
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
