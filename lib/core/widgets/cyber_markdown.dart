import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/constants/app_typography.dart';
import 'package:stack_money/core/theme/theme.dart';

class CyberMarkdown extends StatelessWidget {
  final String data;

  const CyberMarkdown({required this.data, super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return MarkdownBody(
      data: data,
      selectable: true,
      styleSheet: MarkdownStyleSheet(
        // Parágrafos Padrão
        p: textTheme.bodyMedium,

        // Negritos (Destaque Neon Cyan)
        strong: textTheme.bodyMedium?.copyWith(
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
        listBullet: textTheme.bodyMedium?.copyWith(
          color: StackMoneyTheme.magentaNeon,
          fontWeight: AppTypography.weightBold,
        ),

        // Tabelas Leves & Minimalistas
        tableBorder: TableBorder.all(
          color: StackMoneyTheme.carbonGrey,
          width: AppSizes.min,
        ),
        tableHead: textTheme.labelMedium?.copyWith(
          color: StackMoneyTheme.cyanNeon,
          fontWeight: AppTypography.weightBold,
        ),
        tableBody: textTheme.bodySmall,
        tablePadding: const EdgeInsets.symmetric(
          horizontal: AppSizes.x3,
          vertical: AppSizes.x2,
        ),
        tableHeadAlign: TextAlign.center,

        // Blocos de Código Inline / Citações
        code: textTheme.bodySmall?.copyWith(
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
      ),
    );
  }
}
