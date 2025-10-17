import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fulupo/model/cart/getCart_model.dart';
import 'package:fulupo/provider/get_provider.dart';
import 'package:fulupo/util/app_constant.dart';
import 'package:fulupo/util/color_constant.dart';
import 'package:fulupo/customs/styles.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Cartpage extends StatefulWidget {
  const Cartpage({super.key});

  @override
  State<Cartpage> createState() => _CartpageState();
}

class _CartpageState extends State<Cartpage> {
  late Future<List<GetcartModel>> _cartFuture;
  String? userAddress;
  String? savedAddressId;
  String? storeId;
  GetProvider get getprovider => context.read<GetProvider>();
  Map<String, bool> _updatingItems = {}; // Track which items are being updated
  bool _isProcessingOrder = false;
  // Payment method selection
  String _selectedPaymentMethod = 'online'; // Default to online payment

  @override
  void initState() {
    super.initState();
    _cartFuture = getprovider.getCart();
    _getLocation();
  }

  Future<void> _getLocation() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userAddress =
          prefs.getString(AppConstants.USERADDRESS) ?? "No address saved";

      savedAddressId = prefs.getString(AppConstants.ADDRESS_ID);
      storeId = prefs.getString(AppConstants.StoreCode);
    });
    log('$userAddress');
    log('Saved Address ID: $savedAddressId');
  }

  // Function to remove item from cart
  Future<void> _removeFromCart(GetcartModel item, BuildContext context) async {
    // Set updating flag for this specific item
    setState(() {
      _updatingItems[item.productId] = true;
    });

    try {
      final result = await getprovider.RemoveCart(
        storeId: item.storeId,
        productId: item.productId,
      );

      if (result.status) {
        log('Item removed from cart successfully');
        // Refresh the entire cart to reflect the removal
        setState(() {
          _cartFuture = getprovider.getCart();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to remove item: ${result.data}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      log('Error removing item from cart: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("An error occurred while removing the item"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      // Clear updating flag for this item
      setState(() {
        _updatingItems[item.productId] = false;
      });
    }
  }

  // Function to handle cart updates
  Future<void> _updateCartQuantity(
    GetcartModel item,
    int newQuantity,
    BuildContext context,
  ) async {
    // If newQuantity is 0, call remove cart instead
    if (newQuantity == 0) {
      await _removeFromCart(item, context);
      return;
    }

    // Set updating flag for this specific item
    setState(() {
      _updatingItems[item.productId] = true;
    });

    try {
      final result = await getprovider.UpdateCart(
        quantity: newQuantity,
        storeId: item.storeId,
        productId: item.productId,
      );

      if (result.status) {
        log('Cart updated successfully');
        // Just update the item quantity in the local state
        setState(() {
          item.quantity = newQuantity;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to update cart: ${result.data}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      log('Error updating cart: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("An error occurred while updating the cart"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      // Clear updating flag for this item
      setState(() {
        _updatingItems[item.productId] = false;
      });
    }
  }

  // Add a new function to handle the checkout process
  Future<void> _proceedToCheckout() async {
    // Show loading indicator
    setState(() {
      _isProcessingOrder = true;
    });

    try {
      if (savedAddressId == null || savedAddressId!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Please select a delivery address"),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final cartItems = await getprovider.getCart();
      if (cartItems.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Your cart is empty"),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Calculate total amount
      double total = 0;
      for (var item in cartItems) {
        total += (item.mrpPrice * item.quantity);
      }

      // Add delivery charge and tax
      double deliveryCharge = 40.0;
      double tax = total * 0.05;
      double grandTotal = total + deliveryCharge + tax;

      // Prepare items array for the API
      List<Map<String, dynamic>> orderItems = cartItems
          .map(
            (item) => {
              "productId": item.productId,
              "name": item.productName,
              "quantity": item.quantity,
              "price": item.mrpPrice,
              "total": item.mrpPrice * item.quantity,
            },
          )
          .toList();

      // Determine payment mode based on selection
      String paymentMode = _selectedPaymentMethod == 'online'
          ? "Razorpay"
          : "COD";

      // Call the create order API
      final result = await getprovider.createOrder(
        storeId:
            storeId ??
            cartItems
                .first
                .storeId, // Use passed storeId or take from first cart item
        addressId: savedAddressId!,
        items: orderItems,
        totalAmount: grandTotal,
        paymentMode: paymentMode,
      );

      if (result.status) {
        // Handle successful order creation
        if (paymentMode == "Razorpay") {
          // Handle online payment flow (e.g., open Razorpay)
          _initiateRazorpayPayment(result.fullBody);
        } else {
          // Order placed successfully with COD
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "Order placed successfully! You chose Cash on Delivery.",
              ),
              backgroundColor: Colors.green,
            ),
          );

          // Navigate to order success page or order history
          Navigator.pushReplacementNamed(context, '/order-success');
        }
      } else {
        // Handle error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to place order: ${result.data}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      log('Error during checkout: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("An error occurred during checkout"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      // Hide loading indicator
      setState(() {
        _isProcessingOrder = false;
      });
    }
  }

  // Placeholder for Razorpay integration
  void _initiateRazorpayPayment(dynamic orderData) {
    // Implement Razorpay payment flow
    // This would typically involve creating a Razorpay instance,
    // configuring it with the order details, and opening the payment UI

    // For now, just show a message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Online payment integration will be implemented here"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.fillColor,
      appBar: AppBar(
        title: const Text("Cart"),
        backgroundColor: AppColor.fillColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Address Bar at the Top
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: const BoxDecoration(color: AppColor.fillColor),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.location_on,
                  color: Colors.redAccent,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 40),
                        child: Text(
                          "Delivery to Your selected location",
                          style: Styles.textStyleMedium(
                            context,
                            color: AppColor.yellowColor,
                          ),
                        ),
                      ),
                      Text(
                        userAddress ?? "Loading address...",
                        style: Styles.textStyleSmall(
                          context,
                          color: AppColor.whiteColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Add new address coming soon"),
                    ),
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: AppColor.fillColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Icon(
                        Icons.add,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      "Add Address",
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Cart Items and Bill Details - All in one scrollable area
          Expanded(
            child: FutureBuilder<List<GetcartModel>>(
              future: _cartFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }
                final cartItems = snapshot.data ?? [];
                if (cartItems.isEmpty) {
                  return const Center(child: Text("Your cart is empty"));
                }

                // Calculate totals
                double itemsTotal = 0;
                int totalItems = 0;
                for (var item in cartItems) {
                  itemsTotal += (item.mrpPrice * item.quantity);
                  totalItems += item.quantity;
                }

                // Calculate other charges
                double deliveryCharge = 40.0; // Example delivery charge
                double tax = itemsTotal * 0.05; // Example 5% tax
                double grandTotal = itemsTotal + deliveryCharge + tax;

                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      children: [
                        // Cart Items
                        ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: cartItems.length,
                          itemBuilder: (context, index) {
                            final item = cartItems[index];
                            final isUpdating =
                                _updatingItems[item.productId] ?? false;

                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                              ),
                              child: Card(
                                elevation: 3,
                                margin: const EdgeInsets.only(bottom: 5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    children: [
                                      // Product Image
                                      Container(
                                        width: 80,
                                        height: 80,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          border: Border.all(
                                            color: Colors.grey.shade200,
                                            width: 1,
                                          ),
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          child: CachedNetworkImage(
                                            imageUrl:
                                                "${AppConstants.imageBaseUrl}/${item.storeLogo ?? ''}",
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) =>
                                                Container(
                                                  color: Colors.grey[100],
                                                  child: const Center(
                                                    child:
                                                        CircularProgressIndicator(
                                                          strokeWidth: 2,
                                                        ),
                                                  ),
                                                ),
                                            errorWidget:
                                                (
                                                  context,
                                                  url,
                                                  error,
                                                ) => Container(
                                                  color: Colors.grey[100],
                                                  child: const Icon(
                                                    Icons.image_not_supported,
                                                    color: Colors.grey,
                                                    size: 30,
                                                  ),
                                                ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 15),

                                      // Product Details
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // Product name row with delete icon
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    item.productName,
                                                    style:
                                                        Styles.textStyleMedium(
                                                          context,
                                                          color: AppColor
                                                              .fillColor,
                                                        ),
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                // Delete icon button
                                                GestureDetector(
                                                  onTap: isUpdating
                                                      ? null
                                                      : () {
                                                          _removeFromCart(
                                                            item,
                                                            context,
                                                          );
                                                        },
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.all(4),
                                                    decoration: BoxDecoration(
                                                      color: Colors.red
                                                          .withOpacity(0.1),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            4,
                                                          ),
                                                    ),
                                                    child: const Icon(
                                                      Icons.delete,
                                                      size: 18,
                                                      color: Colors.red,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),

                                            Row(
                                              children: [
                                                Text(
                                                  "₹${(item.mrpPrice * item.quantity).toStringAsFixed(2)}",
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.green[700],
                                                  ),
                                                ),
                                                const SizedBox(width: 5),
                                                Text(
                                                  "Unit price: ₹${item.mrpPrice.toStringAsFixed(2)}",
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                              ],
                                            ),

                                            Row(
                                              children: [
                                                Text(
                                                  "Quantity: ",
                                                  style: Styles.textStyleMedium(
                                                    context,
                                                    color: Colors.black54,
                                                  ),
                                                ),
                                                const Spacer(),
                                                Container(
                                                  height: 25,
                                                  decoration: BoxDecoration(
                                                    color: AppColor.fillColor,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          6,
                                                        ),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      // Minus button
                                                      GestureDetector(
                                                        onTap: isUpdating
                                                            ? null
                                                            : () {
                                                                if (item.quantity >
                                                                    1) {
                                                                  _updateCartQuantity(
                                                                    item,
                                                                    item.quantity -
                                                                        1,
                                                                    context,
                                                                  );
                                                                } else if (item
                                                                        .quantity ==
                                                                    1) {
                                                                  // If quantity is 1, next decrement will remove it
                                                                  _updateCartQuantity(
                                                                    item,
                                                                    0, // This will trigger remove cart
                                                                    context,
                                                                  );
                                                                }
                                                              },
                                                        child: Container(
                                                          width: 30,
                                                          height: 30,
                                                          alignment:
                                                              Alignment.center,
                                                          child: const Icon(
                                                            Icons.remove,
                                                            size: 16,
                                                            color: AppColor
                                                                .whiteColor,
                                                          ),
                                                        ),
                                                      ),

                                                      // Quantity display
                                                      Container(
                                                        width: 30,
                                                        alignment:
                                                            Alignment.center,
                                                        child: isUpdating
                                                            ? const SizedBox(
                                                                width: 12,
                                                                height: 12,
                                                                child: CircularProgressIndicator(
                                                                  strokeWidth:
                                                                      2,
                                                                  color: AppColor
                                                                      .yellowColor,
                                                                ),
                                                              )
                                                            : Text(
                                                                "${item.quantity}",
                                                                style: Styles.textStyleMedium(
                                                                  context,
                                                                  color: AppColor
                                                                      .yellowColor,
                                                                ),
                                                              ),
                                                      ),

                                                      // Plus button
                                                      GestureDetector(
                                                        onTap: isUpdating
                                                            ? null
                                                            : () {
                                                                _updateCartQuantity(
                                                                  item,
                                                                  item.quantity +
                                                                      1,
                                                                  context,
                                                                );
                                                              },
                                                        child: Container(
                                                          width: 30,
                                                          height: 30,
                                                          alignment:
                                                              Alignment.center,
                                                          child: const Icon(
                                                            Icons.add,
                                                            size: 16,
                                                            color: AppColor
                                                                .whiteColor,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.only(right: 240),
                          child: Text(
                            "Bill Details",
                            style: Styles.textStyleMedium(
                              context,
                              color: AppColor.yellowColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Bill Details Section
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                child: Column(
                                  children: [
                                    _buildBillRow(
                                      "Item Total",
                                      "₹${itemsTotal.toStringAsFixed(2)}",
                                      isTotal: false,
                                    ),
                                    _buildBillRow(
                                      "Delivery Charge",
                                      "₹${deliveryCharge.toStringAsFixed(2)}",
                                      isTotal: false,
                                    ),
                                    _buildBillRow(
                                      "Taxes & Charges",
                                      "₹${tax.toStringAsFixed(2)}",
                                      isTotal: false,
                                    ),
                                    const Divider(
                                      thickness: 1,
                                      color: Color(0xFFEEEEEE),
                                    ),
                                    // Special highlighted Grand Total row
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 8,
                                        horizontal: 12,
                                      ),
                                      margin: const EdgeInsets.symmetric(
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColor.fillColor.withOpacity(
                                          0.9,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "Grand Total",
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: AppColor.whiteColor,
                                            ),
                                            textScaler: const TextScaler.linear(
                                              1,
                                            ),
                                          ),
                                          Text(
                                            "₹${grandTotal.toStringAsFixed(2)}",
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: AppColor.whiteColor,
                                            ),
                                            textScaler: const TextScaler.linear(
                                              1,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Payment Method Selection - Simplified row
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Select Payment Method",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppColor.yellowColor,
                                ),
                                textScaler: const TextScaler.linear(1),
                              ),
                              const SizedBox(height: 10),

                              // Payment options in a simple row
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  // Online Payment Option
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Radio<String>(
                                        value: 'online',
                                        groupValue: _selectedPaymentMethod,
                                        onChanged: (value) {
                                          setState(() {
                                            _selectedPaymentMethod = value!;
                                          });
                                        },
                                        activeColor: AppColor.yellowColor,
                                        materialTapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      Text(
                                        "Online Payment",
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight:
                                              _selectedPaymentMethod == 'online'
                                              ? FontWeight.w600
                                              : FontWeight.normal,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(width: 20),

                                  // COD Option
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Radio<String>(
                                        value: 'cod',
                                        groupValue: _selectedPaymentMethod,
                                        onChanged: (value) {
                                          setState(() {
                                            _selectedPaymentMethod = value!;
                                          });
                                        },
                                        activeColor: AppColor.yellowColor,
                                        materialTapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      Text(
                                        "COD",
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight:
                                              _selectedPaymentMethod == 'cod'
                                              ? FontWeight.w600
                                              : FontWeight.normal,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 6,
                          ),
                          child: ElevatedButton(
                            onPressed: _isProcessingOrder
                                ? null
                                : _proceedToCheckout,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColor.whiteColor,
                              foregroundColor: AppColor.fillColor,
                              minimumSize: const Size(double.infinity, 45),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: _isProcessingOrder
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: AppColor.fillColor,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        "Processing...",
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ],
                                  )
                                : const Text(
                                    "Proceed To Pay",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                          ),
                        ),
                        // Add some space at the bottom for better scrolling
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to build bill detail rows
  Widget _buildBillRow(String title, String value, {required bool isTotal}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: isTotal ? 15 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: Colors.black87,
            ),
            textScaler: const TextScaler.linear(1),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: isTotal ? AppColor.fillColor : Colors.black87,
            ),
            textScaler: const TextScaler.linear(1),
          ),
        ],
      ),
    );
  }
}
