enum SaleUserRole {
  CLIENT,
  MANAGER,
  ADMINISTRATOR;

  static SaleUserRole fromString(String value) {
    return SaleUserRole.values.firstWhere(
          (SaleUserRole role) => role.name == value,
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
          (SaleUserStatus status) => status.name == value,
      orElse: () => SaleUserStatus.INACTIVE
    );
  }

  String get name => toString().split('.').last;
}

enum FileMappingType {
  CATEGORY,
  ITEM,
  OTHER;

  static FileMappingType fromString(String value) {
    return FileMappingType.values.firstWhere(
            (FileMappingType type) => type.name == value,
        orElse: () => FileMappingType.OTHER
    );
  }

  String get name => toString().split('.').last;
}