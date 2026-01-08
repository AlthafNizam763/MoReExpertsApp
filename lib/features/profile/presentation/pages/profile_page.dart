import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:more_experts/core/constants/app_colors.dart';
import 'package:more_experts/features/auth/presentation/provider/auth_provider.dart';
import 'package:more_experts/features/services/presentation/pages/package_list_page.dart';
import 'edit_profile_page.dart';
import 'change_password_page.dart';
import 'about_app_page.dart';
import 'faq_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Consumer<AuthProvider>(
              builder: (context, auth, _) {
                final user = auth.currentUser;
                if (user == null) return const SizedBox.shrink();

                return Column(
                  children: [
                    if (user.profilePic != null)
                      CircleAvatar(
                        radius: 40,
                        backgroundImage:
                            user.profilePic!.startsWith('data:image')
                                ? MemoryImage(Uri.parse(user.profilePic!)
                                    .data!
                                    .contentAsBytes()) as ImageProvider
                                : NetworkImage(user.profilePic!),
                      )
                    else
                      const CircleAvatar(
                        radius: 40,
                        backgroundColor: AppColors.lightGray,
                        child: Icon(Icons.person,
                            size: 40, color: AppColors.mediaGray),
                      ),
                    const SizedBox(height: 12),
                    Text(
                      user.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                      ),
                    ),
                    Text(
                      user.email,
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
              icon: Icons.card_membership_outlined,
              label: 'Available Packages',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const PackageListPage()),
                );
              },
            ),
            _ProfileMenuItem(
              icon: Icons.lock_outlined,
              label: 'Password',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ChangePasswordPage()),
                );
              },
            ),
            _ProfileMenuItem(
              icon: Icons.notifications_none_outlined,
              label: 'Notifications',
              onTap: () {},
              trailing: Switch.adaptive(
                value: true,
                onChanged: (value) {},
              ),
            ),
            _ProfileMenuItem(
              icon: Icons.question_answer_outlined,
              label: 'FAQ',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FaqPage()),
                );
              },
            ),
            _ProfileMenuItem(
              icon: Icons.info_outline,
              label: 'About App',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AboutAppPage()),
                );
              },
            ),
            const SizedBox(height: 12),
            _ProfileMenuItem(
              icon: Icons.logout,
              label: 'Logout',
              onTap: () => _showLogoutDialog(context),
              isLogout: true,
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to proceed with logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: AppColors.mediaGray),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<AuthProvider>().logout();
              },
              child: const Text(
                'Logout',
                style: TextStyle(
                    color: AppColors.error, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isLogout;
  final Widget? trailing;

  const _ProfileMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isLogout = false,
    this.trailing,
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
      trailing: trailing,
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
    );
  }
}
