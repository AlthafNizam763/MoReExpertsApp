import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/provider/auth_provider.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for the fields
  late final TextEditingController _nameController;
  final _dobController = TextEditingController(text: '1 Jan 1995');
  final _phoneController = TextEditingController(text: '+91 98765 43210');
  late final TextEditingController _emailController;
  final _linkedinController =
      TextEditingController(text: 'linkedin.com/in/username');
  final _locationController = TextEditingController(text: 'New York, USA');

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().currentUser;
    final email = user?.email ?? 'user@gmail.com';
    final name = email.split('@')[0];

    _nameController = TextEditingController(text: name);
    _emailController = TextEditingController(text: email);
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

  String _gender = 'Male';

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
              // Profile Picture with Edit Icon
              Center(
                child: Stack(
                  children: [
                    const CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(
                        'https://i.pravatar.cc',
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.black,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: AppColors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
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
              _buildTextField(_emailController,
                  prefixIcon: Icons.email_outlined),

              const SizedBox(height: 24),
              _buildSectionTitle('Personal Detail'),
              _buildLabel('LinkedIn Profile'),
              _buildTextField(_linkedinController, prefixIcon: Icons.link),

              _buildLabel('City, Country'),
              _buildTextField(_locationController,
                  prefixIcon: Icons.location_on_outlined),

              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Save',
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
      {IconData? prefixIcon, IconData? suffixIcon}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        style: const TextStyle(color: AppColors.black),
        decoration: InputDecoration(
          filled: true,
          fillColor: AppColors.lightGray,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          prefixIcon: prefixIcon != null
              ? Icon(prefixIcon, color: AppColors.black)
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
