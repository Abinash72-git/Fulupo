// class GetallCategoryModel {
//   final String? id;

//   final String? image;

//   final String? name;

//   GetallCategoryModel({this.id, this.image, this.name});

//   factory GetallCategoryModel.fromJson(Map<String, dynamic> json) {
//     return GetallCategoryModel(
//         id: json['category_id'] as String?,
//         image: json['category_image'] as String?,
//         name: json['category_name'] as String?);
//   }
// }

import 'package:flutter/foundation.dart';

class GetAllCategoryModel {
  final String id;
  final String categoryName;
  final List<ProductModel> products;
  final String categoryimage;

  GetAllCategoryModel( {
    required this.id,
    required this.categoryName,
    required this.products,
    required this.categoryimage
  });

  factory GetAllCategoryModel.fromJson(Map<String, dynamic> json) {
    return GetAllCategoryModel(
      id: json['_id'] ?? '',
      categoryName: json['categoryName'] ?? '',
      products: (json['products'] as List<dynamic>?)
              ?.map((e) => ProductModel.fromJson(e))
              .toList() ??
          [],
          categoryimage: json['categoryIcon']??''
    );
  }
}

// class ProductModel {
//   final String id;
//   final String productCode;
//   final String name;
//   final double mrpPrice;
//   final double? discountPrice;
//   final int showAvlQty;
//   final String productImage;

//   ProductModel({
//     required this.id,
//     required this.productCode,
//     required this.name,
//     required this.mrpPrice,
//     this.discountPrice,
//     required this.showAvlQty,
//     required this.productImage,
//   });

//   factory ProductModel.fromJson(Map<String, dynamic> json) {
//     return ProductModel(
//       id: json['_id'] ?? '',
//       productCode: json['productCode'] ?? '',
//       name: json['name'] ?? '',
//       mrpPrice: (json['mrpPrice'] ?? 0).toDouble(),
//       discountPrice: json['discountPrice'] != null
//           ? (json['discountPrice']).toDouble()
//           : null,
//       showAvlQty: json['showAvlQty'] ?? 0,
//       productImage: json['productImage'] ?? '',
//     );
//   }
// }


class ProductModel {
  final String id;
  final String productCode;
  final String name;
  final double mrpPrice;
  final double? discountPrice;
  final int showAvlQty;
  final String productImage;

  ProductModel({
    required this.id,
    required this.productCode,
    required this.name,
    required this.mrpPrice,
    this.discountPrice,
    required this.showAvlQty,
    required this.productImage,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['_id'] ?? '',
      productCode: json['productCode'] ?? '',
      name: json['name'] ?? '',
      mrpPrice: (json['mrpPrice'] ?? 0).toDouble(),
      discountPrice: json['discountPrice'] != null
          ? (json['discountPrice']).toDouble()
          : null,
      showAvlQty: json['showAvlQty'] ?? 0,
      productImage: json['productImage'] ?? '',
    );
  }}
