import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:more_experts/core/constants/app_colors.dart';
import 'package:more_experts/core/constants/service_package.dart';
import 'package:more_experts/features/auth/presentation/provider/auth_provider.dart';
import 'package:more_experts/features/services/presentation/pages/services_page.dart';
import 'package:more_experts/features/profile/presentation/pages/profile_page.dart';
import 'package:more_experts/features/chat/presentation/pages/chat_page.dart';
import 'package:more_experts/features/chat/presentation/providers/chat_provider.dart';
import 'package:more_experts/features/profile/domain/models/user_model.dart';
import 'package:more_experts/core/widgets/spotlight_nav_bar.dart';
import 'package:more_experts/features/profile/presentation/pages/notifications_page.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:more_experts/features/home/presentation/pages/feedback_page.dart';
import 'package:more_experts/features/home/data/feedback_service.dart';
import 'package:more_experts/core/widgets/app_loader.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const DashboardTab(),
    const ServiceListPage(),
    const ChatPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;

    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: user?.id != null
          ? StreamBuilder<bool>(
              stream: context
                  .read<ChatProvider>()
                  .hasUnreadMessagesStream(user!.id),
              initialData: false,
              builder: (context, snapshot) {
                return SpotlightNavBar(
                  currentIndex: _currentIndex,
                  hasUnread: snapshot.data ?? false,
                  onTap: (index) => setState(() => _currentIndex = index),
                );
              },
            )
          : SpotlightNavBar(
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
            ),
    );
  }
}

class DashboardTab extends StatelessWidget {
  static const IconData notifications =
      IconData(0xe44f, fontFamily: 'MaterialIcons');

  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    if (user == null) return const AppLoader();

