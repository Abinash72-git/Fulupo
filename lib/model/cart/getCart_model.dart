class GetcartModel {
  final String id;
  final String productId;
  final String productName;
  final String productCode;
  final double mrpPrice;
  final double? discountPrice;
   int quantity;
  final String storeName;
  final String storeId;
  final String? storeLogo;

  GetcartModel({
    required this.id,
    required this.productId,
    required this.productName,
    required this.productCode,
    required this.mrpPrice,
    required this.discountPrice,
    required this.quantity,
    required this.storeName,
    required this.storeId,
    required this.storeLogo,
  });

  factory GetcartModel.fromJson(Map<String, dynamic> json) {
    final store = json['storeId'] ?? {};
    final product = json['productId'] ?? {};

    return GetcartModel(
      id: json['_id'] ?? '',
      productId: product['_id'] ?? '',
      productName: product['name'] ?? '',
      productCode: product['productCode'] ?? '',
      mrpPrice: (product['mrpPrice'] ?? 0).toDouble(),
      discountPrice: product['discountPrice'] != null
          ? (product['discountPrice'] as num).toDouble()
          : null,
      quantity: json['quantity'] ?? 0,
      storeName: store['store_name'] ?? '',
      storeId: store['_id'] ?? '',
      storeLogo: store['store_logo'],
    );
  }
}
