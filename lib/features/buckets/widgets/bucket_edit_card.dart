import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/helpers/stack_money_string.dart';
import 'package:stack_money/core/theme/theme.dart';
import 'package:stack_money/data/models/bucket.dart';

class BucketEditCard extends StatefulWidget {
  const BucketEditCard({
    required this.bucket,
    required this.securityMode,
    required this.onAutoSave,
    super.key,
  });

  final Bucket bucket;
  final ValueListenable<bool> securityMode;
  final Function(Bucket updatedBucket) onAutoSave;

  @override
  State<BucketEditCard> createState() => BucketEditCardState();
}

class BucketEditCardState extends State<BucketEditCard> {
  bool _isExpanded = false;

  late TextEditingController _whereController;
  late TextEditingController _categoryController;
  late TextEditingController _minValueController;
  bool _isImmediateLiquidity = false;

  final FocusNode _whereFocus = FocusNode();
  final FocusNode _categoryFocus = FocusNode();
  final FocusNode _minValueFocus = FocusNode();

  bool _isSaving = false;
  bool get isExpanded => _isExpanded;

  void setExpandedState(bool expand) {
    if (mounted && widget.securityMode.value) {
      setState(() {
        _isExpanded = expand;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _isImmediateLiquidity = widget.bucket.isImmediateLiquidity;

    _whereController = TextEditingController(text: widget.bucket.where);
    _categoryController = TextEditingController(text: widget.bucket.category);

    // 🪙 Usando o teu helper corporativo 'formatMoney' com a regra interna do sinal negativo
    _minValueController = TextEditingController(
      text: _executeSystemCurrencyFormatting(widget.bucket.minValue),
    );

    _whereFocus.addListener(_handleFocusChange);
    _categoryFocus.addListener(_handleFocusChange);
    _minValueFocus.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    if (!_whereFocus.hasFocus && !_categoryFocus.hasFocus && !_minValueFocus.hasFocus) {
      _triggerAutoSave();
    }
  }

  Future<void> _triggerAutoSave() async {
    final String cleanText = _minValueController.text.replaceAll('R\$', '').replaceAll(' ', '');
    final bool isNegative = cleanText.contains('-');
    final rawNumber = cleanText.replaceAll(RegExp(r'[^0-9]'), '');

    double doubleValue = (double.tryParse(rawNumber) ?? 0.0) / 100.0;
    if (isNegative) doubleValue = -doubleValue;

    final updated = Bucket.withId(
      id: widget.bucket.id,
      where: _whereController.text,
      category: _categoryController.text,
      minValue: doubleValue,
      isImmediateLiquidity: _isImmediateLiquidity,
    );

    setState(() => _isSaving = true);
    await widget.onAutoSave(updated);

    if (mounted) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) setState(() => _isSaving = false);
      });
    }
  }

  // 📝 Regra tática de inversão de sinal casada com o teu helper StackMoneyString
  String _executeSystemCurrencyFormatting(double value) {
    if (value < 0) {
      final rawFormatted = StackMoneyString.formatMoney(doubleValue: value.abs());
      return "R\$ -${rawFormatted.replaceAll('R\$', '').trim()}";
    }
    return StackMoneyString.formatMoney(doubleValue: value);
  }

  @override
  Widget build(BuildContext context) {
    final double currentValue = _parseCurrentValue();
    final Color techColor = currentValue < 0 ? StackMoneyTheme.magentaNeon : StackMoneyTheme.cyanNeon;

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
        boxShadow: _isSaving ? [
          BoxShadow(color: techColor.withOpacity(0.3), blurRadius: 12, spreadRadius: 1)
        ] : null,
      ),
      child: Column(
        children: [
          // 🔒 CABEÇALHO DO CARD (Sólido CarbonGrey)
          GestureDetector(
            onTap: () {
              // 🛡️ Se o modo stealth estiver ativo, BLOQUEIA a abertura e expansão
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
                          color: _isImmediateLiquidity ? techColor : StackMoneyTheme.mutedGrey.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: AppSizes.x4),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _whereController.text.isEmpty && _categoryController.text.isEmpty
                                ? 'UNINITIALIZED_SLOT'
                                : '${_categoryController.text}_${_whereController.text}'.toUpperCase(),
                            style: const TextStyle(
                              fontFamily: 'JetBrainsMono',
                              color: StackMoneyTheme.platinumSilver,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            _categoryController.text.toUpperCase(),
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

                  // Escuta dinamicamente as alterações de privacidade globais
                  ValueListenableBuilder<bool>(
                    valueListenable: widget.securityMode,
                    builder: (context, isSystemVisible, child) {
                      return Text(
                        isSystemVisible ? _executeSystemCurrencyFormatting(currentValue) : "R\$ ••••••",
                        style: TextStyle(
                          fontFamily: 'JetBrainsMono',
                          color: isSystemVisible ? techColor : StackMoneyTheme.mutedGrey,
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

          // 🛠️ MIOLO EXPANDIDO (Rows Compactas + TextFields de Bordas Completas)
          if (_isExpanded && widget.securityMode.value) ...[
            const Divider(color: StackMoneyTheme.background, height: 1, thickness: 1),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
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
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 3,
                        child: _buildOutlineField(
                          label: 'MIN_VALUE',
                          controller: _minValueController,
                          focusNode: _minValueFocus,
                          keyboardType: const TextInputType.numberWithOptions(signed: true),
                          inputFormatters: [_AdvancedCurrencyFormatter()],
                          activeColor: techColor,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'LIQUIDITY',
                              style: TextStyle(fontFamily: 'JetBrainsMono', color: StackMoneyTheme.mutedGrey, fontSize: 9, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            SizedBox(
                              height: 40,
                              child: FittedBox(
                                fit: BoxFit.fill,
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
        inputFormatters: inputFormatters,
        style: const TextStyle(fontFamily: 'JetBrainsMono', color: Colors.white, fontSize: 13),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontFamily: 'JetBrainsMono', color: StackMoneyTheme.mutedGrey, fontSize: 11),
          floatingLabelStyle: TextStyle(fontFamily: 'JetBrainsMono', color: activeColor, fontSize: 12, fontWeight: FontWeight.bold),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.08), width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: activeColor, width: 1.2),
          ),
        ),
      ),
    );
  }

  double _parseCurrentValue() {
    final String cleanText = _minValueController.text.replaceAll('R\$', '').replaceAll(' ', '');
    final bool isNegative = cleanText.contains('-');
    final rawNumber = cleanText.replaceAll(RegExp(r'[^0-9]'), '');
    double doubleValue = (double.tryParse(rawNumber) ?? 0.0) / 100.0;
    return isNegative ? -doubleValue : doubleValue;
  }
}

class _AdvancedCurrencyFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;
    bool isNegative = newValue.text.contains('-');
    String digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) digits = "0";

    double numValue = (double.tryParse(digits) ?? 0.0) / 100.0;
    final baseFormatted = StackMoneyString.formatMoney(doubleValue: numValue).replaceAll('R\$', '').trim();
    String finalOutput = isNegative ? "R\$ -$baseFormatted" : "R\$ $baseFormatted";

    return newValue.copyWith(
      text: finalOutput,
      selection: TextSelection.collapsed(offset: finalOutput.length),
    );
  }
}