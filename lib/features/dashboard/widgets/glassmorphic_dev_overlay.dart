import 'package:flutter/material.dart';
import 'package:stack_money/core/exceptions/exception_scope.dart';
import 'package:stack_money/core/exceptions/stack_money_exception.dart';
import 'package:stack_money/core/theme/theme.dart';
import 'package:stack_money/core/widgets/glassmorphism_effect.dart';

class GlassmorphicDevOverlay extends StatefulWidget {
  final Future<void> Function() onTriggerPipeline;

  const GlassmorphicDevOverlay({super.key, required this.onTriggerPipeline});

  @override
  State<GlassmorphicDevOverlay> createState() => _GlassmorphicDevOverlayState();
}

class _GlassmorphicDevOverlayState extends State<GlassmorphicDevOverlay> {
  bool _isLoading = false;

  void _executePipeline() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      await widget.onTriggerPipeline();
    } catch (e, stack) {
      StackMoneyException(
        message: 'Error executing pipeline',
        scope: ExceptionScope.network,
        payload: {'exception': e},
        stackTrace: stack,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _executePipeline,
      child: GlassmorphismEffect(
        containerHeight: null,
        borderColor: _isLoading
            ? StackMoneyTheme.cyanNeon.withOpacity(0.5)
            : Colors.white.withOpacity(0.08),
        child: Padding(
          padding: EdgeInsets.all(15),
          child: Row(
            children: [
              Icon(
                _isLoading ? Icons.sync : Icons.terminal_rounded,
                color: _isLoading
                    ? StackMoneyTheme.cyanNeon
                    : StackMoneyTheme.magentaNeon,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isLoading
                          ? 'STATUS: INJECTING_NODES...'
                          : 'SYS_CONSOLE: DIRECT_ASSET_PIPELINE',
                      style: TextStyle(
                        fontFamily: 'Courier',
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: _isLoading
                            ? StackMoneyTheme.cyanNeon
                            : Colors.white.withOpacity(0.9),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _isLoading
                          ? 'Processing dynamic splits & batch commits...'
                          : 'Tap to trigger sequential seeder (Buckets + History).',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
              if (_isLoading)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      StackMoneyTheme.cyanNeon,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
