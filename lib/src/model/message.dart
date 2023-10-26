import 'package:json_to_csv_parser/src/model/message_type.dart';

class Message {
  static const csvHeader = ',id,date,from_id,to_id,fwd_from,message,type,duration,reactions';

  final int id;
  final DateTime date;
  final int? fromId;
  final int toId;
  final String fwdFrom;
  final String message;
  final MessageType messageType;
  final int? duration;

  Set<String> get reactions => {};

  const Message({
    required this.id,
    required this.date,
    this.fromId,
    required this.toId,
    this.fwdFrom = '',
    this.message = '',
    required this.messageType,
    this.duration,
  });

  @override
  String toString() =>
      'Message{id: $id, date: $date, fromId: $fromId, toId: $toId, fwdFrom: $fwdFrom, '
      'message: $message, messageType: $messageType, duration: $duration}';

  String toCsv(int index) {
    final DateTime(:year, :month, :day, :hour, :minute, :second, :timeZoneOffset) = date;
    final offsetHours = timeZoneOffset.inHours;
    final offsetMinutes = timeZoneOffset.inMinutes - offsetHours * 60;
    final fromId = this.fromId;
    final duration = this.duration;

    final columns = [
      index,
      id,
      '$year-${_zeroPadNumber(month)}-${_zeroPadNumber(day)} ${_zeroPadNumber(hour)}'
          ':${_zeroPadNumber(minute)}:${_zeroPadNumber(second)}'
          '${timeZoneOffset.isNegative ? '-' : '+'}${_zeroPadNumber(offsetHours)}:'
          '${_zeroPadNumber(offsetMinutes)}',
      fromId != null ? 'PeerUser(user_id=$fromId)' : '',
      toId,
      _escapeCsv(fwdFrom),
      _escapeCsv(message),
      messageType.name,
      duration,
      reactions,
    ];

    assert(columns.length == csvHeader.split(',').length);

    return columns.join(',');
  }
}

String _zeroPadNumber(int number) => number.toString().padLeft(2, '0');

String _escapeCsv(String data) => '"${data.replaceAll('"', '""').replaceAll(RegExp(r'\s+'), ' ')}"';
