import 'dart:io';

class DataExportModel {
  final int planQty;
  final int bucketQty;
  final int historyQty;
  final File? file;

  DataExportModel({
    required this.planQty,
    required this.bucketQty,
    required this.historyQty,
    this.file,
  });

  factory DataExportModel.empty() {
    return DataExportModel(planQty: 0, bucketQty: 0, historyQty: 0);
  }

  String get fileSize {
    if (file == null) {
      return '0.0';
    }

    final int bytes = file!.lengthSync();
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(2)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }
}