    final userName = user.name.toUpperCase();
    final creationDate = DateFormat('dd/MM/yyyy').format(user.createdAt);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.star_border),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FeedbackPage(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(notifications),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationsPage(),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await context.read<AuthProvider>().refreshUserData();
        },
        color: AppColors.primaryBlue,
        backgroundColor: Colors.white,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
              const Text(
                'Welcome Back',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              // Analytics Cards
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      context,
                      'Resume Completed',
                      '2745',
                      Colors.purple,
                      const SparklinePainter(color: Colors.purple),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      context,
                      'Placed Candidates',
                      '86%',
                      Colors.blue,
                      const RadialPercentPainter(
                          percent: 0.86, color: Colors.blue),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Active Service Card (Multi-Package Support)
              _buildAtmCard(context, user, userName, creationDate),

              const SizedBox(height: 20),

              // Feedback Section
              _buildFeedbackSection(),

              // Documents Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Your Documents',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),

              const SizedBox(height: 10),
              // Dynamic Document List
              _buildFilteredDocuments(context, user),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilteredDocuments(BuildContext context, UserModel user) {
    List<Widget> documents = [];
    final package = user.package;

    // Service Guide
    if (package == ServicePackage.premium ||
        package == ServicePackage.premium2) {
      // 1. Resume - Colour
      if (user.documents.serviceGuide != null) {
        documents.add(
          _buildDocumentCard(
            context,
            'Resume (Colour)',
            'PDF',
            Icons.picture_as_pdf,
            Colors.red.shade100,
            Colors.red,
            user.documents.serviceGuide,
          ),
        );
      }

      // 2. Resume - B&W
      if (user.documents.serviceGuide2 != null) {
        documents.add(
          _buildDocumentCard(
            context,
            'Resume (Black & White)',
            'PDF',
            Icons.picture_as_pdf,
            Colors.grey.shade300,
            Colors.black,
            user.documents.serviceGuide2,
          ),
        );
      }
      // 3. Resume - Horizontal
      if (user.documents.serviceGuide3 != null) {
        documents.add(
          _buildDocumentCard(
            context,
            'Resume (Horizontal)',
            'PDF',
            Icons.picture_as_pdf,
            Colors.blue.shade100,
            Colors.blue,
            user.documents.serviceGuide3,
          ),
        );
      }
    } else {
      // Standard Guide for other packages
      if (user.documents.serviceGuide != null) {
        documents.add(
          _buildDocumentCard(
            context,
            'Guide',
            'PDF',
            Icons.picture_as_pdf,
            Colors.red.shade100,
            Colors.red,
            user.documents.serviceGuide,
          ),
        );
      }
    }

    // Contract (Silver2 and above)
    if (package != ServicePackage.silver && user.documents.contract != null) {
      documents.add(
        _buildDocumentCard(
          context,
          'Contract',
          'DOCX',
          Icons.description,
          Colors.blue.shade100,
          Colors.blue,
          user.documents.contract,
        ),
      );
    }

    // Cover Letter (Golden and above)
    if (package != ServicePackage.silver &&
        package != ServicePackage.silver2 &&
        user.documents.coverLetter != null) {
      documents.add(
        _buildDocumentCard(
          context,
          'Cover Letter',
          'PDF',
          Icons.badge_outlined,
          Colors.orange.shade100,
          Colors.orange,
          user.documents.coverLetter,
        ),
      );
    }

    if (documents.isEmpty) {
      return const SizedBox.shrink();
    }

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.1,
      children: documents,
    );
  }

  Widget _buildAtmCard(
      BuildContext context, UserModel user, String userName, String date) {
    final package = user.package;
    String serviceName;
    List<Color> gradientColors;
    Color progressBarColor;
    Color textColor;
    Color accentColor;

    switch (package) {
      case ServicePackage.silver:
        serviceName = 'Silver';
        gradientColors = [const Color(0xFFC0C0C0), const Color(0xFF8E8E8E)];
        progressBarColor = const Color(0xFFE0E0E0);
        textColor = Colors.white;
        accentColor = Colors.white70;
        break;
      case ServicePackage.silver2:
        serviceName = 'Silver';
        gradientColors = [const Color(0xFF757575), const Color(0xFF424242)];
        progressBarColor = const Color(0xFFBDBDBD);
        textColor = Colors.white;
        accentColor = Colors.white70;
        break;
      case ServicePackage.golden:
        serviceName = 'Golden';
        gradientColors = [const Color(0xFF1A1A1A), const Color(0xFF0D0D0D)];
        progressBarColor = const Color(0xFFF5A623);
        textColor = Colors.white;
        accentColor = const Color(0xFFF5A623);
        break;
      case ServicePackage.golden2:
        serviceName = 'Golden';
        gradientColors = [const Color(0xFFF5A623), const Color(0xFFD48806)];
        progressBarColor = Colors.black87;
        textColor = Colors.black87;
        accentColor = Colors.black54;
        break;
      case ServicePackage.premium:
        serviceName = 'Premium';
        gradientColors = [const Color(0xFF0F0F0B), const Color(0xFF1C1C1C)];
        progressBarColor = const Color(0xFFD4AF37);
        textColor = Colors.white;
        accentColor = const Color(0xFFD4AF37);
        break;
      case ServicePackage.premium2:
        serviceName = 'Premium';
        gradientColors = [const Color(0xFF2C0A3B), const Color(0xFF0F0F0F)];
        progressBarColor = const Color(0xFFE1BEE7);
        textColor = Colors.white;
        accentColor = const Color(0xFFE1BEE7);
        break;
    }

    final card = Container(
      width: double.infinity,
      height: 220,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Background abstract shapes
            Positioned.fill(
              child: CustomPaint(
                painter: CardBackgroundPainter(
                  primaryColor: progressBarColor.withOpacity(0.15),
                  secondaryColor: Colors.white.withOpacity(0.05),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        serviceName,
                        style: TextStyle(
                          color: accentColor,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // High-fidelity ME Logo (Tiered)
                      SizedBox(
                        width: 50,
                        height: 50,
                        child: CustomPaint(
                          painter: MeLogoPainter(
                              color: Colors.white, package: package),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Progress Bar (Hidden for Premium 2nd)
                  if (package != ServicePackage.premium2)
                    Stack(
                      children: [
                        Container(
                          height: 12,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        FractionallySizedBox(
                          widthFactor: user.updateProgress,
                          child: Container(
                            height: 12,
                            decoration: BoxDecoration(
                              color: progressBarColor,
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ),
                      ],
                    ),
                  if (package != ServicePackage.premium2)
                    const SizedBox(height: 8),
                  Text(
                    user.updateStatusText,
                    style: TextStyle(
                      color: package == ServicePackage.premium2
                          ? const Color(0xFFFFD700)
                          : Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      fontFamily: '', // Fallback for serif style
                      fontStyle: FontStyle.normal,
                    ),
                  )
                      .animate(
                        onPlay: (controller) => controller.repeat(),
                      )
                      .shimmer(
                        duration: 2000.ms,
                        color: Colors.white.withOpacity(0.5),
                      ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        userName,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        date,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    if (package == ServicePackage.premium2) {
      return card
          .animate(onPlay: (controller) => controller.repeat())
          .shimmer(duration: 3000.ms, color: Colors.white.withOpacity(0.15))
          .animate(onPlay: (controller) => controller.repeat())
          .shimmer(
              duration: 2000.ms,
              color: const Color(0xFFFFD700).withOpacity(0.1));
    }

    return card;
  }

  Future<void> _openDocument(
      BuildContext context, String fileName, String? base64Content) async {
    if (base64Content == null || base64Content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Document content not available.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Opening $fileName...'),
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.black,
        ),
      );

      // Clean the base64 string if it contains a data URI scheme
      String cleanBase64 = base64Content;
      if (base64Content.contains(',')) {
        cleanBase64 = base64Content.split(',').last;
      }

      // Remove any potential whitespace
      cleanBase64 = cleanBase64.replaceAll(RegExp(r'\s+'), '');

      final bytes = base64Decode(cleanBase64);
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(bytes);

      await OpenFilex.open(file.path);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error opening document: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildDocumentCard(BuildContext context, String title, String subtitle,
      IconData icon, Color bgColor, Color iconColor, String? base64Content) {
    return InkWell(
      onTap: () => _openDocument(context, title, base64Content),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 28),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackSection() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: FeedbackService().getFeedback(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'What our users say',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            FeedbackCarousel(feedbackList: snapshot.data!),
            const SizedBox(height: 20),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value,
      Color color, CustomPainter painter) {
    return Container(
      height: 180,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const Spacer(),
          SizedBox(
            height: 40,
            width: double.infinity,
            child: CustomPaint(
              painter: painter,
            ),
          ),
        ],
      ),
    );
  }
}

class SparklinePainter extends CustomPainter {
  final Color color;

  const SparklinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    // Simulate a random-looking positive trend
    path.moveTo(0, size.height * 0.8);
    path.quadraticBezierTo(size.width * 0.2, size.height * 0.9,
        size.width * 0.4, size.height * 0.5);
    path.quadraticBezierTo(size.width * 0.6, size.height * 0.7,
        size.width * 0.8, size.height * 0.2);
    path.lineTo(size.width, size.height * 0.3);

    // Add a gradient fill below
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

class RadialPercentPainter extends CustomPainter {
  final double percent;
  final Color color;

  const RadialPercentPainter({required this.percent, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    // Constrain radius to fit within the available height/width
    final radius = (size.height < size.width ? size.height : size.width) / 2;

    final bgPaint = Paint()
      ..color = color.withOpacity(0.1)
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fgPaint = Paint()
      ..color = color
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    // Draw arc from top (-pi/2)
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -1.5708, // -pi/2
      2 * 3.14159 * percent,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(covariant RadialPercentPainter oldDelegate) =>
      oldDelegate.percent != percent;
}

class MeLogoPainter extends CustomPainter {
  final Color color;
  final ServicePackage package;

  MeLogoPainter({required this.color, required this.package});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final double w = size.width;
    final double h = size.height;
    final double cx = w / 2;
    final double cy = h / 2;
    final double r = (w < h ? w : h) / 2 * 0.9;

    // --- 1. Draw Hexagon Frame(s) ---
    final hexagonPath = Path();
    for (int i = 0; i < 6; i++) {
      double px =
          cx + r * (i == 1 || i == 2 ? 0.866 : (i == 4 || i == 5 ? -0.866 : 0));
      double py = cy +
          r * (i == 0 ? -1 : (i == 3 ? 1 : (i == 1 || i == 5 ? -0.5 : 0.5)));
      if (i == 0)
        hexagonPath.moveTo(px, py);
      else
        hexagonPath.lineTo(px, py);
    }
    hexagonPath.close();

    // Tiered Frames
    if (package == ServicePackage.golden ||
        package == ServicePackage.golden2 ||
        package == ServicePackage.premium ||
        package == ServicePackage.premium2) {
      // Outer or double frame
      canvas.drawPath(hexagonPath, paint);

      // Secondary Inner Frame (Golden tier start)
      final innerFramePath = Path();
      double ir = r * 0.82;
      for (int i = 0; i < 6; i++) {
        double px = cx +
            ir * (i == 1 || i == 2 ? 0.866 : (i == 4 || i == 5 ? -0.866 : 0));
        double py = cy +
            ir * (i == 0 ? -1 : (i == 3 ? 1 : (i == 1 || i == 5 ? -0.5 : 0.5)));
        if (i == 0)
          innerFramePath.moveTo(px, py);
        else
          innerFramePath.lineTo(px, py);
      }
      innerFramePath.close();
      paint.strokeWidth = 1.5;
      canvas.drawPath(innerFramePath, paint);
    } else {
      paint.strokeWidth = (package == ServicePackage.silver2) ? 3.5 : 2.5;
      canvas.drawPath(hexagonPath, paint);
    }

    // --- 2. Tiered Accents (Wings/Flares/Peak) ---
    paint.strokeWidth = 2.0;
    if (package == ServicePackage.golden2 ||
        package == ServicePackage.premium ||
        package == ServicePackage.premium2) {
      // "Wings" at side vertices
      canvas.drawLine(
          Offset(cx - r, cy), Offset(cx - r * 1.2, cy - r * 0.1), paint);
      canvas.drawLine(
          Offset(cx + r, cy), Offset(cx + r * 1.2, cy - r * 0.1), paint);
    }

    if (package == ServicePackage.premium ||
        package == ServicePackage.premium2) {
      // Top Peak Flare
      final peakPath = Path();
      peakPath.moveTo(cx - r * 0.15, cy - r * 0.95);
      peakPath.lineTo(cx, cy - r * 1.25);
      peakPath.lineTo(cx + r * 0.15, cy - r * 0.95);
      canvas.drawPath(peakPath, paint);
    }

    if (package == ServicePackage.premium2) {
      // Ultimate Flare points
      paint.style = PaintingStyle.fill;
      canvas.drawCircle(Offset(cx, cy - r * 1.25), 3, paint); // Top flare point
      canvas.drawCircle(Offset(cx, cy + r), 3, paint); // Bottom flare point
      paint.style = PaintingStyle.stroke;
    }

    // --- 3. Internal "ME" Segments ---
    double innerScale = r * (package == ServicePackage.silver ? 0.55 : 0.45);
    paint.strokeWidth = 2.5;

    // M (Middle/Left)
    canvas.drawLine(Offset(cx - innerScale * 0.7, cy - innerScale * 0.8),
        Offset(cx - innerScale * 0.7, cy + innerScale * 0.8), paint);
    canvas.drawLine(Offset(cx - innerScale * 0.1, cy - innerScale * 0.8),
        Offset(cx - innerScale * 0.1, cy + innerScale * 0.8), paint);

    // E (Right)
    canvas.drawLine(Offset(cx + innerScale * 0.3, cy - innerScale * 0.8),
        Offset(cx + innerScale * 0.3, cy + innerScale * 0.8), paint);
    canvas.drawLine(Offset(cx + innerScale * 0.3, cy - innerScale * 0.75),
        Offset(cx + innerScale * 0.85, cy - innerScale * 0.75), paint);
    canvas.drawLine(Offset(cx + innerScale * 0.3, cy),
        Offset(cx + innerScale * 0.7, cy), paint);
    canvas.drawLine(Offset(cx + innerScale * 0.3, cy + innerScale * 0.75),
        Offset(cx + innerScale * 0.85, cy + innerScale * 0.75), paint);
  }

  @override
  bool shouldRepaint(covariant MeLogoPainter oldDelegate) =>
      oldDelegate.package != package;
}

class CardBackgroundPainter extends CustomPainter {
  final Color primaryColor;
  final Color secondaryColor;

  CardBackgroundPainter(
      {required this.primaryColor, required this.secondaryColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Draw bottom-left shape
    paint.color = primaryColor;
    final path1 = Path();
    path1.moveTo(0, size.height * 0.4);
    path1.quadraticBezierTo(
      size.width * 0.3,
      size.height * 0.5,
      size.width * 0.5,
      size.height,
    );
    path1.lineTo(0, size.height);
    path1.close();
    canvas.drawPath(path1, paint);

    // Draw top-right shape
    paint.color = secondaryColor;
    final path2 = Path();
    path2.moveTo(size.width * 0.4, 0);
    path2.quadraticBezierTo(
      size.width * 0.6,
      size.height * 0.4,
      size.width,
      size.height * 0.3,
    );
    path2.lineTo(size.width, 0);
    path2.close();
    canvas.drawPath(path2, paint);

    // Draw small circle/glow
    paint.color = secondaryColor.withOpacity(0.1);
    canvas.drawCircle(
      Offset(size.width * 0.8, size.height * 0.2),
      size.width * 0.2,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ChipPainter extends CustomPainter {
  final Color lineColor;

  ChipPainter({this.lineColor = Colors.black26});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Draw some lines to simulate a chip
    for (var i = 1; i < 4; i++) {
      canvas.drawLine(
        Offset(size.width * i / 4, 0),
        Offset(size.width * i / 4, size.height),
        paint,
      );
      canvas.drawLine(
        Offset(0, size.height * i / 4),
        Offset(size.width, size.height * i / 4),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class FeedbackCarousel extends StatefulWidget {
  final List<Map<String, dynamic>> feedbackList;

  const FeedbackCarousel({super.key, required this.feedbackList});

  @override
  State<FeedbackCarousel> createState() => _FeedbackCarouselState();
}

class _FeedbackCarouselState extends State<FeedbackCarousel> {
  int _currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.feedbackList.length > 1) {
      _startTimer();
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (mounted) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % widget.feedbackList.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.feedbackList.isEmpty) return const SizedBox.shrink();

    final feedback = widget.feedbackList[_currentIndex];

    return AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(opacity: animation, child: child);
        },
        child: Container(
          key: ValueKey<int>(_currentIndex),
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min, // Wrap content height
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundImage: feedback['profilePic'] != null &&
                            feedback['profilePic'].toString().isNotEmpty
                        ? (feedback['profilePic'].toString().startsWith('http')
                            ? NetworkImage(feedback['profilePic'])
                            : MemoryImage(base64Decode(feedback['profilePic']
                                .toString()
                                .split(',')
                                .last)) as ImageProvider)
                        : null,
                    backgroundColor: Colors.grey[200],
                    child: feedback['profilePic'] == null ||
                            feedback['profilePic'].toString().isEmpty
                        ? const Icon(Icons.person, size: 18, color: Colors.grey)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          feedback['name'] ?? 'Anonymous',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: List.generate(
                            5,
                            (starIndex) => Icon(
                              starIndex < (feedback['rating'] ?? 0)
                                  ? Icons.star
                                  : Icons.star_border,
                              size: 14,
                              color: Colors.amber,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                feedback['feedbackText'] ?? '',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 13,
                  height: 1.4,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        )
            .animate(onPlay: (controller) => controller.forward(from: 0))
            .shimmer(duration: 1200.ms, color: Colors.white.withOpacity(0.8)));
  }
}
