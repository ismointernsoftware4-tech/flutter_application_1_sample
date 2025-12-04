import 'dart:io';

import 'package:path_provider/path_provider.dart';

Future<String> saveCsvFile(String content, String fileName) async {
  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/$fileName');
  await file.writeAsString(content);
  return file.path;
}


