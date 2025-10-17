import 'dart:developer';

import 'package:carousel_slider/carousel_slider.dart';

import 'package:flutter/material.dart';
import 'package:fulupo/customs/styles.dart';
import 'package:fulupo/provider/get_provider.dart';
import 'package:fulupo/util/app_constant.dart';
import 'package:fulupo/util/color_constant.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class ProductDetailsPage extends StatefulWidget {
  final String productId;
  const ProductDetailsPage({super.key, required this.productId});

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  int myCurrentIndex = 0;
  Map<String, String> selectedWeights = {};

  bool isAnyItemAdded() {
    return isAdded.values.contains(true);
  }

  GetProvider get getprovider => context.read<GetProvider>();

  Map<String, bool> isFavorite = {};
  Map<String, bool> isAdded = {};
  Map<String, int> productCount = {};

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    final myitems = [
      ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.asset(
          'assets/images/slider1.jpg',
          width: screenWidth * 0.9,
          fit: BoxFit.cover,
        ),
      ),
      ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.asset(
          'assets/images/slider2.jpeg',
          width: screenWidth * 0.9,
          fit: BoxFit.cover,
        ),
      ),
      ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.asset(
          'assets/images/slider3.jpg',
          width: screenWidth * 0.9,
          fit: BoxFit.cover,
        ),
      ),
    ];
    // Method to calculate the total price of all selected products

    return Scaffold(
      backgroundColor: AppColor.fillColor,
      appBar: AppBar(
        title: Text('Product Details'),
        backgroundColor: AppColor.fillColor,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: screenHeight * 0.03),
                  Container(
                    height: screenHeight * 0.33,
                    width: screenWidth,
                    decoration: BoxDecoration(
                      color: AppColor.whiteColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        CarouselSlider(
                          options: CarouselOptions(
                            autoPlay: false,
                            height: screenHeight * 0.2,
                            autoPlayInterval: const Duration(seconds: 5),
                            viewportFraction: 1,
                            enlargeCenterPage: true,
                            aspectRatio: 200,
                            onPageChanged: (index, reason) {
                              setState(() {
                                myCurrentIndex = index;
                              });
                            },
                          ),
                          items: myitems,
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        Center(
                          child: AnimatedSmoothIndicator(
                            activeIndex: myCurrentIndex,
                            count: myitems.length,
                            effect: const JumpingDotEffect(
                              dotHeight: 7,
                              dotWidth: 7,
                              spacing: 5,
                              dotColor: AppColor.hintTextColor,
                              activeDotColor: AppColor.fillColor,
                              paintStyle: PaintingStyle.fill,
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              ' Fresh Carrot - (Orange loose) ',
                              style: Styles.textStyleLarge(
                                context,
                                color: AppColor.fillColor,
                              ),
                              textScaleFactor: 1.0,
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: Row(
                            children: [
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: '${AppConstants.Rupees}42.00',
                                      style: Styles.textStyleMedium(
                                        context,
                                        color: AppColor.blackColor,
                                      ),
                                    ),
                                    const WidgetSpan(
                                      child: SizedBox(
                                        width: 8,
                                      ), // Adds horizontal space
                                    ),
                                    TextSpan(
                                      text: '${AppConstants.Rupees}52.00',
                                      style:
                                          Styles.textStyleSmall(
                                            context,
                                            color: AppColor.hintTextColor,
                                          ).copyWith(
                                            decoration: TextDecoration
                                                .lineThrough, // Adds the strikethrough
                                          ),
                                    ),
                                  ],
                                ),
                                textScaleFactor: 1.0,
                              ),
                              Spacer(),
                              Container(
                                width: screenWidth * 0.25,
                                padding: EdgeInsets.symmetric(
                                  vertical: 3,
                                  horizontal: 5,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: AppColor.fillColor,
                                ),
                                child: Center(
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      'Add ',
                                      style: Styles.textStyleMedium(
                                        context,
                                        color: AppColor.whiteColor,
                                      ),
                                      textScaleFactor: 1.0,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  Text(
                    'Pack Size',
                    style: Styles.textStyleExtraLarge(
                      context,
                      color: AppColor.yellowColor,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ), // Add spacing between title and containers
                  // Row for containers
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Container for 1kg
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedWeights['weight'] =
                                '1kg'; // Update the selected weight
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: selectedWeights == '1kg'
                                ? Colors.green
                                : AppColor
                                      .whiteColor, // Default white background
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColor.borderColor),
                          ),
                          child: Column(
                            children: [
                              Container(
                                width: 100,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: selectedWeights == '1kg'
                                      ? const Color.fromARGB(255, 201, 195, 195)
                                      : const Color.fromARGB(
                                          255,
                                          201,
                                          195,
                                          195,
                                        ),
                                ),
                                child: Center(
                                  child: Text(
                                    '1kg',
                                    style: Styles.textStyleMedium(
                                      context,
                                      color: selectedWeights == '1kg'
                                          ? Colors
                                                .black // White text for selected
                                          : AppColor.blackColor,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                '${AppConstants.Rupees}50.00',
                                style: Styles.textStyleMedium(
                                  context,
                                  color: selectedWeights == '1kg'
                                      ? Colors.white
                                      : AppColor.blackColor,
                                ),
                              ),
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: '${AppConstants.Rupees}60.00',
                                      style:
                                          Styles.textStyleSmall(
                                            context,
                                            color: selectedWeights == '1kg'
                                                ? Colors.white
                                                : AppColor.blackColor,
                                          ).copyWith(
                                            decoration:
                                                TextDecoration.lineThrough,
                                          ),
                                    ),
                                    const WidgetSpan(child: SizedBox(width: 8)),
                                    TextSpan(
                                      text: '36% OFF',
                                      style: Styles.textStyleSmall(
                                        context,
                                        color: selectedWeights == '1kg'
                                            ? const Color.fromARGB(
                                                255,
                                                255,
                                                0,
                                                0,
                                              )
                                            : const Color.fromARGB(
                                                255,
                                                255,
                                                0,
                                                0,
                                              ),
                                      ).copyWith(fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                textScaleFactor: 1.0,
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Container for 500g
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedWeights['weight'] =
                                '500g'; // Update the selected weight
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: selectedWeights == '500g'
                                ? Colors
                                      .green // Green background for selected
                                : AppColor
                                      .whiteColor, // Default white background
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColor.borderColor),
                          ),
                          child: Column(
                            children: [
                              Container(
                                width: 100,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: selectedWeights == '500g'
                                      ? const Color.fromARGB(255, 201, 195, 195)
                                      : const Color.fromARGB(
                                          255,
                                          201,
                                          195,
                                          195,
                                        ),
                                ),
                                child: Center(
                                  child: Text(
                                    '500g',
                                    style: Styles.textStyleMedium(
                                      context,
                                      color: selectedWeights == '500g'
                                          ? Colors
                                                .white // White text for selected
                                          : AppColor.blackColor,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                '${AppConstants.Rupees}30.00',
                                style: Styles.textStyleMedium(
                                  context,
                                  color: selectedWeights == '500g'
                                      ? Colors.white
                                      : AppColor.blackColor,
                                ),
                              ),
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: '${AppConstants.Rupees}42.00',
                                      style:
                                          Styles.textStyleSmall(
                                            context,
                                            color: selectedWeights == '500g'
                                                ? Colors.white
                                                : AppColor.blackColor,
                                          ).copyWith(
                                            decoration:
                                                TextDecoration.lineThrough,
                                          ),
                                    ),
                                    const WidgetSpan(child: SizedBox(width: 8)),
                                    TextSpan(
                                      text: '36% OFF',
                                      style: Styles.textStyleSmall(
                                        context,
                                        color: selectedWeights == '500g'
                                            ? const Color.fromARGB(
                                                255,
                                                255,
                                                0,
                                                0,
                                              )
                                            : const Color.fromARGB(
                                                255,
                                                255,
                                                0,
                                                0,
                                              ),
                                      ).copyWith(fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                textScaleFactor: 1.0,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  Text(
                    'Description',
                    style: Styles.textStyleExtraLarge(
                      context,
                      color: AppColor.yellowColor,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  Center(
                    child: Text(
                      'About the product',
                      style: Styles.textStyleExtraLarge(
                        context,
                        color: AppColor.yellowColor,
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  Text(
                    'Carrots are a particularly good source of beta carotene, fiber, vitamin K1, potassium, and antioxidants. They also have a number of health benefits. They’re a weight-loss-friendly food and have been linked to lower cholesterol levels and improved eye health.',
                    style: Styles.textStyleMedium(
                      context,
                      color: AppColor.whiteColor,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  Center(
                    child: Text(
                      'Storage',
                      style: Styles.textStyleExtraLarge(
                        context,
                        color: AppColor.yellowColor,
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  Text(
                    'Store in a cool, dry place away from direct sunlight.They also have a number of health benefits. They’re a weight-loss-friendly food and have been linked to lower cholesterol levels and improved eye health.',
                    style: Styles.textStyleMedium(
                      context,
                      color: AppColor.whiteColor,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  // Text(
                  //   'Similar Products',
                  //   style: Styles.textStyleExtraLarge(context,
                  //       color: AppColor.yellowColor),
                  // ),
                  // SizedBox(height: screenHeight * 0.03),
                  //         Consumer<GetProvider>(
                  //   builder: (context, fruitProvider, child) {
                  //     return FruitGridView(
                  //       fruits: fruitProvider.fruits,
                  //       screenHeight: screenHeight,
                  //       screenWidth: screenWidth,
                  //       isAdded: isAdded,
                  //       productCount: productCount,
                  //       isFavorite: isFavorite,
                  //       onAdd: (fruit) {
                  //         setState(() {
                  //           if (!(isAdded[fruit.fruitsId] ?? false)) {
                  //             Product productObj = Product(
                  //               image: fruit.fruitImage ?? '',
                  //               name: fruit.fruitName ?? '',
                  //               subname: fruit.fruitSubname ?? '',
                  //               price: fruit.currentPrice?.toString() ?? '',
                  //               oldPrice: fruit.oldPrice?.toString() ?? '',
                  //               key: fruit.fruitsId ?? '',
                  //             );

                  //             isAdded[fruit.fruitsId ?? ''] = true;
                  //             productCount[fruit.fruitsId ?? ''] = 1;
                  //             selectedProducts.add(productObj);

                  //             // Store the fruit quantity in selectedWeights
                  //             selectedWeights[fruit.fruitsId ?? ''] =
                  //                 fruit.fruitsQuantity ?? '0';

                  //             // Print the fruit details
                  //             print(
                  //                 "Added Fruit: ${fruit.fruitName}, ID: ${fruit.fruitsId}");
                  //             log("Added Fruit: ${fruit.fruitName}, ID: ${fruit.fruitsId}");
                  //           } else {
                  //             productCount[fruit.fruitsId ?? ''] =
                  //                 (productCount[fruit.fruitsId] ?? 0) + 1;

                  //             // Update the quantity in selectedWeights
                  //             selectedWeights[fruit.fruitsId ?? ''] = (int.tryParse(
                  //                         selectedWeights[fruit.fruitsId ?? ''] ??
                  //                             '0') ??
                  //                     0 + 1)
                  //                 .toString();

                  //             // Print the fruit details
                  //             print(
                  //                 "Increased Count for Fruit: ${fruit.fruitName}, ID: ${fruit.fruitsId}");
                  //             log("Increased Count for Fruit: ${fruit.fruitName}, ID: ${fruit.fruitsId}");
                  //           }
                  //         });
                  //       },
                  //       onRemove: (fruit) {
                  //         setState(() {
                  //           if ((productCount[fruit.fruitsId] ?? 0) > 1) {
                  //             productCount[fruit.fruitsId ?? ''] =
                  //                 (productCount[fruit.fruitsId] ?? 0) - 1;

                  //             // Decrease the quantity in selectedWeights
                  //             selectedWeights[fruit.fruitsId ?? ''] = (int.tryParse(
                  //                         selectedWeights[fruit.fruitsId ?? ''] ??
                  //                             '0') ??
                  //                     0 - 1)
                  //                 .toString();

                  //             // Print the fruit details
                  //             print(
                  //                 "Decreased Count for Fruit: ${fruit.fruitName}, ID: ${fruit.fruitsId}");
                  //             log("Decreased Count for Fruit: ${fruit.fruitName}, ID: ${fruit.fruitsId}");
                  //           } else {
                  //             isAdded[fruit.fruitsId ?? ''] = false;
                  //             productCount[fruit.fruitsId ?? ''] = 0;
                  //             selectedProducts
                  //                 .removeWhere((item) => item.key == fruit.fruitsId);

                  //             // Remove the fruit quantity from selectedWeights
                  //             selectedWeights.remove(fruit.fruitsId ?? '');

                  //             // Print the fruit details
                  //             print(
                  //                 "Removed Fruit: ${fruit.fruitName}, ID: ${fruit.fruitsId}");
                  //             log("Removed Fruit: ${fruit.fruitName}, ID: ${fruit.fruitsId}");
                  //           }
                  //         });
                  //       },
                  //       onFavoriteToggle: (fruit) {
                  //         setState(() {
                  //           isFavorite[fruit.fruitsId ?? ''] =
                  //               !(isFavorite[fruit.fruitsId] ?? false);

                  //           // Print the fruit details
                  //           print(
                  //               "Favorite Toggled for Fruit: ${fruit.fruitName}, ID: ${fruit.fruitsId}");
                  //           log("Favorite Toggled for Fruit: ${fruit.fruitName}, ID: ${fruit.fruitsId}");
                  //         });
                  //       },
                  //       onTap: (fruit) {
                  //         print(
                  //             "Tapped Fruit: ${fruit.fruitName}, ID: ${fruit.fruitsId}");
                  //         log("Tapped Fruit: ${fruit.fruitName}, ID: ${fruit.fruitsId}");

                  //         Navigator.push(
                  //           context,
                  //           MaterialPageRoute(
                  //             builder: (context) => ProductDetailsPage(
                  //               productId: fruit.fruitsId ?? '',
                  //             ),
                  //           ),
                  //         );
                  //       },
                  //     );
                  //   },
                  // ),
                ],
              ),
            ),
          ),
          //  if (isAnyItemAdded())
          //   Positioned(
          //     bottom: 10, // Position it at the bottom
          //     left: 0,
          //     right: 0,
          //     child: Padding(
          //       padding: const EdgeInsets.all(10.0),
          //       child: Container(
          //         padding:
          //             const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          //         decoration: BoxDecoration(
          //           color: Colors.white,
          //           boxShadow: [
          //             BoxShadow(
          //               color: Colors.grey.withOpacity(0.5),
          //               spreadRadius: 2,
          //               blurRadius: 5,
          //               offset: Offset(0, 3),
          //             ),
          //           ],
          //           borderRadius: BorderRadius.circular(20),
          //         ),
          //         child: Column(
          //           children: [
          //             Align(
          //                 alignment: Alignment.topCenter,
          //                 child: GestureDetector(
          //                   onTap: () {
          //                     // Show BottomSheet with the updated list of products
          //                     showModalBottomSheet(
          //                       context: context,
          //                       isScrollControlled: true,
          //                       builder: (BuildContext context) {
          //                         return BottomSheetWidget(
          //                           products:
          //                               selectedProducts, // Pass the list of selected products
          //                           productCount:
          //                               productCount, // Pass the count of each product
          //                           selectedWeights:
          //                               selectedWeights, // Map of selected weights
          //                         );
          //                       },
          //                     );
          //                   },
          //                   child: Container(
          //                       height: 30,
          //                       width: 30,
          //                       decoration: const BoxDecoration(
          //                           shape: BoxShape.circle,
          //                           color: Colors.white,
          //                           boxShadow: [
          //                             BoxShadow(
          //                                 blurRadius: 8,
          //                                 color: Colors.grey,
          //                                 offset: Offset(0, 4))
          //                           ]),
          //                       child: const Icon(
          //                         Icons.arrow_drop_up_outlined,
          //                         color: AppColor.fillColor,
          //                       )),
          //                 )),
          //             Row(
          //               mainAxisAlignment: MainAxisAlignment.start,
          //               children: [
          //                 // Image Container
          //                 Container(
          //                   height: 60,
          //                   width: 60,
          //                   decoration: BoxDecoration(
          //                     borderRadius: BorderRadius.circular(10),
          //                     color: Colors.white,
          //                     image: const DecorationImage(
          //                       image: AssetImage(ConstantImageKey
          //                           .vegitable), // Your image logic here
          //                       fit: BoxFit.cover,
          //                     ),
          //                     boxShadow: [
          //                       BoxShadow(
          //                         color: Colors.grey.withOpacity(0.5),
          //                         spreadRadius: 2,
          //                         blurRadius: 5,
          //                         offset: Offset(0, 3),
          //                       ),
          //                     ],
          //                   ),
          //                 ),
          //                 SizedBox(width: 20),
          //                 // Column with Item Info
          //                 Column(
          //                   crossAxisAlignment: CrossAxisAlignment.start,
          //                   children: [
          //                     // Display the number of items and total price
          //                     FittedBox(
          //                       fit: BoxFit.scaleDown,
          //                       child: Text(
          //                         '${selectedProducts.length} Item${selectedProducts.length > 1 ? 's' : ''} | ₹${_calculateTotalAmount().toStringAsFixed(2)}',
          //                         style: Styles.textStyleMedium(
          //                           context,
          //                           color: AppColor.blackColor,
          //                         ),
          //                         textScaleFactor: 1.0,
          //                       ),
          //                     ),
          //                     // Display the saved amount
          //                     FittedBox(
          //                       fit: BoxFit.scaleDown,
          //                       child: Text(
          //                         'You Saved ₹${_calculateTotalDiscount().toStringAsFixed(2)}',
          //                         style: Styles.textStyleSmall(
          //                           context,
          //                           color: AppColor.fillColor,
          //                         ),
          //                         textScaleFactor: 1.0,
          //                       ),
          //                     ),
          //                   ],
          //                 ),
          //                 Spacer(),
          //                 // Cart Button
          //                 GestureDetector(
          //                   onTap: () {
          //                     Navigator.push(
          //                         context,
          //                         MaterialPageRoute(
          //                             builder: (context) => CartPage(
          //                                 products: selectedProducts,
          //                                 productCount: productCount,
          //                                 selectedWeights: selectedWeights)));
          //                   },
          //                   child: Container(
          //                     padding: const EdgeInsets.symmetric(
          //                         vertical: 10, horizontal: 8),
          //                     decoration: BoxDecoration(
          //                       color: AppColor.fillColor,
          //                       borderRadius: BorderRadius.circular(10),
          //                     ),
          //                     child: Center(
          //                       child: Text(
          //                         'Go to Cart',
          //                         style: Styles.textStyleSmall(
          //                           context,
          //                           color: AppColor.whiteColor,
          //                         ),
          //                         textScaleFactor: 1.0,
          //                       ),
          //                     ),
          //                   ),
          //                 ),
          //               ],
          //             ),
          //           ],
          //         ),
          //       ),
          //     ),
          //   ),
        ],
      ),
    );
  }
}
