
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fulupo/customs/styles.dart';
import 'package:fulupo/util/color_constant.dart';
import 'package:fulupo/util/constant_image.dart';
import 'package:url_launcher/url_launcher.dart';

class PrivacyPolicy extends StatefulWidget {
  const PrivacyPolicy({super.key});

  @override
  State<PrivacyPolicy> createState() => _PrivacyPolicyState();
}

class _PrivacyPolicyState extends State<PrivacyPolicy> {
  @override
  Widget build(BuildContext context) {
    final sh = MediaQuery.of(context).size.height;
    final sw = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Privacy & Policy',
          style: Styles.textStyleMedium(context, color: AppColor.blackColor),
        ),
        backgroundColor: AppColor.whiteColor,
      ),
      body: Container(
        height: sh,
        width: sw,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(ConstantImageKey.pageBg),
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: sw * 0.05,
            vertical: sh * 0.02,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const PolicySection(
                title: 'Privacy Policy',
                content:
                    'Last updated: May 24, 2025\n\nThis Privacy Policy describes Our policies and procedures on the collection, use and disclosure of Your information when You use the Service and tells You about Your privacy rights and how the law protects You.\nWe use Your Personal data to provide and improve the Service. By using the Service, You agree to the collection and use of information in accordance with this Privacy Policy.',
              ),
              const SizedBox(height: 10),
              const Text(
                'Interpretation and Definitions',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textScaleFactor: 1,
              ),
              const PolicySection(
                title: 'Interpretation',
                content:
                    'The words of which the initial letter is capitalized have meanings defined under the following conditions. The following definitions shall have the same meaning regardless of whether they appear in singular or in plural.',
              ),
              const Text(
                'Definitions',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textScaleFactor: 1,
              ),
              const SizedBox(height: 7),
              const Text(
                'For the purposes of this Privacy Policy:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textScaleFactor: 1,
              ),
              _buildRichTextDefinition(
                'Account',
                'Means a unique account created for You to access our Service or parts of our Service.',
              ),
              _buildRichTextDefinition(
                'Affiliate',
                'Means an entity that controls, is controlled by or is under common control with a party, where "control" means ownership of 50% or more of the shares, equity interest or other securities entitled to vote for election of directors or other managing authority.',
              ),
              _buildRichTextDefinition(
                'Application',
                'Means refers to Fulupo, the software program provided by the Company.',
              ),
              _buildRichTextDefinition(
                'Company',
                '(referred to as either "the Company", "We", "Us" or "Our" in this Agreement) refers to Fulupo.\nCountry refers to: Tamil Nadu, India',
              ),
              _buildRichTextDefinition(
                'Device',
                'Means any device that can access the Service such as a computer, a cellphone or a digital tablet.',
              ),
              _buildRichTextDefinition(
                'Personal Data',
                'Is any information that relates to an identified or identifiable individual.',
              ),
              _buildRichTextDefinition('Service', 'Refers to the Application.'),
              _buildRichTextDefinition(
                'Service Provider ',
                'Means any natural or legal person who processes the data on behalf of the Company. It refers to third-party companies or individuals employed by the Company to facilitate the Service, to provide the Service on behalf of the Company, to perform services related to the Service or to assist the Company in analyzing how the Service is used.',
              ),
              _buildRichTextDefinition(
                'Usage Data',
                'Data refers to data collected automatically, either generated by the use of the Service or from the Service infrastructure itself (for example, the duration of a page visit).',
              ),
              _buildRichTextDefinition(
                'You',
                'Mean the individual accessing or using the Service, or the company, or other legal entity on behalf of which such individual is accessing or using the Service, as applicable.',
              ),
              const SizedBox(height: 10),
              const Text(
                'Collecting and Using Your Personal Data',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textScaleFactor: 1,
              ),
             
              const SizedBox(height: 10),
              const Text(
                'Types of Data Collected',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textScaleFactor: 1,
              ),
              const SizedBox(height: 4),
              const Text(
                'Personal Data',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textScaleFactor: 1,
              ),
              const SizedBox(height: 4),
              const Text(
                'While using Our Service, we may ask You to provide Us with certain personally identifiable information that can be used to contact or identify You. Personally identifiable information may include, but is not limited to:',
                style: TextStyle(fontSize: 16, color: Colors.black87),
                textScaleFactor: 1,
              ),
              _buildListDefinition([
                'First name and last name',
                'Phone number',
                'Address, State, Province, ZIP/Postal code, City',
                'Usage Data',
              ]),
              const SizedBox(height: 10),
              const Text(
                'Usage Data',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textScaleFactor: 1,
              ),
              const SizedBox(height: 4),
              const Text(
                "Usage Data is collected automatically when using the Service.\nUsage Data may include information such as Your Device's Internet Protocol address (e.g. IP address), browser type, browser version, the pages of our Service that You visit, the time and date of Your visit, the time spent on those pages, unique device identifiers and other diagnostic data.\n\nWhen You access the Service by or through a mobile device, We may collect certain information automatically, including, but not limited to, the type of mobile device You use, Your mobile device unique ID, the IP address of Your mobile device, Your mobile operating system, the type of mobile Internet browser You use, unique device identifiers and other diagnostic data.\n\nWe may also collect information that Your browser sends whenever You visit our Service or when You access the Service by or through a mobile device.",
                style: TextStyle(fontSize: 16, color: Colors.black87),
                textScaleFactor: 1,
              ),

              const SizedBox(height: 10),
              const Text(
                'Information Collected while Using the Application',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textScaleFactor: 1,
              ),
              const SizedBox(height: 4),
              const Text(
                "While using Our Application, in order to provide features of Our Application, We may collect, with Your prior permission:",
                style: TextStyle(fontSize: 16, color: Colors.black87),
                textScaleFactor: 1,
              ),
              const SizedBox(height: 4),
              _buildListDefinition([
                "Information regarding your location We use this information to provide features of Our Service, to improve and customize Our Service. The information may be uploaded to the Company's servers and/or a Service Provider's server or it may be simply stored on Your device.You can enable or disable access to this information at any time, through Your Device settings.",
              ]),

              const SizedBox(height: 10),

              const Text(
                'Use of Your Personal Data',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textScaleFactor: 1,
              ),
              const SizedBox(height: 4),
              const Text(
                'The Company may use Personal Data for the following purposes:',
                style: TextStyle(fontSize: 16, color: Colors.black87),
                textScaleFactor: 1,
              ),
              _buildRichTextDefinition(
                'To provide and maintain our Service',
                'including to monitor the usage of our Service.',
              ),
              _buildRichTextDefinition(
                'To manage Your Account ',
                'to manage Your registration as a user of the Service. The Personal Data You provide can give You access to different functionalities of the Service that are available to You as a registered user.',
              ),
              _buildRichTextDefinition(
                'For the performance of a contract',
                'the development, compliance and undertaking of the purchase contract for the products, items or services You have purchased or of any other contract with Us through the Service.',
              ),
              _buildRichTextDefinition(
                'To contact You ',
                "To contact You by email, telephone calls, SMS, or other equivalent forms of electronic communication, such as a mobile application's push notifications regarding updates or informative communications related to the functionalities, products or contracted services, including the security updates, when necessary or reasonable for their implementation.",
              ),
              _buildRichTextDefinition(
                'To provide You ',
                "with news, special offers and general information about other goods, services and events which we offer that are similar to those that you have already purchased or enquired about unless You have opted not to receive such information.",
              ),
              _buildRichTextDefinition(
                'To manage Your requests ',
                "To attend and manage Your requests to Us.",
              ),
              _buildRichTextDefinition(
                'For business transfers',
                "We may use Your information to evaluate or conduct a merger, divestiture, restructuring, reorganization, dissolution, or other sale or transfer of some or all of Our assets, whether as a going concern or as part of bankruptcy, liquidation, or similar proceeding, in which Personal Data held by Us about our Service users is among the assets transferred.",
              ),
              _buildRichTextDefinition(
                'For other purposes ',
                "We may use Your information for other purposes, such as data analysis, identifying usage trends, determining the effectiveness of our promotional campaigns and to evaluate and improve our Service, products, services, marketing and your experience.",
              ),

              const Text(
                'We may share Your personal information in the following situations:',
                style: TextStyle(fontSize: 16, color: Colors.black87),
                textScaleFactor: 1,
              ),
              _buildRichTextDefinition(
                'With Service Providers ',
                "We may share Your personal information with Service Providers to monitor and analyze the use of our Service, to contact You",
              ),
              _buildRichTextDefinition(
                'For business transfers ',
                "We may share or transfer Your personal information in connection with, or during negotiations of, any merger, sale of Company assets, financing, or acquisition of all or a portion of Our business to another company.",
              ),
              _buildRichTextDefinition(
                'With Affiliates ',
                "We may share Your information with Our affiliates, in which case we will require those affiliates to honor this Privacy Policy. Affiliates include Our parent company and any other subsidiaries, joint venture partners or other companies that We control or that are under common control with Us.",
              ),
              _buildRichTextDefinition(
                'With business partners ',
                "We may share Your information with Our business partners to offer You certain products, services or promotions.",
              ),
              _buildRichTextDefinition(
                'With other users ',
                "when You share personal information or otherwise interact in the public areas with other users, such information may be viewed by all users and may be publicly distributed outside.",
              ),
              _buildRichTextDefinition(
                'With Your consent ',
                "We may disclose Your personal information for any other purpose with Your consent.",
              ),

              const SizedBox(height: 20),
              const PolicySection(
                title: 'Retention of Your Personal Data',
                content:
                    "The Company will retain Your Personal Data only for as long as is necessary for the purposes set out in this Privacy Policy. We will retain and use Your Personal Data to the extent necessary to comply with our legal obligations (for example, if we are required to retain your data to comply with applicable laws), resolve disputes, and enforce our legal agreements and policies.\n\nThe Company will also retain Usage Data for internal analysis purposes. Usage Data is generally retained for a shorter period of time, except when this data is used to strengthen the security or to improve the functionality of Our Service, or We are legally obligated to retain this data for longer time periods.",
              ),
              const PolicySection(
                title: 'Transfer of Your Personal Data',
                content:
                    "Your information, including Personal Data, is processed at the Company's operating offices and in any other places where the parties involved in the processing are located. It means that this information may be transferred to — and maintained on — computers located outside of Your state, province, country or other governmental jurisdiction where the data protection laws may differ than those from Your jurisdiction.\n\nYour consent to this Privacy Policy followed by Your submission of such information represents Your agreement to that transfer.\n\nThe Company will take all steps reasonably necessary to ensure that Your data is treated securely and in accordance with this Privacy Policy and no transfer of Your Personal Data will take place to an organization or a country unless there are adequate controls in place including the security of Your data and other personal information.",
              ),
              const PolicySection(
                title: 'Delete Your Personal Data',
                content:
                    "You have the right to delete or request that We assist in deleting the Personal Data that We have collected about You.\n\nOur Service may give You the ability to delete certain information about You from within the Service.\n\nYou may update, amend, or delete Your information at any time by signing in to Your Account, if you have one, and visiting the account settings section that allows you to manage Your personal information. You may also contact Us to request access to, correct, or delete any personal information that You have provided to Us.\n\nPlease note, however, that We may need to retain certain information when we have a legal obligation or lawful basis to do so.",
              ),
              const SizedBox(height: 20),
              const Text(
                'Disclosure of Your Personal Data',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textScaleFactor: 1,
              ),
              const SizedBox(height: 10),
              _buildRichTextDefinition(
                'Business Transactions',
                'If the Company is involved in a merger, acquisition or asset sale, Your Personal Data may be transferred. We will provide notice before Your Personal Data is transferred and becomes subject to a different Privacy Policy.',
              ),
              const SizedBox(height: 10),
              _buildRichTextDefinition(
                'Law enforcement',
                'Under certain circumstances, the Company may be required to disclose Your Personal Data if required to do so by law or in response to valid requests by public authorities (e.g. a court or a government agency).',
              ),
              const SizedBox(height: 10),
              _buildRichTextDefinition(
                'Other legal requirements',
                'The Company may disclose Your Personal Data in the good faith belief that such action is necessary to:',
              ),
              _buildListDefinition([
                'Comply with a legal obligation',
                'Protect and defend the rights or property of the Company',
                'Prevent or investigate possible wrongdoing in connection with the Service',
                'Protect the personal safety of Users of the Service or the public',
                'Protect against legal liability',
              ]),
              // const SizedBox(height: 20),
              const PolicySection(
                title: 'Security of Your Personal Data',
                content:
                    "The security of Your Personal Data is important to Us, but remember that no method of transmission over the Internet, or method of electronic storage is 100% secure. While We strive to use commercially acceptable means to protect Your Personal Data, We cannot guarantee its absolute security.",
              ),
              const PolicySection(
                title: "Children's Privacy",
                content:
                    "Our Service does not address anyone under the age of 13. We do not knowingly collect personally identifiable information from anyone under the age of 13. If You are a parent or guardian and You are aware that Your child has provided Us with Personal Data, please contact Us. If We become aware that We have collected Personal Data from anyone under the age of 13 without verification of parental consent, We take steps to remove that information from Our servers.\n\nIf We need to rely on consent as a legal basis for processing Your information and Your country requires consent from a parent, We may require Your parent's consent before We collect and use that information.",
              ),
              const PolicySection(
                title: "Links to Other Websites",
                content:
                    "Our Service may contain links to other websites that are not operated by Us. If You click on a third-party link, you will be directed to that third party's site. We strongly advise You to review the Privacy Policy of every site You visit.\n\nWe have no control over and assume no responsibility for the content, privacy policies or practices of any third-party sites or services.",
              ),
              const PolicySection(
                title: "Changes to this Privacy Policy",
                content:
                    "We may update Our Privacy Policy from time to time. We will notify You of any changes by posting the new Privacy Policy on this page.\n\n We will let You know via email and/or a prominent notice on Our Service, prior to the change becoming effective and update the ${"'Last updated'"} date at the top of this Privacy Policy. You are advised to review this Privacy Policy periodically for any changes. Changes to this Privacy Policy are effective when they are posted on this page.",
              ),
              const Text(
                'Contact Us',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textScaler: TextScaler.linear(1),
              ),
              const SizedBox(height: 8),
              RichText(
                text: TextSpan(
                  style: const TextStyle(color: Colors.black87, fontSize: 16),
                  children: [
                    const TextSpan(
                      text:
                          "If you have any questions about this Privacy Policy, you can contact us:\n\n"
                          "• By email: tabsquareinfotech@gmail.com\n\n"
                          "• By visiting this page on our website: ",
                    ),
                    TextSpan(
                      text: "http://fulupo.com",
                      style: const TextStyle(
                        color: Colors.blue,
                        fontSize: 16,
                        decoration: TextDecoration.underline,
                      ),
                      recognizer:
                          TapGestureRecognizer()
                            ..onTap = () async {
                              final Uri url = Uri.parse("http://fulupo.com");
                              if (await canLaunchUrl(url)) {
                                await launchUrl(url);
                              } else {
                                throw 'Could not launch $url';
                              }
                            },
                    ),
                  ],
                ),
              ),
            ],
          ),
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
                color: Colors.black,
              ),
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
                color: Colors.black,
              ),
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
        children:
            items
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
                              fontSize: 16,
                              color: Colors.black87,
                            ),
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

class PolicySection extends StatelessWidget {
  final String title;
  final String content;

  const PolicySection({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Text(
            title,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            textScaleFactor: 1,
          ),
          SizedBox(height: 8),

          // Section Content
          Text(
            content,
            style: TextStyle(fontSize: 16, color: Colors.black87),
            textScaleFactor: 1,
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}
