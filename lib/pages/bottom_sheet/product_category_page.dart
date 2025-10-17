import 'dart:async';
import 'dart:developer';


import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fulupo/customs/styles.dart';
import 'package:fulupo/model/getAll_categeory/getAll_subproduct_model/getAll_subproduct.dart';
import 'package:fulupo/provider/get_provider.dart';
import 'package:fulupo/util/color_constant.dart';
import 'package:fulupo/util/exception.dart';
import 'package:fulupo/widget/dilogue/dilogue.dart';
import 'package:provider/provider.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

class ProductCategoryPage extends StatefulWidget {
  final String categoryId;

  const ProductCategoryPage({Key? key, required this.categoryId})
      : super(key: key);

  @override
  State<ProductCategoryPage> createState() => _ProductCategoryPageState();
}

class _ProductCategoryPageState extends State<ProductCategoryPage> {
  bool isLoading = true;
  Map<String, int> itemCounts = {};
  Map<String, bool> isAddedToCartMap = {};
  String token = '';
  Map<String, Timer?> _debounceTimers = {};
  GetProvider get getprovider => context.read<GetProvider>();

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _debounceApiCall(String subid, int count, String token) {
    if (_debounceTimers[subid] != null) {
      _debounceTimers[subid]?.cancel();
    }

    _debounceTimers[subid] = Timer(const Duration(seconds: 1), () async {
      try {
        await AppDialogue.openLoadingDialogAfterClose(context,
            text: "Updating...", load: () async {
          return await getprovider.updateCart(
            categoryId: subid,
            count: count,
            token: token,
          );
        }, afterComplete: (resp) async {
          if (resp.statusCode==200) {
            print("Success");
            AppDialogue.toast(resp.data);
          }
        });
      } catch (e) {
        ExceptionHandler.showMessage(context, e);
      }

      await getprovider.fetchAddToCart(token);
    });
  }

