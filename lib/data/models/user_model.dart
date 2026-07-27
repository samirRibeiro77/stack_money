import 'package:firebase_auth/firebase_auth.dart';
import 'package:stack_money/data/helper/model_key.dart';
import 'package:stack_money/data/models/user_preferences_model.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String photoUrl;
  final UserPreferencesModel preferences;

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.photoUrl,
    this.preferences = const UserPreferencesModel(),
  });

  factory UserModel.empty() {
    return UserModel(uid: '', name: '', email: '', photoUrl: '');
  }

  factory UserModel.fromJson(Map<String, Object?>? json) {
    return UserModel(
      uid: json?[ModelKey.uid] as String? ?? '',
      name: json?[ModelKey.name] as String? ?? '',
      email: json?[ModelKey.email] as String? ?? '',
      photoUrl: json?[ModelKey.photoUrl] as String? ?? '',
      preferences: UserPreferencesModel.fromJson(json?[ModelKey.preferences] as Map<String, Object?>?),
    );
  }

  factory UserModel.fromUser(User? user) {
    return UserModel(
      uid: user?.uid ?? '',
      name: user?.displayName ?? '',
      email: user?.email ?? '',
      photoUrl: user?.photoURL ?? '',
      preferences: UserPreferencesModel(),
    );
  }

  Map<String, Object?> toJson({bool keepPrefs = false}) {
    final userMap = <String, Object?>{
      ModelKey.uid: uid,
      ModelKey.name: name,
      ModelKey.email: email,
      ModelKey.photoUrl: photoUrl,
    };

    if (keepPrefs) {
      userMap[ModelKey.preferences] = preferences.toJson();
    }

    return userMap;
  }

  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? photoUrl,
    UserPreferencesModel? preferences,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      preferences: preferences ?? this.preferences,
    );
  }
}