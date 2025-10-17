class GetallSubproduct {
  final String? subid;
  final String? id;
  final String? image;
  final String? name;
  final String? subname;
  final String? quantity;
  final double? currentPrice;
  final double? oldPrice;

  GetallSubproduct({
    this.subid,
    this.id,
    this.image,
    this.name,
    this.subname,
    this.quantity,
    this.currentPrice,
    this.oldPrice,
  });

  factory GetallSubproduct.fromJson(Map<String, dynamic> json) {
    return GetallSubproduct(
      subid: json['sub_category_id'] as String?,
      id: json['product_id'] as String?,
      image: json['product_image'] as String?,
      name: json['product_name'] as String?,
      subname: json['product_subname'] as String?,
      quantity: json['product_quantity'] as String?,
      currentPrice: (json['current_price'] as num?)?.toDouble(),
      oldPrice: (json['old_price'] as num?)?.toDouble(),
    );
  }
}
