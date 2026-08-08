import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stack_money/data/helper/firebase_key.dart';
import 'package:stack_money/data/repository/base_firebase_repository.dart';

class FirebaseAiRepository extends BaseFirebaseRepository {
  CollectionReference<Map<String, Object?>> get _collection =>
      getUserDoc().collection(FirebaseKey.buckets);
}