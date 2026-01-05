import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data for notifications
    final List<Map<String, dynamic>> notifications = [
      {
        'title': 'Your order has arrived',
        'description':
            'Lorem ipsum dolor sit amet gui makan nasi goreng enak pakai kecap sekali lagi makan',
        'time': '30m',
        'icon': Icons.shopping_bag_outlined,
        'iconColor': Colors.blue,
      },
      {
        'title': 'Payment verified',
        'description':
            'Lorem ipsum dolor sit amet gui makan nasi goreng enak pakai kecap sekali lagi makan',
        'time': '1d',
        'icon': Icons.credit_card_outlined,
        'iconColor': Colors.cyan,
      },
      {
        'title': 'New promo just for you!',
        'description':
            'Lorem ipsum dolor sit amet gui makan nasi goreng enak pakai kecap sekali lagi makan',
        'time': '2d',
        'icon': Icons.info_outline,
        'iconColor': Colors.lightBlue,
      },
      {
        'title': "It's time for survey",
        'description':
            'Lorem ipsum dolor sit amet gui makan nasi goreng enak pakai kecap sekali lagi makan',
        'time': '2d',
        'icon': Icons.assignment_outlined,
        'iconColor': Colors.blueAccent,
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {},
          ),
        ],
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(24),
        itemCount: notifications.length,
        separatorBuilder: (context, index) => const SizedBox(height: 24),
        itemBuilder: (context, index) {
          final item = notifications[index];
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (item['iconColor'] as Color).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  item['icon'] as IconData,
                  color: item['iconColor'] as Color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          item['title'] as String,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.black,
                          ),
                        ),
                        Text(
                          item['time'] as String,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.mediaGray,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item['description'] as String,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.mediaGray,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
