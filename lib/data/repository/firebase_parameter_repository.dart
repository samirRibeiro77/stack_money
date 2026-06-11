import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stack_money/data/models/bucket.dart';

class FirebaseParameterRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<List<Bucket>> fetchParameters() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception('USER_NOT_AUTHENTICATED');

      final snapshot = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('parameters')
          .get();

      print(
        'DEBUG_SYSTEM [ParameterRepository]: Fetch complete -> ${snapshot.docs.length} entries loaded.',
      );

      return snapshot.docs.map((doc) {
        return Bucket.fromJson(doc.data());
      }).toList();
    } catch (e) {
      print(
        'DEBUG_SYSTEM [ParameterRepository]: Error fetching parameters -> $e',
      );
      rethrow;
    }
  }

  // 🚀 SILENT SYNC PROTOCOL + FALLBACK TEMPORÁRIO
  Future<void> saveParameter(Bucket bucket) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception('USER_NOT_AUTHENTICATED');

      // 🧪 FALLBACK: Injeta strings temporárias se o usuário inicializou o slot mas não digitou nada ainda
      final cleanWhere = bucket.where.trim().isEmpty
          ? 'BUCKET'
          : bucket.where.trim();
      final cleanCategory = bucket.category.trim().isEmpty
          ? 'NEW'
          : bucket.category.trim();

      final bkpBucket = Bucket(
        id: bucket.id,
        where: cleanWhere,
        category: cleanCategory,
        minValue: bucket.minValue,
        isImmediateLiquidity: bucket.isImmediateLiquidity,
      );

      print(
        '📡 [FIRESTORE_WRITE] -> Initializing sync for UUID: ${bkpBucket.id}',
      );

      // Executa sem o 'await' explícito na chamada da tela (Silent Sync)
      // para a UI destravar na hora, deixando o Firestore sincronizar em background!
      _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('parameters')
          .doc(bkpBucket.id)
          .set(bkpBucket.toJson(), SetOptions(merge: true))
          .then((_) {
            print(
              '✅ [FIRESTORE_SUCCESS] -> Document synced in background: ${bkpBucket.id} (${cleanCategory}_$cleanWhere)',
            );
          })
          .catchError((error) {
            print(
              '❌ [FIRESTORE_FAIL] -> Background sync failed for ${bkpBucket.id}: $error',
            );
          });
    } catch (e) {
      print(
        'DEBUG_SYSTEM [ParameterRepository]: Critical error pre-saving -> $e',
      );
      rethrow;
    }
  }

  // 🗑️ SAFE DELETE INTERCEPTOR (BLOQUEIO DE SEGURANÇA)
  Future<void> deleteParameter(String id) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception('USER_NOT_AUTHENTICATED');

      print(
        '🔍 [SECURITY_CHECK] -> Evaluating purge authorization for UUID: $id',
      );

      // Busca o documento atual direto no banco para checar o saldo real dele antes de apagar
      final docSnap = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('parameters')
          .doc(id)
          .get();

      if (docSnap.exists) {
        final currentData = docSnap.data();
        // Nota: Assumindo que seu JSON salve o saldo acumulado atual no campo 'currentValue' ou similar.
        // Se o seu model de Bucket só tiver o 'minValue', use o 'minValue' para o teste de validação:
        final double currentBalance =
            (currentData?['minValue'] as num?)?.toDouble() ?? 0.0;

        // 🛑 SÓ DEIXA EXCLUIR SE O VALOR ESTIVER ZERADO!
        if (currentBalance > 0.0) {
          print(
            '🚫 [PURGE_DENIED] -> Operation aborted. Bucket $id contains active allocation funds (R\$ $currentBalance).',
          );
          throw Exception('PURGE_DENIED: BUCKET_HAS_ACTIVE_FUNDS');
        }
      }

      print(
        '🔥 [PURGE_PROTOCOL] -> Executing permanent destruction on UUID: $id',
      );

      await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('parameters')
          .doc(id)
          .delete();

      print(
        '🗑️ [FIRESTORE_SUCCESS] -> Document expurged from system core: $id',
      );
    } catch (e) {
      print(
        'DEBUG_SYSTEM [ParameterRepository]: Error executing purge protocol -> $e',
      );
      rethrow;
    }
  }
}
