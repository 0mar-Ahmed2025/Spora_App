class UserModel {
  final bool ok;
  final UserData? data;

  UserModel({required this.ok, this.data});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      ok: json['ok'] ?? false,
      data: json['data'] != null ? UserData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'ok': ok, 'data': data?.toJson()};
  }
}

class UserData {
  final String id;
  final String email;
  final String displayName;
  final String firstName;
  final String lastName;
  final String locale;
  final String avatarUrl;
  final String timezone;
  final String mobile;
  final String theme;
  final bool isActive;
  final DateTime? lastActivity;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  UserData({
    required this.id,
    required this.email,
    required this.displayName,
    required this.firstName,
    required this.lastName,
    required this.locale,
    required this.avatarUrl,
    required this.timezone,
    required this.mobile,
    required this.theme,
    required this.isActive,
    this.lastActivity,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    DateTime? safeParseDate(dynamic dateStr) {
      if (dateStr == null || dateStr.toString().isEmpty) return null;
      return DateTime.tryParse(dateStr.toString());
    }

    return UserData(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      displayName: json['display_name']?.toString() ?? '',
      firstName: json['first_name']?.toString() ?? '',
      lastName: json['last_name']?.toString() ?? '',
      locale: json['locale']?.toString() ?? '',
      avatarUrl: json['avatar_url']?.toString() ?? '',
      timezone: json['timezone']?.toString() ?? '',
      mobile: json['mobile']?.toString() ?? '',
      theme: json['theme']?.toString() ?? '',
      isActive: json['is_active'] ?? false,
      lastActivity: safeParseDate(json['last_activity']),
      createdAt: safeParseDate(json['created_at']) ?? DateTime.now(),
      updatedAt: safeParseDate(json['updated_at']) ?? DateTime.now(),
      deletedAt: safeParseDate(json['deleted_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'display_name': displayName,
      'first_name': firstName,
      'last_name': lastName,
      'locale': locale,
      'avatar_url': avatarUrl,
      'timezone': timezone,
      'mobile': mobile,
      'theme': theme,
      'is_active': isActive,
      'last_activity': lastActivity?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }
}
