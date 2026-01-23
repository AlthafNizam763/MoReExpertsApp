import 'package:flutter/material.dart';
import 'package:more_experts/core/constants/app_colors.dart';
import 'package:more_experts/features/profile/data/notification_service.dart';
import 'package:more_experts/features/profile/domain/models/notification_model.dart';
import 'package:more_experts/core/widgets/app_loader.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final NotificationService _notificationService = NotificationService();
  List<NotificationModel> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    final notifications = await _notificationService.getNotifications();
    if (mounted) {
      setState(() {
        _notifications = notifications;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
        centerTitle: true,
        backgroundColor: AppColors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const AppLoader()
          : _notifications.isEmpty
              ? const Center(
                  child: Text(
                    'No notifications',
                    style: TextStyle(color: AppColors.mediaGray),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(24),
                  itemCount: _notifications.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 24),
                  itemBuilder: (context, index) {
                    final item = _notifications[index];

                    IconData icon;
                    Color color;
                    Color bgColor;

                    switch (item.type.toLowerCase()) {
                      case 'update':
                        icon = Icons.update;
                        color = Colors.orange;
                        bgColor = Colors.orange.withOpacity(0.1);
                        break;
                      case 'offer':
                        icon = Icons.local_offer_outlined;
                        color = Colors.purple;
                        bgColor = Colors.purple.withOpacity(0.1);
                        break;
                      default:
                        icon = Icons.notifications_outlined;
                        color = Colors.blue;
                        bgColor = Colors.blue.withOpacity(0.1);
                    }

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: bgColor,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            icon,
                            color: color,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      item.title,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.black,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    item.timeAgo,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: AppColors.mediaGray,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item.description,
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
