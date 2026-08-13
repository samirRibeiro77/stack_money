import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/constants/app_typography.dart';
import 'package:stack_money/core/theme/theme.dart';

class CyberMarkdown extends StatelessWidget {
  final String data;
  final TextStyle? p;

  const CyberMarkdown(this.data, {this.p, super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return MarkdownBody(
      data: data,
      selectable: true,
      styleSheet: MarkdownStyleSheet(
        // Parágrafos Padrão
        p: p ?? textTheme.bodyLarge,

        // Negritos (Destaque Neon Cyan)
        strong: (p ?? textTheme.bodyLarge)?.copyWith(
          color: StackMoneyTheme.cyanNeon,
          fontWeight: AppTypography.weightBold,
        ),

        // Títulos (H1, H2, H3)
        h1: textTheme.titleLarge?.copyWith(
          color: StackMoneyTheme.cyanNeon,
          fontWeight: AppTypography.weightBold,
        ),
        h2: textTheme.titleMedium?.copyWith(
          color: StackMoneyTheme.magentaNeon,
          fontWeight: AppTypography.weightBold,
        ),
        h3: textTheme.titleMedium?.copyWith(color: StackMoneyTheme.cyanNeon),

        // Listas com Marcadores Neon
        listBullet: (p ?? textTheme.bodyLarge)?.copyWith(
          color: StackMoneyTheme.magentaNeon,
          fontWeight: AppTypography.weightBold,
        ),

        // Tabelas Leves & Minimalistas
        tableBorder: TableBorder.all(
          color: StackMoneyTheme.mutedGrey,
          width: AppSizes.min,
        ),
        tableHead: (p ?? textTheme.bodyLarge)?.copyWith(
          color: StackMoneyTheme.magentaNeon,
          fontWeight: AppTypography.weightBold,
        ),
        tableBody: (p ?? textTheme.bodyLarge),
        tablePadding: const EdgeInsets.only(
          top: AppSizes.sizedBoxSmall,
          right: AppSizes.sizedBoxSmall,
          left: AppSizes.sizedBoxSmall,
          bottom: AppSizes.x10,
        ),
        tableColumnWidth: IntrinsicColumnWidth(),
        tableHeadAlign: TextAlign.center,

        // Blocos de Código Inline / Citações
        code: textTheme.bodyMedium?.copyWith(
          color: StackMoneyTheme.magentaNeon,
          backgroundColor: StackMoneyTheme.carbonGrey.withValues(alpha: 0.5),
          fontWeight: AppTypography.weightMedium,
        ),
        codeblockDecoration: BoxDecoration(
          color: StackMoneyTheme.carbonGrey.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          border: Border.all(
            color: StackMoneyTheme.magentaNeon.withValues(alpha: 0.4),
            width: AppSizes.min,
          ),
        ),

        // Teste
        horizontalRuleDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          border: Border.all(
            color: StackMoneyTheme.magentaNeon.withValues(alpha: 0.4),
            width: 1,
          ),
        )
      ),
    );
  }
}
