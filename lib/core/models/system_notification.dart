enum NotificationType { reward, penalty, info, alert }

class SystemNotification {
  final String id;
  final String playerId;
  final String title;
  final String message;
  final NotificationType type;
  final bool isRead;
  final DateTime createdAt;

  SystemNotification({
    required this.id,
    required this.playerId,
    required this.title,
    required this.message,
    required this.type,
    this.isRead = false,
    required this.createdAt,
  });

  SystemNotification copyWith({
    bool? isRead,
  }) {
    return SystemNotification(
      id: id,
      playerId: playerId,
      title: title,
      message: message,
      type: type,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'player_id': playerId,
      'title': title,
      'message': message,
      'type': type.name,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory SystemNotification.fromJson(Map<String, dynamic> json) {
    return SystemNotification(
      id: json['id'],
      playerId: json['player_id'],
      title: json['title'],
      message: json['message'],
      type: NotificationType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => NotificationType.info,
      ),
      isRead: json['is_read'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
