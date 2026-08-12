import 'package:stack_money/data/enum/action_status.dart';
import 'package:stack_money/data/helper/model_key.dart';
import 'package:uuid/uuid.dart';

class ProposedActionModel {
  final String _id;
  final String actionType;
  final String title;
  final String description;
  final Map<String, Object?> payload;
  final ActionStatus status;

  String get id => _id;

  ProposedActionModel({
    String? id,
    required this.actionType,
    required this.title,
    required this.description,
    required this.payload,
    this.status = ActionStatus.pending,
  }) : _id = id ?? const Uuid().v4();

  static ProposedActionModel? fromJson(Map<String, Object?>? json) {
    return json == null ? null : ProposedActionModel(
      id: json[ModelKey.id] as String?,
      actionType: json[ModelKey.actionType] as String? ?? '',
      title: json[ModelKey.title] as String? ?? '',
      description: json[ModelKey.description] as String? ?? '',
      payload: Map<String, Object?>.from(json[ModelKey.payload] as Map? ?? {}),
      status: ActionStatus.fromJson(json[ModelKey.status] as String?),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      ModelKey.id: _id,
      ModelKey.actionType: actionType,
      ModelKey.title: title,
      ModelKey.description: description,
      ModelKey.payload: payload,
      ModelKey.status: status.name,
    };
  }

  ProposedActionModel copyWith({ActionStatus? status, bool newId = false}) {
    return ProposedActionModel(
      id: newId ? const Uuid().v4() : _id,
      actionType: actionType,
      title: title,
      description: description,
      payload: payload,
      status: status ?? this.status,
    );
  }
}
