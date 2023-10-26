import 'dart:io';

import 'package:json_to_csv_parser/json_to_csv_parser.dart';

const outputDir = 'output';

String argsToPath(List<String> args) {
  if (args.isEmpty) {
    print('File path is not specified');
    exit(1);
  }

  return args.join(' ');
}

void main(List<String> arguments) {
  final fileName = argsToPath(arguments);
  Directory(outputDir).createSync();

  final t00 = DateTime.now();

  final json = readJson(fileName);
  final res = decode(json, chatOwnerId: 477350397);

  final t01 = DateTime.now();

  print('parsing took ${(t01.millisecondsSinceEpoch - t00.millisecondsSinceEpoch) / 1000} seconds');
  print('dialogs parsed: ${res.length}');
  print('messages parsed: ${res.map((e) => e.messages.length).reduce((val, el) => val + el)}');

  final t10 = DateTime.now();

  var counter = 0;
  for (final (:userId, :messages) in res) {
    if (userId == -1) {
      continue;
    }

    writeCsv(outputDir, '$userId.csv', messages.asMap().entries.map((e) => e.value.toCsv(e.key)));
    counter++;
  }

  final t11 = DateTime.now();

  print(
    'transforming took '
    '${(t11.millisecondsSinceEpoch - t10.millisecondsSinceEpoch) / 1000} seconds',
  );
  print('files written: $counter');
}
