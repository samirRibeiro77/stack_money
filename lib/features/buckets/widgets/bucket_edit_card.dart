import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/helpers/stack_money_string.dart';
import 'package:stack_money/core/theme/theme.dart';
import 'package:stack_money/data/models/bucket.dart';

class BucketEditCard extends StatefulWidget {
  const BucketEditCard({
    required this.bucket,
    required this.securityMode,
    required this.onAutoSave,
    this.initiallyExpanded = false,
    super.key,
  });

  final Bucket bucket;
  final ValueListenable<bool> securityMode;
  final Function(Bucket updatedBucket) onAutoSave;
  final bool initiallyExpanded;

  @override
  State<BucketEditCard> createState() => BucketEditCardState();
}

class BucketEditCardState extends State<BucketEditCard> {
  bool _isExpanded = false;

  late TextEditingController _whereController;
  late TextEditingController _categoryController;
  late TextEditingController _minValueController;
  bool _isImmediateLiquidity = false;
  bool _isNegative = false;

  final FocusNode _whereFocus = FocusNode();
  final FocusNode _categoryFocus = FocusNode();
  final FocusNode _minValueFocus = FocusNode();

  bool _isSaving = false;

  void setExpandedState(bool expand) {
    if (mounted && widget.securityMode.value) {
      setState(() {
        _isExpanded = expand;
      });
    }
  }

  bool get isExpanded => _isExpanded;

  @override
  void initState() {
    super.initState();
    _isImmediateLiquidity = widget.bucket.isImmediateLiquidity;
    _isExpanded = widget.initiallyExpanded;

    _isNegative = widget.bucket.minValue < 0;
    _whereController = TextEditingController(text: widget.bucket.where);
    _categoryController = TextEditingController(text: widget.bucket.category);

    _minValueController = TextEditingController(
      text: StackMoneyString.formatMoney(doubleValue: widget.bucket.minValue),
    );

    _whereFocus.addListener(_handleFocusChange);
    _categoryFocus.addListener(_handleFocusChange);
    _minValueFocus.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    _triggerAutoSave();
  }

  void _toggleValueSign() {
    setState(() {
      _isNegative = !_isNegative;
    });

    final rawNumber = _minValueController.text.replaceAll(
      RegExp(r'[^0-9]'),
      '',
    );
    double doubleValue = (double.tryParse(rawNumber) ?? 0.0) / 100.0;
    if (_isNegative) doubleValue = -doubleValue;

    _minValueController.text = StackMoneyString.formatMoney(
      doubleValue: doubleValue,
    );

    _triggerAutoSave();
  }

  Future<void> _triggerAutoSave() async {
    final rawNumber = _minValueController.text.replaceAll(
      RegExp(r'[^0-9]'),
      '',
    );
    double doubleValue = (double.tryParse(rawNumber) ?? 0.0) / 100.0;

    if (_isNegative) doubleValue = -doubleValue;

    final updated = Bucket.withId(
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
    final double currentValue = _parseCurrentValue();
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
          color: _isSaving ? techColor : Colors.white.withOpacity(0.04),
          width: _isSaving ? 1.0 : 0.5,
        ),
        boxShadow: _isSaving
            ? [
                BoxShadow(
                  color: techColor.withOpacity(0.3),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Column(
        children: [
          // 🔒 CABEÇALHO DO CARD (Sempre Visível)
          GestureDetector(
            onTap: () {
              if (!widget.securityMode.value) return;
              setState(() => _isExpanded = !_isExpanded);
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
                              : StackMoneyTheme.mutedGrey.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: AppSizes.x4),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _whereController.text.isEmpty &&
                                    _categoryController.text.isEmpty
                                ? 'UNINITIALIZED_SLOT'
                                : '${_categoryController.text}_${_whereController.text}'
                                      .toUpperCase(),
                            style: const TextStyle(
                              fontFamily: 'JetBrainsMono',
                              color: StackMoneyTheme.platinumSilver,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            widget.bucket.id.substring(0, 8).toUpperCase(),
                            style: const TextStyle(
                              fontFamily: 'JetBrainsMono',
                              color: StackMoneyTheme.mutedGrey,
                              fontSize: 9,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  ValueListenableBuilder<bool>(
                    valueListenable: widget.securityMode,
                    builder: (context, isVisible, child) {
                      return Text(
                        isVisible
                            ? StackMoneyString.formatMoney(
                                doubleValue: currentValue,
                              )
                            : "R\$ ••••••",
                        style: TextStyle(
                          fontFamily: 'JetBrainsMono',
                          color: isVisible
                              ? techColor
                              : StackMoneyTheme.mutedGrey,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // 🛠️ MIOLO EXPANDIDO (Grid Corrigido e Alinhado)
          if (_isExpanded && widget.securityMode.value) ...[
            const Divider(
              color: StackMoneyTheme.background,
              height: 1,
              thickness: 1,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Linha superior: Categoria e Destino
                  Row(
                    children: [
                      Expanded(
                        child: _buildOutlineField(
                          label: 'CATEGORY',
                          controller: _categoryController,
                          focusNode: _categoryFocus,
                          activeColor: techColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildOutlineField(
                          label: 'WHERE',
                          controller: _whereController,
                          focusNode: _whereFocus,
                          activeColor: techColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 🔥 ALINHAMENTO CORRIGIDO: Força os elementos a se alinharem pela base de layout deles
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // 🎛️ BOTÃO +/- RECALIBRADO PARA ALINHAMENTO COM O OUTLINE FIELD
                      GestureDetector(
                        onTap: _toggleValueSign,
                        child: Container(
                          height: 44, // Altura exata da caixa do Outline Field
                          width: 44,
                          decoration: BoxDecoration(
                            color: StackMoneyTheme.surface,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: techColor.withOpacity(0.3),
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
                        child: _buildOutlineField(
                          label: 'MIN_VALUE',
                          controller: _minValueController,
                          focusNode: _minValueFocus,
                          keyboardType: TextInputType.number,
                          inputFormatters: [PureDigitCurrencyFormatter()],
                          activeColor: techColor,
                        ),
                      ),
                      const SizedBox(width: 16),

                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              StackMoneyString.formatTitle(
                                'Is Immediate Liquidity',
                              ),
                              style: TextStyle(
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
          labelText: label,
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
              color: Colors.white.withOpacity(0.08),
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
      height: 44, // Iguala a altura do botão e do input
      child: Center(
        child: FittedBox(
          fit: BoxFit.contain,
          child: Switch(
            value: _isImmediateLiquidity,
            activeColor: techColor,
            activeTrackColor: techColor.withOpacity(0.15),
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

  double _parseCurrentValue() {
    final rawNumber = _minValueController.text.replaceAll(
      RegExp(r'[^0-9]'),
      '',
    );
    double doubleValue = (double.tryParse(rawNumber) ?? 0.0) / 100.0;
    return _isNegative ? -doubleValue : doubleValue;
  }
}
