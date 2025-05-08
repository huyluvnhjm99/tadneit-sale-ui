import '../../../core/constants/enums.dart';

class UserProfileDTO {
  final String id;
  String? fullName;
  String username;
  String? phone;
  String? email;
  String? avatarUrl;
  DateTime? dob;
  DateTime? lastLogin;
  SaleUserRole role;
  SaleUserStatus status;

  UserProfileDTO({
    required this.id,
    this.fullName,
    required this.username,
    this.phone,
    this.email,
    this.avatarUrl,
    this.dob,
    this.lastLogin,
    required this.role,
    required this.status,
  });

  factory UserProfileDTO.fromJson(Map<String, dynamic> json) {
    return UserProfileDTO(
      id: json['id'],
      fullName: json['fullName'],
      username: json['username'],
      phone: json['phone'],
      email: json['email'],
      avatarUrl: json['avatarUrl'] ?? '',
      dob: DateTime.parse(json['dob']),
      lastLogin: DateTime.parse(json['lastLogin']),
      role: SaleUserRole.fromString(json['role']),
      status: SaleUserStatus.fromString(json['status'] ?? 'INACTIVE'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'username': username,
      'phone': phone,
      'email': email,
      'avatarUrl': avatarUrl,
      'dob': dob?.toIso8601String(),
      'lastLogin': lastLogin?.toIso8601String(),
      'role': role.name,
      'status': status.name,
    };
  }
}