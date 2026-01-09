import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:more_experts/core/constants/app_colors.dart';
import 'package:more_experts/features/auth/presentation/provider/auth_provider.dart';
import 'package:more_experts/features/profile/domain/models/user_model.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers and initial values for tracking changes
  late final TextEditingController _nameController;
  late final TextEditingController _dobController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _linkedinController;
  late final TextEditingController _locationController;

  late Map<String, String> _initialValues;
  bool _isModified = false;
  String _gender = 'Male';

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().currentUser;

    _nameController = TextEditingController(text: user?.name ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _dobController = TextEditingController(text: user?.dob ?? '');
    _phoneController = TextEditingController(text: user?.mobile ?? '');
    _linkedinController = TextEditingController(text: user?.linkedin ?? '');
    _locationController = TextEditingController(text: user?.address ?? '');
    _gender = user?.gender ?? 'Male';

    // Capture initial values
    _initialValues = {
      'name': _nameController.text,
      'dob': _dobController.text,
      'phone': _phoneController.text,
      'email': _emailController.text,
      'linkedin': _linkedinController.text,
      'location': _locationController.text,
      'gender': _gender,
    };

    // Add listeners to detect changes
    _nameController.addListener(_checkModifications);
    _dobController.addListener(_checkModifications);
    _phoneController.addListener(_checkModifications);
    _emailController.addListener(_checkModifications);
    _linkedinController.addListener(_checkModifications);
    _locationController.addListener(_checkModifications);
  }

  void _checkModifications() {
    final currentlyModified = _nameController.text != _initialValues['name'] ||
        _dobController.text != _initialValues['dob'] ||
        _phoneController.text != _initialValues['phone'] ||
        _emailController.text != _initialValues['email'] ||
        _linkedinController.text != _initialValues['linkedin'] ||
        _locationController.text != _initialValues['location'] ||
        _gender != _initialValues['gender'];

    if (currentlyModified != _isModified) {
      setState(() {
        _isModified = currentlyModified;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _linkedinController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text(
          'My Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Picture (Read-only)
              Center(
                child: Consumer<AuthProvider>(
                  builder: (context, auth, _) {
                    final user = auth.currentUser;
                    if (user?.profilePic != null) {
                      final isBase64 =
                          user!.profilePic!.startsWith('data:image');
                      return CircleAvatar(
                        radius: 50,
                        backgroundImage: isBase64
                            ? MemoryImage(Uri.parse(user.profilePic!)
                                .data!
                                .contentAsBytes()) as ImageProvider
                            : NetworkImage(user.profilePic!),
                      );
                    }
                    return const CircleAvatar(
                      radius: 50,
                      backgroundColor: AppColors.lightGray,
                      child: Icon(Icons.person,
                          size: 50, color: AppColors.mediaGray),
                    );
                  },
                ),
              ),
              const SizedBox(height: 32),

              _buildSectionTitle('Basic Detail'),
              _buildLabel('Full name'),
              _buildTextField(_nameController,
                  prefixIcon: Icons.person_outline),

              _buildLabel('Date of birth'),
              _buildTextField(_dobController,
                  prefixIcon: Icons.calendar_today_outlined),

              _buildLabel('Gender'),
              Row(
                children: [
                  Expanded(
                    child: _buildGenderOption('Male'),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildGenderOption('Female'),
                  ),
                ],
              ),

              const SizedBox(height: 24),
              _buildSectionTitle('Contact Detail'),
              _buildLabel('Mobile number'),
              _buildTextField(_phoneController,
                  prefixIcon: Icons.phone_outlined),

              _buildLabel('Email'),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.lightGray,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.email_outlined, color: AppColors.black),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _emailController.text,
                        style: const TextStyle(
                          color: AppColors.mediaGray,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              _buildSectionTitle('Personal Detail'),
              _buildLabel('LinkedIn Profile'),
              _buildTextField(_linkedinController, prefixIcon: Icons.link),

              _buildLabel('City, Country'),
              _buildTextField(_locationController,
                  prefixIcon: Icons.location_on_outlined),

              const SizedBox(height: 48),
              if (_isModified)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        final authProvider = context.read<AuthProvider>();
                        final currentUser = authProvider.currentUser;

                        if (currentUser != null) {
                          // Create updated user object
                          final updatedUser = UserModel(
                            id: currentUser.id,
                            name: _nameController.text,
                            email: currentUser.email, // Read-only
                            password: currentUser.password,
                            package: currentUser.package,
                            status: currentUser.status,
                            profilePic: currentUser
                                .profilePic, // TODO: Update if modified
                            documents: currentUser.documents,
                            createdAt: currentUser.createdAt,
                            address: _locationController.text,
                            dob: _dobController.text,
                            gender: _gender,
                            linkedin: _linkedinController.text,
                            mobile: _phoneController.text,
                          );

                          // Call update method
                          await authProvider.updateUser(updatedUser);

                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Profile updated successfully'),
                                backgroundColor: AppColors.black,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                            Navigator.pop(context);
                          }
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Update',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.black,
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          color: AppColors.mediaGray,
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller,
      {IconData? prefixIcon, IconData? suffixIcon, bool enabled = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        enabled: enabled,
        style:
            TextStyle(color: enabled ? AppColors.black : AppColors.mediaGray),
        decoration: InputDecoration(
          filled: true,
          fillColor: enabled ? AppColors.lightGray : Colors.grey[200],
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          prefixIcon: prefixIcon != null
              ? Icon(prefixIcon,
                  color: enabled ? AppColors.black : AppColors.mediaGray)
              : null,
          suffixIcon: suffixIcon != null
              ? Icon(suffixIcon, color: AppColors.mediaGray)
              : null,
        ),
      ),
    );
  }

  Widget _buildGenderOption(String gender) {
    final isSelected = _gender == gender;
    return GestureDetector(
      onTap: () {
        setState(() {
          _gender = gender;
          _checkModifications();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? AppColors.primaryBlue : AppColors.borderGray,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isSelected)
              const Icon(Icons.check_circle,
                  color: AppColors.primaryBlue, size: 20),
            if (isSelected) const SizedBox(width: 8),
            Text(
              gender,
              style: TextStyle(
                color: isSelected ? AppColors.primaryBlue : AppColors.mediaGray,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
