import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/helpers/money_input_formatter.dart';
import 'package:stack_money/core/helpers/stack_money_number.dart';
import 'package:stack_money/core/helpers/stack_money_string.dart';
import 'package:stack_money/core/l10n/app_localizations.dart';
import 'package:stack_money/core/providers/security_provider.dart';
import 'package:stack_money/core/theme/theme.dart';
import 'package:stack_money/core/widgets/security_text.dart';
import 'package:stack_money/core/widgets/stack_money_card.dart';
import 'package:stack_money/data/enum/security_type.dart';
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

  late bool _isImmediateLiquidity;
  late bool _isNegative;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _isImmediateLiquidity = widget.bucket.isImmediateLiquidity;
    _isNegative = widget.bucket.minValue < 0;

    _whereController = TextEditingController(text: widget.bucket.where);
    _categoryController = TextEditingController(text: widget.bucket.category);
    _minValueController = TextEditingController(
      text: StackMoneyString.formatMoney(widget.bucket.minValue),
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
    final rawNumber = _minValueController.text.replaceAll(
      RegExp(r'[^0-9]'),
      '',
    );
    double doubleValue = (double.tryParse(rawNumber) ?? 0.0) / 100.0;

    setState(() {
      _isNegative = !_isNegative;
    });

    if (_isNegative) doubleValue = -doubleValue;

    _minValueController.text = doubleValue.toString();
    _triggerAutoSave();
  }

  Future<void> _triggerAutoSave() async {
    double doubleValue = StackMoneyNumber.parseMoneyStringToDouble(
      _minValueController.text,
    );

    print(
      '[SAVE] Raw: ${_minValueController.text} // Converted: ${StackMoneyNumber.parseMoneyStringToDouble(_minValueController.text)} // Real: $doubleValue',
    );

    if (_isNegative) doubleValue = -doubleValue;

    final updated = Bucket(
      id: widget.bucket.id,
      where: _whereController.text,
      category: _categoryController.text,
      minValue: doubleValue,
      isImmediateLiquidity: _isImmediateLiquidity,
    );

    if (widget.bucket.equalsTo(updated)) return;

    setState(() => _isSaving = true);
    await widget.onAutoSave(updated);

    if (mounted) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) setState(() => _isSaving = false);
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
    final Color techColor = _isNegative
        ? StackMoneyTheme.magentaNeon
        : StackMoneyTheme.cyanNeon;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.fastOutSlowIn,
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      decoration: BoxDecoration(
        color: StackMoneyTheme.surface,
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(
          color: _isSaving ? techColor : Colors.white.withValues(alpha: 0.04),
          width: _isSaving ? 1.0 : 0.5,
        ),
        boxShadow: _isSaving
            ? [
                BoxShadow(
                  color: techColor.withValues(alpha: 0.3),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: StackMoneyCard(
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
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 4,
                          height: 24,
                          decoration: BoxDecoration(
                            color: _isImmediateLiquidity
                                ? techColor
                                : StackMoneyTheme.mutedGrey.withValues(
                                    alpha: 0.3,
                                  ),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: AppSizes.x4),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SecurityText(
                              StackMoneyString.formatTitle(
                                _categoryController.text,
                              ),
                              style: const TextStyle(
                                fontFamily: 'JetBrainsMono',
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                              type: SecurityType.systemLocked,
                            ),
                            SecurityText(
                              StackMoneyString.formatTitle(
                                _whereController.text,
                              ),
                              style: const TextStyle(
                                fontFamily: 'JetBrainsMono',
                                fontSize: 9,
                              ),
                              activeColor: StackMoneyTheme.mutedGrey,
                              type: SecurityType.systemLocked,
                            ),
                          ],
                        ),
                      ],
                    ),
                    SecurityText(
                      StackMoneyString.formatMoney(widget.bucket.minValue, symbol: true),
                      type: SecurityType.mask,
                      style: const TextStyle(
                        fontFamily: 'JetBrainsMono',
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                      activeColor: techColor,
                    ),
                  ],
                ),
              ),
            ),

            if (widget.isExpanded && !isSecureActive) ...[
              const Divider(
                color: StackMoneyTheme.background,
                height: 1,
                thickness: 1,
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildOutlineField(
                            label: l10n.category,
                            controller: _categoryController,
                            focusNode: _categoryFocus,
                            activeColor: techColor,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildOutlineField(
                            label: l10n.where,
                            controller: _whereController,
                            focusNode: _whereFocus,
                            activeColor: techColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: _toggleValueSign,
                          child: Container(
                            height: 44,
                            width: 44,
                            decoration: BoxDecoration(
                              color: StackMoneyTheme.surface,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: techColor.withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                _isNegative ? ' - ' : ' + ',
                                style: TextStyle(
                                  fontFamily: 'Orbitron',
                                  color: techColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 3,
                          child: TextFormField(
                            controller: _minValueController,
                            keyboardType: TextInputType.number,
                            focusNode: _minValueFocus,
                            style: Theme.of(context).textTheme.bodySmall,
                            decoration: StackMoneyTheme.inputDecoration(
                              l10n.minValue,
                            ),
                            inputFormatters: [MoneyInputFormatter()],
                          ),
                          // child: _buildOutlineField(
                          //   label: l10n.minValue,
                          //   controller: _minValueController,
                          //   focusNode: _minValueFocus,
                          //   keyboardType: TextInputType.number,
                          //   inputFormatters: [MoneyInputFormatter()],
                          //   activeColor: techColor,
                          // ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                StackMoneyString.formatTitle(l10n.liquidity),
                                style: const TextStyle(
                                  fontFamily: 'JetBrainsMono',
                                  color: StackMoneyTheme.mutedGrey,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
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

  Widget _buildOutlineField({
    required String label,
    required TextEditingController controller,
    required FocusNode focusNode,
    Color activeColor = StackMoneyTheme.cyanNeon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Theme(
      data: Theme.of(context).copyWith(primaryColor: activeColor),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: keyboardType,
        textCapitalization: TextCapitalization.sentences,
        inputFormatters: inputFormatters,
        style: const TextStyle(
          fontFamily: 'JetBrainsMono',
          color: Colors.white,
          fontSize: 13,
        ),
        decoration: InputDecoration(
          labelText: StackMoneyString.formatTitle(label),
          labelStyle: const TextStyle(
            fontFamily: 'JetBrainsMono',
            color: StackMoneyTheme.mutedGrey,
            fontSize: 11,
          ),
          floatingLabelStyle: TextStyle(
            fontFamily: 'JetBrainsMono',
            color: activeColor,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 14,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: Colors.white.withValues(alpha: 0.08),
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: activeColor, width: 1.2),
          ),
        ),
      ),
    );
  }

  Widget _buildLiquiditySwitch({required Color techColor}) {
    return SizedBox(
      height: 44,
      child: Center(
        child: FittedBox(
          fit: BoxFit.contain,
          child: Switch(
            value: _isImmediateLiquidity,
            activeThumbColor: techColor,
            activeTrackColor: techColor.withValues(alpha: 0.15),
            inactiveThumbColor: StackMoneyTheme.mutedGrey,
            inactiveTrackColor: StackMoneyTheme.surface,
            onChanged: (value) {
              setState(() => _isImmediateLiquidity = value);
              _triggerAutoSave();
            },
          ),
        ),
      ),
    );
  }

  // double _parseCurrentValue() {
  //   final rawNumber = _minValueController.text.replaceAll(
  //     RegExp(r'[^0-9]'),
  //     '',
  //   );
  //   double doubleValue = (double.tryParse(rawNumber) ?? 0.0) / 100.0;
  //   return _isNegative ? -doubleValue : doubleValue;
  // }
}
