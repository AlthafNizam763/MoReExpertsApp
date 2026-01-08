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
import 'package:more_experts/features/profile/domain/models/user_model.dart';
import 'package:more_experts/core/widgets/spotlight_nav_bar.dart';
import 'package:more_experts/features/profile/presentation/pages/notifications_page.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';

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
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: SpotlightNavBar(
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
    if (user == null) return const Center(child: CircularProgressIndicator());

    final userName = user.name.toUpperCase();
    final creationDate = DateFormat('dd/MM/yyyy').format(user.createdAt);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        automaticallyImplyLeading: false,
        actions: [
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
      body: SingleChildScrollView(
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

            // Active Service Card (Multi-Package Support)
            _buildAtmCard(context, user, userName, creationDate),

            const SizedBox(height: 10),

            // Documents Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Documents',
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
    );
  }

  Widget _buildFilteredDocuments(BuildContext context, UserModel user) {
    List<Widget> documents = [];
    final package = user.package;

    // Service Guide
    if (user.documents.serviceGuide != null) {
      documents.add(
        _buildDocumentCard(
          context,
          'Service Guide.pdf',
          'PDF Document • 2.4 MB',
          Icons.picture_as_pdf,
          Colors.red.shade100,
          Colors.red,
          user.documents.serviceGuide,
        ),
      );
    }

    // Contract (Silver2 and above)
    if (package != ServicePackage.silver && user.documents.contract != null) {
      documents.add(
        _buildDocumentCard(
          context,
          'Contract.docx',
          'Word Document • 1.1 MB',
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
          'Cover Letter.pdf',
          'PDF Document • 850 KB',
          Icons.badge_outlined,
          Colors.orange.shade100,
          Colors.orange,
          user.documents.coverLetter,
        ),
      );
    }

    // ID Proof
    // if (user.documents.idProof != null) {
    //   documents.add(
    //     _buildDocumentCard(
    //       context,
    //       'ID Proof.pdf',
    //       'PDF Document • 1.2 MB',
    //       Icons.fingerprint,
    //       Colors.green.shade100,
    //       Colors.green,
    //       user.documents.idProof,
    //     ),
    //   );
    // }

    return Column(
      children: documents
          .map((doc) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: doc,
              ))
          .toList(),
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
        padding: const EdgeInsets.all(16),
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
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
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
