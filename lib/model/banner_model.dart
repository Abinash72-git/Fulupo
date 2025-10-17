class BannerModel {
  final String? Id;

  final String? Image;

  BannerModel({
    this.Id,
    this.Image,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      Id: json['banner_id'] as String?,
      Image: json['banner_images'] as String?,
    );
  }
}
