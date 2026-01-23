import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String title;
  final String body;
  final String type; // 'class_scheduled', 'broadcast', 'reminder', 'attendance'
  final String targetUserId;
  final String? targetRole; // For broadcasts: 'coach', 'parent', 'all'
  final String? relatedSessionId;
  final DateTime createdAt;
  final bool read;
  final DateTime? readAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.targetUserId,
    this.targetRole,
    this.relatedSessionId,
    required this.createdAt,
    this.read = false,
    this.readAt,
  });

  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NotificationModel(
      id: doc.id,
      title: data['title'] ?? '',
      body: data['body'] ?? '',
      type: data['type'] ?? 'broadcast',
      targetUserId: data['targetUserId'] ?? '',
      targetRole: data['targetRole'],
      relatedSessionId: data['relatedSessionId'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      read: data['read'] ?? false,
      readAt: (data['readAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'body': body,
      'type': type,
      'targetUserId': targetUserId,
      'targetRole': targetRole,
      'relatedSessionId': relatedSessionId,
      'createdAt': Timestamp.fromDate(createdAt),
      'read': read,
      'readAt': readAt != null ? Timestamp.fromDate(readAt!) : null,
    };
  }

  NotificationModel copyWith({
    String? id,
    String? title,
    String? body,
    String? type,
    String? targetUserId,
    String? targetRole,
    String? relatedSessionId,
    DateTime? createdAt,
    bool? read,
    DateTime? readAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      targetUserId: targetUserId ?? this.targetUserId,
      targetRole: targetRole ?? this.targetRole,
      relatedSessionId: relatedSessionId ?? this.relatedSessionId,
      createdAt: createdAt ?? this.createdAt,
      read: read ?? this.read,
      readAt: readAt ?? this.readAt,
    );
  }

  /// Get a user-friendly icon name based on notification type
  String get iconName {
    switch (type) {
      case 'class_scheduled':
        return 'calendar_today';
      case 'broadcast':
        return 'campaign';
      case 'reminder':
        return 'alarm';
      case 'attendance':
        return 'how_to_reg';
      default:
        return 'notifications';
    }
  }

  /// Get time ago string for display
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 7) {
      return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
