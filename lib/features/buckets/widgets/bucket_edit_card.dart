import 'package:flutter/foundation.dart';
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
import 'package:stack_money/core/widgets/sm_card.dart';
import 'package:stack_money/core/widgets/sign_toggle_button.dart';
import 'package:stack_money/data/enum/security_type.dart';
import 'package:stack_money/data/enum/value_sign.dart';
import 'package:stack_money/data/models/bucket.dart';

class BucketEditCard extends StatefulWidget {
  const BucketEditCard({
    required this.bucket,
    required this.isExpanded,
    required this.onHeaderTap,
    required this.onAutoSave,
    super.key,
  });

  final Bucket bucket;
  final bool isExpanded;
  final VoidCallback onHeaderTap;
  final Function(Bucket updatedBucket) onAutoSave;

  @override
  State<BucketEditCard> createState() => _BucketEditCardState();
}

class _BucketEditCardState extends State<BucketEditCard> {
  late final TextEditingController _whereController;
  late final TextEditingController _categoryController;
  late final TextEditingController _minValueController;

  final FocusNode _whereFocus = FocusNode();
  final FocusNode _categoryFocus = FocusNode();
  final FocusNode _minValueFocus = FocusNode();

  bool _whereHadFocus = false;
  bool _categoryHadFocus = false;
  bool _minValueHadFocus = false;

  final _isImmediateLiquidity = ValueNotifier(false);
  final _isNegative = ValueNotifier(false);
  bool _isSaving = false;

  ValueListenable<bool> get isImmediateLiquidity => _isImmediateLiquidity;

  ValueListenable<bool> get isNegative => _isNegative;

  @override
  void initState() {
    super.initState();
    _isImmediateLiquidity.value = widget.bucket.isImmediateLiquidity;
    _isNegative.value = widget.bucket.minValue < 0;

    _whereController = TextEditingController(text: widget.bucket.where);
    _categoryController = TextEditingController(text: widget.bucket.category);
    _minValueController = TextEditingController(
      text: StackMoneyString.formatMoney(widget.bucket.minValue.abs()),
    );

    _whereFocus.addListener(_handleWhereFocusChange);
    _categoryFocus.addListener(_handleCategoryFocusChange);
    _minValueFocus.addListener(_handleMinValueFocusChange);
  }

  void _handleWhereFocusChange() {
    if (_whereHadFocus && !_whereFocus.hasFocus) {
      _triggerAutoSave();
    }
    _whereHadFocus = _whereFocus.hasFocus;
  }

  void _handleCategoryFocusChange() {
    if (_categoryHadFocus && !_categoryFocus.hasFocus) {
      _triggerAutoSave();
    }
    _categoryHadFocus = _categoryFocus.hasFocus;
  }

  void _handleMinValueFocusChange() {
    if (_minValueHadFocus && !_minValueFocus.hasFocus) {
      _triggerAutoSave();
    }
    _minValueHadFocus = _minValueFocus.hasFocus;
  }

  void _toggleValueSign() {
    if (widget.bucket.minValue != 0) {
      _isNegative.value = !_isNegative.value;
      _triggerAutoSave();
    }
  }

  Future<void> _triggerAutoSave() async {
    double doubleValue = StackMoneyNumber.parseMoneyStringToDouble(
      _minValueController.text,
    );

    if (_isNegative.value) doubleValue = -doubleValue;

    final updated = Bucket(
      id: widget.bucket.id,
      where: _whereController.text,
      category: _categoryController.text,
      minValue: doubleValue,
      isImmediateLiquidity: _isImmediateLiquidity.value,
      position: widget.bucket.position,
    );

    if (widget.bucket.equalsTo(updated)) return;

    setState(() {
      _isSaving = true;
    });
    await widget.onAutoSave(updated);

    if (mounted) {
      Future.delayed(const Duration(milliseconds: 500), () {
        setState(() {
          _isSaving = false;
        });
      });
    }
  }

