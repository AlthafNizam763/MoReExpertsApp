import 'package:flutter/material.dart';
import 'package:more_experts/features/admin/data/admin_service.dart';
import 'package:more_experts/features/profile/domain/models/user_model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:more_experts/core/constants/service_package.dart';
import 'package:more_experts/features/admin/presentation/widgets/glass_widgets.dart';

class AdminUserDetailPage extends StatefulWidget {
  final UserModel user;
  const AdminUserDetailPage({super.key, required this.user});

  @override
  State<AdminUserDetailPage> createState() => _AdminUserDetailPageState();
}

class _AdminUserDetailPageState extends State<AdminUserDetailPage> {
  late UserModel user;
  final AdminService _adminService = AdminService();
  bool isUploading = false;

  @override
  void initState() {
    super.initState();
    user = widget.user;
  }

  Future<void> _deleteDocument(String docField) async {
    setState(() => isUploading = true);
    try {
      Map<String, dynamic> docJson = user.documents.toJson();
      docJson[docField] = null; // Clear the field

      final updatedDocs = UserDocuments.fromJson(docJson);
      final updatedUser = UserModel(
        id: user.id,
        name: user.name,
        email: user.email,
        password: user.password,
        package: user.package,
        status: user.status,
        profilePic: user.profilePic,
        documents: updatedDocs,
        createdAt: user.createdAt,
        address: user.address,
        dob: user.dob,
        gender: user.gender,
        linkedin: user.linkedin,
        mobile: user.mobile,
      );

      await _adminService.updateUser(updatedUser);

      setState(() {
        user = updatedUser;
        isUploading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Document removed successfully')));
      }
    } catch (e) {
      setState(() => isUploading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to remove document: $e')));
      }
    }
  }

  Future<void> _uploadDocument(String docField) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null && result.files.single.path != null) {
      setState(() => isUploading = true);
      try {
        final filePath = result.files.single.path!;
        final fileName = result.files.single.name;

        // Upload to Storage
        final downloadUrl =
            await _adminService.uploadUserDocument(user.id, filePath, fileName);

        // Update user model documents mapping
        Map<String, dynamic> docJson = user.documents.toJson();
        docJson[docField] = downloadUrl;

        final updatedDocs = UserDocuments.fromJson(docJson);
        final updatedUser = UserModel(
          id: user.id,
          name: user.name,
          email: user.email,
          password: user.password,
          package: user.package,
          status: user.status,
          profilePic: user.profilePic,
          documents: updatedDocs,
          createdAt: user.createdAt,
          address: user.address,
          dob: user.dob,
          gender: user.gender,
          linkedin: user.linkedin,
          mobile: user.mobile,
        );

        // Update Firestore
        await _adminService.updateUser(updatedUser);

        setState(() {
          user = updatedUser;
          isUploading = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Document uploaded successfully')));
        }
      } catch (e) {
        setState(() => isUploading = false);
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Upload failed: $e')));
        }
      }
    }
  }

  void _showEditDialog() {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    String name = user.name;
    String mobile = user.mobile;
    ServicePackage package = user.package;
    String status = user.status.toLowerCase();

    // Restrict to ONLY active or suspended
    if (!['active', 'suspended'].contains(status)) {
      status = 'suspended';
    }

    bool isSaving = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: const Color(0xFF1E1E1E),
            title:
                const Text('Edit User', style: TextStyle(color: Colors.white)),
            content: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      initialValue: name,
                      style: const TextStyle(
                          color: Color.fromARGB(134, 17, 38, 233)),
                      decoration: InputDecoration(
                        labelText: 'Name',
                        labelStyle: TextStyle(
                            color: const Color.fromARGB(255, 7, 7, 7)),
                        enabledBorder: UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.grey.shade700)),
                      ),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                      onSaved: (v) => name = v!,
                    ),
                    TextFormField(
                      initialValue: mobile,
                      style: const TextStyle(
                          color: Color.fromARGB(134, 17, 38, 233)),
                      decoration: InputDecoration(
                        labelText: 'Mobile',
                        labelStyle: TextStyle(
                            color: const Color.fromARGB(255, 7, 7, 7)),
                        enabledBorder: UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.grey.shade700)),
                      ),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                      onSaved: (v) => mobile = v!,
                    ),
                    DropdownButtonFormField<ServicePackage>(
                      value: package,
                      dropdownColor: const Color(0xFF2A2A2A),
                      style: const TextStyle(
                          color: Color.fromARGB(134, 17, 38, 233)),
                      decoration: InputDecoration(
                        labelText: 'Package',
                        labelStyle: TextStyle(
                            color: const Color.fromARGB(255, 7, 7, 7)),
                        enabledBorder: UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.grey.shade700)),
                      ),
                      items: ServicePackage.values.map((pkg) {
                        return DropdownMenuItem(
                            value: pkg,
                            child: Text(pkg.toString().split('.').last));
                      }).toList(),
                      onChanged: (v) => setDialogState(() => package = v!),
                    ),
                    DropdownButtonFormField<String>(
                      value: status,
                      dropdownColor: const Color(0xFF2A2A2A),
                      style: const TextStyle(
                          color: Color.fromARGB(134, 17, 38, 233)),
                      decoration: InputDecoration(
                        labelText: 'Status',
                        labelStyle: TextStyle(
                            color: const Color.fromARGB(255, 7, 7, 7)),
                        enabledBorder: UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.grey.shade700)),
                      ),
                      items: ['active', 'suspended'].map((s) {
                        return DropdownMenuItem(
                            value: s, child: Text(s.toUpperCase()));
                      }).toList(),
                      onChanged: (v) => setDialogState(() => status = v!),
                    ),
                  ],
                ),
              ),
            ),
            actionsPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            actions: [
              SizedBox(
                width: double.maxFinite,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: isSaving
                          ? null
                          : () {
                              showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  backgroundColor: const Color(0xFF1E1E1E),
                                  title: const Text('Delete User',
                                      style: TextStyle(color: Colors.white)),
                                  content: const Text(
                                    'Are you sure you want to delete this user? This action cannot be undone.',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx),
                                      child: const Text('Cancel',
                                          style: TextStyle(color: Colors.grey)),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red),
                                      onPressed: () async {
                                        Navigator.pop(ctx);
                                        setDialogState(() => isSaving = true);
                                        try {
                                          await _adminService
                                              .deleteUser(user.id);
                                          if (mounted) {
                                            Navigator.pop(
                                                context); // Close edit dialog
                                            Navigator.pop(
                                                context); // Go back to users list
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                  content: Text(
                                                      'User deleted successfully')),
                                            );
                                          }
                                        } catch (e) {
                                          setDialogState(
                                              () => isSaving = false);
                                          if (mounted) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                  content: Text(
                                                      'Failed to delete user: $e')),
                                            );
                                          }
                                        }
                                      },
                                      child: const Text('Delete',
                                          style:
                                              TextStyle(color: Colors.white)),
                                    ),
                                  ],
                                ),
                              );
                            },
                      child: const Text('Delete',
                          style: TextStyle(color: Colors.redAccent)),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel',
                              style: TextStyle(color: Colors.grey)),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue),
                          onPressed: isSaving
                              ? null
                              : () async {
                                  if (formKey.currentState!.validate()) {
                                    formKey.currentState!.save();
                                    setDialogState(() => isSaving = true);
                                    try {
                                      final updatedUser = UserModel(
                                        id: user.id,
                                        name: name,
                                        email: user.email,
                                        password: user.password,
                                        package: package,
                                        status: status,
                                        profilePic: user.profilePic,
                                        documents: user.documents,
                                        createdAt: user.createdAt,
                                        address: user.address,
                                        dob: user.dob,
                                        gender: user.gender,
                                        linkedin: user.linkedin,
                                        mobile: mobile,
                                      );

                                      await _adminService
                                          .updateUser(updatedUser);
                                      if (mounted) {
                                        setState(() => user = updatedUser);
                                        Navigator.pop(context);
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(const SnackBar(
                                                content: Text(
                                                    'User updated successfully')));
                                      }
                                    } catch (e) {
                                      setDialogState(() => isSaving = false);
                                      if (mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                                content: Text(
                                                    'Error updating user: $e')));
                                      }
                                    }
                                  }
                                },
                          child: isSaving
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white))
                              : const Text('Save',
                                  style: TextStyle(color: Colors.white)),
                        ),
                      ],
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111111),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(user.name,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.blue),
            onPressed: _showEditDialog,
          ),
        ],
      ),
      body: isUploading
          ? const Center(
              child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Colors.blue),
                SizedBox(height: 16),
                Text("Updating Document... Please wait.",
                    style: TextStyle(color: Colors.white))
              ],
            ))
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Center(
                  child: GlassAvatar(
                    imagePath: user.profilePic,
                    name: user.name,
                    radius: 60,
                  ),
                ),
                const SizedBox(height: 24),
                const Text('USER DETAILS',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                        letterSpacing: 1.2)),
                const SizedBox(height: 12),
                _buildDetailTile('Email', user.email),
                _buildDetailTile('Mobile', user.mobile),
                _buildDetailTile('Package',
                    user.package.toString().split('.').last.toUpperCase()),
                _buildDetailTile('Status', user.status.toUpperCase(),
                    valueColor: user.status == 'active'
                        ? Colors.greenAccent
                        : Colors.redAccent),
                const SizedBox(height: 32),
                const Text('DOCUMENTS (UPLOAD)',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                        letterSpacing: 1.2)),
                const SizedBox(height: 16),
                _buildDocItem('ID Proof', 'idProof', user.documents.idProof,
                    Icons.shield_outlined, Colors.tealAccent),
                _buildDocItem(
                    'Resume (Color)',
                    'serviceGuide',
                    user.documents.serviceGuide,
                    Icons.description_outlined,
                    Colors.redAccent),
                _buildDocItem(
                    'Resume (B&W)',
                    'serviceGuide2',
                    user.documents.serviceGuide2,
                    Icons.description_outlined,
                    Colors.redAccent),
                _buildDocItem(
                    'Resume (Horizontal)',
                    'serviceGuide3',
                    user.documents.serviceGuide3,
                    Icons.description_outlined,
                    Colors.redAccent),
                _buildDocItem('Contract', 'contract', user.documents.contract,
                    Icons.insert_drive_file_outlined, Colors.blue),
                _buildDocItem(
                    'Cover Letter',
                    'coverLetter',
                    user.documents.coverLetter,
                    Icons.security_outlined,
                    Colors.orangeAccent),
              ],
            ),
    );
  }

  Widget _buildDetailTile(String title, String value, {Color? valueColor}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          Text(value,
              style: TextStyle(
                  color: valueColor ?? Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildDocItem(String label, String docField, String? currentUrl,
      IconData icon, Color iconColor) {
    bool isUploaded = currentUrl != null;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A), // Very dark background
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isUploaded ? 'UPLOADED' : 'CLICK TO UPLOAD PDF',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: isUploaded
                  ? Colors.red.withOpacity(0.1)
                  : Colors.blue.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(
                isUploaded ? Icons.delete_outline : Icons.cloud_upload_outlined,
                color: isUploaded ? Colors.redAccent : Colors.blueAccent,
                size: 20,
              ),
              onPressed: () => isUploaded
                  ? _deleteDocument(docField)
                  : _uploadDocument(docField),
            ),
          ),
        ],
      ),
    );
  }
}
