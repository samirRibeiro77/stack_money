import 'package:stack_money/data/models/bucket.dart';
import 'package:stack_money/data/repository/firebase_parameter_repository.dart';

class ParameterManagementService {
  final FirebaseParameterRepository _parameterRepository = FirebaseParameterRepository();

  Future<List<Bucket>> getActiveParameters() async {
    // Aqui você pode injetar regras futuras, como filtrar potes arquivados ou ordenar por prioridade
    return await _parameterRepository.fetchParameters();
  }
}