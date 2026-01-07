import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class FaqPage extends StatelessWidget {
  const FaqPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text(
          'FAQ',
          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.black),
        ),
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildFaqItem(
            'How do I book a service?',
            'You can book a service by navigating to the "Services" tab, selecting a package that fits your needs, and following the checkout process.',
          ),
          _buildFaqItem(
            'How can I contact support?',
            'Our support team is available 24/7. You can reach us through the "Chat" section in the app or by emailing support@moreexperts.com.',
          ),
          _buildFaqItem(
            'What are the available packages?',
            'We offer various packages ranging from Basic to Premium. You can view all details in the "Available Packages" section of your profile.',
          ),
          _buildFaqItem(
            'How do I update my profile?',
            'Go to your Profile tab, click on "My Profile", and you will be able to edit your personal and professional details.',
          ),
          _buildFaqItem(
            'Can I cancel a booking?',
            'Yes, bookings can be cancelled up to 24 hours before the scheduled time. Please refer to our cancellation policy for more details.',
          ),
        ],
      ),
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.black,
          ),
        ),
        childrenPadding: const EdgeInsets.all(16),
        iconColor: AppColors.black,
        collapsedIconColor: AppColors.mediaGray,
        shape: const RoundedRectangleBorder(side: BorderSide.none),
        children: [
          Text(
            answer,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.darkGray,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
