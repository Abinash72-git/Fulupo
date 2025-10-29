import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fulupo/model/cart/getCart_model.dart';
import 'package:fulupo/pages/saved_address_list_bottomsheet.dart';
import 'package:fulupo/provider/get_provider.dart';
import 'package:fulupo/route_genarator.dart';
import 'package:fulupo/util/app_constant.dart';
import 'package:fulupo/util/color_constant.dart';
import 'package:fulupo/customs/styles.dart';
import 'package:fulupo/widget/dilogue/dilogue.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

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
  Map<String, bool> _updatingItems = {};
  bool _isProcessingOrder = false;
  String _selectedPaymentMethod = 'online';

  // Razorpay instance
  late Razorpay _razorpay;

  // Store order details for payment verification
  String? _currentOrderId;
  Map<String, dynamic>? _currentOrderData;

  @override
  void initState() {
    super.initState();
    _cartFuture = getprovider.getCart();
    _getLocation();
    _initializeRazorpay();
  }

  // Initialize Razorpay
  void _initializeRazorpay() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    log('✅ Payment Success - Payment ID: ${response.paymentId}');
    log('Order ID: ${response.orderId}');
    log('Signature: ${response.signature}');

    setState(() {
      _isProcessingOrder = true;
    });

    try {
      // Verify payment on backend
      final result = await getprovider.verifyPayment(
        razorpayOrderId: response.orderId ?? '',
        razorpayPaymentId: response.paymentId ?? '',
        razorpaySignature: response.signature ?? '',
        orderId: _currentOrderId,
      );

      // Log full response for debugging
      log('Payment verification result: ${result.status}');
      log('Payment verification data: ${result.data}');
      log('Payment verification fullBody: ${result.fullBody}');

      if (result.status) {
        // Payment verified successfully
        AppDialogue.toast("Payment successful! Order placed.");

        // Get the latest cart items before clearing
        final cartItems = await getprovider.getCart();

        // Clear all items from cart
        await _clearEntireCart(cartItems);

        // Navigate to home page
        // AppRouteName.homepage.push(context);
      } else {
        // Handle verification failure
        String errorMessage =
            result.data?.toString() ?? "Payment verification failed";
        throw Exception(errorMessage);
      }
    } catch (e) {
      log('❌ Error verifying payment: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Payment verification failed: ${e.toString().replaceAll('Exception: ', '')}",
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    } finally {
      setState(() {
        _isProcessingOrder = false;
      });
    }
  }

  // Handle payment failure
  void _handlePaymentError(PaymentFailureResponse response) {
    log('❌ Payment Error - Code: ${response.code}');
    log('Message: ${response.message}');

    setState(() {
      _isProcessingOrder = false;
    });

    AppDialogue.toast("Payment failed: ${response.message}");
  }

  // Handle external wallet
  void _handleExternalWallet(ExternalWalletResponse response) {
    log('External Wallet Selected: ${response.walletName}');

    AppDialogue.toast("External wallet: ${response.walletName}");
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

  Future<void> _removeFromCart(GetcartModel item, BuildContext context) async {
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
        AppDialogue.toast(result.data);
        setState(() {
          _cartFuture = getprovider.getCart();
        });
      } else {
        AppDialogue.toast("Failed to remove item: ${result.data}");
      }
    } catch (e) {
      log('Error removing item from cart: $e');
      AppDialogue.toast("An error occurred while removing the item");
    } finally {
      setState(() {
        _updatingItems[item.productId] = false;
      });
    }
  }

  Future<void> _updateCartQuantity(
    GetcartModel item,
    int newQuantity,
    BuildContext context,
  ) async {
    if (newQuantity == 0) {
      await _removeFromCart(item, context);
      return;
    }

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
        setState(() {
          item.quantity = newQuantity;
        });
      } else {
        AppDialogue.toast("Failed to update cart: ${result.data}");
      }
    } catch (e) {
      log('Error updating cart: $e');
      AppDialogue.toast("An error occurred while updating the cart");
    } finally {
      setState(() {
        _updatingItems[item.productId] = false;
      });
    }
  }

  Future<void> _proceedToCheckout() async {
    setState(() {
      _isProcessingOrder = true;
    });

    try {
      if (savedAddressId == null || savedAddressId!.isEmpty) {
        AppDialogue.toast("Please select a delivery address");
        return;
      }

      final cartItems = await getprovider.getCart();
      if (cartItems.isEmpty) {
        AppDialogue.toast("Your cart is empty");
        return;
      }

      // Calculate total amount
      double total = 0;
      for (var item in cartItems) {
        total += (item.mrpPrice * item.quantity);
      }

      double deliveryCharge = 40.0;
      double tax = total * 0.05;
      double grandTotal = total + deliveryCharge + tax;

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

      String paymentMode = _selectedPaymentMethod == 'online'
          ? "Razorpay"
          : "COD";

      // Call the create order API
      final result = await getprovider.createOrder(
        storeId: storeId ?? cartItems.first.storeId,
        addressId: savedAddressId!,
        items: orderItems,
        totalAmount: grandTotal,
        paymentMode: paymentMode,
      );

      if (result.status) {
        if (paymentMode == "Razorpay") {
          // Handle online payment flow
          _initiateRazorpayPayment(result.fullBody);
        } else {
          // Order placed successfully with COD
          AppDialogue.toast(
            "Order placed successfully! You chose Cash on Delivery.",
          );

          // Get the latest cart items before clearing
          final cartItems = await getprovider.getCart();

          // Clear all items from cart
          await _clearEntireCart(cartItems);

          // Navigate to app page with index 1
          //  AppRouteName.apppage.push(context, args: 1);
        }
      } else {
        AppDialogue.toast("Failed to place order: ${result.data}");
      }
    } catch (e) {
      log('Error during checkout: $e');
      AppDialogue.toast("An error occurred during checkout");
    } finally {
      if (_selectedPaymentMethod != 'online') {
        setState(() {
          _isProcessingOrder = false;
        });
      }
    }
  }

  void _initiateRazorpayPayment(dynamic orderData) {
    try {
      // Extract data from response
      final razorpayOrder = orderData['razorpayOrder'];
      final order = orderData['order'];
      final razorpayKey = orderData['key'];

      // Store order details for verification
      _currentOrderId = order['_id'];
      _currentOrderData = order;

      // Get user details from SharedPreferences or provider
      String userName = "Customer"; // Replace with actual user name
      String userEmail = "customer@example.com"; // Replace with actual email
      String userPhone = "9999999999"; // Replace with actual phone

      // Razorpay options
      var options = {
        'key': razorpayKey,
        'amount': razorpayOrder['amount'], // Amount in paise
        'currency': razorpayOrder['currency'],
        'name': 'Fulupo',
        'description': 'Order Payment',
        'order_id': razorpayOrder['id'],
        'prefill': {'contact': userPhone, 'email': userEmail, 'name': userName},
        'theme': {
          'color': '#F59E0B', // Your app's primary color
        },
        'retry': {'enabled': true, 'max_count': 3},
        'send_sms_hash': true,
        'remember_customer': false,
        'timeout': 300, // 5 minutes
      };

      log('Opening Razorpay with options: $options');
      _razorpay.open(options);
    } catch (e) {
      log('❌ Error initiating Razorpay: $e');
      setState(() {
        _isProcessingOrder = false;
      });
      AppDialogue.toast("Failed to initiate payment: ${e.toString()}");
    }
  }

  Future<void> _clearEntireCart(List<GetcartModel> cartItems) async {
    log('🧹 Starting to clear cart with ${cartItems.length} items');

    setState(() {
      _isProcessingOrder = true;
    });

    try {
      for (var item in cartItems) {
        log('Removing item: ${item.productName} (${item.productId})');

        final result = await getprovider.RemoveCart(
          storeId: item.storeId,
          productId: item.productId,
        );

        if (result.status) {
          log('✅ Successfully removed ${item.productName} from cart');
        } else {
          log(
            '❌ Failed to remove ${item.productName} from cart: ${result.data}',
          );
        }
      }

      log('🎉 Cart clearing completed');

      // Refresh cart UI
      setState(() {
        _cartFuture = getprovider.getCart();
      });
    } catch (e) {
      log('❌ Error clearing cart: $e');
      AppDialogue.toast("Error clearing cart");
    } finally {
      setState(() {
        _isProcessingOrder = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.fillColor,
      appBar: AppBar(
        title: const Text("Cart"),
        backgroundColor: AppColor.fillColor,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/bg.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            // Address Bar
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: GestureDetector(
                  onTap: () async {
                    final val = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const SavedAddressListBottomsheet(page: 'Home'),
                      ),
                    );
                    if (val == "Yes") {
                      _getLocation();
                    }
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

            // Cart Items and Bill Details
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

                  double itemsTotal = 0;
                  int totalItems = 0;
                  for (var item in cartItems) {
                    itemsTotal += (item.mrpPrice * item.quantity);
                    totalItems += item.quantity;
                  }

                  double deliveryCharge = 40.0;
                  double tax = itemsTotal * 0.05;
                  double grandTotal = itemsTotal + deliveryCharge + tax;

                  return SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        children: [
                          // Cart Items List
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
                                                          const EdgeInsets.all(
                                                            4,
                                                          ),
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
                                                      fontWeight:
                                                          FontWeight.bold,
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
                                                    style:
                                                        Styles.textStyleMedium(
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
                                                                    _updateCartQuantity(
                                                                      item,
                                                                      0,
                                                                      context,
                                                                    );
                                                                  }
                                                                },
                                                          child: Container(
                                                            width: 30,
                                                            height: 30,
                                                            alignment: Alignment
                                                                .center,
                                                            child: const Icon(
                                                              Icons.remove,
                                                              size: 16,
                                                              color: AppColor
                                                                  .whiteColor,
                                                            ),
                                                          ),
                                                        ),
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
                                                            alignment: Alignment
                                                                .center,
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
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
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
                                              textScaler:
                                                  const TextScaler.linear(1),
                                            ),
                                            Text(
                                              "₹${grandTotal.toStringAsFixed(2)}",
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: AppColor.whiteColor,
                                              ),
                                              textScaler:
                                                  const TextScaler.linear(1),
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

                          // Payment Method Selection
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
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
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
                                          fillColor:
                                              MaterialStateProperty.resolveWith<
                                                Color
                                              >((states) {
                                                if (states.contains(
                                                  MaterialState.selected,
                                                )) {
                                                  return AppColor
                                                      .yellowColor; // ✅ Selected color
                                                }
                                                return Colors
                                                    .white; // ✅ Unselected color
                                              }),
                                          activeColor: AppColor
                                              .yellowColor, // still good for selected ripple
                                          materialTapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                        ),
                                        Text(
                                          "Online Payment",
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight:
                                                _selectedPaymentMethod ==
                                                    'online'
                                                ? FontWeight.w600
                                                : FontWeight.normal,
                                            color: Colors.white,
                                          ),
                                          textScaler: TextScaler.linear(1),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(width: 20),
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
                                          fillColor:
                                              MaterialStateProperty.resolveWith<
                                                Color
                                              >((states) {
                                                if (states.contains(
                                                  MaterialState.selected,
                                                )) {
                                                  return AppColor.yellowColor;
                                                }
                                                return Colors.white;
                                              }),
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
                                            color: Colors.white,
                                          ),
                                          textScaler: TextScaler.linear(1),
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                                          ),textScaler: TextScaler.linear(1),
                                        ),
                                      ],
                                    )
                                  : const Text(
                                      "Proceed To Pay",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w900,
                                      ),textScaler: TextScaler.linear(1),
                                    ),
                            ),
                          ),
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
      ),
    );
  }

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
