class LoginResponseDTO {
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final int expiresIn;
  final String? userId;
  final String? username;

  LoginResponseDTO({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.expiresIn,
    this.userId,
    this.username,
  });

  factory LoginResponseDTO.fromJson(Map<String, dynamic> json) {
    return LoginResponseDTO(
      accessToken: json['access_token'],
      refreshToken: json['refresh_token'],
      tokenType: json['token_type'] ?? 'bearer',
      expiresIn: json['expires_in'] ?? 3600,
      userId: json['user_id'],
      username: json['username'],
    );
  }
}