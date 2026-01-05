import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/service_package.dart';

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Project Status',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ..._buildStatusList(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildStatusList() {
    if (serviceTitle != 'Resume Making') {
      return [
        _buildStatusItem(
          title: serviceTitle,
          status: 'In Progress',
          icon: Icons.assignment_outlined,
        ),
      ];
    }

    List<Widget> items = [];

    // 1. Resume PDF (Always for all)
    items.add(_buildStatusItem(
      title: 'Resume PDF',
      status: 'Completed',
      icon: Icons.picture_as_pdf,
    ));

    // 2. Resume Word (Silver 2nd and above)
    if (package != ServicePackage.silver) {
      items.add(_buildStatusItem(
        title: 'Resume Word Document',
        status: 'In Progress',
        icon: Icons.description,
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