  Future<void> _fetchData() async {
    setState(() {
      isLoading = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token') ?? '';

    await _fetchCategoryData();
    await _fetchCartData();

    setState(() {
      isLoading = false;
    });
  }

  Future<void> _fetchCategoryData() async {
    await getprovider.fetchSubProduct(widget.categoryId);
  }

  Future<void> _fetchCartData() async {
    try {
      final cartData = await getprovider.fetchAddToCart(token);

      for (var item in cartData) {
        final subid = item.fruitCategoryId;
        final count = item.count;

        if (subid != null) {
          itemCounts[subid] = count ?? 0;
          isAddedToCartMap[subid] = true;
        }
      }
    } catch (e) {
      print('Error fetching cart data: $e');
    }
  }

  @override
  void dispose() {
    for (var timer in _debounceTimers.values) {
      timer?.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final getProvider = context.watch<GetProvider>();
    final categoryList = getProvider.subproduct;

    return Container(
      height: screenHeight * 0.55,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 5),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Products",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context, 'Yes')),
            ],
          ),
          Expanded(
              child: isLoading
                  ? _buildShimmer()
                  : _buildCategoryList(categoryList)),
        ],
      ),
    );
  }

  ListView _buildCategoryList(List<GetallSubproduct> categoryList) {
    return ListView.builder(
      itemCount: categoryList.length,
      itemBuilder: (context, index) {
        final category = categoryList[index];
        final count = itemCounts[category.subid ?? ''] ?? 0;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: _buildProductCard(category, count),
        );
      },
    );
  }

  Widget _buildShimmer() {
    return ListView.builder(
      itemCount: 6,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Row(
            children: [
              Container(
                height: 70,
                width: 70,
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[300],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 15,
                      width: 150,
                      color: Colors.grey[300],
                      margin: const EdgeInsets.only(bottom: 5),
                    ),
                    Container(
                      height: 12,
                      width: 100,
                      color: Colors.grey[300],
                      margin: const EdgeInsets.only(bottom: 10),
                    ),
                    Container(
                      height: 12,
                      width: 70,
                      color: Colors.grey[300],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard(GetallSubproduct category, int count) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 5),
      decoration: BoxDecoration(
        color: Colors.white70,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
          ),
        ],
        border: Border.all(color: AppColor.fillColor),
      ),
      child: Row(
        children: [
          Container(
            height: 75,
            width: 72,
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey[200],
              image: category.image != null && category.image!.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(category.image!), fit: BoxFit.cover)
                  : null,
            ),
            child: category.image == null || category.image!.isEmpty
                ? const Center(
                    child: Icon(Icons.image_not_supported, color: Colors.grey))
                : null,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.name ?? 'Unknown',
                  style: Styles.textStyleMedium(context,
                          color: AppColor.blackColor)
                      .copyWith(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  category.subname ?? 'Unknown',
                  style: Styles.textStyleSmall(context,
                      color: AppColor.hintTextColor),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(category.quantity ?? 'Unknown',
                    style: Styles.textStyleSmall(context,
                        color: AppColor.hintTextColor)),
                Row(
                  children: [
                    Text(
                        '₹${category.currentPrice?.toStringAsFixed(2) ?? '0.00'}',
                        style: Styles.textStyleMedium(context,
                                color: AppColor.blackColor)
                            .copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(width: 10),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text('₹${category.oldPrice ?? '0.00'}',
                          style: Styles.textStyleSmall(context,
                                  color: AppColor.hintTextColor)
                              .copyWith(
                                  decoration: TextDecoration.lineThrough)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          isAddedToCartMap[category.subid] == true && count > 0
              ? Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          if (itemCounts[category.subid]! > 0) {
                            itemCounts[category.subid ?? ''] =
                                itemCounts[category.subid]! - 1;
                          }
                          if (itemCounts[category.subid] == 0) {
                            isAddedToCartMap[category.subid ?? ''] = false;
                          }
                        });

                        // Trigger the debounced API call
                        _debounceApiCall(
                          category.subid ?? '',
                          itemCounts[category.subid] ?? 0,
                          token,
                        );
                      },
                    ),
                    Text('$count'),
                    IconButton(
                      icon: const Icon(Icons.add, color: AppColor.fillColor),
                      onPressed: () {
                        setState(() {
                          itemCounts[category.subid!] =
                              (itemCounts[category.subid] ?? 0) + 1;
                        });

                        // Trigger the debounced API call
                        _debounceApiCall(
                          category.subid ?? '',
                          itemCounts[category.subid] ?? 0,
                          token,
                        );
                      },
                    )
                  ],
                )
              : GestureDetector(
                  onTap: () async {
                    setState(() {
                      isAddedToCartMap[category.subid!] = true;
                      itemCounts[category.subid!] = 1;
                    });

                    try {
                      await AppDialogue.openLoadingDialogAfterClose(context,
                          text: "Adding to cart...", load: () async {
                        return await getprovider.addToCart(
                            fruitId: category.id!,
                            categoryId: category.subid!,
                            count: itemCounts[category.subid] ?? 0,
                            token: token);
                      }, afterComplete: (resp) async {
                        if (resp.statusCode==200) {
                          print("sucess");

                          AppDialogue.toast(resp.data);
                        }
                      });
                    } on Exception catch (e) {
                      ExceptionHandler.showMessage(context, e);
                    }
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    decoration: BoxDecoration(
                      color: AppColor.fillColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('Add to cart',
                        style: Styles.textStyleSmall(context,
                            color: AppColor.whiteColor)),
                  ),
                ),
        ],
      ),
    );
  }
}


// class ProductCategoryPage extends StatefulWidget {
//   final String categoryId;

//   const ProductCategoryPage({Key? key, required this.categoryId})
//       : super(key: key);

//   @override
//   State<ProductCategoryPage> createState() => _ProductCategoryPageState();
// }

// class _ProductCategoryPageState extends State<ProductCategoryPage> {
//   bool isLoading = true;
//   Map<String, int> itemCounts = {};
//   Map<String, bool> isAddedToCartMap = {};
//   String token = '';

//   @override
//   void initState() {
//     super.initState();
//     _fetchData();
//   }

