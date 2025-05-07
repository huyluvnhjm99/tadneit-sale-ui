class AuthTokenDTO {
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final int expiresIn;

  AuthTokenDTO({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.expiresIn,
  });

  factory AuthTokenDTO.fromJson(Map<String, dynamic> json) {
    return AuthTokenDTO(
      accessToken: json['access_token'],
      refreshToken: json['refresh_token'],
      tokenType: json['token_type'] ?? 'bearer',
      expiresIn: json['expires_in'] ?? 3600,
    );
  }
}