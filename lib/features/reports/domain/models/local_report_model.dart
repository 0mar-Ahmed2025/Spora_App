import 'report_enums.dart';

class LocalReportModel {
  final String localId;
  final String? serverId;
  final String title;
  final String description;
  final String categoryId;
  final ReportPriorityEnum priority;
  final String? imagePath;
  final double? latitude;
  final double? longitude;
  final ReportStatusEnum status;
  final int retryCount;
  final String? lastError;
  final DateTime createdAt;
  final DateTime updatedAt;

  const LocalReportModel({
    required this.localId,
    this.serverId,
    required this.title,
    required this.description,
    required this.categoryId,
    required this.priority,
    this.imagePath,
    this.latitude,
    this.longitude,
    required this.status,
    this.retryCount = 0,
    this.lastError,
    required this.createdAt,
    required this.updatedAt,
  });

  LocalReportModel copyWith({
    String? localId,
    String? serverId,
    String? title,
    String? description,
    String? categoryId,
    ReportPriorityEnum? priority,
    String? imagePath,
    double? latitude,
    double? longitude,
    ReportStatusEnum? status,
    int? retryCount,
    String? lastError,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LocalReportModel(
      localId: localId ?? this.localId,
      serverId: serverId ?? this.serverId,
      title: title ?? this.title,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      priority: priority ?? this.priority,
      imagePath: imagePath ?? this.imagePath,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      status: status ?? this.status,
      retryCount: retryCount ?? this.retryCount,
      lastError: lastError ?? this.lastError,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'local_id': localId,
      'server_id': serverId,
      'title': title,
      'description': description,
      'category_id': categoryId,
      'priority': priority.name,
      'image_path': imagePath,
      'latitude': latitude,
      'longitude': longitude,
      'status': status.name,
      'retry_count': retryCount,
      'last_error': lastError,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory LocalReportModel.fromMap(Map<String, dynamic> map) {
    return LocalReportModel(
      localId: map['local_id'] as String,
      serverId: map['server_id'] as String?,
      title: map['title'] as String,
      description: map['description'] as String,
      categoryId: map['category_id'] as String,
      priority: ReportPriorityEnum.fromString(map['priority'] as String),
      imagePath: map['image_path'] as String?,
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      status: ReportStatusEnum.fromString(map['status'] as String),
      retryCount: map['retry_count'] as int? ?? 0,
      lastError: map['last_error'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
}
