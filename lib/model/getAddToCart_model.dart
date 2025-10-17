class GetaddtocartModel {
  final String? fruitsId;
  final String? fruitCategoryId;
  final String? fruitImage;
  final String? fruitName;
  final String? fruitSubname;
  final String? fruitsQuantity;
  final double? currentPrice;
  final double? oldPrice;
  int? count;

  GetaddtocartModel({
    required this.fruitsId,
    required this.fruitCategoryId,
    required this.fruitImage,
    required this.fruitName,
    required this.fruitSubname,
    required this.fruitsQuantity,
    required this.currentPrice,
    required this.count,
    this.oldPrice,
  });

  factory GetaddtocartModel.fromJson(Map<String, dynamic> json) {
    return GetaddtocartModel(
      fruitsId: json['id'] as String?,
      fruitCategoryId: json['category_id'] as String?,
      fruitImage: json['image'] as String?,
      fruitName: json['name'] as String?,
      fruitSubname: json['subname'] as String?,
      fruitsQuantity: json['quantity'] as String?,
      currentPrice: (json['current_price'] as num?)?.toDouble(),
      oldPrice: (json['old_price'] as num?)?.toDouble(),
      count: json['count'] as int?,
    );
  }
}
