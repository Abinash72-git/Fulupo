class GetallSubscriptionModel {
  final String? subscriptionId;
  final String? mainImage;
  final String? subImage;
  final String? subscriptionname;

  GetallSubscriptionModel({
    this.subscriptionId,
    this.mainImage,
    this.subImage,
    this.subscriptionname,
  });

  factory GetallSubscriptionModel.fromJson(Map<String, dynamic> json) {
    return GetallSubscriptionModel(
      subscriptionId: json['subscription_id'] as String?,
      mainImage: json['image2'] as String?,
      subImage: json['image1'] as String?,
      subscriptionname: json['subscription_name'] as String?,
    );
  }
}
