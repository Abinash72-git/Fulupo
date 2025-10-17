// class GetAllOrderAddressModel {
//   final bool success;
//   final String message;
//   final String? token;
//   final String? userId;
//   final String? addressId;
//   final String? userName;
//   final String? mobile;
//   final String? addressType;
//   final String? address;
//   final String? buildingNumber;
//   final String? nearbyLandmark;

//   GetAllOrderAddressModel({
//     required this.success,
//     required this.message,
//     this.token,
//     this.userId,
//     this.addressId,
//     this.userName,
//     this.mobile,
//     this.addressType,
//     this.address,
//     this.buildingNumber,
//     this.nearbyLandmark,
//   });

//   factory GetAllOrderAddressModel.fromJson(Map<String, dynamic> json) {
//     return GetAllOrderAddressModel(
//       success: json['success'] ?? false,
//       message: json['message'] ?? '',
//       token: json['token'] as String?,
//       userId: json['user_id']?.toString(),
//       addressId: json['address_id']?.toString(),
//       userName: json['user_name']?.toString(),
//       mobile: json['mobile']?.toString(),
//       addressType: json['address_type']?.toString(),
//       address: json['address']?.toString(),
//       buildingNumber: json['building_number']?.toString(),
//       nearbyLandmark: json['nearby_landmark']?.toString(),
//     );
//   }
// }


class GetAllOrderAddressModel {
  final String? id;
  final String? name;
  final String? mobile;
  final String? addressLine;
  final String? addressType;
  final String? addressName;
  final bool? isDefault;

  GetAllOrderAddressModel({
    this.id,
    this.name,
    this.mobile,
    this.addressLine,
    this.addressType,
    this.addressName,
    this.isDefault,
  });

  factory GetAllOrderAddressModel.fromJson(Map<String, dynamic> json) {
    return GetAllOrderAddressModel(
      id: json['_id']?.toString(),
      name: json['name']?.toString(),
      mobile: json['mobile']?.toString(),
      addressLine: json['addressLine']?.toString(),
      addressType: json['addressType']?.toString(),
      addressName: json['addressName']?.toString(),
      isDefault: json['isDefault'] ?? false,
    );
  }
}
