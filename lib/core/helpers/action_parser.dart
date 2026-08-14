import 'dart:convert';
import 'package:stack_money/core/exceptions/exception_scope.dart';
import 'package:stack_money/core/exceptions/stack_money_exception.dart';
import 'package:stack_money/data/models/proposed_action_model.dart';

class ParsedCfoResponse {
  final String cleanText;
  final ProposedActionModel? action;

  const ParsedCfoResponse({required this.cleanText, this.action});
}

class ActionParser {
  static final _actionRegex = RegExp(
    r'<<<PROPOSED_ACTION\s*(\{.*?\})\s*>>>',
    dotAll: true,
  );

  static ParsedCfoResponse parse(String fullResponse) {
    final match = _actionRegex.firstMatch(fullResponse);

    if (match == null) {
      return ParsedCfoResponse(cleanText: fullResponse);
    }

    final jsonString = match.group(1);
    final cleanText = fullResponse.replaceFirst(match.group(0)!, '').trim();

    if (jsonString == null || jsonString.isEmpty) {
      return ParsedCfoResponse(cleanText: cleanText);
    }

    try {
      final Map<String, Object?>? map = jsonDecode(jsonString);
      final action = ProposedActionModel.fromJson(map);
      return ParsedCfoResponse(cleanText: cleanText, action: action);
    } catch (e, stack) {
      StackMoneyException(
        message: 'Error parsing action',
        scope: ExceptionScope.business,
        payload: {'text': fullResponse},
        exception: e as Exception,
        stackTrace: stack,
      );
      return ParsedCfoResponse(cleanText: cleanText);
    }
  }
}
