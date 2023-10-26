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
      '$year-${zeroPadNumber(month)}-${zeroPadNumber(day)} ${zeroPadNumber(hour)}'
          ':${zeroPadNumber(minute)}:${zeroPadNumber(second)}'
          '${timeZoneOffset.isNegative ? '-' : '+'}${zeroPadNumber(offsetHours)}:'
          '${zeroPadNumber(offsetMinutes)}',
      fromId != null ? 'PeerUser(user_id=$fromId)' : '',
      toId,
      fwdFrom,
      '"${message.replaceAll('"', '""').replaceAll(RegExp(r'\s+'), ' ')}"',
      messageType.name,
      duration,
      reactions,
    ];

    assert(columns.length == csvHeader.split(',').length);

    return columns.join(',');
  }
}

String zeroPadNumber(int number) => number.toString().padLeft(2, '0');
