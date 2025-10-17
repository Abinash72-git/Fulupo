
import 'package:flutter/material.dart';
import 'package:fulupo/customs/styles.dart';
import 'package:fulupo/pages/subscription_pages/weekly_subscription/weekly_packages_pages.dart';
import 'package:fulupo/provider/get_provider.dart';
import 'package:fulupo/util/color_constant.dart';
import 'package:provider/provider.dart';

class WeeklySubscriptionPage extends StatefulWidget {
  const WeeklySubscriptionPage({super.key});

  @override
  State<WeeklySubscriptionPage> createState() => _WeeklySubscriptionPageState();
}

class _WeeklySubscriptionPageState extends State<WeeklySubscriptionPage> {
  GetProvider get getprovider => context.read<GetProvider>();
  bool isLoading = true;

  Future<void> _fetchWeeklySubscriptionData() async {
    setState(() {
      isLoading = true;
    });

    try {
      await getprovider.fetchWeeklySubscription();
    } catch (e) {
      print("Error fetching subscription data: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchWeeklySubscriptionData();
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColor.fillColor,
      appBar: AppBar(
        title: Text(
          "Weekly Subscription",
          style: Styles.textStyleMedium(context, color: AppColor.whiteColor),
        ),
        backgroundColor: AppColor.fillColor,
        leading: BackButton(
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: AppColor.yellowColor,
              ),
            )
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: ListView.builder(
                itemCount: getprovider.weeklySubscription.length,
                itemBuilder: (context, index) {
                  final weekly = getprovider.weeklySubscription[index];
                  return Column(
                    children: [
                      SizedBox(height: screenHeight * 0.03),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => WeeklyPackagesPages(
                                packageName: weekly.packageType!,
                                price: weekly.packagePrice.toString(),
                                weekId: weekly.weeklyId!,
                              ),
                            ),
                          );
                        },
                        child: subscriptionCard(
                          screenHeight: screenHeight,
                          screenWidth: screenWidth,
                          imagePath: weekly.image!,
                          packageName: weekly.packageType!,
                          price: weekly.packagePrice.toString(),
                        ),
                      ),
                      SizedBox(
                          height: screenHeight * 0.03), // Space between items
                    ],
                  );
                },
              ),
            ),
    );
  }

  Widget subscriptionCard({
    required double screenHeight,
    required double screenWidth,
    required String imagePath,
    required String packageName,
    required String price,
  }) {
    return Container(
      height: screenHeight * 0.22,
      width: screenWidth,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: DecorationImage(
          image: NetworkImage(imagePath),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: screenWidth,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      packageName,
                      style: Styles.textStyleLarge(context,
                          color: AppColor.yellowColor),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    "₹$price",
                    style: Styles.textStyleLarge(context,
                        color: AppColor.yellowColor),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
