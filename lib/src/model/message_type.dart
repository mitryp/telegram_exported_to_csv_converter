typedef MessageTypePredicate = bool Function(Map<String, dynamic> json);

enum MessageType {
  photo(_photoMessagePredicate),
  video(_videoMessagePredicate),
  audio(_audioMessagePredicate),
  sticker(_stickerMessagePredicate),
  voice(_voiceMessagePredicate),
  text(_textMessagePredicate);

  final MessageTypePredicate predicate;

  const MessageType(this.predicate);

  static MessageType typeOf(Map<String, dynamic> json) {
    return values.firstWhere((type) => type.predicate(json), orElse: () => text);
  }
}

bool _photoMessagePredicate(Map<String, dynamic> json) => json.containsKey('photo');

bool _videoMessagePredicate(Map<String, dynamic> json) {
  final val = json['message_type'];

  return val == 'video_file' || val == 'video_message' || val == 'animation';
}

bool _stickerMessagePredicate(Map<String, dynamic> json) => json['message_type'] == 'sticker';

bool _voiceMessagePredicate(Map<String, dynamic> json) => json['message_type'] == 'voice_message';

bool _audioMessagePredicate(Map<String, dynamic> json) => json['message_type'] == 'audio_message';

bool _textMessagePredicate(Map<String, dynamic> _) => true;
