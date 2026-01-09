import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class AboutAppPage extends StatelessWidget {
  const AboutAppPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text(
          'About App',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
        child: Column(
          children: [
            // App Logo
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.asset(
                'assets/images/logo2.png',
                height: 100,
                width: 100,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'MoRe Experts',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
            const Text(
              'Version 1.0.0',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.mediaGray,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'MoRe Experts is your premium platform for expert services and professional management. We connect you with top-tier professionals to ensure quality and reliability in every service.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.black,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 48),
            _buildListTile(
              label: 'Terms of Service',
              onTap: () {},
            ),
            _buildListTile(
              label: 'Privacy Policy',
              onTap: () {},
            ),
            _buildListTile(
              label: 'Licenses',
              onTap: () {},
            ),
            const SizedBox(height: 60),
            const Text(
              '© 2026 MoRe Experts. All rights reserved.',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.mediaGray,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListTile({required String label, required VoidCallback onTap}) {
    return ListTile(
      title: Text(
        label,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.black,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: AppColors.mediaGray),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }
}
