import 'package:flutter/material.dart';
import 'package:more_experts/features/profile/data/notification_service.dart';
import 'package:more_experts/features/profile/domain/models/notification_model.dart';
import 'package:timeago/timeago.dart' as timeago;

class AdminNotificationsPage extends StatefulWidget {
  const AdminNotificationsPage({super.key});

  @override
  State<AdminNotificationsPage> createState() => _AdminNotificationsPageState();
}

class _AdminNotificationsPageState extends State<AdminNotificationsPage> {
  final NotificationService _notificationService = NotificationService();

  Future<void> _deleteNotification(String docId) async {
    try {
      await _notificationService.deleteNotification(docId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Notification deleted'),
            backgroundColor: Colors.red));
        setState(() {}); // Refresh list
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Failed to delete: $e'),
            backgroundColor: Colors.red));
      }
    }
  }

  void _showAddSheet() async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: const _BroadcastNewSheet(),
      ),
    );

    if (result == true) {
      if (mounted) setState(() {}); // Refresh list if a notification was added
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      appBar: AppBar(
        title: const Text('Manage Notifications',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF111111),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: FutureBuilder<List<NotificationModel>>(
        future: _notificationService.getNotifications(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: Colors.blue));
          }

          final notifications = snapshot.data ?? [];
          if (notifications.isEmpty) {
            return Center(
                child: Text('No notifications found.',
                    style: TextStyle(color: Colors.grey.shade500)));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notif = notifications[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.blue.withOpacity(0.1),
                        child: Icon(
                          notif.type == 'offer'
                              ? Icons.local_offer_outlined
                              : Icons.system_update_alt,
                          color: Colors.blueAccent,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              notif.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              notif.description,
                              style: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              timeago.format(notif.createdAt),
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline,
                            color: Colors.redAccent),
                        onPressed: () {
                          // Confirm deletion
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              backgroundColor: const Color(0xFF1E1E1E),
                              title: const Text('Delete Notification?',
                                  style: TextStyle(color: Colors.white)),
                              content: Text(
                                  'Users will no longer see this notification in their history.',
                                  style:
                                      TextStyle(color: Colors.grey.shade400)),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancel',
                                      style: TextStyle(color: Colors.grey)),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.redAccent),
                                  onPressed: () {
                                    Navigator.pop(context);
                                    _deleteNotification(notif.id);
                                  },
                                  child: const Text('Delete',
                                      style: TextStyle(color: Colors.white)),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddSheet,
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class _BroadcastNewSheet extends StatefulWidget {
  const _BroadcastNewSheet({Key? key}) : super(key: key);

  @override
  State<_BroadcastNewSheet> createState() => _BroadcastNewSheetState();
}

class _BroadcastNewSheetState extends State<_BroadcastNewSheet> {
  final NotificationService _notificationService = NotificationService();
  final _formKey = GlobalKey<FormState>();

  String title = '';
  String description = '';
  String type = 'update';
  bool isSubmitting = false;

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() => isSubmitting = true);

      try {
        final notif = NotificationModel(
          id: '', // Firestore auto-id
          title: title,
          description: description,
          type: type,
          createdAt: DateTime.now(),
        );

        await _notificationService.addNotification(notif);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Notification broadcast successfully')));
          Navigator.pop(context, true); // Return true to indicate success
        }
      } catch (e) {
        setState(() => isSubmitting = false);
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Failed: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E1E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Broadcast New',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.white)),
            const SizedBox(height: 8),
            Text('Push system updates or promotional offers',
                style: TextStyle(color: Colors.grey.shade400, fontSize: 14)),
            const SizedBox(height: 24),

            // Type Selection Row
            Row(
              children: [
                Expanded(
                  child: _TypeSelectionCard(
                    title: 'Update',
                    icon: Icons.system_update_alt,
                    isSelected: type == 'update',
                    onTap: () => setState(() => type = 'update'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _TypeSelectionCard(
                    title: 'Offer',
                    icon: Icons.local_offer_outlined,
                    isSelected: type == 'offer',
                    onTap: () => setState(() => type = 'offer'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            const Text('Notification Title',
                style: TextStyle(
                    fontWeight: FontWeight.w600, color: Colors.white)),
            const SizedBox(height: 8),
            TextFormField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'e.g. System Performance Boost',
                hintStyle: TextStyle(color: Colors.grey.shade600),
                filled: true,
                fillColor: const Color(0xFF111111),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              validator: (v) => v!.isEmpty ? 'Required' : null,
              onSaved: (v) => title = v!,
            ),
            const SizedBox(height: 20),

            const Text('Message Description',
                style: TextStyle(
                    fontWeight: FontWeight.w600, color: Colors.white)),
            const SizedBox(height: 8),
            TextFormField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'What should the users know about this?',
                hintStyle: TextStyle(color: Colors.grey.shade600),
                filled: true,
                fillColor: const Color(0xFF111111),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
              validator: (v) => v!.isEmpty ? 'Required' : null,
              onSaved: (v) => description = v!,
              maxLines: 4,
            ),
            const SizedBox(height: 32),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: Colors.white.withOpacity(0.1)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: isSubmitting
                        ? null
                        : () => Navigator.pop(
                            context), // Discard just closes the sheet
                    child: const Text('Discard',
                        style: TextStyle(color: Colors.grey)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    onPressed: isSubmitting ? null : _submit,
                    child: isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Text('Push Notification',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _TypeSelectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _TypeSelectionCard({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.blueAccent.withOpacity(0.1)
              : const Color(0xFF111111),
          border: Border.all(
            color:
                isSelected ? Colors.blueAccent : Colors.white.withOpacity(0.05),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                color: isSelected ? Colors.blueAccent : Colors.grey.shade600,
                size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: isSelected ? Colors.blueAccent : Colors.grey.shade400,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
