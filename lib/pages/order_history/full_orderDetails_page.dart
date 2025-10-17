
import 'package:flutter/material.dart';
import 'package:fulupo/customs/styles.dart';
import 'package:fulupo/model/order_history/getOrder_history.dart';
import 'package:fulupo/provider/get_provider.dart';
import 'package:fulupo/util/color_constant.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class FullOrderDetailsPage extends StatefulWidget {
  final String orderId;

  const FullOrderDetailsPage({super.key, required this.orderId});

  @override
  State<FullOrderDetailsPage> createState() => _FullOrderDetailsPageState();
}

class _FullOrderDetailsPageState extends State<FullOrderDetailsPage> {
  GetProvider get getprovider => context.read<GetProvider>();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _getData();
  }

  Future<void> _getData() async {
    await getprovider.fetchOrderHistory(context.read<GetProvider>().token);
    setState(() {});
  }

  String _formatTime(String? time) {
    if (time == null || time.isEmpty) return '';

    try {
      final parsedTime = DateFormat("HH:mm:ss").parse(time);
      return DateFormat("hh:mm a").format(parsedTime);
    } catch (e) {
      return time;
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    List<GetOrderHistory> orders = getprovider.orderHistory
        .where((order) => order.orderId == widget.orderId)
        .toList();

    if (orders.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text("Order Details")),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    GetOrderHistory firstProduct = orders.first;

    return Scaffold(
      backgroundColor: AppColor.fillColor,
      appBar: AppBar(
        title: Text(
          'Order Details',
          style: Styles.textStyleMedium(context, color: AppColor.whiteColor),
        ),
        backgroundColor: AppColor.fillColor,
      ),
      body: SingleChildScrollView(
        // Wrap entire body in a SingleChildScrollView
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Order Placed",
                style: Styles.textStyleMedium(context,
                    color: AppColor.yellowColor)),
            Text("${firstProduct.orderAddress}",
                style:
                    Styles.textStyleSmall(context, color: AppColor.whiteColor)),
            SizedBox(
              height: 20,
            ),
            Text("Order Placed",
                style: Styles.textStyleMedium(context,
                    color: AppColor.yellowColor)),
            Text(
              "${DateFormat('dd MMM yy').format(firstProduct.bookingDate!.toLocal())} (${firstProduct.slotSchedule} ${_formatTime(firstProduct.startTime)} - ${_formatTime(firstProduct.endTime)})",
              style: Styles.textStyleSmall(context, color: AppColor.whiteColor),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 8), // Spacer between the icon and text
                Text(
                  "Your Selected Items are Delivered!",
                  style: Styles.textStyleMedium(
                    context,
                    color:
                        AppColor.yellowColor, // Text color as per your design
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              primary: false,
              itemCount: orders.length,
              itemBuilder: (context, index) {
                var order = orders[index];
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          order.image ?? '',
                          height: 70,
                          width: 70,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.image_not_supported, size: 50),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              order.productName!,
                              style: Styles.textStyleMedium(
                                context,
                                color: AppColor.fillColor,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                            Text(
                              order.productSubname!,
                              style: Styles.textStyleSmall(
                                context,
                                color: AppColor.hintTextColor,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text(
                                  "${order.productQuantity}",
                                  style: Styles.textStyleSmall(context,
                                      color: AppColor.hintTextColor),
                                ),
                                SizedBox(width: 16),
                                Text(
                                  "Qty -${order.count}",
                                  style: Styles.textStyleSmall(context,
                                      color: AppColor.hintTextColor),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Text(
                        "₹ ${order.currentPrice?.toStringAsFixed(2)}",
                        style: Styles.textStyleMedium(context,
                            color: Colors.green),
                      ),
                    ],
                  ),
                );
              },
            ),
            SizedBox(
              height: screenHeight * 0.05,
            ),
            Container(
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var item in [
                    {
                      'label': 'Old Price:',
                      'value':
                          firstProduct.oldPrice?.toStringAsFixed(2) ?? '0.00',
                    },
                    {
                      'label': 'Savings:',
                      'value':
                          firstProduct.savings?.toStringAsFixed(2) ?? '0.00'
                    },
                    {
                      'label': 'GST Amount:',
                      'value': firstProduct.gst?.toStringAsFixed(2) ?? '0.00'
                    },
                    {
                      'label': 'Delivery Fees',
                      'value': firstProduct.deliveryFees?.toStringAsFixed(2) ??
                          '0.00',
                      'strikethrough': true
                    },
                  ])
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            item['label'] as String,
                            style: Styles.textStyleMedium(context,
                                color: AppColor.fillColor),
                            textScaleFactor: 1.0,
                          ),
                          Text(
                            '₹${item['value']}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColor.hintTextColor,
                              decoration: item['strikethrough'] == true
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                            textScaleFactor: 1.0,
                          ),
                        ],
                      ),
                    ),
                  SizedBox(height: 10),
                  Divider(),
                  SizedBox(height: 10),
                  // Total Pay Row
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                    decoration: BoxDecoration(
                      color: AppColor.fillColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Pay',
                          style: Styles.textStyleMedium(context,
                              color: AppColor.whiteColor),
                          textScaleFactor: 1.0,
                        ),
                        Text(
                          '₹${firstProduct.totalPay?.toStringAsFixed(2) ?? '0.00'}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColor.whiteColor,
                          ),
                          textScaleFactor: 1.0,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: screenHeight * 0.05),
          
          ],
        ),
      ),
    );
  }
}
