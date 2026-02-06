import 'package:flutter/material.dart';
import 'package:more_experts/core/constants/app_colors.dart';
import 'package:more_experts/features/services/presentation/pages/package_list_page.dart';
import 'package:url_launcher/url_launcher.dart';

class ServicesMenuPage extends StatelessWidget {
  const ServicesMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text('Our Services'),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.black,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildServiceCard(
            context,
            'Resume Building',
            Icons.description_outlined,
            Colors.blue,
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PackageListPage()),
            ),
          ),
          const SizedBox(height: 16),
          _buildServiceCard(
            context,
            'Graphic Designing',
            Icons.brush,
            Colors.purple,
            () => _showServiceDetails(context, 'Graphic Designing'),
          ),
          const SizedBox(height: 16),
          _buildServiceCard(
            context,
            'Web Development',
            Icons.web,
            Colors.orange,
            () => _showServiceDetails(context, 'Web Development'),
          ),
          const SizedBox(height: 16),
          _buildServiceCard(
            context,
            'App Development',
            Icons.smartphone,
            Colors.green,
            () => _showServiceDetails(context, 'App Development'),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(BuildContext context, String title, IconData icon,
      Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  void _showServiceDetails(BuildContext context, String title) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _ServiceDetailPage(title: title),
      ),
    );
  }
}

class _ServiceDetailPage extends StatelessWidget {
  final String title;

  const _ServiceDetailPage({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title == 'Graphic Designing') ...[
              _buildPriceCard('Basic starts @ ₹350'),
              const SizedBox(height: 24),
              const Text(
                'Reminder:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _buildBulletPoint(
                  'Changes according to design and customer needs'),
              _buildBulletPoint('Printable format'),
              _buildBulletPoint('Digital sharable format'),
            ] else if (title == 'Web Development') ...[
              const Text(
                'We design and develop modern, responsive, and high-performance websites tailored to your business needs. Our websites are user-friendly, scalable, and optimized for all devices.',
                style: TextStyle(
                  fontSize: 16,
                  height: 1.6,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 24),
              _buildContactButtons(context),
            ] else if (title == 'App Development') ...[
              const Text(
                'We build custom mobile applications with clean UI, smooth performance, and secure architecture. Our apps are developed based on client requirements and business goals.',
                style: TextStyle(
                  fontSize: 16,
                  height: 1.6,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 24),
              _buildContactButtons(context),
            ],
            const SizedBox(height: 40),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceCard(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryBlue.withOpacity(0.2)),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryBlue,
        ),
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: Icon(Icons.circle, size: 8, color: Colors.black54),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                height: 1.4,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _launchWhatsApp,
            icon: const Icon(Icons.chat_bubble_outline),
            label: const Text('WhatsApp'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF25D366), // WhatsApp Green
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _launchEmail,
            icon: const Icon(Icons.email_outlined),
            label: const Text('Email'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _launchWhatsApp() async {
    // Number: 919633146330
    const phoneNumber = '919633146330';

    // Try the app scheme first
    final Uri appUrl = Uri.parse('whatsapp://send?phone=$phoneNumber');
    // Fallback to web link
    final Uri webUrl = Uri.parse('https://wa.me/$phoneNumber');

    try {
      if (await canLaunchUrl(appUrl)) {
        await launchUrl(appUrl);
      } else if (await canLaunchUrl(webUrl)) {
        await launchUrl(webUrl, mode: LaunchMode.externalApplication);
      } else {
        // Last resort: just try to launch the web url without checking
        // This is often needed on Android 11+ where canLaunchUrl returns false
        await launchUrl(webUrl, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Error launching WhatsApp: $e');
      // Even if it fails, try the web url one last time if it was an app launch error
      try {
        await launchUrl(webUrl, mode: LaunchMode.externalApplication);
      } catch (_) {}
    }
  }

  Future<void> _launchEmail() async {
    final Uri emailUrl = Uri(
      scheme: 'mailto',
      path: 'bondithedeveloper@gmail.com',
      query: 'subject=Inquiry regarding Development Services',
    );

    try {
      if (await canLaunchUrl(emailUrl)) {
        await launchUrl(emailUrl);
      } else {
        // Try launching anyway, some devices report false negatives
        await launchUrl(emailUrl);
      }
    } catch (e) {
      debugPrint('Error launching Email: $e');
    }
  }
}
