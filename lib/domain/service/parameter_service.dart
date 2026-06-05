import 'package:stack_money/data/models/bucket.dart';
import 'package:stack_money/data/repository/firebase_parameter_repository.dart'; // Ajuste o import se necessário

class ParameterManagementService {
  final FirebaseParameterRepository _repository = FirebaseParameterRepository();

  Future<List<Bucket>> getActiveParameters() async {
    return await _repository.fetchParameters();
  }

  // 🛰️ Ponte para salvar ou atualizar o Bucket usando o UUID
  Future<void> saveParameter(Bucket bucket) async {
    await _repository.saveParameter(bucket);
  }

  // 🗑️ Ponte para expurgar o documento da subcoleção do usuário
  Future<void> deleteParameter(String id) async {
    await _repository.deleteParameter(id);
  }
}