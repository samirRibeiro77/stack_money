import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/exceptions/stack_money_exception.dart';
import 'package:stack_money/core/helpers/stack_money_string.dart';
import 'package:stack_money/core/l10n/app_localizations.dart';
import 'package:stack_money/core/theme/theme.dart';
import 'package:stack_money/features/error/widgets/error_details.dart';
import 'package:stack_money/features/error/widgets/error_header.dart';

class ErrorScreen extends StatelessWidget {
  static const route = '/error';

  final StackMoneyException exception;

  const ErrorScreen({required this.exception, super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.close_rounded, size: AppSizes.x12),
          onPressed: () => SystemNavigator.pop(),
        ),
        title: Text(
          StackMoneyString.formatTitle('${exception.scope.name} ${l10n.error}'),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          vertical: AppSizes.errorPadding,
          horizontal: AppSizes.x5,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ErrorHeader(icon: exception.scope.icon, message: exception.message),
            Expanded(child: SizedBox.shrink()),
            if (exception.payload != null) ...[
              ErrorDetails(
                title: l10n.payload,
                detail: exception.payload,
                color: StackMoneyTheme.cyanNeon,
              ),
            ],
            if (exception.exception != null) ...[
              ErrorDetails(
                title: l10n.exception,
                detail: exception.exception,
                color: StackMoneyTheme.magentaNeon,
              ),
            ],
            if (exception.stackTrace != null) ...[
              ErrorDetails(
                title: l10n.stackTrace,
                detail: exception.stackTrace,
                color: StackMoneyTheme.magentaNeon,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
