import 'package:flutter/material.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/exceptions/exception_scope.dart';
import 'package:stack_money/core/exceptions/stack_money_exception.dart';
import 'package:stack_money/core/helpers/stack_money_string.dart';
import 'package:stack_money/core/l10n/app_localizations.dart';
import 'package:stack_money/core/providers/app_coordinator.dart';
import 'package:stack_money/core/theme/theme.dart';

class ErrorScreen extends StatelessWidget {
  static const route = '/error';
  final StackMoneyException exception;

  const ErrorScreen(this.exception, {super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;

    final e = StackMoneyException(
      message: 'Example of a error message goes here',
      scope: ExceptionScope.business,
      payload: {
        'user': AppCoordinator.instance.user.value.toJson(),
        'exception': Exception('Another kind of exception goes here'),
      },
      stackTrace: StackTrace.fromString(
        AppCoordinator.instance.buckets.value.map((b) => b.toJson()).toString(),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          StackMoneyString.formatTitle('${e.scope.name} ${l10n.error}'),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: AppSizes.errorPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: StackMoneyTheme.magentaNeon.withAlpha(100),
                          blurRadius: 30,
                          spreadRadius: 30,
                        ),
                      ],
                    ),
                    child: Icon(
                      e.scope.icon,
                      size: AppSizes.errorIcon,
                      color: StackMoneyTheme.surface,
                    ),
                  ),
                  SizedBox(height: AppSizes.errorPadding),
                  Text(
                    e.message,
                    style: textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            SizedBox(height: AppSizes.errorPadding),

            if (e.payload != null) ...[
              Text(
                StackMoneyString.formatTitle(l10n.payload),
                style: textTheme.titleMedium,
              ),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      width: AppSizes.x2,
                      decoration: BoxDecoration(
                        color: StackMoneyTheme.cyanNeon,
                        borderRadius: BorderRadius.circular(
                          AppSizes.navBarRadius,
                        ),
                      ),
                    ),
                    SizedBox(width: AppSizes.sizedBoxSmall),
                    Expanded(
                      child: SelectableText(
                        e.payload.toString(),
                        style: textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppSizes.sizedBoxLarge),
            ],
            if (e.stackTrace != null) ...[
              Text(
                StackMoneyString.formatTitle(l10n.stackTrace),
                style: textTheme.titleMedium,
              ),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      width: AppSizes.x2,
                      decoration: BoxDecoration(
                        color: StackMoneyTheme.magentaNeon,
                        borderRadius: BorderRadius.circular(
                          AppSizes.navBarRadius,
                        ),
                      ),
                    ),
                    SizedBox(width: AppSizes.sizedBoxSmall),
                    Expanded(
                      child: SelectableText(
                        e.stackTrace.toString(),
                        style: textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppSizes.sizedBoxLarge),
            ],
          ],
        ),
      ),
    );
  }
}
