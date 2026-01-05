import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/provider/auth_provider.dart';
import 'edit_profile_page.dart';
import 'notifications_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Header Section
            const CircleAvatar(
              radius: 40,
              backgroundImage: NetworkImage(
                'https://i.pravatar.cc', // Placeholder
              ),
            ),
            const SizedBox(height: 12),
            Consumer<AuthProvider>(
              builder: (context, auth, _) {
                final user = auth.currentUser;
                final email = user?.email ?? 'user@gmail.com';
                final userName = email.split('@')[0];

                return Column(
                  children: [
                    Text(
                      userName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                      ),
                    ),
                    Text(
                      email,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.mediaGray,
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 32),

            // Menu Items
            _ProfileMenuItem(
              icon: Icons.person_outline,
              label: 'My Profile',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const EditProfilePage()),
                );
              },
            ),
            _ProfileMenuItem(
              icon: Icons.settings_outlined,
              label: 'Settings',
              onTap: () {},
            ),
            _ProfileMenuItem(
              icon: Icons.notifications_none_outlined,
              label: 'Notifications',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const NotificationsPage()),
                );
              },
            ),
            _ProfileMenuItem(
              icon: Icons.assignment_outlined,
              label: 'Transaction History',
              onTap: () {},
            ),
            _ProfileMenuItem(
              icon: Icons.question_answer_outlined,
              label: 'FAQ',
              onTap: () {},
            ),
            _ProfileMenuItem(
              icon: Icons.info_outline,
              label: 'About App',
              onTap: () {},
            ),
            const SizedBox(height: 12),
            _ProfileMenuItem(
              icon: Icons.logout,
              label: 'Logout',
              onTap: () {
                context.read<AuthProvider>().logout();
              },
              isLogout: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isLogout;

  const _ProfileMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isLogout = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        child: Icon(
          icon,
          color: AppColors.black,
          size: 24,
        ),
      ),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.black,
        ),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
    );
  }
}
