class OrderItem {
  final String? productId;
  final String? name;
  final int? quantity;
  final double? price;
  final double? total;
  final String? id;

  OrderItem({
    this.productId,
    this.name,
    this.quantity,
    this.price,
    this.total,
    this.id,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['productId'],
      name: json['name'],
      quantity: json['quantity'],
      price: json['price']?.toDouble(),
      total: json['total']?.toDouble(),
      id: json['_id'],
    );
  }
}

class AddressInfo {
  final String? id;
  final String? consumerId;
  final String? name;
  final String? mobile;
  final String? addressLine;
  final String? addressName;
  final String? addressType;
  final bool? isDefault;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  AddressInfo({
    this.id,
    this.consumerId,
    this.name,
    this.mobile,
    this.addressLine,
    this.addressName,
    this.addressType,
    this.isDefault,
    this.createdAt,
    this.updatedAt,
  });

  factory AddressInfo.fromJson(Map<String, dynamic> json) {
    return AddressInfo(
      id: json['_id'],
      consumerId: json['consumerId'],
      name: json['name'],
      mobile: json['mobile'],
      addressLine: json['addressLine'],
      addressName: json['addressName'],
      addressType: json['addressType'],
      isDefault: json['isDefault'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }
}

class StoreInfo {
  final String? id;

  StoreInfo({this.id});

  factory StoreInfo.fromJson(Map<String, dynamic> json) {
    return StoreInfo(
      id: json['_id'],
    );
  }
}

class GetOrderHistory {
  final String? id;
  final String? consumerId;
  final StoreInfo? storeId;
  final AddressInfo? addressId;
  final List<OrderItem>? items;
  final double? totalAmount;
  final String? paymentMode;
  final String? paymentStatus;
  final String? razorpayOrderId;
  final String? razorpayPaymentId;
  final String? razorpaySignature;
  final String? orderStatus;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  GetOrderHistory({
    this.id,
    this.consumerId,
    this.storeId,
    this.addressId,
    this.items,
    this.totalAmount,
    this.paymentMode,
    this.paymentStatus,
    this.razorpayOrderId,
    this.razorpayPaymentId,
    this.razorpaySignature,
    this.orderStatus,
    this.createdAt,
    this.updatedAt,
  });

  factory GetOrderHistory.fromJson(Map<String, dynamic> json) {
    return GetOrderHistory(
      id: json['_id'],
      consumerId: json['consumerId'],
      storeId: json['storeId'] != null ? StoreInfo.fromJson(json['storeId']) : null,
      addressId: json['addressId'] != null ? AddressInfo.fromJson(json['addressId']) : null,
      items: json['items'] != null
          ? List<OrderItem>.from(json['items'].map((x) => OrderItem.fromJson(x)))
          : null,
      totalAmount: json['totalAmount']?.toDouble(),
      paymentMode: json['paymentMode'],
      paymentStatus: json['paymentStatus'],
      razorpayOrderId: json['razorpayOrderId'],
      razorpayPaymentId: json['razorpayPaymentId'],
      razorpaySignature: json['razorpaySignature'],
      orderStatus: json['orderStatus'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }
}
