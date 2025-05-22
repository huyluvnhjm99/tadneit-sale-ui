import '../../../core/constants/enums.dart';
import '../file/file.dart';

class UserProfileDTO {
  String? id;
  String? fullName;
  String? username;
  String? phone;
  String? email;
  String? avatarUrl;
  DateTime? dob;
  DateTime? lastLogin;
  SaleUserRole? role;
  SaleUserStatus? status;
  FileDTO? avatar;

  UserProfileDTO({
    this.id,
    this.fullName,
    this.username,
    this.phone,
    this.email,
    this.avatarUrl,
    this.dob,
    this.lastLogin,
    this.role,
    this.status,
    this.avatar
  });

  factory UserProfileDTO.fromJson(Map<String, dynamic> json) {
    return UserProfileDTO(
      id: json['id'],
      fullName: json['fullName'],
      username: json['username'],
      phone: json['phone'],
      email: json['email'],
      avatarUrl: json['avatarUrl'] ?? '',
      dob: json['dob'] != null ? DateTime.parse(json['dob']) : null,
      lastLogin: json['lastLogin'] != null ? DateTime.parse(json['lastLogin']) : null,
      role: SaleUserRole.fromString(json['role']),
      status: SaleUserStatus.fromString(json['status'] ?? 'INACTIVE'),
      avatar: json['avatar'] != null && json['avatar'] is Map<String, dynamic> ? FileDTO.fromJson(json['avatar']) : null,
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
      'role': role?.name,
      'status': status?.name,
      'avatar': avatar
    };
  }
}