  @override
  void dispose() {
    _whereFocus.removeListener(_handleWhereFocusChange);
    _categoryFocus.removeListener(_handleCategoryFocusChange);
    _minValueFocus.removeListener(_handleMinValueFocusChange);

    _whereController.dispose();
    _categoryController.dispose();
    _minValueController.dispose();
    _whereFocus.dispose();
    _categoryFocus.dispose();
    _minValueFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSecureActive = SecurityProvider.isSecureOf(context);
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;

    final Color techColor = _isNegative.value
        ? StackMoneyTheme.magentaNeon
        : StackMoneyTheme.cyanNeon;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.fastOutSlowIn,
      margin: const EdgeInsets.symmetric(vertical: AppSizes.x3),
      decoration: BoxDecoration(
        color: StackMoneyTheme.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        border: Border.all(
          color: _isSaving ? techColor : Colors.white.withValues(alpha: 0.04),
          width: _isSaving ? 1.0 : 0.5,
        ),
        boxShadow: _isSaving
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
            GestureDetector(
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
                      valueListenable: isImmediateLiquidity,
                      builder: (_, liquidity, _) {
                        return Container(
                          width: AppSizes.x2,
                          height: AppSizes.x12,
                          decoration: BoxDecoration(
                            color: liquidity
                                ? techColor
                                : StackMoneyTheme.mutedGrey.withValues(
                                    alpha: 0.3,
                                  ),
                            borderRadius: BorderRadius.circular(
                              AppSizes.radiusLarge,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: AppSizes.sizedBoxSmall),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SecurityText(
                          StackMoneyString.formatTitle(
                            _categoryController.text,
                          ),
                          style: textTheme.titleSmall?.copyWith(
                            fontWeight: AppTypography.weightBold,
                          ),
                          type: SecurityType.systemLocked,
                        ),
                        SecurityText(
                          StackMoneyString.formatTitle(_whereController.text),
                          style: textTheme.titleSmall?.copyWith(
                            fontSize: AppTypography.fontSmallest,
                          ),
                          activeColor: StackMoneyTheme.mutedGrey,
                        ),
                      ],
                    ),
                    const Expanded(child: SizedBox()),
                    SecurityText(
                      StackMoneyString.formatMoney(
                        widget.bucket.minValue,
                        symbol: true,
                      ),
                      type: SecurityType.mask,
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: AppTypography.weightBold,
                      ),
                      activeColor: techColor,
                    ),
                  ],
                ),
              ),
            ),

            if (widget.isExpanded && !isSecureActive) ...[
              const Divider(color: StackMoneyTheme.background, height: 1),
              Padding(
                padding: const EdgeInsets.all(AppSizes.x8),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _whereController,
                            focusNode: _whereFocus,
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
                            controller: _categoryController,
                            focusNode: _categoryFocus,
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
                        SignToggleButton(
                          _toggleValueSign,
                          initialValue: _isNegative.value
                              ? ValueSign.negative
                              : ValueSign.positive,
                        ),
                        const SizedBox(width: AppSizes.sizedBoxMedium),
                        Expanded(
                          flex: 3,
                          child: TextFormField(
                            controller: _minValueController,
                            keyboardType: TextInputType.number,
                            focusNode: _minValueFocus,
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
                              _buildLiquiditySwitch(techColor: techColor),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLiquiditySwitch({required Color techColor}) {
    return SizedBox(
      height: AppSizes.x16,
      child: Center(
        child: FittedBox(
          fit: BoxFit.contain,
          child: Switch(
            value: _isImmediateLiquidity.value,
            activeThumbColor: techColor,
            activeTrackColor: techColor.withValues(alpha: 0.15),
            inactiveThumbColor: StackMoneyTheme.mutedGrey,
            inactiveTrackColor: StackMoneyTheme.surface,
            onChanged: (value) {
              _isImmediateLiquidity.value = value;
              _triggerAutoSave();
            },
          ),
        ),
      ),
    );
  }
}
