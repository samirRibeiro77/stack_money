import 'package:stack_money/data/enum/action_status.dart';

class ProposedActionModel {
  final String id;
  final String actionType; // ex: 'update_bucket', 'update_plan'
  final String title;
  final String description;
  final Map<String, dynamic> payload;
  final ActionStatus status;

  const ProposedActionModel({
    required this.id,
    required this.actionType,
    required this.title,
    required this.description,
    required this.payload,
    this.status = ActionStatus.pending,
  });

  ProposedActionModel copyWith({
    ActionStatus? status,
  }) {
    return ProposedActionModel(
      id: id,
      actionType: actionType,
      title: title,
      description: description,
      payload: payload,
      status: status ?? this.status,
    );
  }
}