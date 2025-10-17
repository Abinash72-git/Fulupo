import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fulupo/route_genarator.dart';
import 'package:fulupo/util/app_constant.dart';
import 'package:fulupo/util/color_constant.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Payment extends StatefulWidget {
  final double grandTotal;

  const Payment({super.key, required this.grandTotal});

  @override
  State<Payment> createState() => _PaymentState();
}

class _PaymentState extends State<Payment> {
  // Store values in SharedPreferences

  //first its no indicator show
  bool _isLoading = false;
// in this function say that only two second show the indicator
  void _handlePayment() async {
    setState(() {
      _isLoading = true; // Show loading spinner and overlay
    });

    await Future.delayed(Duration(seconds: 2)); // Simulate a 2-second delay

    // Hide the loading spinner and overlay
    // after go balck to false
    setState(() {
      _isLoading = false;
    });

    // Show the payment success dialog
    // already this fuction as been written just passing the data to that page
    DialogHelper.showSuccessDialog(
      context,
      title: "Payment Successful",
      message: "Your order has been booked successfully!",
      totalAmount: widget.grandTotal, // Pass the full total amount here
      onDone: () {
        Navigator.of(context).pop(); // Close the dialog
        AppRouteName.apppage.pushAndRemoveUntil(
          context,
          args: 1,
          (route) => false,
        );
      },
    );
  }

  int _selectedPaymentMethod = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text(
      //     'Payment Method',
      //     style: TextStyle(fontWeight: FontWeight.bold),
      //   ),
      //   leading: BackButton(),
      //   backgroundColor: Colors.transparent,
      //   foregroundColor: const Color.fromARGB(255, 0, 0, 0),
      //   elevation: 0,
      //   centerTitle: true,
      // ),
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                SizedBox(height: 20),
                _buildPaymentOption(
                  context,
                  1,
                  'Amazon Pay',
                  'assets/images/amazonpay.png',
                  imageWidth: 50,
                  imageHeight: 50,
                ),
                SizedBox(height: 16),
                _buildPaymentOption(
                  context,
                  2,
                  'Google Pay',
                  'assets/images/gpay.png',
                  imageWidth: 40,
                  imageHeight: 40,
                ),
                SizedBox(height: 16),
                _buildPaymentOption(
                  context,
                  3,
                  'Paytm',
                  'assets/images/paytm.png',
                  imageWidth: 45,
                  imageHeight: 45,
                ),
                SizedBox(height: 16),
                _buildPaymentOption(
                  context,
                  4,
                  'PhonePe',
                  'assets/images/phonepay.png',
                  imageWidth: 55,
                  imageHeight: 55,
                ),
                Spacer(),
                _buildPayButton(),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color:
                  Colors.black.withOpacity(0.5), // Semi-transparent background
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(
    BuildContext context,
    int value,
    String text,
    String imagePath, {
    required double imageWidth,
    required double imageHeight,
  }) {
    return Container(
      padding: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        children: [
          Radio<int>(
            value: value,
            groupValue: _selectedPaymentMethod,
            activeColor: Colors.blue,
            onChanged: (int? newValue) {
              setState(() {
                _selectedPaymentMethod = newValue!;
              });
            },
          ),
          SizedBox(width: 20),
          Text(
            text,
            style: TextStyle(
              fontSize: 18,
              color:
                  _selectedPaymentMethod == value ? Colors.black : Colors.grey,
              fontWeight: _selectedPaymentMethod == value
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
          ),
          Spacer(),
          Image.asset(
            imagePath,
            width: imageWidth,
            height: imageHeight,
          ),
        ],
      ),
    );
  }

  Widget _buildPayButton() {
    bool isSelected = _selectedPaymentMethod != 0;

    return GestureDetector(
      onTap: () {
        // if (isSelected) {
        _handlePayment(); // Trigger payment logic with loading spinner
        //  }
        // else {
        // // Show a message that no payment method is selected
        // DialogHelper.showInfoDialog(
        //   context,
        //   title: "No Payment Method Selected",
        //   message: "Please select a payment method before proceeding.",
        // );
        // }
      },
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: isSelected ? AppColor.fillColor : Colors.grey,
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Text(
          'Pay ${AppConstants.Rupees} ${widget.grandTotal.toStringAsFixed(2)}',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}

class DialogHelper {
  // Function to show a success dialog with a checkmark icon, paid amount, and transaction ID
  static Future<void> showSuccessDialog(
    //its show the location of the wedgeit where the information to show
    BuildContext context, {
    //payment success is a title
    required String title,
    //Your order has been booked successfully! is a message
    required String message,
    //total ammount is store in that
    required double totalAmount,
    // its a call back function
    required VoidCallback onDone,
    //done is a botton button color
    Color buttonColor = Colors.green, // Default button color
  }) async {
    // Generate a random transaction ID and format it for better readability
    String transactionId = _generateFormattedTransactionID();
    // Save the generated transaction ID in SharedPreferences
    await _saveTransactionId(transactionId);

    return showDialog<void>(
      context: context,
      barrierDismissible:
          false, // Prevent closing the dialog by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0), // Rounded corners
          ),
          contentPadding: EdgeInsets.all(20), // Add padding around content
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                Icons.check_circle_outline,
                color: Colors.green,
                size: 100.0, // Success icon size
              ),
              SizedBox(height: 20),
              Text(
                '${AppConstants.Rupees} ${totalAmount.toStringAsFixed(2)} Paid', // Show full paid amount
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                message, // "Payment Successful" message
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Transaction ID: $transactionId', // Formatted Transaction ID
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: onDone, // Go to Home when "Done" is clicked
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor, // Customizable button color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: Text(
                  'Done',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Helper function to generate a formatted random transaction ID
  //_generateFormattedTransactionID its function name this name only call in the top of the code
  static _generateFormattedTransactionID() {
    //its the char is varaible storing that date
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    // using  Random() its show any random variable
    Random random = Random();
    //its used to choose any 12 random variable and store in the rawId
    String rawId = String.fromCharCodes(Iterable.generate(
        12, (_) => chars.codeUnitAt(random.nextInt(chars.length))));

    // Format as groups of 4 characters (e.g., ABCD-EFGH-IJKL)
    //and contain total 14 character
    return rawId
        .replaceAllMapped(RegExp(r".{4}"), (match) => '${match.group(0)}-')
        .substring(0, 14);
  }

  // Helper function to save transaction ID in local storage (SharedPreferences)
  static Future<void> _saveTransactionId(String transactionId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'transactionId', transactionId); // Store the transaction ID
  }

  // Function to retrieve transaction ID from local storage
  static Future<String?> getTransactionId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('transactionId');
    // Retrieve the transaction ID
  }

  //to print the transaction id
  void _printTransactionId() async {
    String? transactionId = await DialogHelper.getTransactionId();

    if (transactionId != null) {
      print('Stored Transaction ID: $transactionId');
    } else {
      print('No Transaction ID found.');
    }
  }

  // static void showInfoDialog(BuildContext context,
  //     {required String title, required String message}) {}
}
