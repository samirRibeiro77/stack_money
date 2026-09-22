import 'package:flutter/material.dart';
import 'package:stack_money/core/l10n/app_localizations.dart';
import 'package:stack_money/data/models/bucket.dart';

enum CfoStarterSuggestion {
  ecosystemAudit(Icons.radar_rounded),
  targetPacing(Icons.speed_rounded),
  maxCashFlow(Icons.sync_alt_rounded),
  cfoProtocols(Icons.integration_instructions_rounded),
  moneySprint(Icons.savings_outlined);

  final IconData icon;

  const CfoStarterSuggestion(this.icon);

  /// Translated title
  String title(AppLocalizations l10n) {
    switch (this) {
      case CfoStarterSuggestion.ecosystemAudit:
        return l10n.cfoSuggestionEcosystemAuditTitle;
      case CfoStarterSuggestion.targetPacing:
        return l10n.cfoSuggestionTargetPacingTitle;
      case CfoStarterSuggestion.maxCashFlow:
        return l10n.cfoSuggestionMaxCashFlowTitle;
      case CfoStarterSuggestion.cfoProtocols:
        return l10n.cfoSuggestionCfoProtocolsTitle;
      case CfoStarterSuggestion.moneySprint:
        return l10n.cfoSuggestionMoneySprintTitle;
    }
  }

  /// Translated AI prompt
  String prompt(AppLocalizations l10n) {
    switch (this) {
      case CfoStarterSuggestion.ecosystemAudit:
        return l10n.cfoSuggestionEcosystemAuditPrompt;
      case CfoStarterSuggestion.targetPacing:
        return l10n.cfoSuggestionTargetPacingPrompt;
      case CfoStarterSuggestion.maxCashFlow:
        return l10n.cfoSuggestionMaxCashFlowPrompt;
      case CfoStarterSuggestion.cfoProtocols:
        return l10n.cfoSuggestionCfoProtocolsPrompt;
      case CfoStarterSuggestion.moneySprint:
        return l10n.cfoSuggestionMoneySprintPrompt;
    }
  }

  /// Translated AI template
  String template(AppLocalizations l10n, {Bucket? bucket}) {
    switch (this) {
      case CfoStarterSuggestion.moneySprint:
        if (bucket == null) {
          return l10n.error;
        }
        return l10n.cfoSuggestionMoneySprintTemplate(bucket.id, bucket.name);
      default:
        return '';
    }
  }
}
