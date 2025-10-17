class GetwishlistModel {
  final String? Id;
  final String? CategoryId;
  final String? Image;
  final String? Name;
  final String? Subname;
  final String? Quantity;
  final double? currentPrice;
  final double? oldPrice;

  GetwishlistModel({
    this.Id,
    this.CategoryId,
    this.Image,
    this.Name,
    this.Subname,
    this.Quantity,
    this.currentPrice,
    this.oldPrice,
  });

  factory GetwishlistModel.fromJson(Map<String, dynamic> json) {
    return GetwishlistModel(
      Id: json['id'] as String?,
      CategoryId: json['category_id'] as String?,
      Image: json['image'] as String?,
      Name: json['name'] as String?,
      Subname: json['subname'] as String?,
      Quantity: json['quantity'] as String?,
      currentPrice: (json['current_price'] as num?)?.toDouble(),
      oldPrice: (json['old_price'] as num?)?.toDouble(),
    );
  }
}
