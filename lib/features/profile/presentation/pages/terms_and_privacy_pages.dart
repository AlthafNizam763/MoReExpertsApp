import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class TermsOfServicePage extends StatelessWidget {
  const TermsOfServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text(
          'Terms of Service',
          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.black),
        ),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: const Text(
          '''
1. Introduction
Welcome to MoRe Experts. By accessing or using our mobile application, you agree to be bound by these Terms of Service. If you do not agree to these terms, please do not use our app.

2. Services
MoRe Experts provides a platform to connect users with professional service providers for resume building, graphic design, web development, and app development.

3. User Accounts
To access certain features, you may need to register for an account. You agree to provide accurate, current, and complete information during the registration process.

4. Acceptable Use
You agree not to use the app for any unlawful purpose or in any way that interrupts, damages, or impairs the service.

5. Intellectual Property
All content included on this app, such as text, graphics, logos, images, and software, is the property of MoRe Experts or its content suppliers.

6. Limitation of Liability
MoRe Experts shall not be liable for any indirect, incidental, special, consequential, or punitive damages, or any loss of profits or revenues.

7. Changes to Terms
We reserve the right to modify these terms at any time. We will notify you of any changes by posting the new terms on this page.

8. Contact Us
If you have any questions about these Terms, please contact us.
          ''',
          style: TextStyle(
            fontSize: 16,
            height: 1.6,
            color: AppColors.black,
          ),
        ),
      ),
    );
  }
}

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text(
          'Privacy Policy',
          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.black),
        ),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: const Text(
          '''
1. Information We Collect
We collect information you provide directly to us, such as when you create an account, request a service, or contact customer support.

2. How We Use Your Information
We use the information we collect to provide, maintain, and improve our services, to process transactions, and to send you related information.

3. Sharing of Information
We may share your information with third-party vendors, consultants, and other service providers who need access to such information to carry out work on our behalf.

4. Data Security
We take reasonable measures to help protect information about you from loss, theft, misuse, and unauthorized access, disclosure, alteration, and destruction.

5. Your Choices
You may update, correct, or delete information about you at any time by logging into your online account or by contacting us.

6. Changes to this Policy
We may change this privacy policy from time to time. If we make changes, we will notify you by revising the date at the top of the policy.

7. Contact Us
If you have any questions about this Privacy Policy, please contact us.
          ''',
          style: TextStyle(
            fontSize: 16,
            height: 1.6,
            color: AppColors.black,
          ),
        ),
      ),
    );
  }
}
