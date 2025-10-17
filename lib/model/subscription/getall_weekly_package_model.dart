class GetallWeeklyPackageModel {
  final String? subscriptionId;
  final String? weeklyId;
  final String? weeklyPackageId;
  final String? image;
  final String? packageType;
  final double? packagePrice;
  final String? description;
  final List<Map<String, String>>? days; // Changed to List<Map<String, String>>

  GetallWeeklyPackageModel({
    this.subscriptionId,
    this.weeklyId,
    this.image,
    this.packageType,
    this.packagePrice,
    this.description,
    this.days,
    this.weeklyPackageId,
  });

  factory GetallWeeklyPackageModel.fromJson(Map<String, dynamic> json) {
    return GetallWeeklyPackageModel(
      subscriptionId: json['subscription_id'] as String?,
      weeklyId: json['weekly_id'] as String?,
      weeklyPackageId: json['weeklypackage_id'] as String?,
      image: (json['images'] as List?)?.isNotEmpty == true
          ? json['images'][0] as String?
          : null, // Getting the first image from list
      packageType: json['package_name'] as String?,
      packagePrice: (json['package_amount'] as num?)?.toDouble(),
      description: json['description'] as String?,
      // Corrected to map each day to a Map<String, String> pair
      days: (json['days'] as List<dynamic>?)?.map((day) {
            if (day is Map<String, dynamic>) {
              // Convert each map to a Map<String, String>
              return Map<String, String>.from(
                  day.map((key, value) => MapEntry(key, value.toString())));
            }
            return <String, String>{}; // Return an empty map if it's not valid
          }).toList() ??
          [],
    );
  }
}
