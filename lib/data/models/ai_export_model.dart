import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:stack_money/data/models/bucket.dart';
import 'package:stack_money/data/models/chat_message_model.dart';
import 'package:stack_money/data/models/history.dart';
import 'package:stack_money/data/models/salary_plan.dart';

class AiExportModel {
  final String systemPrompt;
  final List<SalaryPlan>? plans;
  final List<Bucket>? buckets;
  final List<History>? history;
  final String? chatName;
  final List<ChatMessageModel>? messages;
  final DateTime _exportedAt;

  AiExportModel({
    required this.systemPrompt,
    this.plans,
    this.buckets,
    this.history,
    this.chatName,
    this.messages,
  }) : _exportedAt = DateTime.now();

  bool get hasRealTimeData =>
      plans != null || buckets != null || history != null;

  /// Optimized Markdown for LLMs
  String toMD() {
    final buffer = StringBuffer();
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm:ss');

    /// Headers
    buffer.writeln('# 🤖 STACK MONEY - PERSONAL CFO FULL CONTEXT EXPORT');
    buffer.writeln('> **Export Date:** ${dateFormat.format(_exportedAt)} UTC');
    buffer.writeln('>');
    buffer.writeln('> **Application:** Stack Money');
    buffer.writeln('>');
    buffer.writeln(
      '> **Purpose:** Complete context prompt transfer for external LLM execution',
    );
    buffer.writeln('\n');

    /// System Prompt
    buffer.writeln('## 📜 SYSTEM PROMPT & ROLE DEFINITION');
    buffer.writeln('```markdown');
    buffer.writeln(systemPrompt);

    /// Real time data
    if (hasRealTimeData) {
      /// Salary Plans
      if (plans?.isNotEmpty ?? false) {
        buffer.writeln('\n### Salary Plans');
        buffer.writeln(_parseData(plans!.map((p) => p.toJson()).toList()));
        buffer.writeln('\n');
      }

      /// Buckets
      if (buckets?.isNotEmpty ?? false) {
        buffer.writeln('\n### Buckets');
        buffer.writeln(_parseData(buckets!.map((b) => b.toJson()).toList()));
        buffer.writeln('\n');
      }

      /// History
      if (history?.isNotEmpty ?? false) {
        buffer.writeln('\n### History');
        buffer.writeln(_parseData(history!.map((h) => h.toJson()).toList()));
        buffer.writeln('\n');
      }
    }
    buffer.writeln('```\n\n');

    /// Personal CFO Transcription
    if (messages?.isNotEmpty ?? false) {
      buffer.writeln('## 💬 CONVERSATION TRANSCRIPT');
      if (chatName != null) {
        buffer.writeln('> **$chatName:**');
      }
      buffer.writeln('```json');
      buffer.writeln(_parseData(messages!.map((m) => m.toJson()).toList()));
      buffer.writeln('```\n\n');
    }

    /// Finals instructions for LLM
    buffer.writeln('---');
    buffer.writeln('### 🎯 INSTRUCTION FOR EXTERNAL LLM:');
    buffer.writeln(
      'You are now initialized as the user\'s Personal CFO for Stack Money based on the context, rules, and conversation transcript above. '
      'Acknowledge this context warmly and await the user\'s next financial prompt.',
    );

    return buffer.toString();
  }

  String _parseData(List<Object?> jsonList) {
    return jsonEncode(
      jsonList,
      toEncodable: (nonEncodable) {
        if (nonEncodable is Timestamp) {
          return nonEncodable.toDate().toIso8601String();
        }
        return nonEncodable.toString();
      },
    );
  }
}
