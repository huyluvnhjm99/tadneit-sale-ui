import '../base_filter.dart';

class ItemFilter extends BaseFilter {
  String? name;
  String? description;
  String? categoryId;
  String? categoryName;
  String? brand;
  double? priceFrom;
  double? priceTo;

  ItemFilter({
    this.name,
    this.description,
    this.categoryId,
    this.categoryName,
    this.brand,
    this.priceFrom,
    this.priceTo
  }) : super();

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = super.toJson();
    json.addAll({
      'name': name,
      'description': description,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'brand': brand,
      'priceFrom': priceFrom,
      'priceTo': priceTo,
    });
    return json;
  }
}