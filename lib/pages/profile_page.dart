import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:fulupo/components/button.dart';
import 'package:fulupo/customs/styles.dart';
import 'package:fulupo/route_genarator.dart';
import 'package:fulupo/util/app_constant.dart';
import 'package:fulupo/util/color_constant.dart';
import 'package:fulupo/widget/dilogue/dilogue.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController addressController;
  late TextEditingController addressTypeController;
  late TextEditingController addressNameController;

  bool isLoading = false;
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    phoneController = TextEditingController();
    addressController = TextEditingController();
    addressTypeController = TextEditingController();
    addressNameController = TextEditingController();
    _loadLocalUserData();
  }

  Future<void> _loadLocalUserData() async {
    setState(() => isLoading = true);

    final prefs = await SharedPreferences.getInstance();

    // Load locally stored values
    nameController.text = prefs.getString(AppConstants.USERNAME) ?? '';
    phoneController.text = prefs.getString(AppConstants.USERMOBILE) ?? '';
    addressController.text = prefs.getString(AppConstants.USERADDRESS) ?? '';
    addressTypeController.text = prefs.getString(AppConstants.ADDRESS_TYPE) ?? 'Home';
    addressNameController.text = prefs.getString(AppConstants.ADDRESS_NAME) ?? '';

    log("Loaded local data: ${nameController.text}, ${phoneController.text}");
    log("Address type: ${addressTypeController.text}, Address name: ${addressNameController.text}");

    setState(() => isLoading = false);
  }

  Future<void> _saveLocalUserData() async {
    setState(() => isLoading = true);
    
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString(AppConstants.USERNAME, nameController.text);
      await prefs.setString(AppConstants.USERMOBILE, phoneController.text);
      await prefs.setString(AppConstants.USERADDRESS, addressController.text);
      await prefs.setString(AppConstants.ADDRESS_TYPE, addressTypeController.text);
      await prefs.setString(AppConstants.ADDRESS_NAME, addressNameController.text);

      AppDialogue.toast("Profile updated successfully!");
      log("✅ Local data saved successfully!");
      
      setState(() {
        isEditing = false;
        isLoading = false;
      });
    } catch (e) {
      log("Error saving data: $e");
      setState(() => isLoading = false);
      AppDialogue.toast("Failed to update profile");
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    addressTypeController.dispose();
    addressNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColor.fillColor,
        title: Text(
          'My Profile',
          style: Styles.textStyleMedium(context, color: AppColor.whiteColor),
        ),
        centerTitle: true,
        actions: [
          // Edit toggle button
          IconButton(
            icon: Icon(
              isEditing ? Icons.close : Icons.edit,
              color: AppColor.whiteColor,
            ),
            onPressed: () {
              setState(() {
                isEditing = !isEditing;
              });
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColor.fillColor))
          : Stack(
              children: [
                // Profile header curved background
                Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColor.fillColor,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                ),
                
                SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      
                      // Profile Avatar with edit badge
                      Center(
                        child: Stack(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 10,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: const CircleAvatar(
                                radius: 60,
                                backgroundImage: AssetImage("assets/images/MAN.png"),
                              ),
                            ),
                            if (isEditing)
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: AppColor.yellowColor,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // User details card
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Personal Details',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColor.fillColor,
                              ),
                            ),
                            const SizedBox(height: 15),
                            
                            // Name field
                            _buildProfileField(
                              label: 'Full Name',
                              controller: nameController,
                              icon: Icons.person,
                              isEditable: isEditing,
                            ),
                            const Divider(height: 30),
                            
                            // Phone field
                            _buildProfileField(
                              label: 'Phone Number',
                              controller: phoneController,
                              icon: Icons.phone,
                              keyboardType: TextInputType.phone,
                              isEditable: isEditing,
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Address card
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Address Details',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColor.fillColor,
                              ),
                            ),
                            const SizedBox(height: 15),
                            
                            // Address Type
                            _buildProfileField(
                              label: 'Address Type',
                              controller: addressTypeController,
                              icon: Icons.label,
                              isEditable: isEditing,
                              dropdownOptions: const ['Home', 'Work', 'Other'],
                            ),
                            const Divider(height: 30),
                            
                            // Address Name - Show only when address type is "Other"
                            if (isEditing || addressTypeController.text.toLowerCase() == 'other')
                              Column(
                                children: [
                                  _buildProfileField(
                                    label: addressTypeController.text.toLowerCase() == 'other' 
                                        ? 'Address Label' 
                                        : 'Address Name',
                                    controller: addressNameController,
                                    icon: Icons.house,
                                    isEditable: isEditing,
                                    hint: 'e.g., PG, Friend\'s House, etc.',
                                  ),
                                  const Divider(height: 30),
                                ],
                              ),
                            
                            // Full Address
                            _buildProfileField(
                              label: 'Full Address',
                              controller: addressController,
                              icon: Icons.location_on,
                              maxLines: 2,
                              isEditable: isEditing,
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 30),
                      
                      // Save button - only show when editing
                      if (isEditing)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: MyButton(
                            text: 'Save Profile',
                            textcolor: AppColor.blackColor,
                            textsize: 18,
                            fontWeight: FontWeight.bold,
                            letterspacing: 0.7,
                            buttoncolor: AppColor.yellowColor,
                            borderColor: AppColor.yellowColor,
                            buttonheight: 55,
                            buttonwidth: screenWidth,
                            radius: 12,
                            onTap: _saveLocalUserData,
                          ),
                        ),
                      
                      // Sign out button
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 20,
                        ),
                        child: MyButton(
                          text: 'Sign Out',
                          textcolor: AppColor.whiteColor,
                          textsize: 16,
                          fontWeight: FontWeight.bold,
                          letterspacing: 0.5,
                          buttoncolor: Colors.red.shade800,
                          borderColor: Colors.red.shade800,
                          buttonheight: 50,
                          buttonwidth: screenWidth * 0.5,
                          radius: 12,
                          onTap: () {
                            // Show confirmation dialog
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text("Sign Out"),
                                content: const Text("Are you sure you want to sign out?"),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text("Cancel"),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red.shade800,
                                    ),
                                    onPressed: () {
                                      // Handle sign out logic
                                      Navigator.pop(context);
                                      AppRouteName.apppage.pushAndRemoveUntil(
                                        args: 0,
                                        context,
                                        (route) => false,
                                      );
                                    },
                                    child: const Text("Sign Out"),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildProfileField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    bool isEditable = false,
    String? hint,
    List<String>? dropdownOptions,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColor.fillColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon, 
            color: AppColor.fillColor,
            size: 22,
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 5),
              if (isEditable && dropdownOptions != null)
                // Show dropdown for address type
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: dropdownOptions.contains(controller.text) 
                          ? controller.text 
                          : dropdownOptions[0],
                      items: dropdownOptions.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          controller.text = newValue!;
                          // Clear address name if not Other
                          if (controller.text != 'Other') {
                            addressNameController.clear();
                          }
                        });
                      },
                    ),
                  ),
                )
              else if (isEditable)
                // Regular text field
                TextField(
                  controller: controller,
                  maxLines: maxLines,
                  keyboardType: keyboardType,
                  style: const TextStyle(fontSize: 16),
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColor.fillColor),
                    ),
                    hintText: hint,
                    hintStyle: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 14,
                    ),
                  ),
                )
              else
                // Display text (not editing)
                Text(
                  controller.text.isEmpty ? 'No Address' : controller.text,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
