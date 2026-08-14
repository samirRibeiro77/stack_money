import 'package:cloud_firestore/cloud_firestore.dart';

class TimestampParser {
  static Timestamp fromJson(Object? value) {
    if (value == null) {
      return Timestamp.now();
    }

    // 1. Se já for um Timestamp, retorna ele mesmo
    if (value is Timestamp) {
      return value;
    }

    // 2. Se for um DateTime do Dart, converte para Timestamp
    if (value is DateTime) {
      return Timestamp.fromDate(value);
    }

    // 3. Se for uma String, tenta transformá-la em DateTime e depois em Timestamp
    if (value is String) {
      try {
        DateTime parsedDate = DateTime.parse(value);
        return Timestamp.fromDate(parsedDate);
      } catch (e) {
        throw FormatException("A string fornecida não está em um formato de data válido (ISO 8601). Erro: $e");
      }
    }

    // 4. Se o valor for nulo ou de um tipo não esperado, define um valor padrão ou lança erro
    // Aqui estamos retornando o horário atual como segurança, mas você pode adaptar.
    return Timestamp.now();
  }
}