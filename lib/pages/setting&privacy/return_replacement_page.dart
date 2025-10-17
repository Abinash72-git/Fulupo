
import 'package:flutter/material.dart';
import 'package:fulupo/customs/styles.dart';
import 'package:fulupo/pages/setting&privacy/privacy_policy.dart';
import 'package:fulupo/util/color_constant.dart';

class ReturnReplacementPage extends StatefulWidget {
  const ReturnReplacementPage({super.key});

  @override
  State<ReturnReplacementPage> createState() => _ReturnReplacementPageState();
}

class _ReturnReplacementPageState extends State<ReturnReplacementPage> {
  @override
  Widget build(BuildContext context) {
    final sh = MediaQuery.of(context).size.height;
    final sw = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: AppColor.fillColor,
      appBar: AppBar(
        backgroundColor: AppColor.fillColor,
        title: Text(
          'Terms & Conditions',
          style: Styles.textStyleMedium(context, color: AppColor.whiteColor),
        ),
      ),
      body: SingleChildScrollView(
        padding:
            EdgeInsets.symmetric(horizontal: sw * 0.05, vertical: sh * 0.02),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PolicySection(
              title: 'Return and Replacement Policy of The Farms',
              content:
                  'Last Updated: December 21, 2024\n\nThank you for shopping at The Farms.\n\nIf, for any reason, you are not completely satisfied with a purchase We invite You to review our policy on return and replacement.\n\nThe following terms are applicable for any products that You purchased with Us.',
            ),
            const Text(
              '1.	Interpretation and Definitions',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textScaleFactor: 1,
            ),
            SizedBox(height: 10),
            _buildRichTextDefinition(
              'Interpretation',
              'The words of which the initial letter is capitalized have meanings defined under the following conditions. The following definitions shall have the same meaning regardless of whether they appear in singular or in plural.',
            ),
            SizedBox(height: 10),
            const Text(
              'Definitions',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textScaleFactor: 1,
            ),
            SizedBox(height: 10),
            const Text(
              'For the purposes of this Return and Replacement Policy:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textScaleFactor: 1,
            ),
            SizedBox(height: 10),
            _buildRichTextDefinition(
              'Application ',
              'means the software program provided by the Company downloaded by You on any electronic device, named The Farms',
            ),
            _buildRichTextDefinition(
              'Company ',
              '(referred to as either "the Company", "We", "Us" or "Our" in this Agreement) refers to The Farms',
            ),
            _buildRichTextDefinition(
              'Goods ',
              'refer to the items offered for sale on the Service.',
            ),
            _buildRichTextDefinition(
              'Orders  ',
              'mean a request by You to purchase Goods from Us.',
            ),
            _buildRichTextDefinition(
              'Service ',
              'refers to the Application.',
            ),
            _buildRichTextDefinition(
              'You ',
              'mean the individual accessing or using the Service, or the company, or other legal entity on behalf of which such individual is accessing or using the Service, as applicable.',
            ),
            const SizedBox(height: 20),
            const PolicySection(
              title: '2.	Your Order Cancellation/Return Rights',
              content:
                  'Once an order is placed, it cannot be canceled under any circumstances.\n\nPlease review your order details carefully before confirming your purchase.\n\nIn case of issues with your order (e.g., defects, incorrect items), please refer to our Return and Replacement Policy for assistance.\n\nYou are entitled to Return Your Order within 5 days without giving any reason for doing so.\n\nThe deadline for Returning an Order is 5 days from the date on which You received the Goods or on which a third party you have appointed, who is not the carrier, takes possession of the product delivered.\n\nIn order to exercise Your right of Return, you must inform Us of your decision by means of a clear statement. You can inform us of your decision by:\n\nBy email: thefarmsdev24@gmail.com\n\nBy phone number: +91 99407 21766\n\nWe will reimburse You no later than 14 days from the day on which We receive the returned Goods for replacement. We will use the same means of payment as You used for the Order, and You will not incur any fees for such reimbursement.',
            ),
            const PolicySection(
              title: '3.	Conditions for Replacement',
              content:
                  'In order for the Goods to be eligible for a replacement, please make sure that:\n\nThe Goods were purchased in the last 5 days\n\nThe Goods are in the original packaging\n\nThe following Goods cannot be replaced:\n\nThe supply of Goods made to Your specifications or clearly personalized.\n\nThe supply of Goods which according to their nature are not suitable to be returned, deteriorate rapidly or where the date of expiry is over.\n\nThe supply of Goods which are not suitable for return due to health protection or hygiene reasons and were unsealed after delivery.\n\nThe supply of Goods which are, after delivery, according to their nature, inseparably mixed with other items.\n\nWe reserve the right to refuse returns of any merchandise that does not meet the above return conditions in our sole discretion.\n\nOnly regular priced Goods may be replaced. Unfortunately, goods on sale cannot be replaced. This exclusion may not apply to You if it is not permitted by applicable law.',
            ),
            const PolicySection(
              title: '4.	Replacement of Goods',
              content:
                  'You are responsible for the cost and risk of replacement of the Goods to Us. You should send the Goods at the following address:\n\n3A, 4th cross, Wood creek county, Nandambakkam, Chennai 600089.\n\nWe cannot be held responsible for Goods damaged or lost in return shipment. Therefore, we recommend an insured and trackable mail service. We are unable to issue a replace without actual receipt of the Goods or proof of received delivery.',
            ),
            const PolicySection(
              title: '5.	Gifts',
              content:
                  "'If the Goods were marked as a gift when purchased and then shipped directly to you, you’ll receive a gift credit for the value of your replacement. Once the replacement product is received, a gift certificate will be mailed to You.\n\nIf the Goods weren't marked as a gift when purchased, or the gift giver had the Order shipped to themselves to give it to You later, the gift giver will be responsible for any replacement. In such cases, we shall not be liable to you any further.'",
            ),
            const PolicySection(
              title: '6.	Contact Us',
              content:
                  "'If you have any questions about our Returns and Replacement Policy, please contact us:\n\nBy email: thefarmsdev24@gmail.com\n\nBy phone number: +91 99407 21766'",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRichTextDefinition(String term, String definition) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '• $term: ',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
            TextSpan(
              text: definition,
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRichTextDefinition1(String term, String definition) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$term ',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
            TextSpan(
              text: definition,
              style: TextStyle(fontSize: 18, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListDefinition(List<String> items) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, top: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: items
            .map(
              (item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '• ',
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                    Expanded(
                      child: Text(
                        item,
                        style: const TextStyle(
                            fontSize: 16, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
