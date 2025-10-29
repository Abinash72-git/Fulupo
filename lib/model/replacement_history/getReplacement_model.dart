class ReplacementResponse {
  final bool success;
  final List<Replacement> replacements;

  ReplacementResponse({
    required this.success,
    required this.replacements,
  });

  factory ReplacementResponse.fromJson(Map<String, dynamic> json) {
    return ReplacementResponse(
      success: json['success'] ?? false,
      replacements: (json['replacements'] as List<dynamic>?)
              ?.map((e) => Replacement.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'success': success,
        'replacements': replacements.map((e) => e.toJson()).toList(),
      };
}

class Replacement {
  final String id;
  final Order orderId;
  final Product productId;
  final String customerId;
  final String storeId;
  final String reason;
  final List<String> images;
  final String status;
  final int quantity;
  final String createdAt;
  final String updatedAt;

  Replacement({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.customerId,
    required this.storeId,
    required this.reason,
    required this.images,
    required this.status,
    required this.quantity,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Replacement.fromJson(Map<String, dynamic> json) {
    return Replacement(
      id: json['_id'] ?? '',
      orderId: Order.fromJson(json['orderId']),
      productId: Product.fromJson(json['productId']),
      customerId: json['customerId'] ?? '',
      storeId: json['storeId'] ?? '',
      reason: json['reason'] ?? '',
      images: List<String>.from(json['images'] ?? []),
      status: json['status'] ?? '',
      quantity: json['quantity'] ?? 0,
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'orderId': orderId.toJson(),
        'productId': productId.toJson(),
        'customerId': customerId,
        'storeId': storeId,
        'reason': reason,
        'images': images,
        'status': status,
        'quantity': quantity,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };
}

class Order {
  final String id;
  final String consumerId;
  final String storeId;
  final String addressId;
  final List<OrderItem> items;
  final double totalAmount;
  final String paymentMode;
  final String paymentStatus;
  final String razorpayOrderId;
  final String orderStatus;
  final String createdAt;
  final String updatedAt;
  final String? razorpayPaymentId;
  final String? razorpaySignature;

  Order({
    required this.id,
    required this.consumerId,
    required this.storeId,
    required this.addressId,
    required this.items,
    required this.totalAmount,
    required this.paymentMode,
    required this.paymentStatus,
    required this.razorpayOrderId,
    required this.orderStatus,
    required this.createdAt,
    required this.updatedAt,
    this.razorpayPaymentId,
    this.razorpaySignature,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['_id'] ?? '',
      consumerId: json['consumerId'] ?? '',
      storeId: json['storeId'] ?? '',
      addressId: json['addressId'] ?? '',
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => OrderItem.fromJson(e))
              .toList() ??
          [],
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      paymentMode: json['paymentMode'] ?? '',
      paymentStatus: json['paymentStatus'] ?? '',
      razorpayOrderId: json['razorpayOrderId'] ?? '',
      orderStatus: json['orderStatus'] ?? '',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      razorpayPaymentId: json['razorpayPaymentId'],
      razorpaySignature: json['razorpaySignature'],
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'consumerId': consumerId,
        'storeId': storeId,
        'addressId': addressId,
        'items': items.map((e) => e.toJson()).toList(),
        'totalAmount': totalAmount,
        'paymentMode': paymentMode,
        'paymentStatus': paymentStatus,
        'razorpayOrderId': razorpayOrderId,
        'orderStatus': orderStatus,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
        'razorpayPaymentId': razorpayPaymentId,
        'razorpaySignature': razorpaySignature,
      };
}

class OrderItem {
  final String productId;
  final String name;
  final int quantity;
  final double price;
  final double total;
  final String id;

  OrderItem({
    required this.productId,
    required this.name,
    required this.quantity,
    required this.price,
    required this.total,
    required this.id,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['productId'] ?? '',
      name: json['name'] ?? '',
      quantity: json['quantity'] ?? 0,
      price: (json['price'] ?? 0).toDouble(),
      total: (json['total'] ?? 0).toDouble(),
      id: json['_id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'name': name,
        'quantity': quantity,
        'price': price,
        'total': total,
        '_id': id,
      };
}

class Product {
  final String id;
  final String storeId;
  final String productCode;
  final String name;
  final List<dynamic> dimenstionImages;
  final String masterProductId;
  final double purchasePrice;
  final double mrpPrice;
  final double? discountPrice;
  final int showAvlQty;
  final String createdAt;
  final String updatedAt;

  Product({
    required this.id,
    required this.storeId,
    required this.productCode,
    required this.name,
    required this.dimenstionImages,
    required this.masterProductId,
    required this.purchasePrice,
    required this.mrpPrice,
    this.discountPrice,
    required this.showAvlQty,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id'] ?? '',
      storeId: json['storeId'] ?? '',
      productCode: json['productCode'] ?? '',
      name: json['name'] ?? '',
      dimenstionImages: List<dynamic>.from(json['dimenstionImages'] ?? []),
      masterProductId: json['masterProductId'] ?? '',
      purchasePrice: (json['purchasePrice'] ?? 0).toDouble(),
      mrpPrice: (json['mrpPrice'] ?? 0).toDouble(),
      discountPrice: json['discountPrice'] != null
          ? (json['discountPrice']).toDouble()
          : null,
      showAvlQty: json['showAvlQty'] ?? 0,
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'storeId': storeId,
        'productCode': productCode,
        'name': name,
        'dimenstionImages': dimenstionImages,
        'masterProductId': masterProductId,
        'purchasePrice': purchasePrice,
        'mrpPrice': mrpPrice,
        'discountPrice': discountPrice,
        'showAvlQty': showAvlQty,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };
}
