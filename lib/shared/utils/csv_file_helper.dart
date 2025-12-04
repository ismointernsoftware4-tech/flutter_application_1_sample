import 'csv_file_helper_io.dart'
    if (dart.library.html) 'csv_file_helper_web.dart'
    as helper;

Future<String> saveCsvFile(String content, String fileName) {
  return helper.saveCsvFile(content, fileName);
}


