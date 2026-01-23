import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/service_package.dart';
import '../../../auth/presentation/provider/auth_provider.dart';
import 'package:more_experts/core/widgets/app_loader.dart';
import 'service_detail_page.dart';

class ServiceListPage extends StatelessWidget {
  const ServiceListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Services Status'),
        automaticallyImplyLeading: false,
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          final user = authProvider.currentUser;

          if (user == null) {
            return const AppLoader();
          }

          final docs = user.documents;
          final package = user.package;

          // Resume Logic: serviceGuide (PDF) + contract (Word)
          final resumeCompleted = docs.serviceGuide != null &&
              docs.serviceGuide!.isNotEmpty &&
              docs.contract != null &&
              docs.contract!.isNotEmpty;

          // Cover Letter Logic
          final coverLetterCompleted =
              docs.coverLetter != null && docs.coverLetter!.isNotEmpty;

          // Build list items
          List<Widget> services = [];

          // 1. Resume (Always shown)
          services.add(_buildServiceItem(
            title: 'Resume',
            isCompleted: resumeCompleted,
            context: context,
            package: package,
          ));

          // 2. Cover Letter (Hidden for Silver/Silver2)
          if (package != ServicePackage.silver &&
              package != ServicePackage.silver2) {
            services.add(_buildServiceItem(
              title: 'Cover Letter',
              isCompleted: coverLetterCompleted,
              context: context,
              package: package,
            ));
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: services,
          );
        },
      ),
    );
  }

  Widget _buildServiceItem({
    required String title,
    required bool isCompleted,
    required BuildContext context,
    required ServicePackage package,
  }) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ServiceDetailPage(
              serviceTitle: title,
              package: package,
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.lightGray),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isCompleted ? AppColors.black : AppColors.lightGray,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isCompleted ? Icons.check : Icons.timer_outlined,
                color: isCompleted ? AppColors.white : AppColors.black,
              ),
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
                    isCompleted ? 'Completed' : 'In Progress',
                    style: TextStyle(
                      color:
                          isCompleted ? AppColors.success : AppColors.warning,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.mediaGray),
          ],
        ),
      ),
    );
  }
}
