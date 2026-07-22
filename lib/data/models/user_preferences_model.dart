import 'package:stack_money/data/enum/dashboard_sort_filter.dart';
import 'package:stack_money/data/helper/model_key.dart';

class UserPreferencesModel {
  final bool securityMode;
  final bool cardExpand;
  final DashboardSortFilter? defaultFilter;

  const UserPreferencesModel({
    this.securityMode = false,
    this.cardExpand = true,
    this.defaultFilter,
  });

  factory UserPreferencesModel.fromJson(Map<String, Object?>? json) {
    if (json == null) {
      return UserPreferencesModel();
    }

    return UserPreferencesModel(
      securityMode: json[ModelKey.securityMode] as bool? ?? false,
      cardExpand: json[ModelKey.cardExpand] as bool? ?? true,
      defaultFilter: DashboardSortFilter.fromJson(
        json[ModelKey.defaultFilter] as String?,
      ),
    );
  }

  Map<String, Object?> toJson() {
    return {
      ModelKey.securityMode: securityMode,
      ModelKey.cardExpand: cardExpand,
      ModelKey.defaultFilter: defaultFilter?.name,
    };
  }

  UserPreferencesModel copyWith({
    bool? securityMode,
    bool? cardExpand,
    DashboardSortFilter? defaultFilter,
  }) {
    return UserPreferencesModel(
      securityMode: securityMode ?? this.securityMode,
      cardExpand: cardExpand ?? this.cardExpand,
      defaultFilter: defaultFilter ?? this.defaultFilter,
    );
  }
}
