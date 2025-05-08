enum SaleUserRole {
  CLIENT,
  MANAGER,
  ADMINISTRATOR;

  static SaleUserRole fromString(String value) {
    return SaleUserRole.values.firstWhere(
          (role) => role.name == value,
      orElse: () => SaleUserRole.CLIENT, // Default value if not found
    );
  }

  String get name => toString().split('.').last;
}

enum SaleUserStatus {
  INACTIVE,
  ACTIVE,
  DELETED;

  static SaleUserStatus fromString(String value) {
    return SaleUserStatus.values.firstWhere(
          (status) => status.name == value,
      orElse: () => SaleUserStatus.INACTIVE
    );
  }

  String get name => toString().split('.').last;
}