import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/constants/app_typography.dart';
import 'package:stack_money/core/theme/theme.dart';

class CyberMarkdown extends StatelessWidget {
  final String data;
  final TextStyle? p;
  final double horizontalPadding;

  const CyberMarkdown(
    this.data, {
    this.p,
    this.horizontalPadding = AppSizes.sizedBoxLarge,
    super.key,
  });

  BoxDecoration _cardDecoration(Color color) {
    return BoxDecoration(
      color: color.withAlpha(30),
      borderRadius: BorderRadius.zero,
      border: Border.all(
        color: color.withAlpha(60),
        width: 1,
      ),
    );
  }

  EdgeInsets get _cardPadding =>
      EdgeInsets.symmetric(vertical: AppSizes.x2, horizontal: AppSizes.x4);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return MarkdownBody(
      data: data,
      selectable: true,
      styleSheet: MarkdownStyleSheet(
        /// Standard paragraph
        p: p ?? textTheme.bodyLarge,
        pPadding: EdgeInsets.symmetric(horizontal: horizontalPadding),

        /// Bold
        strong: (p ?? textTheme.bodyLarge)?.copyWith(
          color: StackMoneyTheme.cyanNeon,
          fontWeight: AppTypography.weightBold,
        ),

        /// Titles
        /// - H1
        h1: textTheme.titleLarge?.copyWith(
          color: StackMoneyTheme.cyanNeon,
          fontWeight: AppTypography.weightBold,
        ),
        h1Padding: EdgeInsets.symmetric(horizontal: horizontalPadding),

        /// - H2
        h2: textTheme.titleLarge?.copyWith(
          color: StackMoneyTheme.magentaNeon,
          fontWeight: AppTypography.weightBold,
        ),
        h2Padding: EdgeInsets.symmetric(horizontal: horizontalPadding),

        /// - H3
        h3: textTheme.titleMedium?.copyWith(color: StackMoneyTheme.cyanNeon),
        h3Padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding + AppSizes.x4,
        ),

        /// - H4
        h4: textTheme.titleMedium?.copyWith(color: StackMoneyTheme.magentaNeon),
        h4Padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding + AppSizes.x4,
        ),

        /// - H5
        h5: textTheme.titleMedium?.copyWith(
          color: StackMoneyTheme.cyanNeon,
          fontWeight: AppTypography.weightNormal,
        ),
        h5Padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding + AppSizes.x8,
        ),

        /// - H6
        h6: textTheme.titleMedium?.copyWith(
          color: StackMoneyTheme.magentaNeon,
          fontWeight: AppTypography.weightNormal,
        ),
        h6Padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding + AppSizes.x8,
        ),

        /// List
        listBullet: (p ?? textTheme.bodyLarge)?.copyWith(
          color: StackMoneyTheme.magentaNeon,
          fontWeight: AppTypography.weightBold,
        ),
        listBulletPadding: EdgeInsets.symmetric(horizontal: horizontalPadding),

        /// Table
        tableBorder: TableBorder.all(
          color: StackMoneyTheme.mutedGrey,
          width: AppSizes.min,
        ),
        tableHead: (p ?? textTheme.bodyLarge)?.copyWith(
          color: StackMoneyTheme.magentaNeon,
          fontWeight: AppTypography.weightBold,
        ),
        tableBody: (p ?? textTheme.bodyLarge),
        tablePadding: EdgeInsets.only(
          top: AppSizes.sizedBoxSmall,
          right: horizontalPadding,
          left: horizontalPadding,
          bottom: AppSizes.x10,
        ),
        tableColumnWidth: IntrinsicColumnWidth(),
        tableHeadAlign: TextAlign.center,

        /// Code block
        code: (p ?? textTheme.bodyLarge)?.copyWith(
          color: StackMoneyTheme.magentaNeon,
          backgroundColor: StackMoneyTheme.carbonGrey.withValues(alpha: 0.6),
          fontWeight: AppTypography.weightMedium,
        ),
        codeblockDecoration: _cardDecoration(StackMoneyTheme.magentaNeon),
        codeblockPadding: _cardPadding,

        /// Quote
        blockquote: textTheme.titleSmall,
        blockquoteDecoration: _cardDecoration(StackMoneyTheme.cyanNeon),
        blockquotePadding: _cardPadding,

        /// Divider
        horizontalRuleDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          border: Border.all(
            color: StackMoneyTheme.platinumSilver.withValues(alpha: 0.4),
            width: 1,
          ),
        ),
      ),
    );
  }
}
