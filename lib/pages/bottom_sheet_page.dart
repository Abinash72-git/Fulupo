import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:fulupo/customs/styles.dart';
import 'package:fulupo/pages/cart_page.dart';
import 'package:fulupo/provider/get_provider.dart';
import 'package:fulupo/util/color_constant.dart';
import 'package:fulupo/util/constant_image.dart';
import 'package:fulupo/util/exception.dart';
import 'package:fulupo/widget/dilogue/dilogue.dart';

import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BottomSheetWidget extends StatefulWidget {
  const BottomSheetWidget({super.key});

  @override
  _BottomSheetWidgetState createState() => _BottomSheetWidgetState();
}

class _BottomSheetWidgetState extends State<BottomSheetWidget> {
  GetProvider get getprovider => context.read<GetProvider>();
  String token = '';
  double TotalCurrentPrice = 0;
  double TotalOldPrice = 0;
  double totalSavings = 0;
  Timer? _debounce;

  getdata() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      token = prefs.getString('token') ?? '';
      print(token);
      log('Token: $token');
    });

    await getprovider.fetchAddToCart(token);
    recalculateTotalPrice();
  }

  void recalculateTotalPrice() {
    double totalCurrentPrice = 0;
    double totalOldPrice = 0;

    getprovider.getAddToCart.forEach((item) {
      totalCurrentPrice += (item.currentPrice ?? 0.0) * (item.count ?? 0);
      totalOldPrice += (item.oldPrice ?? 0.0) * (item.count ?? 0);
    });

    setState(() {
      TotalCurrentPrice = totalCurrentPrice;
      TotalOldPrice = totalOldPrice;
      totalSavings = totalOldPrice - totalCurrentPrice;
    });
  }

  void _onCountChanged(int newCount, item) {
    // Cancel the previous timer if it exists
    _debounce?.cancel();

    // Set a new timer for 1 second
    _debounce = Timer(const Duration(seconds: 1), () async {
      // Trigger the API call here after the debounce delay
      try {
        await AppDialogue.openLoadingDialogAfterClose(context,
            text: "Loading...", load: () async {
          return await getprovider.updateCart(
              categoryId: item.fruitCategoryId ?? '',
              count: newCount,
              token: token);
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getdata();
  }

  @override
  void dispose() {
    // Dispose of the timer when the widget is disposed
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return AnimatedContainer(
      duration: Duration(milliseconds: 300), // Animation duration
      padding: EdgeInsets.all(10),
      height: screenHeight * 0.5,

      width: screenWidth,

      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(35)),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context, 'Yes');
                },
                child: Container(
                    height: 30,
                    width: 30,
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                              blurRadius: 8,
                              color: Colors.grey,
                              offset: Offset(0, 4))
                        ]),
                    child: const Icon(
                      Icons.arrow_drop_down,
                      color: AppColor.fillColor,
                    )),
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 15),
              child: Text(
                'Check Your Items',
                style:
                    Styles.textStyleLarge(context, color: AppColor.blackColor),
                textScaleFactor: 1.0,
              ),
            ),
            SizedBox(height: 15),
            Consumer<GetProvider>(
              builder: (context, cartProvider, child) {
                if (cartProvider.getAddToCart.isEmpty) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // SizedBox(
                      //   height: screenHeight * 0.12,
                      // ),
                      Lottie.asset("assets/map_pin/emptycart.json",
                          height: screenHeight * 0.3,
                          width: screenWidth * 0.9,
                          fit: BoxFit.cover),
                      Center(
                        child: Text(
                          'Your cart is empty',
                          style: TextStyle(fontSize: 18),
                          textScaleFactor: 1.0,
                        ),
                      ),
                    ],
                  );
                }

                return Column(
                  children: [
                    // ListView.builder for the cart items
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: cartProvider.getAddToCart.length,
                      itemBuilder: (context, index) {
                        final item = cartProvider.getAddToCart[index];

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.12,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 5),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  // Image Container
                                  Container(
                                    height: 70,
                                    width: 70,
                                    margin: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.5),
                                          spreadRadius: 1,
                                          blurRadius: 5,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                      image: DecorationImage(
                                        image:
                                            NetworkImage(item.fruitImage ?? ''),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  // Product Details Column
                                  Expanded(
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            item.fruitName ?? 'Unknown',
                                            style: Styles.textStyleMedium(
                                                context,
                                                color: AppColor.fillColor),
                                            textScaleFactor: 1.0,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            item.fruitSubname ?? '',
                                            style: Styles.textStyleSmall(
                                                context,
                                                color: AppColor.hintTextColor),
                                            textScaleFactor: 1.0,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            item.fruitsQuantity ?? '',
                                            style: Styles.textStyleSmall(
                                                context,
                                                color: AppColor.hintTextColor),
                                            textScaleFactor: 1.0,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                '₹${item.currentPrice?.toStringAsFixed(2) ?? '0.00'}',
                                                style: Styles.textStyleSmall(
                                                    context,
                                                    color: AppColor.blackColor),
                                                textScaleFactor: 1.0,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              SizedBox(width: 10),
                                              if (item.oldPrice != null)
                                                Text(
                                                  '₹${item.oldPrice?.toStringAsFixed(2) ?? '0.00'}',
                                                  style: Styles
                                                          .textStyleExtraSmall(
                                                              context,
                                                              color: AppColor
                                                                  .hintTextColor)
                                                      .copyWith(
                                                          decoration:
                                                              TextDecoration
                                                                  .lineThrough),
                                                  textScaleFactor: 1.0,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  // Counter Section
                                  Row(
                                    children: [
                                      // Decrease Button
                                      IconButton(
                                        icon: const Icon(Icons.remove,
                                            color: Colors.red),
                                        onPressed: () {
                                          setState(() {
                                            if (item.count != null &&
                                                item.count! > 0) {
                                              item.count = item.count! - 1;
                                              print(
                                                  "Decremented Item: Name: ${item.fruitName}, ID: ${item.fruitsId}, Count: ${item.count}");
                                              log("Decremented Item: Name: ${item.fruitName}, ID: ${item.fruitsId}, Count: ${item.count}");
                                              recalculateTotalPrice();
                                              _onCountChanged(item.count ?? 0,
                                                  item); // Trigger debounced API call
                                            }
                                          });
                                        },
                                      ),

                                      // Display the item count
                                      Text(item.count?.toString() ?? '0'),

                                      // Increase Button
                                      IconButton(
                                        icon: const Icon(Icons.add,
                                            color: AppColor.fillColor),
                                        onPressed: () {
                                          setState(() {
                                            if (item.count != null) {
                                              item.count = item.count! + 1;
                                              print(
                                                  "Incremented Item: Name: ${item.fruitName}, ID: ${item.fruitsId}, Count: ${item.count}");
                                              log("Incremented Item: Name: ${item.fruitName}, ID: ${item.fruitsId}, Count: ${item.count}");
                                              recalculateTotalPrice();
                                              _onCountChanged(item.count ?? 0,
                                                  item); // Trigger debounced API call
                                            }
                                          });
                                        },
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                );
              },
            ),
            if (TotalCurrentPrice != 0)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 2, vertical: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // Image Container
                    Container(
                      height: 60,
                      width: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                        image: const DecorationImage(
                          image: AssetImage(ConstantImageKey
                              .vegitable), // Your image logic here
                          fit: BoxFit.cover,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 20),
                    // Column with Item Info
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Display the number of items and total price
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            '${getprovider.getAddToCart.length} Item${getprovider.getAddToCart.length > 1 ? 's' : ''} | ₹${TotalCurrentPrice.toStringAsFixed(2)}',
                            style: Styles.textStyleMedium(
                              context,
                              color: AppColor.blackColor,
                            ),
                            textScaleFactor: 1.0,
                          ),
                        ),
                        // Display the saved amount
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'You Saved ₹${totalSavings.toStringAsFixed(2)}',
                            style: Styles.textStyleSmall(
                              context,
                              color: AppColor.fillColor,
                            ),
                            textScaleFactor: 1.0,
                          ),
                        ),
                      ],
                    ),
                    Spacer(),
                    // Cart Button
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => CartPage(
                                    // products: widget.products,
                                    // productCount: widget.productCount,
                                    // selectedWeights: widget.selectedWeights
                                    )));
                      },
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                        decoration: BoxDecoration(
                          color: AppColor.fillColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            'Go to Cart',
                            style: Styles.textStyleSmall(
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
    );
  }
}