//   Future<void> _fetchData() async {
//     setState(() {
//       isLoading = true; // Show shimmer while fetching data
//     });

//     // Fetch category data
//     await context.read<GetProvider>().fetchFruitsCategory(widget.categoryId);

//     // Fetch token
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     token = prefs.getString('token') ?? '';

//     // Fetch cart data from backend
//     await _fetchCartData();

//     setState(() {
//       isLoading = false;
//     });
//   }

//   Future<void> _fetchCartData() async {
//     try {
//       // Fetch cart data
//       final cartData = await context.read<GetProvider>().fetchAddToCart(token);

//       // Process the fetched data
//       for (var item in cartData) {
//         final categoryId = item.fruitCategoryId;
//         final count = item.count;

//         if (categoryId != null) {
//           itemCounts[categoryId] = count ?? 0;
//           isAddedToCartMap[categoryId] = true;
//         }
//       }
//     } catch (e) {
//       print('Error fetching cart data: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final screenHeight = MediaQuery.of(context).size.height;
//     final getProvider = context.watch<GetProvider>();

//     return Container(
//       height: screenHeight * 0.55,
//       padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: const BorderRadius.only(
//           topLeft: Radius.circular(20),
//           topRight: Radius.circular(20),
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 10,
//             spreadRadius: 5,
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           // Header with Close Button
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               const Text(
//                 "Product Categories",
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               IconButton(
//                 icon: const Icon(Icons.close),
//                 onPressed: () {
//                   Navigator.of(context).pop();
//                 },
//               ),
//             ],
//           ),

//           // Category List or Shimmer
//           Expanded(
//             child: isLoading
//                 ? ListView.builder(
//                     itemCount: 6, // Placeholder shimmer items
//                     itemBuilder: (context, index) => Padding(
//                       padding: const EdgeInsets.symmetric(vertical: 10.0),
//                       child: Shimmer.fromColors(
//                         baseColor: Colors.grey[300]!,
//                         highlightColor: Colors.grey[100]!,
//                         child: Row(
//                           children: [
//                             Container(
//                               height: 70,
//                               width: 70,
//                               margin: const EdgeInsets.only(right: 10),
//                               decoration: BoxDecoration(
//                                 borderRadius: BorderRadius.circular(8),
//                                 color: Colors.grey[300],
//                               ),
//                             ),
//                             Expanded(
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Container(
//                                     height: 15,
//                                     width: 150,
//                                     color: Colors.grey[300],
//                                     margin: const EdgeInsets.only(bottom: 5),
//                                   ),
//                                   Container(
//                                     height: 12,
//                                     width: 100,
//                                     color: Colors.grey[300],
//                                     margin: const EdgeInsets.only(bottom: 10),
//                                   ),
//                                   Container(
//                                     height: 12,
//                                     width: 70,
//                                     color: Colors.grey[300],
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   )
                // : ListView.builder(
                //     itemCount: getProvider.fruitsCategories.length,
                //     itemBuilder: (context, index) {
                //       final category = getProvider.fruitsCategories[index];
                //       final count = itemCounts[category.fruitCategoryId] ?? 0;

                //       return Padding(
                //         padding: const EdgeInsets.symmetric(vertical: 10.0),
                //         child: Container(
                //           padding: const EdgeInsets.symmetric(
                //               vertical: 10.0, horizontal: 10),
                //           decoration: BoxDecoration(
                //             color: Colors.white70,
                //             borderRadius: BorderRadius.circular(12),
                //             boxShadow: [
                //               BoxShadow(
                //                 color: Colors.grey.withOpacity(0.2),
                //                 spreadRadius: 2,
                //                 blurRadius: 5,
                //               ),
                //             ],
                //             border: Border.all(color: AppColor.fillColor),
                //           ),
                //           child: Row(
                //             children: [
                //               // Image Container
                //               Container(
                //                 height: 70,
                //                 width: 70,
                //                 margin: const EdgeInsets.only(right: 10),
                //                 decoration: BoxDecoration(
                //                   borderRadius: BorderRadius.circular(8),
                //                   color: Colors.grey[200],
                //                   image: category.fruitImage != null &&
                //                           category.fruitImage!.isNotEmpty
                //                       ? DecorationImage(
                //                           image: NetworkImage(
                //                               category.fruitImage!),
                //                           fit: BoxFit.cover,
                //                         )
                //                       : null,
                //                 ),
                //                 child: category.fruitImage == null ||
                //                         category.fruitImage!.isEmpty
                //                     ? const Center(
                //                         child: Icon(
                //                           Icons.image_not_supported,
                //                           color: Colors.grey,
                //                         ),
                //                       )
                //                     : null,
                //               ),
                //               // Product Details
                //               Expanded(
                //                 child: Column(
                //                   crossAxisAlignment: CrossAxisAlignment.start,
                //                   children: [
                //                     Text(
                //                       category.fruitName ?? 'Unknown',
                //                       style: Styles.textStyleMedium(context,
                //                           color: Colors.black),
                //                       overflow: TextOverflow.ellipsis,
                //                     ),
                //                     Text(
                //                       category.fruitSubname ?? 'Unknown',
                //                       style: Styles.textStyleSmall(
                //                         context,
                //                         color: AppColor.hintTextColor,
                //                       ),
                //                       overflow: TextOverflow.ellipsis,
                //                     ),
                //                     Text(
                //                       category.fruitsQuantity ?? 'Unknown',
                //                       style: Styles.textStyleSmall(
                //                         context,
                //                         color: AppColor.hintTextColor,
                //                       ),
                //                     ),
                //                     Row(
                //                       children: [
                //                         Text(
                //                           '₹${category.currentPrice?.toStringAsFixed(2) ?? '0.00'}',
                //                           style: Styles.textStyleMedium(context,
                //                               color: Colors.black),
                //                         ),
                //                         const SizedBox(width: 10),
                //                         Text(
                //                           '₹${category.oldPrice?.toStringAsFixed(2) ?? '0.00'}',
                //                           style: Styles.textStyleSmall(
                //                             context,
                //                             color: AppColor.hintTextColor,
                //                           ).copyWith(
                //                             decoration:
                //                                 TextDecoration.lineThrough,
                //                           ),
                //                         ),
                //                       ],
                //                     ),
                //                   ],
                //                 ),
                //               ),
                //               // Add to Cart or Count buttons
                //               isAddedToCartMap[category.fruitCategoryId] ==
                //                           true &&
                //                       count > 0
                //                   ? Row(
                //                       children: [
                //                         IconButton(
                //                           icon: const Icon(Icons.remove,
                //                               color: Colors.red),
                //                           onPressed: () async {
                //                             setState(() {
                //                               if ((itemCounts[category
                //                                           .fruitCategoryId!] ??
                //                                       0) >
                //                                   0) {
                //                                 itemCounts[category
                //                                         .fruitCategoryId!] =
                //                                     (itemCounts[category
                //                                                 .fruitCategoryId!] ??
                //                                             0) -
                //                                         1;

                //                                 // Print and log details after decrementing
                //                                 print(
                //                                     "Decremented Item: Name: ${category.fruitName}, ID: ${category.fruitsId}, Count: ${itemCounts[category.fruitCategoryId]}");
                //                                 log("Decremented Item: Name: ${category.fruitName}, ID: ${category.fruitsId}, Count: ${itemCounts[category.fruitCategoryId]}");

                //                                 // If the count is zero, update the cart state
                //                                 if (itemCounts[category
                //                                         .fruitCategoryId] ==
                //                                     0) {
                //                                   isAddedToCartMap[category
                //                                           .fruitCategoryId!] =
                //                                       false;
                //                                 }
                //                               }
                //                             });
                //                             try {
                //                               await AppDialogue
                //                                   .openLoadingDialogAfterClose(
                //                                       context,
                //                                       text: "Updating...",
                //                                       load: () async {
                //                                 return await getProvider.updateCart(
                //                                     categoryId: category
                //                                             .fruitCategoryId ??
                //                                         '',
                //                                     count: itemCounts[category
                //                                             .fruitCategoryId] ??
                //                                         0,
                //                                     token: token);
                //                               }, afterComplete: (resp) async {
                //                                 if (resp.status) {
                //                                   print("Success");
                //                                   AppDialogue.toast(resp.data);
                //                                 }
                //                               });
                //                             } catch (e) {
                //                               ExceptionHandler.showMessage(
                //                                   context, e);
                //                             }
                //                             await getProvider
                //                                 .fetchAddToCart(token);
                //                           },
                //                         ),
                //                         Text('$count'),
                //                         IconButton(
                //                           icon: const Icon(Icons.add,
                //                               color: AppColor.fillColor),
                //                           onPressed: () async {
                //                             setState(() {
                //                               itemCounts[category
                //                                       .fruitCategoryId!] =
                //                                   (itemCounts[category
                //                                               .fruitCategoryId!] ??
                //                                           0) +
                //                                       1;

                //                               // Print and log details after incrementing
                //                               print(
                //                                   "Incremented Item: Name: ${category.fruitName}, ID: ${category.fruitsId}, Count: ${itemCounts[category.fruitCategoryId]}");
                //                               log("Incremented Item: Name: ${category.fruitName}, ID: ${category.fruitsId}, Count: ${itemCounts[category.fruitCategoryId]}");
                //                             });
                //                             try {
                //                               await AppDialogue
                //                                   .openLoadingDialogAfterClose(
                //                                       context,
                //                                       text: "Updating...",
                //                                       load: () async {
                //                                 return await getProvider.updateCart(
                //                                     categoryId: category
                //                                             .fruitCategoryId ??
                //                                         '',
                //                                     count: itemCounts[category
                //                                             .fruitCategoryId] ??
                //                                         0,
                //                                     token: token);
                //                               }, afterComplete: (resp) async {
                //                                 if (resp.status) {
                //                                   print("Success");
                //                                   AppDialogue.toast(resp.data);
                //                                 }
                //                               });
                //                             } catch (e) {
                //                               ExceptionHandler.showMessage(
                //                                   context, e);
                //                             }
                //                             await getProvider
                //                                 .fetchAddToCart(token);
                //                           },
                //                         ),
                //                       ],
                //                     )
                //                   : GestureDetector(
                //                       onTap: () async {
                //                         print(
                //                             "Category ID: ${category.fruitCategoryId}");
                //                         log("Category ID: ${category.fruitCategoryId}");

                //                         setState(() {
                //                           isAddedToCartMap[
                //                               category.fruitCategoryId!] = true;
                //                           itemCounts[
                //                               category.fruitCategoryId!] = 1;
                //                         });
                //                         try {
                //                           await AppDialogue
                //                               .openLoadingDialogAfterClose(
                //                                   context,
                //                                   text: "Adding to cart...",
                //                                   load: () async {
                //                             return await getProvider.addToCart(
                //                                 fruitId: category.fruitsId!,
                //                                 categoryId:
                //                                     category.fruitCategoryId!,
                //                                 count: itemCounts[category
                //                                         .fruitCategoryId] ??
                //                                     0,
                //                                 token: token);
                //                           }, afterComplete: (resp) async {
                //                             if (resp.status) {
                //                               print("sucess");

                //                               AppDialogue.toast(resp.data);
                //                             }
                //                           });
                //                         } on Exception catch (e) {
                //                           ExceptionHandler.showMessage(
                //                               context, e);
                //                         }
                //                       },
                //                       child: Container(
                //                         padding: const EdgeInsets.symmetric(
                //                             vertical: 5, horizontal: 10),
                //                         decoration: BoxDecoration(
                //                           color: AppColor.fillColor,
                //                           borderRadius:
                //                               BorderRadius.circular(8),
                //                         ),
                //                         child: Text(
                //                           'Add to cart',
                //                           style: Styles.textStyleSmall(context,
                //                               color: Colors.white),
                //                         ),
                //                       ),
                //                     ),
                //             ],
                //           ),
                //         ),
                //       );
                //     },
                //   ),
//           ),
//         ],
//       ),
//     );
//   }
// }
