class RandomProductModel {
  final String? Id;
  final String? CategoryId;
  final String? Image;
  final String? Name;
  final String? Subname;
  final String? Quantity;
  final double? currentPrice;
  final double? oldPrice;
  final int? count;
  final String? subCategoryId;

  RandomProductModel({
    required this.Id,
    required this.CategoryId,
    required this.Image,
    required this.Name,
    required this.Subname,
    required this.Quantity,
    required this.currentPrice,
    required this.oldPrice,
    required this.count,
    this.subCategoryId,
  });

  factory RandomProductModel.fromJson(Map<String, dynamic> json) {
    return RandomProductModel(
      Id: json['product_id'] as String?,
      subCategoryId: json['sub_category_id'] as String?,
      CategoryId: json['category_id'] as String?,
      Image: json['image'] as String?,
      Name: json['name'] as String?,
      Subname: json['subname'] as String?,
      Quantity: json['quantity'] as String?,
      currentPrice: (json['current_price'] as num?)?.toDouble(),
      oldPrice: (json['old_price'] as num?)?.toDouble(),
      count: json['count'] as int?,
    );
  }
}
