enum ChatSender { user, assistant }

class ChatMessage {
  final String id;
  final ChatSender sender;
  final String text;
  final Map<String, dynamic>? attachedData;
  final DateTime timestamp;

  const ChatMessage({
    required this.id,
    required this.sender,
    required this.text,
    this.attachedData,
    required this.timestamp,
  });

  ChatMessage copyWith({
    String? id,
    ChatSender? sender,
    String? text,
    Map<String, dynamic>? attachedData,
    DateTime? timestamp,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      sender: sender ?? this.sender,
      text: text ?? this.text,
      attachedData: attachedData ?? this.attachedData,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      sender: ChatSender.values.firstWhere((e) => e.name == json['sender']),
      text: json['text'] as String,
      attachedData: json['attachedData'] as Map<String, dynamic>?,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender': sender.name,
      'text': text,
      'attachedData': attachedData,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
