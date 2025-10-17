// import 'package:flutter/material.dart';
// import 'package:fulupo/model/product_base_model.dart';
// import 'package:fulupo/pages/product_cart_widget.dart';

// class ProductGridView extends StatelessWidget {
//   final List<Product> products;
//   final Function(Product) onProductTap;
//   final Function(Product) onAdd;
//   final Function(Product) onIncrease;
//   final Function(Product) onRemove;
//   final Function(Product) onFavoriteToggle;
//   final Map<String, bool> isAdded;
//   final Map<String, int> itemCounts;
//   final Map<String, bool> isFavorite;
//   final Function recalculateTotalPrice;
//   final Future<void> Function() fetchCart;

//   const ProductGridView({
//     Key? key,
//     required this.products,
//     required this.onProductTap,
//     required this.onAdd,
//     required this.onIncrease,
//     required this.onRemove,
//     required this.onFavoriteToggle,
//     required this.isAdded,
//     required this.itemCounts,
//     required this.isFavorite,
//     required this.recalculateTotalPrice,
//     required this.fetchCart,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final screenHeight = MediaQuery.of(context).size.height;
//     final screenWidth = MediaQuery.of(context).size.width;

//     return GridView.builder(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       // gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//       //   crossAxisCount: 2,
//       //   crossAxisSpacing: 10,
//       //   mainAxisSpacing: 10,
//       //   childAspectRatio: screenHeight * 0.65 / screenWidth * 0.44,
//       // ),
//       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 3, // Changed from 2 to 3
//         crossAxisSpacing: 0,
//         mainAxisSpacing: 0,
//         //childAspectRatio: screenHeight * 0.65 / screenWidth * 0.44,
//         childAspectRatio: screenHeight * 0.6 / screenWidth * 0.5,
//       ),
//       // gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//       //   crossAxisCount: 3, // Changed from 2 to 3
//       //   crossAxisSpacing: 8, // Reduced spacing for better fit
//       //   mainAxisSpacing: 8, // Reduced spacing for better fit
//       //   childAspectRatio: 0.75, // Adjusted for 3 columns
//       // ),
//       itemCount: products.length,
//       itemBuilder: (context, index) {
//         final product = products[index];
//         final count = itemCounts[product.categoryId] ?? 0;

//         return GestureDetector(
//           onTap: () {},
//           child: ProductCard(
//             image: product.image ?? '',
//             name: product.name ?? '',
//             subname: product.subname ?? '',
//             price: product.currentPrice?.toString() ?? '',
//             oldPrice: product.oldPrice?.toString() ?? '',
//             weights: product.weights ?? '',
//             selectedWeight: product.weights ?? '',
//             onChanged: (newValue) {},
//             isAdded: isAdded[product.categoryId] == true && count > 0,
//             onAdd: () => onAdd(product),
//             onIcrease: () => onIncrease(product),
//             onRemove: () => onRemove(product),
//             onFavoriteToggle: () => onFavoriteToggle(product),
//             isFavorite: isFavorite[product.categoryId] ?? false,
//             count: count,
//             fruitsCount: product.count ?? 0,
//             catgoryId: product.categoryId ?? '',
//             onTap: () => onProductTap(product),
//           ),
//         );
//       },
//     );
//   }
// }



import 'package:flutter/material.dart';
import 'package:fulupo/model/getAll_categeory/getAll_category_model.dart';
import 'package:fulupo/model/product_base_model.dart';
import 'package:fulupo/pages/product_cart_widget.dart';

class ProductGridView extends StatelessWidget {
  final List<ProductModel> products;
  final Function(ProductModel) onProductTap;
  final Function(ProductModel) onAdd;
  final Function(ProductModel) onIncrease;
  final Function(ProductModel) onRemove;
  final Function(ProductModel) onFavoriteToggle;
  final Map<String, bool> isAdded;
  final Map<String, int> itemCounts;
  final Map<String, bool> isFavorite;
  final Function recalculateTotalPrice;
  final Future<void> Function() fetchCart;

  const ProductGridView({
    Key? key,
    required this.products,
    required this.onProductTap,
    required this.onAdd,
    required this.onIncrease,
    required this.onRemove,
    required this.onFavoriteToggle,
    required this.isAdded,
    required this.itemCounts,
    required this.isFavorite,
    required this.recalculateTotalPrice,
    required this.fetchCart,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: screenHeight * 0.6 / screenWidth * 0.5,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        final count = itemCounts[product.id] ?? 0;

        return GestureDetector(
          onTap: () => onProductTap(product),
          child: ProductCard(
            image: product.productImage,
            name: product.name,
            subname: '', // If you have no subname, leave empty
            price: product.discountPrice?.toString() ?? product.mrpPrice.toString(),
            oldPrice: product.discountPrice != null
                ? product.mrpPrice.toString()
                : '',
            weights: '', // Not available in ProductModel
            selectedWeight: '', // Not available in ProductModel
            onChanged: (newValue) {},
            isAdded: isAdded[product.id] == true && count > 0,
            onAdd: () => onAdd(product),
            onIcrease: () => onIncrease(product),
            onRemove: () => onRemove(product),
            onFavoriteToggle: () => onFavoriteToggle(product),
            isFavorite: isFavorite[product.id] ?? false,
            count: count,
            fruitsCount: product.showAvlQty,
            catgoryId: product.id,
            onTap: () => onProductTap(product),
          ),
        );
      },
    );
  }
}

