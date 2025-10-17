
import 'package:flutter/material.dart';
import 'package:fulupo/customs/styles.dart';
import 'package:fulupo/pages/login_page.dart';
import 'package:fulupo/provider/user_provider.dart';
import 'package:fulupo/util/color_constant.dart';
import 'package:fulupo/util/constant_image.dart';
import 'package:fulupo/widget/dilogue/dilogue.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeleteAccountPage extends StatefulWidget {
  const DeleteAccountPage({super.key});

  @override
  State<DeleteAccountPage> createState() => _DeleteAccountPageState();
}

class _DeleteAccountPageState extends State<DeleteAccountPage> {
  final List<String> reasons = [
    "I don’t want to use this fulupo anymore",
    "I’m using a different account",
    "The app is not working properly",
    "Other",
  ];

  final TextEditingController _feedbackController = TextEditingController();
  String? selectedReason; // Store the selected reason
  String? actualSelectedReason;
  UserProvider get userProvider => context.read<UserProvider>();

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            if (selectedReason != null) {
              setState(() {
                selectedReason = null; // Go back to the reasons list
              });
            } else {
              Navigator.pop(context); // Navigate to the previous page
            }
          },
        ),
        actions: [
          if (selectedReason == "I don’t want to use this fulupo anymore")
            TextButton(
              onPressed: () {
                // Proceed to confirmation screen
                FocusScope.of(context).unfocus(); // dismiss keyboard if any
                setState(() {
                  // Optional: store feedback if needed
                  selectedReason =
                      "confirm"; // now it’ll show confirmation screen
                });
              },
              child: Text(
                "Next",
                style: Styles.textStyleMedium(
                  context,
                  color: AppColor.fillColor,
                ).copyWith(fontWeight: FontWeight.bold, fontSize: 19),
                textScaler: TextScaler.linear(1.0),
              ),
            ),
        ],
      ),
      body: Container(
        height: screenHeight,
        width: screenWidth,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(ConstantImageKey.pageBg),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
          child:
              selectedReason == null
                  ? _buildReasonsList()
                  : selectedReason == "confirm"
                  ? _buildConfirmationScreen()
                  : _buildReasonFlow(selectedReason!),
        ),
      ),
      floatingActionButton:
          selectedReason == "report_app_issue"
              ? Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: FloatingActionButton.extended(
                    backgroundColor: AppColor.fillColor,
                    onPressed: () {
                      AppDialogue.toast(
                        "Feedback submitted: ${_feedbackController.text}",
                      );
                      Navigator.pop(context);
                    },
                    label: const Text(
                      "Submit feedback",
                      textScaler: TextScaler.linear(1.0),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              )
              : null,
    );
  }

  /// **Step 1: Show List of Reasons**
  Widget _buildReasonsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Delete account",
          style: Styles.textStyleLarge(context, color: Colors.black),
          textScaler: TextScaler.linear(1.0),
        ),
        Text(
          "Why would you like to delete your account?",
          style: Styles.textStyleSmall(context, color: Colors.black),
          textScaler: TextScaler.linear(1.0),
        ),
        const SizedBox(height: 15),
        Expanded(
          child: ListView.separated(
            itemCount: reasons.length,
            separatorBuilder: (context, index) => _divider(),
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedReason = reasons[index];
                    actualSelectedReason = reasons[index];
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          reasons[index],
                          style: Styles.textStyleMedium(
                            context,
                            color: Colors.black,
                          ),
                          textScaler: TextScaler.linear(1.0),
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// **Step 2: Show Confirmation Screen**
  Widget _buildConfirmationScreen() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "You have requested the deletion of your account",
          style: Styles.textStyleLarge(context, color: Colors.black),
          textScaler: TextScaler.linear(1.0),
        ),
        const SizedBox(height: 10),
        Text(
          "Please note that the account will get deleted. By proceeding with this request, you understand and acknowledge that information associated with your account cannot be retrieved by you once it has been deleted. Please refer to our privacy policy for more information on data deletion.",
          style: Styles.textStyleSmall(context, color: Colors.black),
          textScaler: TextScaler.linear(1.0),
        ),
        const SizedBox(height: 30),
        Center(
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder:
                          (context) =>
                              Center(child: CircularProgressIndicator()),
                    );

                    await Future.delayed(Duration(seconds: 1));

                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    await prefs.clear();

                    Navigator.pop(context);

                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => Login()),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.fillColor,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    "Delete my account",
                    style: Styles.textStyleMedium(context, color: Colors.white),
                    textScaler: TextScaler.linear(1.0),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              GestureDetector(
                onTap: () {
                  setState(() {
                    selectedReason = null; // Go back to reasons list
                  });
                },
                child: Text(
                  "Back to Settings",
                  style: Styles.textStyleMedium(
                    context,
                    color: AppColor.fillColor,
                  ),
                  textScaler: TextScaler.linear(1.0),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReasonFlow(String reason) {
    // Special widget for selected reason (like in the image)
    if (reason == "I don’t want to use this fulupo anymore") {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Text(
            reason,
            style: Styles.textStyleLarge(context, color: Colors.black),
            textScaler: const TextScaler.linear(1.0),
          ),
          const SizedBox(height: 10),

          // Subtitle
          Text(
            "Do you have any feedback for us? We would love to hear from you! (Optional)",
            style: Styles.textStyleSmall(context, color: Colors.black54),
            textScaler: const TextScaler.linear(1.0),
          ),
          const SizedBox(height: 20),

          // Feedback TextField
          MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(1.0)),
            child: TextFormField(
              controller: _feedbackController,
              maxLines: 3,
              cursorColor: Colors.black54,
              decoration: InputDecoration(
                hintText: "Your feedback...",
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.all(12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.grey, width: .5),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.grey, width: .5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.grey, width: .5),
                ),
              ),
            ),
          ),
        ],
      );
    } else if (reason == "The app is not working properly") {
      return _buildAppIssueScreen(); // 👈 NEW one added here
    } else if (reason == "report_app_issue") {
      return _buildReportIssueScreen(); // 👈 Add this condition
    }

    // Default: go to confirmation screen
    return _buildConfirmationScreen();
  }

  Widget _buildAppIssueScreen() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Facing issues with the app?",
          style: Styles.textStyleLarge(context, color: Colors.black),
          textScaler: TextScaler.linear(1.0),
        ),
        const SizedBox(height: 8),
        Text(
          "Feel free to report any issues that you’re facing with the app. We’ll do our best to fix them!",
          style: Styles.textStyleSmall(context, color: Colors.black),
          textScaler: TextScaler.linear(1.0),
        ),
        const SizedBox(height: 20),

        // 👉 Report issues
        GestureDetector(
          onTap: () {
            setState(() {
              selectedReason =
                  "report_app_issue"; // Or navigate to a new screen
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Report issues with the app",
                  style: Styles.textStyleMedium(context, color: Colors.black),
                  textScaler: TextScaler.linear(1.0),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        ),

        _divider(),

        // 👉 Continue with deletion
        const SizedBox(height: 10),
        Text(
          "Would you rather delete your account?",
          style: Styles.textStyleSmall(
            context,
            color: Colors.black,
          ).copyWith(fontSize: 16),
          textScaler: TextScaler.linear(1.0),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () {
            setState(() {
              actualSelectedReason = selectedReason;
              selectedReason = "confirm";
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Continue with deletion",
                  style: Styles.textStyleMedium(context, color: Colors.black),
                  textScaler: TextScaler.linear(1.0),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        ),
        _divider(),
      ],
    );
  }

  Widget _buildReportIssueScreen() {
    final TextEditingController feedbackController = TextEditingController();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Text(
          "Send Feedback",
          style: Styles.textStyleLarge(context, color: Colors.black),
          textScaler: const TextScaler.linear(1.0),
        ),
        const SizedBox(height: 5),
        Text(
          "Tell us what you love about the app, or what we could be doing better.",
          style: Styles.textStyleSmall(context, color: Colors.grey[700]!),
          textScaler: const TextScaler.linear(1.0),
        ),
        const SizedBox(height: 30),

        Text(
          "Enter feedback",
          style: Styles.textStyleMedium(context, color: Colors.grey[800]!),
          textScaler: const TextScaler.linear(1.0),
        ),
        const SizedBox(height: 10),

        MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(1.0)),
          child: TextField(
            controller: feedbackController,
            maxLines: 3,
            cursorColor: Colors.black54,
            decoration: InputDecoration(
              hintText: "Type your feedback here...",
              hintStyle: Styles.textStyleSmall(
                context,
                color: Colors.grey[500]!,
              ),
              contentPadding: const EdgeInsets.all(16),
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.grey, width: .5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.grey, width: .5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.grey, width: .5),
              ),
            ),
          ),
        ),

        const SizedBox(height: 25),

        // Card for quick help
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(10),
                blurRadius: 6,
                spreadRadius: 1,
                offset: const Offset(3, 2),
              ),
            ],
          ),
          child: ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.yellow.shade100,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.star, color: Colors.orange, size: 24),
            ),
            title: Text(
              "Need help with your customer support team?",
              style: Styles.textStyleMedium(context),
              textScaler: const TextScaler.linear(1.0),
            ),
            onTap: () {
              // Implement help redirection logic
            },
          ),
        ),
      ],
    );
  }

  /// **Divider Styling**
  Widget _divider() {
    return const Divider(color: Colors.black26, thickness: 0.3, height: 5);
  }
}
