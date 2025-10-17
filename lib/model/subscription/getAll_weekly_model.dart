class GetallWeeklyModel {
  final String? subscriptionId;
  final String? weeklyId;
  final String? image;

  final String? packageType;
  final double? packagePrice;

  GetallWeeklyModel({
    this.subscriptionId,
    this.weeklyId,
    this.image,
    this.packageType,
    this.packagePrice,
  });

  factory GetallWeeklyModel.fromJson(Map<String, dynamic> json) {
    return GetallWeeklyModel(
      subscriptionId: json['subscription_id'] as String?,
      image: json['image'] as String?,
      weeklyId: json['weekly_id'] as String?,
      packageType: json['package_type'] as String?,
      packagePrice: (json['package_amount'] as num?)?.toDouble(),
    );
  }
}
