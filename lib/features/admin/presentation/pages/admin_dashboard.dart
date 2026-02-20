import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:more_experts/features/auth/presentation/provider/auth_provider.dart';
import 'package:more_experts/features/admin/presentation/pages/admin_users_page.dart';
import 'package:more_experts/features/admin/presentation/pages/admin_chat_list_page.dart';
import 'package:more_experts/features/admin/presentation/pages/admin_notifications_page.dart';
import 'package:more_experts/features/admin/presentation/widgets/admin_spotlight_nav_bar.dart';
import 'package:more_experts/features/admin/presentation/widgets/glass_widgets.dart';

import 'package:more_experts/features/admin/data/admin_service.dart';
import 'package:more_experts/features/home/data/feedback_service.dart';
import 'package:more_experts/features/profile/domain/models/user_model.dart';
import 'package:more_experts/core/constants/service_package.dart';
import 'package:more_experts/core/services/notification_service.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _initNotifications();
  }

  void _initNotifications() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().currentUser;
      if (user != null) {
        NotificationService().startListening(user.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _AdminHomeTab(
          onNavigate: (index) => setState(() => _currentIndex = index)),
      const AdminUsersPage(),
      const AdminChatListPage(),
      const AdminNotificationsPage(),
      const _AdminSettingsTab(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Stack(
        children: [
          const LiquidGlassBackground(),
          pages[_currentIndex],
        ],
      ),
      bottomNavigationBar: AdminSpotlightNavBar(
        currentIndex: _currentIndex,
        hasUnread: false,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}

class _AdminHomeTab extends StatefulWidget {
  final Function(int) onNavigate;
  const _AdminHomeTab({required this.onNavigate});

  @override
  State<_AdminHomeTab> createState() => _AdminHomeTabState();
}

class _AdminHomeTabState extends State<_AdminHomeTab> {
  final AdminService _adminService = AdminService();
  final FeedbackService _feedbackService = FeedbackService();

  late Stream<List<UserModel>> _usersStream;
  late Future<List<Map<String, dynamic>>> _feedbackFuture;

  @override
  void initState() {
    super.initState();
    _usersStream = _adminService.getUsersStream();
    _feedbackFuture = _feedbackService.getFeedback();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Admin Dashboard',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: RefreshIndicator(
        color: Colors.blueAccent,
        backgroundColor: const Color(0xFF1E1E1E).withOpacity(0.8),
        onRefresh: () async {
          setState(() {
            _usersStream = _adminService.getUsersStream();
            _feedbackFuture = _feedbackService.getFeedback();
          });
          await Future.delayed(const Duration(seconds: 1));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Welcome, Admin',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              const SizedBox(height: 20),
              StreamBuilder<List<UserModel>>(
                  stream: _usersStream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                          child: CircularProgressIndicator(color: Colors.blue));
                    }

                    final users = snapshot.data ?? [];

                    final totalUsersCount = users.length;
                    final activeUsersCount =
                        users.where((u) => u.status == 'active').length;
                    final premiumUsersCount = users
                        .where((u) =>
                            u.package == ServicePackage.premium ||
                            u.package == ServicePackage.premium2)
                        .length;

                    final recentUsers = List<UserModel>.from(users)
                      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
                    final topRecentUsers = recentUsers.take(5).toList();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                context,
                                'Total Users',
                                totalUsersCount.toString(),
                                Colors.purpleAccent,
                                const _AdminSparklinePainter(
                                    color: Colors.purpleAccent),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildStatCard(
                                context,
                                'Active Users',
                                activeUsersCount.toString(),
                                Colors.blueAccent,
                                const _AdminSparklinePainter(
                                    color: Colors.blueAccent),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                context,
                                'Premium Users',
                                premiumUsersCount.toString(),
                                Colors.amberAccent,
                                const _AdminSparklinePainter(
                                    color: Colors.amberAccent),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Container(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        const Text('Recent Users',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                        const SizedBox(height: 16),
                        if (topRecentUsers.isEmpty)
                          Text('No recent users.',
                              style: TextStyle(color: Colors.grey.shade500)),
                        ...topRecentUsers.map((u) {
                          return GlassCard(
                            margin: const EdgeInsets.only(bottom: 12),
                            borderRadius: 16,
                            child: ListTile(
                              leading: GlassAvatar(
                                imagePath: u.profilePic,
                                name: u.name,
                                radius: 20,
                              ),
                              title: Text(u.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white)),
                              subtitle: Text(u.email,
                                  style:
                                      TextStyle(color: Colors.grey.shade400)),
                              trailing: Text(
                                  DateFormat('MMM dd').format(u.createdAt),
                                  style:
                                      TextStyle(color: Colors.grey.shade500)),
                            ),
                          );
                        }).toList(),
                      ],
                    );
                  }),
              const SizedBox(height: 32),
              const Text(
                'Quick Actions',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              const SizedBox(height: 16),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.1,
                children: [
                  _buildActionCard(context, 'Manage Users', Icons.people,
                      Colors.blueAccent, () => widget.onNavigate(1)),
                  _buildActionCard(context, 'View Chats', Icons.chat,
                      Colors.greenAccent, () => widget.onNavigate(2)),
                  _buildActionCard(
                      context,
                      'Send Alerts',
                      Icons.notifications_active,
                      Colors.orangeAccent,
                      () => widget.onNavigate(3)),
                  _buildActionCard(context, 'Settings', Icons.settings,
                      Colors.grey.shade400, () => widget.onNavigate(4)),
                ],
              ),
              const SizedBox(height: 32),
              const Text('Recent Feedback',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
              const SizedBox(height: 16),
              FutureBuilder<List<Map<String, dynamic>>>(
                  future: _feedbackFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                          child: CircularProgressIndicator(color: Colors.blue));
                    }

                    final feedbacks = snapshot.data ?? [];
                    if (feedbacks.isEmpty) {
                      return Text('No feedback found.',
                          style: TextStyle(color: Colors.grey.shade500));
                    }

                    return _RotatingFeedbackWidget(
                        feedbacks: feedbacks.take(5).toList());
                  }),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value,
      Color color, CustomPainter painter) {
    return GlassCard(
      height: 140,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white.withOpacity(0.7)),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
                fontSize: 28, fontWeight: FontWeight.bold, color: color),
          ),
          const Spacer(),
          SizedBox(
            height: 25,
            width: double.infinity,
            child: CustomPaint(
              painter: painter,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, String title, IconData icon,
      Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: GlassCard(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 36, color: color),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class _RotatingFeedbackWidget extends StatefulWidget {
  final List<Map<String, dynamic>> feedbacks;

  const _RotatingFeedbackWidget({required this.feedbacks});

  @override
  State<_RotatingFeedbackWidget> createState() =>
      _RotatingFeedbackWidgetState();
}

class _RotatingFeedbackWidgetState extends State<_RotatingFeedbackWidget> {
  late PageController _pageController;
  Timer? _timer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    if (widget.feedbacks.length > 1) {
      _timer = Timer.periodic(const Duration(seconds: 4), (Timer timer) {
        if (_currentPage < widget.feedbacks.length - 1) {
          _currentPage++;
        } else {
          _currentPage = 0;
        }

        if (_pageController.hasClients) {
          _pageController.animateToPage(
            _currentPage,
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 110,
      child: PageView.builder(
        controller: _pageController,
        itemCount: widget.feedbacks.length,
        onPageChanged: (int page) {
          setState(() {
            _currentPage = page;
          });
        },
        itemBuilder: (context, index) {
          final fb = widget.feedbacks[index];
          final rating = fb['rating'] ?? 0;
          return GlassCard(
            margin: const EdgeInsets.only(right: 8),
            borderRadius: 16,
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(rating.toString(),
                        style: const TextStyle(
                            color: Colors.amber,
                            fontWeight: FontWeight.bold,
                            fontSize: 14)),
                    const SizedBox(width: 4),
                    const Icon(Icons.star, size: 14, color: Colors.amber),
                  ],
                ),
              ),
              title: Text(fb['name'] ?? 'Anonymous',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white)),
              subtitle: Text(fb['feedbackText'] ?? '',
                  style: TextStyle(color: Colors.white.withOpacity(0.6)),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
            ),
          );
        },
      ),
    );
  }
}

class _AdminSettingsTab extends StatelessWidget {
  const _AdminSettingsTab();

  @override
  Widget build(BuildContext context) {
    final adminUser = context.watch<AuthProvider>().currentUser;
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Admin Settings',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Center(
              child: GlassAvatar(
                imagePath: adminUser?.profilePic,
                name: adminUser?.name ?? 'Admin',
                radius: 60,
                isAdmin: true,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              adminUser?.name ?? 'MoRe Admin',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              adminUser?.email ?? 'admin@moreexperts.com',
              style:
                  TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14),
            ),
            const SizedBox(height: 40),
            _buildSettingsTile(
              context,
              icon: Icons.info_outline,
              title: 'About App',
              onTap: () {
                showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                          backgroundColor: const Color(0xFF1E1E1E),
                          title: const Text('About MoRe Experts',
                              style: TextStyle(color: Colors.white)),
                          content: const Text(
                              'MoRe Experts v1.0.0\nPremium Service Platform.',
                              style: TextStyle(color: Colors.grey)),
                          actions: [
                            TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Close',
                                    style: TextStyle(color: Colors.blue))),
                          ],
                        ));
              },
            ),
            const SizedBox(height: 16),
            _buildSettingsTile(
              context,
              icon: Icons.logout,
              title: 'Logout',
              color: Colors.redAccent,
              onTap: () => context.read<AuthProvider>().logout(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTile(BuildContext context,
      {required IconData icon,
      required String title,
      required VoidCallback onTap,
      Color? color}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        borderRadius: 16,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: (color ?? Colors.blue).withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color ?? Colors.blue, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                    color: color ?? Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
            ),
            Icon(Icons.arrow_forward_ios,
                color: Colors.white.withOpacity(0.3), size: 16),
          ],
        ),
      ),
    );
  }
}

class _AdminSparklinePainter extends CustomPainter {
  final Color color;

  const _AdminSparklinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    path.moveTo(0, size.height * 0.8);
    path.quadraticBezierTo(size.width * 0.2, size.height * 0.9,
        size.width * 0.4, size.height * 0.5);
    path.quadraticBezierTo(size.width * 0.6, size.height * 0.7,
        size.width * 0.8, size.height * 0.2);
    path.lineTo(size.width, size.height * 0.3);

    final fillPath = Path.from(path);
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();

    final gradientPaint = Paint()
      ..shader = LinearGradient(
        colors: [color.withOpacity(0.2), color.withOpacity(0.0)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(fillPath, gradientPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
