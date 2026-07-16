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
    return UserData(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      displayName: json['display_name'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      locale: json['locale'] ?? '',
      avatarUrl: json['avatar_url'] ?? '',
      timezone: json['timezone'] ?? '',
      mobile: json['mobile'] ?? '',
      theme: json['theme'] ?? '',
      isActive: json['is_active'] ?? false,
      lastActivity: json['last_activity'] != null
          ? DateTime.parse(json['last_activity'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      deletedAt: json['deleted_at'] != null
          ? DateTime.parse(json['deleted_at'])
          : null,
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
