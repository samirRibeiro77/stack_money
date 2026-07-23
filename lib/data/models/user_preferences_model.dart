import 'package:stack_money/data/enum/dashboard_sort_filter.dart';
import 'package:stack_money/data/helper/model_key.dart';

class UserPreferencesModel {
  final bool securityMode;
  final bool cardExpand;
  final DashboardSortFilter? defaultFilter;
  final DashboardSortFilter lastFilter;

  const UserPreferencesModel({
    this.securityMode = true,
    this.cardExpand = false,
    this.lastFilter = DashboardSortFilter.position,
    this.defaultFilter,
  });

  factory UserPreferencesModel.fromJson(Map<String, Object?>? json) {
    if (json == null) {
      return UserPreferencesModel();
    }

    return UserPreferencesModel(
      securityMode: json[ModelKey.securityMode] as bool? ?? true,
      cardExpand: json[ModelKey.cardExpand] as bool? ?? false,
      lastFilter:
          DashboardSortFilter.fromJson(
            json[ModelKey.lastFilter] as String?,
          ) ??
          DashboardSortFilter.position,
      defaultFilter: DashboardSortFilter.fromJson(
        json[ModelKey.defaultFilter] as String?,
      ),
    );
  }

  Map<String, Object?> toJson() {
    return {
      ModelKey.securityMode: securityMode,
      ModelKey.cardExpand: cardExpand,
      ModelKey.lastFilter: lastFilter.name,
      ModelKey.defaultFilter: defaultFilter?.name,
    };
  }

  UserPreferencesModel copyWith({
    bool? securityMode,
    bool? cardExpand,
    DashboardSortFilter? lastFilter,
    DashboardSortFilter? defaultFilter,
  }) {
    return UserPreferencesModel(
      securityMode: securityMode ?? this.securityMode,
      cardExpand: cardExpand ?? this.cardExpand,
      lastFilter: lastFilter ?? this.lastFilter,
      defaultFilter: defaultFilter ?? this.defaultFilter,
    );
  }
}
