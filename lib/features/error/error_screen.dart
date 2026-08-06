import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/exceptions/exception_scope.dart';
import 'package:stack_money/core/exceptions/stack_money_exception.dart';
import 'package:stack_money/core/helpers/stack_money_string.dart';
import 'package:stack_money/core/l10n/app_localizations.dart';
import 'package:stack_money/core/providers/app_coordinator.dart';
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

    final e = StackMoneyException(
      message: 'Error in plan timeline stream',
      scope: ExceptionScope.network,
      payload: AppCoordinator.instance.user.value.toJson(keepPrefs: true),
      stackTrace: StackTrace.fromString(
        AppCoordinator.instance.buckets.value.map((b) => b.toJson()).toString(),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.close_rounded, size: AppSizes.x12),
          onPressed: () => SystemNavigator.pop(),
        ),
        title: Text(
          StackMoneyString.formatTitle('${e.scope.name} ${l10n.error}'),
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
            ErrorHeader(icon: e.scope.icon, message: e.message),
            Expanded(child: SizedBox.shrink()),
            if (e.payload != null) ...[
              ErrorDetails(
                title: l10n.payload,
                detail: e.payload,
                color: StackMoneyTheme.cyanNeon,
              ),
            ],
            if (e.stackTrace != null) ...[
              ErrorDetails(
                title: l10n.stackTrace,
                detail: e.stackTrace,
                color: StackMoneyTheme.magentaNeon,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
