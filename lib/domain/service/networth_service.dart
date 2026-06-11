import 'package:stack_money/data/models/net_worth.dart';
import 'package:stack_money/data/repository/firebase_networth_repository.dart';

class NetworthManagementService {
  final FirebaseNetworthRepository _networthRepository = FirebaseNetworthRepository();

  Future<NetWorth> get() async {
    return await _networthRepository.get();
  }
}