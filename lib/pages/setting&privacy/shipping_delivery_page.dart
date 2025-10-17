
import 'package:flutter/material.dart';
import 'package:fulupo/customs/styles.dart';
import 'package:fulupo/pages/setting&privacy/privacy_policy.dart';
import 'package:fulupo/util/color_constant.dart';

class ShippingDeliveryPage extends StatefulWidget {
  const ShippingDeliveryPage({super.key});

  @override
  State<ShippingDeliveryPage> createState() => _ShippingDeliveryPageState();
}

class _ShippingDeliveryPageState extends State<ShippingDeliveryPage> {
  @override
  Widget build(BuildContext context) {
    final sh = MediaQuery.of(context).size.height;
    final sw = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: AppColor.fillColor,
      appBar: AppBar(
        backgroundColor: AppColor.fillColor,
        title: Text(
          'Shipping & Delivery Policy',
          style: Styles.textStyleMedium(context, color: AppColor.whiteColor),
        ),
      ),
      body: SingleChildScrollView(
        padding:
            EdgeInsets.symmetric(horizontal: sw * 0.05, vertical: sh * 0.02),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PolicySection(
              title: 'THE FARMS SHIPPING POLICY',
              content:
                  'Last Updated: December 21, 2024\n\nThe Farms is committed to excellence, and the full satisfaction of our customers.\n\nThe Farms proudly offers shipping services. Be assured we are doing everything in our power to get your order to you as soon as possible. Please consider any holidays that might impact delivery times.',
            ),
            PolicySection(
              title: '1. SHIPPING',
              content:
                  'All orders for our products are processed and shipped out in 4-10 business days. Orders are not shipped or delivered on weekends or holidays. If we are experiencing a high volume of orders, shipments may be delayed by a few days. Please allow additional days in transit for delivery. If there will be a significant delay in the shipment of your order, we will contact you via email.',
            ),
            PolicySection(
              title: '2. WRONG ADDRESS DISCLAIMER',
              content:
                  'It is the responsibility of the customers to make sure that the shipping address entered is correct. We do our best to speed up processing and shipping time, so there is always a small window to correct an incorrect shipping address. Please contact us immediately if you believe you have provided an incorrect shipping address.',
            ),
            PolicySection(
              title: '3. UNDELIVERABLE ORDERS',
              content:
                  'Orders that are returned to us as undeliverable because of incorrect shipping information are subject to a restocking fee to be determined by us.',
            ),
            PolicySection(
              title: '4. LOST/STOLEN PACKAGES',
              content:
                  'The Farms is not responsible for lost or stolen packages. If your tracking information states that your package was delivered to your address and you have not received it, please report to the local authorities.',
            ),
            PolicySection(
              title: '5. RETURN REQUEST DAYS',
              content:
                  'The Farms allows you to return its item (s) within a period of 2 days. Kindly be advised that the item (s) should be returned unopened and unused.',
            ),
            PolicySection(
              title: '6. OUT OF STOCK ITEM PROCESS',
              content:
                  'In case of out-of-stock, The Farms Wait for all items to be in stock before dispatching',
            ),
            PolicySection(
              title: '7. IMPORT DUTY AND TAXES',
              content:
                  'When working with The Farms, you have the following options when it comes to taxes as well and import taxes: pre-paid and included in price of order',
            ),
            PolicySection(
              title: '8. ACCEPTANCE',
              content:
                  'By accessing our site and placing an order you have willingly accepted the terms of this Shipping Policy.',
            ),
            PolicySection(
              title: '9. CONTACT INFORMATION',
              content:
                  'In the event you have any questions or comments please reach us via the following contacts:\n\nEmail -   thefarmsdev24@gmail.com',
            ),
          ],
        ),
      ),
    );
  }
}
