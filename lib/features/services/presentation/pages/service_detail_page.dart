import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/service_package.dart';
import '../../../auth/presentation/provider/auth_provider.dart';

class ServiceDetailPage extends StatelessWidget {
  final String serviceTitle;
  final ServicePackage package;

  const ServiceDetailPage({
    super.key,
    required this.serviceTitle,
    required this.package,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(serviceTitle),
        elevation: 0,
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          final user = authProvider.currentUser;
          if (user == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = user.documents;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Status',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                ..._buildStatusList(docs),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildStatusList(dynamic docs) {
    List<Widget> items = [];

    if (serviceTitle == 'Resume') {
      // 1. Resume PDF (serviceGuide)
      final pdfCompleted =
          docs.serviceGuide != null && docs.serviceGuide!.isNotEmpty;
      items.add(_buildStatusItem(
        title: 'Resume PDF',
        status: pdfCompleted ? 'Completed' : 'In Progress',
        icon: Icons.picture_as_pdf,
      ));

      // 2. Resume Word (contract)
      final wordCompleted = docs.contract != null && docs.contract!.isNotEmpty;
      items.add(_buildStatusItem(
        title: 'Resume Word Document',
        status: wordCompleted ? 'Completed' : 'In Progress',
        icon: Icons.description,
      ));
    } else if (serviceTitle == 'Cover Letter') {
      // Cover Letter
      final clCompleted =
          docs.coverLetter != null && docs.coverLetter!.isNotEmpty;
      items.add(_buildStatusItem(
        title: 'Cover Letter',
        status: clCompleted ? 'Completed' : 'In Progress',
        icon: Icons.description_outlined,
      ));
    } else {
      // Default / Other services
      items.add(_buildStatusItem(
        title: serviceTitle,
        status: 'In Progress', // Logic not yet defined for others
        icon: Icons.assignment_outlined,
      ));
    }

    return items;
  }

  Widget _buildStatusItem({
    required String title,
    required String status,
    required IconData icon,
  }) {
    Color statusColor;
    IconData statusIcon;

    switch (status) {
      case 'Completed':
        statusColor = AppColors.success;
        statusIcon = Icons.check_circle;
        break;
      case 'In Progress':
        statusColor = AppColors.warning;
        statusIcon = Icons.cached;
        break;
      default:
        statusColor = AppColors.mediaGray;
        statusIcon = Icons.radio_button_unchecked;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.lightGray),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.lightGray.withOpacity(0.5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.black, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(statusIcon, size: 14, color: statusColor),
                    const SizedBox(width: 4),
                    Text(
                      status,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 13,
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
    );
  }
}
