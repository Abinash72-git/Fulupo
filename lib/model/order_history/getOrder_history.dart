class GetOrderHistory {
  final String? orderId;
  final String? userId;
  final String? subcategoryId;
  final int? count;
  final DateTime? bookingDate;
  final String? slotSchedule;
  final String? startTime;
  final String? endTime;
  final double? oldPrice;
  final double? savings;
  final double? gst;
  final double? deliveryFees;
  final double? totalPay;
  final String? productName;
  final String? productSubname;
  final String? productQuantity;
  final double? currentPrice;
  final String? orderAddress;
  final String? image;

  GetOrderHistory({
    this.orderId,
    this.userId,
    this.subcategoryId,
    this.count,
    this.bookingDate,
    this.slotSchedule,
    this.startTime,
    this.endTime,
    this.oldPrice,
    this.savings,
    this.gst,
    this.deliveryFees,
    this.totalPay,
    this.productName,
    this.productSubname,
    this.productQuantity,
    this.currentPrice,
    this.orderAddress,
    this.image,
  });

  // Factory method to create an instance from JSON
  factory GetOrderHistory.fromJson(Map<String, dynamic> json) {
    return GetOrderHistory(
      orderId: json['order_id'] as String?,
      userId: json['user_id'] as String?,
      subcategoryId: json['sub_category_id'] as String?,
      count: json['count'] as int?,
      bookingDate: json['booking_date'] != null
          ? DateTime.tryParse(json['booking_date'])
          : null,
      slotSchedule: json['slot_schedule'] as String?,
      startTime: json['start_time'] as String?,
      endTime: json['end_time'] as String?,
      oldPrice: (json['old_price'] as num?)?.toDouble(),
      savings: (json['savings'] as num?)?.toDouble(),
      gst: (json['gst'] as num?)?.toDouble(),
      deliveryFees: (json['delivery_fees'] as num?)?.toDouble(),
      totalPay: (json['total_pay'] as num?)?.toDouble(),
      productName: json['product_name'] as String?,
      productSubname: json['product_subname'] as String?,
      productQuantity: json['product_quantity'] as String?,
      currentPrice: (json['current_price'] as num?)?.toDouble(),
      orderAddress: json['order_address'] as String?,
      image: json['image'] as String?,
    );
  }
}
