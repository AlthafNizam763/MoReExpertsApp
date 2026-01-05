import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/service_package.dart';
import 'service_detail_page.dart';

class ServiceListPage extends StatelessWidget {
  final ServicePackage currentPackage =
      ServicePackage.premium; // For demonstration

  const ServiceListPage({super.key});

  @override
  Widget build(BuildContext context) {
    // All possible services
    final allServices = [
      {
        'title': 'Resume Making',
        'status': 'Completed',
        'date': 'Today',
        'package': 'silver'
      },
      // {
      //   'title': 'LinkedIn Optimization',
      //   'status': 'Pending',
      //   'date': 'Upcoming',
      //   'package': 'silver2'
      // },
      {
        'title': 'Cover Letter',
        'status': 'In-Progress',
        'date': 'Yesterday',
        'package': 'golden'
      },
    ];

    // Filter based on package
    final services = allServices.where((service) {
      final req = service['package'];
      if (currentPackage == ServicePackage.silver) return req == 'silver';
      if (currentPackage == ServicePackage.silver2)
        return req == 'silver' || req == 'silver2';
      return true; // Golden, Golden2, Premium, Premium2
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Services Status'),
        automaticallyImplyLeading: false,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: services.length,
        itemBuilder: (context, index) {
          final service = services[index];
          final isCompleted = service['status'] == 'Completed';

          return InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ServiceDetailPage(
                    serviceTitle: service['title']!,
                    package: currentPackage,
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
                      color:
                          isCompleted ? AppColors.black : AppColors.lightGray,
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
                          service['title']!,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isCompleted ? 'Complete' : 'Not Complete',
                          style: TextStyle(
                            color: isCompleted
                                ? AppColors.success
                                : AppColors.warning,
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
        },
      ),
    );
  }
}
