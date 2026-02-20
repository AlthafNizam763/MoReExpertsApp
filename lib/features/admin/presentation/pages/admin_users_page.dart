import 'package:flutter/material.dart';
import 'package:more_experts/features/admin/data/admin_service.dart';
import 'package:more_experts/features/profile/domain/models/user_model.dart';
import 'package:more_experts/core/constants/service_package.dart';
import 'package:more_experts/features/admin/presentation/pages/admin_user_detail_page.dart';

import 'package:more_experts/features/admin/presentation/widgets/glass_widgets.dart';

class AdminUsersPage extends StatefulWidget {
  const AdminUsersPage({super.key});

  @override
  State<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage> {
  final AdminService _adminService = AdminService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Manage Users',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: RefreshIndicator(
        color: Colors.blueAccent,
        backgroundColor: const Color(0xFF1E1E1E).withOpacity(0.8),
        onRefresh: () async {
          setState(() {});
          await Future.delayed(const Duration(seconds: 1));
        },
        child: StreamBuilder<List<UserModel>>(
          stream: _adminService.getUsersStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                  child: CircularProgressIndicator(color: Colors.blue));
            }
            if (snapshot.hasError) {
              return Center(
                  child: Text('Error: ${snapshot.error}',
                      style: const TextStyle(color: Colors.red)));
            }
            final users = snapshot.data ?? [];
            if (users.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.7,
                    child: Center(
                      child: Text('No users found.',
                          style:
                              TextStyle(color: Colors.white.withOpacity(0.5))),
                    ),
                  ),
                ],
              );
            }

            return ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                final bool hasPic = user.profilePic != null &&
                    user.profilePic!.trim().isNotEmpty &&
                    user.profilePic!.trim().startsWith('http');
                return GlassCard(
                  margin: const EdgeInsets.only(bottom: 12),
                  borderRadius: 16,
                  child: ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: CircleAvatar(
                      backgroundColor: Colors.white.withOpacity(0.1),
                      radius: 24,
                      child: hasPic
                          ? ClipOval(
                              child: Image.network(
                                user.profilePic!.trim(),
                                width: 48,
                                height: 48,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Center(
                                  child: Text(
                                    user.name.isNotEmpty
                                        ? user.name[0].toUpperCase()
                                        : '?',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            )
                          : Text(
                              user.name.isNotEmpty
                                  ? user.name[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                    ),
                    title: Text(user.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.white)),
                    subtitle: Text(user.email,
                        style: TextStyle(color: Colors.white.withOpacity(0.6))),
                    trailing: Icon(Icons.arrow_forward_ios,
                        size: 16, color: Colors.white.withOpacity(0.3)),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AdminUserDetailPage(user: user),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddUserDialog(context),
        backgroundColor: Colors.blueAccent.withOpacity(0.8),
        elevation: 8,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showAddUserDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const _AddUserDialog(),
    );
  }
}

class _AddUserDialog extends StatefulWidget {
  const _AddUserDialog();

  @override
  State<_AddUserDialog> createState() => _AddUserDialogState();
}

class _AddUserDialogState extends State<_AddUserDialog> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String email = '';
  String password = '';
  String mobile = '';
  ServicePackage package = ServicePackage.silver;
  bool isLoading = false;

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() => isLoading = true);
      try {
        final newUser = UserModel(
          id: '',
          name: name,
          email: email,
          password: password,
          package: package,
          status: 'active',
          documents: UserDocuments(),
          createdAt: DateTime.now(),
          address: '',
          dob: '',
          gender: '',
          mobile: mobile,
        );

        await AdminService().addUser(newUser, password);
        if (mounted) Navigator.pop(context);
      } catch (e) {
        setState(() => isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1E1E1E),
      title: const Text('Add New User', style: TextStyle(color: Colors.white)),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Name',
                  labelStyle: TextStyle(color: Colors.grey.shade400),
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey.shade700)),
                ),
                validator: (v) => v!.isEmpty ? 'Required' : null,
                onSaved: (v) => name = v!,
              ),
              TextFormField(
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(color: Colors.grey.shade400),
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey.shade700)),
                ),
                validator: (v) => v!.isEmpty ? 'Required' : null,
                onSaved: (v) => email = v!,
              ),
              TextFormField(
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: TextStyle(color: Colors.grey.shade400),
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey.shade700)),
                ),
                validator: (v) => v!.length < 6 ? 'Min 6 chars' : null,
                onSaved: (v) => password = v!,
              ),
              TextFormField(
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Mobile',
                  labelStyle: TextStyle(color: Colors.grey.shade400),
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey.shade700)),
                ),
                validator: (v) => v!.isEmpty ? 'Required' : null,
                onSaved: (v) => mobile = v!,
              ),
              DropdownButtonFormField<ServicePackage>(
                value: package,
                dropdownColor: const Color(0xFF2A2A2A),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Package',
                  labelStyle: TextStyle(color: Colors.grey.shade400),
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey.shade700)),
                ),
                items: ServicePackage.values.map((pkg) {
                  return DropdownMenuItem(
                      value: pkg, child: Text(pkg.toString().split('.').last));
                }).toList(),
                onChanged: (v) => setState(() => package = v!),
              )
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey))),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
          onPressed: isLoading ? null : _submit,
          child: isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white))
              : const Text('Add User', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
