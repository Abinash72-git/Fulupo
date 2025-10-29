// import 'dart:developer';


// import 'package:flutter/material.dart';

// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:fulupo/customs/styles.dart';
// import 'package:fulupo/provider/get_provider.dart';
// import 'package:fulupo/route_genarator.dart';
// import 'package:fulupo/util/color_constant.dart';
// import 'package:provider/provider.dart';

// class SubscriptionIntroPage extends StatefulWidget {
//   const SubscriptionIntroPage({super.key});

//   @override
//   State<SubscriptionIntroPage> createState() => _SubscriptionIntroPageState();
// }

// class _SubscriptionIntroPageState extends State<SubscriptionIntroPage> {
//   bool isLoading = true;

//   GetProvider get getprovider => context.read<GetProvider>();

//   @override
//   void initState() {
//     super.initState();
//     _fetchSubscriptionData();
//   }

//   Future<void> _fetchSubscriptionData() async {
//     setState(() {
//       isLoading = true;
//     });

//     try {
//       await getprovider.fetchSubscription();
//     } catch (e) {
//       print("Error fetching subscription data: $e");
//     } finally {
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final double screenHeight = MediaQuery.of(context).size.height;
//     final double screenWidth = MediaQuery.of(context).size.width;

//     return Scaffold(
//       backgroundColor: AppColor.fillColor,
//       appBar: AppBar(
//         automaticallyImplyLeading: false,
//         title: Center(
//           child: Text(
//             "Subscription",
//             style: Styles.textStyleMedium(context, color: AppColor.whiteColor),
//           ),
//         ),
//         backgroundColor: AppColor.fillColor,
//       ),
//       body:
//           isLoading
//               ? const Center(child: CircularProgressIndicator())
//               : SingleChildScrollView(
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 25),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children:
//                         getprovider.subscription.asMap().entries.toList().sublist(0, 2).map((
//                           entry,
//                         ) {
//                           final int index = entry.key;
//                           final item = entry.value;

//                           return Column(
//                             children: [
//                               _subscriptionItem(
//                                 screenHeight: screenHeight,
//                                 screenWidth: screenWidth,
//                                 topImage: item.mainImage!,
//                                 circleImage: item.subImage!,
//                                 label: item.subscriptionname!,
//                                 onTapTop: () async {
//                                   print(
//                                     "Tapped on top image: ${item.subscriptionname}, ${item.subscriptionId} ",
//                                   );
//                                   log(
//                                     "Tapped on top image: ${item.subscriptionname}, ${item.subscriptionId} ",
//                                   );
//                                   if (item.subscriptionname ==
//                                       'Weekly booking') {
//                                     AppRouteName.weeklypage.push(context);
//                                   } else if (item.subscriptionname ==
//                                       'Monthly booking') {
//                                     AppRouteName.montlyschedule.push(context);
//                                   } else if (item.subscriptionname ==
//                                       'Yearly booking') {
//                                     print(
//                                       "Tapped on top image: ${item.subscriptionname}, ${item.subscriptionId} ",
//                                     );

//                                     Fluttertoast.showToast(
//                                       msg:
//                                           "This feature is not available for this location",
//                                       toastLength: Toast.LENGTH_SHORT,
//                                       gravity: ToastGravity.BOTTOM,
//                                       backgroundColor: Colors.red,
//                                       textColor: Colors.white,
//                                       fontSize: 16.0,
//                                     );
//                                   }
//                                 },
//                                 onTapCircle: () async {
//                                   print(
//                                     "Tapped on top image: ${item.subscriptionname}, ${item.subscriptionId} ",
//                                   );
//                                   log(
//                                     "Tapped on top image: ${item.subscriptionname}, ${item.subscriptionId} ",
//                                   );
//                                   if (item.subscriptionname ==
//                                       'Weekly booking') {
//                                     AppRouteName.weeklypage.push(context);
//                                   } else if (item.subscriptionname ==
//                                       'Monthly booking') {
//                                     AppRouteName.montlyschedule.push(context);
//                                   } else if (item.subscriptionname ==
//                                       'Yearly booking') {}
//                                 },
//                               ),
//                               if (index == getprovider.subscription.length - 1)
//                                 SizedBox(height: screenHeight * 0.06),
//                             ],
//                           );
//                         }).toList(),
//                   ),
//                 ),
//               ),
//     );
//   }

//   /// Reusable Widget Function
//   Widget _subscriptionItem({
//     required double screenHeight,
//     required double screenWidth,
//     required String topImage,
//     required String circleImage,
//     required String label,
//     required VoidCallback onTapTop,
//     required VoidCallback onTapCircle,
//   }) {
//     return Column(
//       children: [
//         SizedBox(height: screenHeight * 0.07),
//         Stack(
//           clipBehavior: Clip.none,
//           children: [
//             GestureDetector(
//               onTap: onTapTop,
//               child: Container(
//                 height: screenHeight * 0.2,
//                 width: double.infinity,
//                 decoration: BoxDecoration(
//                   borderRadius: const BorderRadius.only(
//                     topLeft: Radius.circular(25),
//                     topRight: Radius.circular(25),
//                   ),
//                   image: DecorationImage(
//                     image: NetworkImage(topImage), // Load from API
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//               ),
//             ),
//             Positioned(
//               bottom: screenHeight * 0.1,
//               child: GestureDetector(
//                 onTap: onTapCircle,
//                 child: Container(
//                   height: screenHeight * 0.15,
//                   width: screenWidth * 0.9,
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     border: Border.all(color: AppColor.fillColor, width: 7),
//                     color: AppColor.whiteColor,
//                     image: DecorationImage(
//                       image: NetworkImage(circleImage), // Load from API
//                       fit: BoxFit.cover,
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//         GestureDetector(
//           onTap: onTapCircle,
//           child: Container(
//             padding: const EdgeInsets.symmetric(vertical: 15),
//             decoration: const BoxDecoration(
//               color: AppColor.whiteColor,
//               borderRadius: BorderRadius.only(
//                 bottomLeft: Radius.circular(25),
//                 bottomRight: Radius.circular(25),
//               ),
//             ),
//             alignment: Alignment.center,
//             child: Text(
//               label,
//               style: Styles.textStyleLarge(context, color: AppColor.fillColor),
//               textAlign: TextAlign.center,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:fulupo/util/app_constant.dart';
import 'package:fulupo/util/color_constant.dart';

class SubscriptionIntroPage extends StatefulWidget {
  const SubscriptionIntroPage({super.key});

  @override
  State<SubscriptionIntroPage> createState() => _SubscriptionIntroPageState();
}

class _SubscriptionIntroPageState extends State<SubscriptionIntroPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween(begin: 0.4, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     // backgroundColor: Colors.black,
      // appBar: AppBar(
      //   title: const Text("Subscription"),
      // backgroundColor: AppColor.fillColor,
      //   elevation: 0,
      // ),
      body: Container(  width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/bg.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _animation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [const Text(
                  "Subscription",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),       const SizedBox(height: 20),
                Icon(
                  Icons.hourglass_top_sharp,
                  color: Colors.amberAccent,
                  size: 80,
                ),
                const SizedBox(height: 20),
                const Text(
                  "Will be soon...",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

