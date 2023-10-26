import 'package:json_to_csv_parser/src/model/message.dart';
import 'package:json_to_csv_parser/src/model/message_type.dart';

typedef DecodedDialog = ({int userId, List<Message> messages});

String decodeRichText(List<Object> richText) => richText.map((entry) {
      if (entry is String) {
        return entry;
      }

      if (entry is Map<String, dynamic>) {
        final maybeText = entry['text'] as String?;
        if (maybeText != null) {
          return maybeText;
        }
      }

      return '';
    }).join();

Message? decodeMessage(
  Map<String, dynamic> json, {
  required int chatOwnerId,
  required int userId,
}) {
  // skip phone calls, pinned messages, joined announcements
  final action = json['action'];
  if (action == 'phone_call' || action == 'pin_message' || action == 'joined_telegram') {
    return null;
  }

  final id = json['id'] as int?;
  final dateStr = json['date_unixtime'] as String?;
  final fromIdStr = json['from_id'] as String?;
  final fwdFrom = json['forwarded_from'] as String?;
  final durationSeconds = json['duration_seconds'] as int?;
  final richText = json['text'] as Object? ?? '';

  if (id == null || dateStr == null || fromIdStr == null) {
    return null;
  }

  final type = MessageType.typeOf(json);

  if ((type == MessageType.video || type == MessageType.audio) && durationSeconds == null) {
    return null;
  }

  final date = DateTime.fromMillisecondsSinceEpoch(int.parse(dateStr) * 1000).toUtc();
  final fromId = int.parse(fromIdStr.replaceFirst('user', ''));
  final toId = fromId == userId ? chatOwnerId : userId;
  final message = decodeRichText(richText is List<Object> ? richText : [richText]);

  return Message(
    id: id,
    date: date,
    toId: toId,
    fromId: toId == chatOwnerId ? null : chatOwnerId,
    messageType: type,
    message: message,
    duration: durationSeconds,
    fwdFrom: fwdFrom ?? '',
  );
}

DecodedDialog decodeDialog(
  List<Map<String, dynamic>> dialogJson, {
  required int chatOwnerId,
}) {
  final ownerIdStr = 'user$chatOwnerId';
  final userIdStr = dialogJson
      .map((msgJson) => msgJson['from_id'] as String?)
      .whereType<String>()
      .firstWhere((id) => id != ownerIdStr, orElse: () => '-1')
      .replaceFirst('user', '');
  final userId = int.parse(userIdStr);

  final messages = dialogJson
      .map((messageJson) => decodeMessage(messageJson, chatOwnerId: chatOwnerId, userId: userId))
      .whereType<Message>()
      .toList();

  return (userId: userId, messages: messages);
}

List<DecodedDialog> decode(Map<String, dynamic> json, {required int chatOwnerId}) {
  final chats = json['chats'] as Map<String, dynamic>?;

  if (chats == null || chats.isEmpty) {
    return [];
  }

  final chatsList = chats['list'] as List?;

  if (chatsList == null) {
    return [];
  }

  return chatsList.map<DecodedDialog>((chatJson) {
    final messagesJson = chatJson['messages'] as List?;

    if (messagesJson == null || messagesJson.isEmpty) {
      return (userId: -1, messages: []);
    }

    return decodeDialog(messagesJson.cast<Map<String, dynamic>>(), chatOwnerId: chatOwnerId);
  }).toList();
}
