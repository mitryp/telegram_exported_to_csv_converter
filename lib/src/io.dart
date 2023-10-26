import 'dart:convert';
import 'dart:io';

import 'package:json_to_csv_parser/src/model/message.dart';

Map<String, dynamic> readJson(String fileName, {Encoding encoding = utf8}) {
  final file = File(fileName);

  if (!file.existsSync()) {
    print('File does not exit');
    exit(1);
  }

  return jsonDecode(file.readAsStringSync(encoding: encoding)) as Map<String, dynamic>;
}

void writeCsv(String outputDir, String filePath, Iterable<String> data) {
  final file = File('$outputDir/$filePath');

  file.writeAsStringSync([Message.csvHeader, ...data].join('\n'));
}
