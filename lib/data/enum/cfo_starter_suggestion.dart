import 'package:flutter/material.dart';
import 'package:stack_money/core/l10n/app_localizations.dart';

enum CfoStarterSuggestion {
  ecosystemAudit(Icons.radar_rounded),
  targetPacing(Icons.speed_rounded),
  maxCashFlow(Icons.sync_alt_rounded),
  cfoProtocols(Icons.integration_instructions_rounded);

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
    }
  }
}
