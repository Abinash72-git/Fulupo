import 'package:flutter/material.dart';
import 'package:fulupo/customs/styles.dart';
import 'package:fulupo/model/replacement_history/getReplacement_model.dart';
import 'package:fulupo/provider/get_provider.dart';
import 'package:fulupo/util/app_constant.dart';
import 'package:fulupo/util/color_constant.dart';
import 'package:fulupo/widget/dilogue/dilogue.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer';
import 'dart:math' as Math;
import 'package:intl/intl.dart';

class ReplacementPage extends StatefulWidget {
  const ReplacementPage({super.key});

  @override
  State<ReplacementPage> createState() => _ReplacementPageState();
}

class _ReplacementPageState extends State<ReplacementPage> {
  GetProvider get gprovider => context.read<GetProvider>();
  bool isLoading = true;
  
  // Map to track expanded state of each replacement card
  final Map<String, bool> _expandedStates = {};

  @override
  void initState() {
    super.initState();
    _loadReplacements();
  }

  Future<void> _loadReplacements() async {
    setState(() {
      isLoading = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString(AppConstants.token);
      String? userId = prefs.getString(AppConstants.USER_ID);
      
      await gprovider.fetchReplacementList(
        token: token.toString(), 
        customerId: userId.toString()
      );
    } catch (e) {
      log('Error loading replacements: $e');
      AppDialogue.toast("Failed to load replacement requests");
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.fillColor,
      appBar: AppBar(
        title: const Text("My Replacements", textScaler: TextScaler.linear(1)),
        backgroundColor: AppColor.fillColor,
        foregroundColor: Colors.white,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/bg.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Consumer<GetProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading || isLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColor.yellowColor),
              );
            }

            if (provider.isApiValidationError) {
              return _buildErrorState();
            }

            // Check if we have any replacement responses
            if (provider.replacementList.isEmpty) {
              return _buildEmptyState();
            }

            // Check if we have any replacements in the first response
            final ReplacementResponse response = provider.replacementList[0];
            if (response.replacements.isEmpty) {
              return _buildEmptyState();
            }

            return _buildReplacementsList(response.replacements);
          }
        ),
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.swap_horiz,
            size: 80,
            color: AppColor.yellowColor,
          ),
          const SizedBox(height: 16),
          Text(
            "No Replacement Requests Yet!",
            style: Styles.textStyleMedium(context, color: AppColor.whiteColor),
          ),
          const SizedBox(height: 8),
          Text(
            "Your replacement requests will appear here",
            style: Styles.textStyleSmall(context, color: Colors.grey[400]!),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.yellowColor,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              "Go to Orders",
              textScaler: TextScaler.linear(1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: Colors.red[300],
          ),
          const SizedBox(height: 16),
          Text(
            "Failed to load replacements",
            style: Styles.textStyleMedium(context, color: AppColor.whiteColor),
          ),
          const SizedBox(height: 8),
          Text(
            "Please try again later",
            style: Styles.textStyleSmall(context, color: Colors.grey[400]!),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _loadReplacements,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.yellowColor,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              "Retry",
              textScaler: TextScaler.linear(1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReplacementsList(List<Replacement> replacements) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColor.fillColor.withOpacity(0.05),
            Colors.grey.withOpacity(0.1),
          ],
        ),
      ),
      child: RefreshIndicator(
        onRefresh: _loadReplacements,
        color: AppColor.yellowColor,
        child: ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: replacements.length,
          itemBuilder: (context, index) {
            final replacement = replacements[index];
            
            // Initialize expanded state for this replacement if not already set
            if (!_expandedStates.containsKey(replacement.id)) {
              _expandedStates[replacement.id] = false;
            }
            
            return Column(
              children: [
                _buildReplacementCard(replacement),
                if (index < replacements.length - 1)
                  Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 0,
                    ),
                    decoration: BoxDecoration(
                      color: AppColor.fillColor.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildReplacementCard(Replacement replacement) {
    final requestDate = replacement.createdAt.isNotEmpty
        ? DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.parse(replacement.createdAt))
        : 'Unknown date';

    Color getStatusColor() {
      final status = replacement.status.toLowerCase();
      switch (status) {
        case 'pending':
          return Colors.orange;
        case 'approved':
          return Colors.green;
        case 'rejected':
          return Colors.red;
        case 'completed':
          return Colors.amber;
        default:
          return Colors.grey;
      }
    }
    
    // Get current expanded state
    bool isExpanded = _expandedStates[replacement.id] ?? false;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Colors.white, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Request Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: AppColor.fillColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Order #${replacement.orderId.id.substring(Math.max(0, replacement.orderId.id.length - 8))}",
                      style: Styles.textStyleMedium(
                        context,
                        color: AppColor.yellowColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      requestDate,
                      style: Styles.textStyleSmall(
                        context,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: getStatusColor().withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: getStatusColor()),
                  ),
                  child: Text(
                    replacement.status,
                    style: TextStyle(
                      color: getStatusColor(),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    textScaler: const TextScaler.linear(1),
                  ),
                ),
              ],
            ),
          ),

          // Product Details
          Container(
            color: Colors.white,
           // padding: const EdgeInsets.all(10),
           padding: EdgeInsets.symmetric(horizontal: 10,vertical: 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Product Details",
                  style: Styles.textStyleMedium(
                    context,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 5),

                // Product Info
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Quantity Circle
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColor.fillColor.withOpacity(0.8),
                            AppColor.fillColor,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: AppColor.fillColor.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        "${replacement.quantity}x",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Product Name and Price
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            replacement.productId.name,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textScaler: const TextScaler.linear(1),
                          ),
                          Text(
                            "₹${(replacement.productId.mrpPrice).toStringAsFixed(2)}",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green[700],
                              fontSize: 14,
                            ),
                            textScaler: const TextScaler.linear(1),
                          ),
                        ],
                      ),
                    ),

                    // Product Image (if available)
                    if (replacement.productId.dimenstionImages.isNotEmpty)
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            replacement.productId.dimenstionImages[0].toString(),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => 
                              Container(
                                color: Colors.grey[200],
                                child: const Icon(Icons.image_not_supported, size: 24),
                              ),
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 10),

                // Reason Section
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Reason for Replacement",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            replacement.reason,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Images Section (if any)
                if (replacement.images.isNotEmpty) ...[
                  const SizedBox(height: 5),
                  InkWell(
                    onTap: () {
                      // Toggle expanded state
                      setState(() {
                        _expandedStates[replacement.id] = !isExpanded;
                      });
                    },
                    child: Row(
                      children: [
                        Icon(
                          Icons.image_outlined,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Uploaded Images",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColor.fillColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.all(4),
                          child: Icon(
                            isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                            size: 18,
                            color: AppColor.fillColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Expandable images section
                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: isExpanded
                        ? Column(
                            children: [
                              const SizedBox(height: 8),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey.shade200),
                                ),
                                padding: const EdgeInsets.all(8),
                                child: GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    crossAxisSpacing: 8,
                                    mainAxisSpacing: 8,
                                    childAspectRatio: 1,
                                  ),
                                  itemCount: replacement.images.length,
                                  itemBuilder: (context, imgIndex) {
                                    return GestureDetector(
                                      onTap: () => _showFullImage(replacement.images[imgIndex]),
                                      child: Hero(
                                        tag: replacement.images[imgIndex],
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(color: Colors.grey.shade300),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.05),
                                                blurRadius: 2,
                                                offset: const Offset(0, 1),
                                              ),
                                            ],
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(8),
                                            child: Image.network(
                                              replacement.images[imgIndex],
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) => 
                                                Container(
                                                  color: Colors.grey[200],
                                                  child: const Icon(Icons.broken_image),
                                                ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          )
                        : Container(
                            margin: const EdgeInsets.only(top: 8),
                            height: 24,
                            child: Text(
                              "${replacement.images.length} images attached",
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 12,
                              ),
                            ),
                          ),
                  ),
                ],

                const Divider(thickness: 1, height: 24),

                // Total amount
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Total Amount",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        fontSize: 15,
                      ),
                      textScaler: const TextScaler.linear(1),
                    ),
                    Text(
                      "₹${(replacement.productId.mrpPrice * replacement.quantity).toStringAsFixed(2)}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                        fontSize: 16,
                      ),
                      textScaler: const TextScaler.linear(1),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Action buttons
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      _showReplacementDetails(replacement);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColor.fillColor,
                      side: BorderSide(color: AppColor.fillColor),
                      padding: const EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 8,
                      ),
                      minimumSize: const Size(0, 32),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "View Details",
                      textScaler: TextScaler.linear(1),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: replacement.status.toLowerCase() != 'pending'
                        ? null
                        : () {
                            _showCancellationDialog(replacement);
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.yellowColor,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 8,
                      ),
                      minimumSize: const Size(0, 32),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      disabledBackgroundColor: Colors.grey.withOpacity(0.3),
                    ),
                    child: const Text(
                      "Cancel Request",
                      textScaler: TextScaler.linear(1),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showFullImage(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(16),
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              title: const Text('Image View'),
              backgroundColor: AppColor.fillColor,
              centerTitle: true,
              automaticallyImplyLeading: false,
              elevation: 0,
              actions: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            ),
            InteractiveViewer(
              panEnabled: true,
              minScale: 0.5,
              maxScale: 4,
              child: Hero(
                tag: imageUrl,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => 
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.broken_image, size: 48),
                            const SizedBox(height: 16),
                            Text(
                              'Failed to load image',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCancellationDialog(Replacement replacement) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Cancel Replacement Request',
          style: TextStyle(
            color: AppColor.fillColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'Are you sure you want to cancel this replacement request? This action cannot be undone.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey,
            ),
            child: const Text("NO"),
          ),
          ElevatedButton(
            onPressed: () {
              // Implement cancellation API call
              // Provider.of<GetProvider>(context, listen: false).cancelReplacementRequest(replacement.id);
              Navigator.pop(context);
              AppDialogue.toast("Replacement request cancelled");
              
              // Optionally refresh the list after cancellation
              _loadReplacements();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[600],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text("YES, CANCEL"),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: Colors.white,
        elevation: 4,
      ),
    );
  }

  void _showReplacementDetails(Replacement replacement) {
    final requestDate = replacement.createdAt.isNotEmpty
        ? DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.parse(replacement.createdAt))
        : 'Unknown date';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Replacement Details",
                    style: Styles.textStyleMedium(
                      context,
                      color: AppColor.fillColor,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const Divider(),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Request Info
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            _detailRow(
                              "Replacement ID",
                              "#${replacement.id.substring(Math.max(0, replacement.id.length - 8))}",
                            ),
                            _detailRow(
                              "Order ID",
                              "#${replacement.orderId.id.substring(Math.max(0, replacement.orderId.id.length - 8))}",
                            ),
                            _detailRow("Request Date", requestDate),
                            _detailRow("Status", replacement.status),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Product Details
                      Text(
                        "Product Details",
                        style: Styles.textStyleMedium(
                          context,
                          color: AppColor.fillColor,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Card(
                        elevation: 1,
                        margin: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColor.fillColor.withOpacity(0.8),
                                      AppColor.fillColor,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  "${replacement.quantity}x",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                  textScaler: const TextScaler.linear(1),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      replacement.productId.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14,
                                      ),
                                      textScaler: const TextScaler.linear(1),
                                    ),
                                    Text(
                                      "₹${replacement.productId.mrpPrice.toStringAsFixed(2)} x ${replacement.quantity}",
                                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                                      textScaler: const TextScaler.linear(1),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                "₹${(replacement.productId.mrpPrice * replacement.quantity).toStringAsFixed(2)}",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green[700],
                                ),
                                textScaler: const TextScaler.linear(1),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Reason Details
                      Text(
                        "Reason for Replacement",
                        style: Styles.textStyleMedium(
                          context,
                          color: AppColor.fillColor,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          replacement.reason,
                          style: const TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Images Section
                      if (replacement.images.isNotEmpty) ...[
                        Text(
                          "Uploaded Images",
                          style: Styles.textStyleMedium(
                            context,
                            color: AppColor.fillColor,
                          ),
                        ),
                        const SizedBox(height: 10),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                            childAspectRatio: 1,
                          ),
                          itemCount: replacement.images.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () => _showFullImage(replacement.images[index]),
                              child: Hero(
                                tag: "${replacement.id}_details_${replacement.images[index]}",
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.grey.shade300),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      replacement.images[index],
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => 
                                        Container(
                                          color: Colors.grey[200],
                                          child: const Icon(Icons.broken_image),
                                        ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Order Details Section
                      Text(
                        "Original Order Details",
                        style: Styles.textStyleMedium(
                          context,
                          color: AppColor.fillColor,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            _detailRow(
                              "Order Date", 
                              replacement.orderId.createdAt.isNotEmpty
                                  ? DateFormat('dd MMM yyyy').format(DateTime.parse(replacement.orderId.createdAt))
                                  : 'Unknown',
                            ),
                            _detailRow("Order Status", replacement.orderId.orderStatus),
                            _detailRow("Payment Method", replacement.orderId.paymentMode),
                            _detailRow("Payment Status", replacement.orderId.paymentStatus),
                            _detailRow(
                              "Total Order Amount", 
                              "₹${replacement.orderId.totalAmount.toStringAsFixed(2)}",
                              valueStyle: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        AppDialogue.toast("Support request submitted");
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.fillColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        "Contact Support",
                        textScaler: TextScaler.linear(1),
                      ),
                    ),
                  ),

                  if (replacement.status.toLowerCase() == 'pending') ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.cancel_outlined),
                        label: const Text(
                          "Cancel Request",
                          textScaler: TextScaler.linear(1),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          _showCancellationDialog(replacement);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _detailRow(
    String title,
    String value, {
    TextStyle? titleStyle,
    TextStyle? valueStyle,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style:
                titleStyle ?? TextStyle(fontSize: 14, color: Colors.grey[700]),
            textScaler: const TextScaler.linear(1),
          ),
          Text(
            value,
            style:
                valueStyle ??
                const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
            textScaler: const TextScaler.linear(1),
          ),
        ],
      ),
    );
  }
}
